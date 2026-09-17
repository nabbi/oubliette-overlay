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
  config. The image's entrypoint isn't a shell, mount the repo at
  `/github/workspace` (matching where the real action puts it — some
  pkgcheck code paths care about this), and `pmaint regen` needs
  `--dir ~/.cache/pkgcheck/repos` or it'll try to write into the mounted
  repo itself:
  ```sh
  docker run --rm --entrypoint /usr/bin/bash \
    --workdir /github/workspace -v "$PWD":/github/workspace \
    ghcr.io/pkgcore/pkgcheck:latest -c "
      pmaint sync gentoo &&
      pmaint regen --dir ~/.cache/pkgcheck/repos . &&
      pkgcheck --color n ci --exit GentooCI \
        --checks=-RedundantVersionCheck --keywords=-PotentialStable"
  ```
  This is much faster to iterate on than pushing empty commits, and it's
  how the pkgcore-internals dig in §5's case study was actually done —
  each guess took one local run instead of a round-trip through CI.
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
4. **Check both workflows separately — `package.unmask` at the repo root
   fixes `repoman` but does *not* fix `pkgcheck`.** This isn't a typo or a
   sync-timing fluke; it's a real, verified gap in pkgcore (traced into its
   source, not guessed): `pkgcheck`'s `ProfileAddon` builds the masked-atom
   set for its `NonsolvableDeps*` checks as
   `target_repo.pkg_masks | repo.pkg_masks | masks` — explicitly folding in
   *every* repo's repo-root `package.mask` across the masters chain — but
   the corresponding unmask set is just bare `profile_obj.unmasks`, the
   walked profile-*directory* chain only (`ProfileStack.stack`, built from
   each profile dir's `parent` file). `pkgcore.ebuild.repo_objs.RepoConfig`
   has a `pkg_masks` property for the repo-root `package.mask`; it has
   **no `pkg_unmasks` counterpart at all** — so a repo-root
   `profiles/package.unmask` (the standard override mechanism, and what
   this file already used for the smokeping accounts) is structurally
   invisible to this specific check, even though real dependency
   resolution (`repoman`, `emerge`) honors it correctly. Confirmed by
   direct introspection in the pkgcheck container:
   ```python
   from pkgcore.ebuild.repo_objs import RepoConfig
   oubliette = RepoConfig('/github/workspace')
   oubliette.base_profile.unmasks  # correctly contains the atom
   oubliette.pkg_masks             # separate property; no pkg_unmasks exists
   ```
   The only way to make a profile-directory-level unmask visible to
   pkgcheck would be duplicating `::gentoo`'s profile directory tree
   locally just to drop a `package.unmask` inside each one — a maintenance
   trap, not a fix; this overlay doesn't carry its own profile tree at all
   (`profiles/default/` doesn't exist here) and shouldn't start for this.
   Given `::gentoo` masks are usually a prelude to actual removal, and the
   mask *entry itself* normally gets deleted along with the ebuilds once
   removal completes (there's no reason to keep masking something that no
   longer exists), this class of pkgcheck false-positive is generally
   **self-resolving on the mask's own removal date** — treat "wait it out"
   as a legitimate option alongside "unmask + accept pkgcheck stays red
   until then", not a failure to find the real fix.

**Case study (2026-09-17), and how it actually got resolved:**
`www-misc/zoneminder` (1.36.x–1.38.x) depended on `dev-libs/libjwt[gnutls]`.
`dev-libs/libjwt` was *also* forked into this overlay (with its own
`*_multi_ssl_atools.patch` per version) purely to keep that one revdep
alive, since `zoneminder` itself was treecleaned from `::gentoo` and now
only lives here. On 2026-09-16, `::gentoo` masked `dev-libs/libjwt`
outright (removal 2026-10-16, bugs #929073 and #939530), reasoning
"No revdeps [...] unable to properly SLOT" — true for `::gentoo`, false
for this overlay, and invisible to the mask author either way. First
response was `package.unmask` (§3) as a stopgap: fixed `repoman`
immediately, left `pkgcheck` red for the reason in step 4 above.

That stopgap turned out to be unnecessary. Checking what the dependency
was actually *for* (don't stop at "it's declared, so it must be needed")
found the real fix:

- `zoneminder` upstream added a `ZM_JWT_BACKEND` cmake option
  (`libjwt`|`jwt_cpp`) starting in **1.37.74**, defaulting to `jwt_cpp` — a
  vendored, header-only library (`dep/jwt-cpp/`) needing only OpenSSL, no
  external package. This overlay's 1.37.74+ ebuilds never wired
  `ZM_JWT_BACKEND`/`ZM_CRYPTO_BACKEND` into `mycmakeargs` at all, so the
  `+gnutls` USE flag's `libjwt` dependency was **already dead code** —
  CMake silently built with the `jwt_cpp` default regardless of the flag.
  Removing it was a pure cleanup, zero behavior change.
- For **1.36.x**, upstream never backported that cmake option (checked the
  live `release-1.36` branch tip directly, not just the last tag) — so a
  version bump couldn't do the same trick there. But reading the actual
  C++ (`src/zm_crypt.cpp`) showed 1.36.38 already had the *identical*
  `#if HAVE_LIBJWT ... #else ... #endif` dual implementation of
  `verifyToken()` as 1.37+, and `dep/jwt-cpp` is linked **unconditionally**
  in `src/CMakeLists.txt` regardless of whether libjwt is found. In other
  words: 1.36.x's build system *already* falls back to the vendored
  jwt-cpp cleanly when libjwt is absent — nothing to backport. The `+gnutls`
  branch could be deleted exactly like 1.37+'s, no functional loss.
- With every consuming ebuild fixed, `dev-libs/libjwt` had zero consumers
  left in this overlay. Deleted the whole forked package (and the now
  pointless `package.unmask` entry) rather than leaving it as an orphaned
  fork nobody needed.

**Lesson:** don't stop at "unmask it, wait for upstream's removal date to
make the tool noise go away." That's the right call when the dependency is
*genuinely* needed. Here it wasn't — the `+gnutls` DEPEND branch was stale
relative to what the consuming ebuild's own build system actually required,
on both the version where that was obviously true (1.37+, dead cmake wiring)
and the version where it looked load-bearing at first glance (1.36.x, until
the C++ source was actually read). Verified locally (docker repro from §4)
before pushing: `pkgcheck ci --exit GentooCI` across the whole repo went
from failing to a clean `exit=0`.

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

## 7. Editing a previously-published ebuild: bump the revision

**Mistake made and caught in this session:** editing `DEPEND` (or any
behavior-affecting content) in an ebuild that's already been committed —
e.g. `zoneminder-1.37.74.ebuild` — without renaming it to `-r1` (or the
next `-rN`). Portage identifies an installed package by version+revision
string only; it never diffs ebuild *content*. A user who already has
`1.37.74` installed and just re-syncs the tree gets the edited DEPEND
silently — no prompt to rebuild, no signal anything changed. Renaming the
file to `-r1` is what makes the change visible to Portage (and to
`world`/`@world` updates) at all. This applies to any published version,
not just ones already pushed to GitHub — if it's a distinct
version+revision string someone could have already emerged, treat it as
published.

Rule: **new content needs a new filename.** If the exact version+revision
already exists in a state someone could have installed, don't edit it in
place — copy to the next revision and edit that. Only a version+revision
that's never been "released" from this overlay's perspective (a bump you
are introducing in the same commit, like `zoneminder-1.38.4.ebuild` in the
case study above) can be added fresh without an `-rN` suffix.

**Live (`-9999`) ebuilds are the exception, but don't assume the suffix is
meaningful — check.** `-9999` ebuilds are inherently unpinned (`emerge`
always pulls current VCS HEAD), so editing one in place is normal practice
and doesn't need a revision bump the way a numbered release does. But an
existing `-9999-rN` filename isn't automatically evidence that a genuine
per-change bump history exists — it can be leftover from an old bulk
import that suffixed everything touched in that batch, independent of
whether each individual file had a real prior `-r(N-1)` to revise. Check
before trusting the suffix:
```sh
git log --oneline --follow -- path/to/pkg-9999-r1.ebuild   # full history
git log --oneline --diff-filter=A -- path/to/pkg-9999.ebuild   # did a
                                                                # non-'-rN'
                                                                # version
                                                                # ever exist?
```
In this repo, `zoneminder-9999-r1.ebuild` was added with `-r1` already in
the filename in a single "refreshed with nginx support" bulk-import commit
(2023-07-02), alongside `zoneminder-1.36.33-r1.ebuild` and
`zoneminder-1.36.9999-r1.ebuild` getting the same blanket `-r1` in the same
commit — not a deliberate second revision of a previously-published
`zoneminder-9999.ebuild` (no such file existed at that point; it had been
pruned earlier). Confirmed legacy naming, not a meaningful revision
marker, and renamed back to `zoneminder-9999.ebuild`.
