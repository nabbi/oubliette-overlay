---
name: ci-triage
description: Diagnose failing repoman/pkgcheck GitHub Actions in this overlay, trace the root cause against what Gentoo upstream actually did (mask/removal bugs, news items, their own commits), apply a fix that matches upstream's resolution, and sanity-check it before pushing. Use when a workflow run is red, or before/after touching an ebuild that depends on packages outside this overlay.
---

# CI triage for oubliette-overlay

This overlay carries some packages that no longer exist in the main Gentoo
tree (e.g. `net-analyzer/smokeping`, treecleaned upstream). Nothing here
tracks upstream removals/masks automatically, so an ebuild can go red in CI
purely because something it *depends on* — never something in this repo —
was masked or removed from `::gentoo`. Don't assume the failure is caused by
the last local commit; check upstream state first.

## 1. Pull the actual failure, not just the red X

```sh
gh run list --limit 20
gh run view <run-id> --log-failed
```

Both workflows run every matrix leg / both jobs even if one already failed —
read the full `--log-failed` output for each failing job, not just the first
hit.

## 2. Separate fatal from cosmetic

`pkgcheck` runs with `--exit GentooCI`, which only fails the job on a subset
of check classes. `repoman full` similarly separates `[fatal]`-tagged
categories from advisory ones. Do not chase every line in the output —
identify what's actually load-bearing:

- **Fatal / build-breaking** (fix these): `dependency.bad [fatal]`
  (repoman), `NonsolvableDepsInStable`, `NonsolvableDepsInDev` (pkgcheck) —
  these mean a DEPEND/RDEPEND can't be resolved against the current main
  tree for some profile.
- **Cosmetic / advisory** (leave alone unless asked): `PythonCompatUpdate`,
  `BadDescription`, `DeprecatedDep`, `RequiredUseDefaults`,
  `ExcessiveLineLength`, `TarballAvailable`, `BadFilename`,
  `NonexistentBlocker`, `upstream.workaround`, `dependency.deprecated`.

Grep the raw log for `[error]`, `[fatal]`, and the pkgcheck job's
`outcome=failure` line to confirm which category actually tripped the exit
code before editing anything.

## 3. Trace the root cause against upstream, don't guess a fix

When the fatal error names a dependency (e.g. `net-dns/bind-tools`), check
what Gentoo actually did to it before picking a replacement:

- `https://packages.gentoo.org/packages/<cat>/<pkg>` — current KEYWORDS,
  whether it's masked, and the mask comment (often names the bug + the
  suggested replacement directly).
- `https://bugs.gentoo.org/buglist.cgi?quicksearch=<pkg>` (or the bug number
  cited in the mask comment) — the removal/mask rationale. This is usually
  the fastest way to find the *recommended* replacement, rather than
  inventing one.
- `https://www.gentoo.org/support/news-items/` — official GLEP 42 news items
  for larger migrations (Python slot deprecations, USE_EXPAND changes,
  profile deprecations, OpenRC/systemd-relevant shifts). If a fatal error
  correlates with a profile or Python target, check here before touching an
  ebuild's dependency list.
- `https://gitweb.gentoo.org/repo/gentoo.git/log/<cat>/<pkg>` — if upstream
  still carries a same-named or sibling package, their own commit that
  handled the same transition is the pattern to mirror, not something to
  redesign. A `404` on `packages.gentoo.org` or on the ebuild's
  `plain/<path>` URL means it's gone from `::gentoo` entirely (treecleaned),
  which itself is diagnostic — it confirms the package this overlay carries
  is now maintained *only* here.

`curl` these directly with `--max-time 15`; `gitweb.gentoo.org` can hang
without a timeout. Prefer `WebFetch`/`curl` over guessing a URL shape.

Match the fix to what upstream actually recommends (e.g. swap to the named
successor package) rather than dropping the USE flag/feature outright —
removal is a last resort, not the default move.

## 4. Local sanity checks before pushing

This environment does **not** have the Gentoo master repo synced
(`/var/db/repos/gentoo` is `not-mounted`; `repos.conf` points `sync-type =
rsync` with `auto-sync = no`), so full offline `repoman`/`egencache
--update` runs will fail with `Unavailable repository 'gentoo' referenced by
masters entry`. Known constraints to work around, not to try to bypass:

- **Regenerate the ebuild's Manifest digest whenever the ebuild's content
  changes** (DEPEND/RDEPEND, IUSE, anything — not just SRC_URI). This
  repo's `Manifest` files are **not thin** — they include an `EBUILD <file>
  <size> BLAKE2B <hash> SHA512 <hash>` line for the ebuild itself, not just
  `DIST` lines for the tarball. Editing the ebuild without updating that
  line leaves a stale digest that `repoman`/`pkgcheck` will flag. `egencache
  --update`/`ebuild <file> manifest` need the synced master repo this
  environment doesn't have, so compute and patch it by hand:
  ```sh
  python3 -c "
  import hashlib
  data = open('path/to/foo-1.2.3.ebuild', 'rb').read()
  print(len(data))
  print(hashlib.blake2b(data, digest_size=64).hexdigest())
  print(hashlib.sha512(data).hexdigest())
  "
  ```
  Then replace the `EBUILD` line's size/BLAKE2B/SHA512 in the package's
  `Manifest` to match. Sanity-check the method once per session by
  recomputing an *unchanged* file in the same directory (e.g.
  `metadata.xml`) and confirming it matches the existing Manifest line
  exactly, before trusting the hash you computed for the changed file.
- `metadata/md5-cache/*` is **gitignored** (`.gitignore`) — never hand-edit
  or commit it to "fix" a stale cache. It's regenerated by CI's own
  `pmaint regen` step and isn't part of what ships to GitHub.
- If you need to actually execute pkgcheck locally against the fix, mirror
  the workflow's own container rather than the unsynced local portage
  config:
  ```sh
  docker run --rm -v "$PWD":/repo -w /repo ghcr.io/pkgcore/pkgcheck:latest \
    -c "pmaint sync gentoo && pmaint regen . && pkgcheck --color y ci --checks=-RedundantVersionCheck --keywords=-PotentialStable"
  ```
- At minimum, always do the cheap checks that don't need the master repo:
  `git diff` the ebuild change, and re-read the fatal log line to confirm
  the exact atom you changed is the one that was unresolvable (not a
  look-alike nearby).

## 5. A different failure mode: inherited masks, not broken deps

Not every red run is a bad dependency atom. `metadata/layout.conf` sets
`masters=gentoo`, which means **`::gentoo`'s `profiles/package.mask` applies
to this overlay too** — for any category/package name, regardless of which
repo actually ships the matching ebuild. If `::gentoo` masks a package this
overlay also carries under the same name (because we forked it, or because
we're one of its upstream maintainers and it's mid-removal there), every
local ebuild depending on it goes `NonsolvableDeps*`/`dependency.bad` even
though the overlay's own copy is perfectly fine and even though `--exit
GentooCI`'s check names look identical to a genuinely-missing-dependency
failure. Distinguish the two:

1. Fetch `::gentoo`'s current mask file and grep for the package:
   ```sh
   curl -s --max-time 15 "https://gitweb.gentoo.org/repo/gentoo.git/plain/profiles/package.mask" | grep -B6 '^<cat>/<pkg>$'
   ```
   A hit, with a dated comment and bug numbers, means this is a mask
   inheritance problem, not a broken atom.
2. If this overlay has a genuine reason to keep using it (a real revdep the
   mask author didn't know about, because the revdep itself only lives in
   this overlay), the fix is `profiles/package.unmask`, not touching the
   dependent ebuild at all. Comment the entry the way `::gentoo`'s own
   `package.mask` comments theirs: who, when, why, bug numbers, and — since
   this is the overlay overriding upstream's judgment — what would make it
   safe to drop the unmask later (e.g. "drop together if zoneminder moves
   off libjwt").
3. Sanity-check the override the same way as any other fix: force a real
   run (see §6) and confirm the specific `NonsolvableDeps`/`dependency.bad`
   lines for that package are gone from the new log, not just that the mask
   file now has an entry.

**Case study (2026-09-17):** `www-misc/zoneminder` (1.36.x–1.38.x) depends
on `dev-libs/libjwt[gnutls]`. `dev-libs/libjwt` is *also* forked into this
overlay (`dev-libs/libjwt/`, with its own `*_multi_ssl_atools.patch` per
version) because `zoneminder` itself was treecleaned from `::gentoo` and
now only lives here — so this overlay depends on a package it has to keep
patching just to keep one revdep alive. On 2026-09-16, `::gentoo` masked
`dev-libs/libjwt` outright (removal 2026-10-16, bugs #929073 and #939530:
`slibtool`/musl link failures — `cannot find -ljwt`), with the mask comment
reasoning "No revdeps [...] unable to properly SLOT." The mask author is
right about `::gentoo` (no revdeps *there*) and wrong about this overlay
(one real revdep here, invisible to them). That's structural, not a
one-off: **any package this overlay forks *specifically because* a revdep
of it was treecleaned is now permanently exposed to `::gentoo` masking it
out from under us with zero warning**, since nothing here subscribes to
upstream's package.mask changes. The multi-ssl patch itself — building
`libjwt.so`, `libjwt-ossl.so`, and `libjwt-gnutls.so` as three separate
libraries so both SSL backends can coexist — is very likely *why* it's
being called unmaintainable upstream ("Three different APIs"); the fix
here is `package.unmask`, but it's a stopgap on a package upstream has
decided isn't worth maintaining, not a real resolution. Revisit if
`zoneminder` upstream drops its libjwt dependency (check their build docs)
or a lighter JWT library becomes viable, rather than treating the unmask
as permanent.

## 6. After pushing

- `schedule:` triggers in both workflows (`cron: "0 18 * * 1"`, weekly) are
  **auto-disabled by GitHub after 60 days with no push to the default
  branch**. Check with `gh workflow list --all` — a disabled workflow shows
  `disabled_inactivity`. **A push alone does NOT re-enable it** (this was
  wrong in an earlier version of this doc — verified by pushing a real fix
  commit and watching `gh run list` stay empty for it). Re-enable
  explicitly:
  ```sh
  gh workflow enable pkgcheck
  gh workflow enable repoman
  ```
- Neither workflow has a `workflow_dispatch` trigger, so there's no
  `gh workflow run` to force a one-off validation run either. If you need
  to confirm a fix actually goes green *now* rather than waiting for next
  Monday's schedule, push an empty commit (`git commit --allow-empty`) to
  fire the `push:` trigger — cheap, visible in history, and honest about
  why it's there (say so in the commit message).
- Confirm outcome with `gh run list --limit 5` and read the new run's log
  the same way as step 1 — don't assume green just because the specific
  issue you fixed is gone; a fresh run against the current `::gentoo`
  snapshot can surface unrelated breakage that was simply never observed
  while the schedule was dormant (see the libjwt case study above, found
  exactly this way).
