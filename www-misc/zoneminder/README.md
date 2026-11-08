# www-misc/zoneminder

ZoneMinder for Gentoo: the 1.38 release, the live release branches, dated
snapshots of master, and 1.36. API v2 at `/zm/api` is served by one of
`apiv2-cake` (upstream's CakePHP 2 API, the default) or `apiv2-php`
([zm-php-api](https://github.com/nabbi/zm-php-api), a CakePHP-free replacement
answering the same requests); `apiv3` adds `www-misc/zm-api`, the Rust API v3
meant to replace API v2, as a service next to it.

| Package | Versions | Notes |
| --- | --- | --- |
| `www-misc/zoneminder` | 1.38.5-r2, 1.38.9999; master [snapshots](#snapshots), 9999; 1.36.38-r1, 1.36.9999 | `apiv2-cake` (default) or `apiv2-php`; optional `apiv3` |
| `www-misc/zm-api` | master [snapshots](#snapshots) (`~amd64`), 9999 | ZoneMinder API v3 (Rust); pulled in by `zoneminder[apiv3]` |

## Installing

As root, with the overlay enabled (`eselect repository enable oubliette`).

### 1. Pick the ebuild and the APIs

```shell
mkdir -p /etc/portage/package.accept_keywords /etc/portage/package.use /etc/portage/package.mask

# 1.38 release; for live ebuilds, master snapshots or 1.36, use the block
# from "Choosing a ZoneMinder series" below instead
echo 'www-misc/zoneminder::oubliette ~amd64' > /etc/portage/package.accept_keywords/zoneminder
rm -f /etc/portage/package.mask/zoneminder
# with apiv3 (not on 1.36): www-misc/zm-api comes in (its snapshots are ~amd64;
# on a stable host add the line below; for 9999 see "API v3" below)
#echo 'www-misc/zm-api::oubliette ~amd64'     >> /etc/portage/package.accept_keywords/zoneminder

# API v2: apiv2-cake is the default; for zm-php-api instead:
#echo 'www-misc/zoneminder apiv2-php -apiv2-cake' >> /etc/portage/package.use/zoneminder
# API v3 next to v2:
#echo 'www-misc/zoneminder apiv3' >> /etc/portage/package.use/zoneminder
```

On a stable (`amd64`) host, zoneminder also needs these dependencies keyworded,
and PHP built with the features it uses. Skip the keywords on `~amd64` hosts.

```shell
cat > /etc/portage/package.accept_keywords/zoneminder-deps <<'END'
dev-perl/Class-Std
dev-perl/Class-Std-Fast
dev-perl/HTTP-Lite
dev-perl/IO-Socket-Multicast
dev-perl/SOAP-WSDL
dev-perl/Sys-Mmap
dev-perl/URI-Encode
dev-perl/X10
END
cat > /etc/portage/package.use/zoneminder-php <<'END'
# apache2 = mod_php for zoneminder USE=apache2 (the default); with USE=nginx
# replace apache2 with fpm on both lines
dev-lang/php apache2 curl gd inifile intl mysql mysqli pdo sockets sysvipc
app-eselect/eselect-php apache2
END
```

The flags are on `zoneminder` (1.38 and later; 1.36 has none of them).
`apiv2-cake` and `apiv2-php` are exclusive, and exactly one must be set.
`apiv3` adds API v3 and does not replace either of them. `www-misc/zm-api` is
the Rust API v3, meant to replace API v2 in the long run; upstream does not tag
it yet, so it comes as master snapshots and a live 9999.

With `apiv2-php`, the source is [nabbi/zm-php-api](https://github.com/nabbi/zm-php-api)
on GitHub: the release and snapshot ebuilds download the tarball of a pinned
release (`ZM_PHP_API_PV`), 9999 clones its `main` branch. `USE=test` runs its
unit tests against the ZoneMinder tree being built.

### 2. Install

```shell
emerge -av www-misc/zoneminder
```

Then follow `/usr/share/doc/zoneminder-*/README.gentoo*`. With `apiv3`, also
follow `emerge`'s notes for `www-misc/zm-api`:

1. Run `emerge --config www-misc/zm-api` to create the JWT keys.
2. Back up the database, then run `zm-api-db bridge` on it.
3. Run `rc-update add zm-api default`.
4. Copy the web server example into place. With `apiv3`, its proxy block to
   zm-api is already enabled: it maps `/zm/api/v3`, `/zm/api-docs` and
   `/zm/swagger-ui` to zm-api, and `APP_SERVER__PUBLIC_PREFIX=/zm` in
   `/etc/zm-api/zm-api.env` puts `/zm` in the links zm-api writes, so nothing
   is served at the site root. API documentation is at `/zm/api-docs/`: a page
   listing what the install serves, the v2 reference (`/zm/api-docs/v2/`,
   zm-php-api's Redoc page and OpenAPI document, installed with `apiv2-php`)
   and v3 (`/zm/api-docs/v3/` opens Swagger UI; `/zm/api-docs/v3/openapi.json`).
   The `/zm/api-docs/` block of the nginx example is on by default; Apache
   serves it from the `/zm` alias. A config copied from an earlier install
   needs the block added by hand: it is between the `# BEGIN api/v3` and
   `# END api/v3` lines of the example. Apache also needs mod_proxy,
   mod_proxy_http and mod_proxy_wstunnel (`-D PROXY` in `APACHE2_OPTS`), and
   mod_headers.

From then on, `emaint sync -a` and `emerge -avuDN @world` keep the host current.

## Choosing a ZoneMinder series

Each host follows one series. Pick it with the block for that series below and run it as root. Every block rewrites `/etc/portage/package.accept_keywords/zoneminder` and `/etc/portage/package.mask/zoneminder`, so switching series means running a different block.

| Series | Ebuild | Keywords | Flags |
| --- | --- | --- | --- |
| [1.38 release](#138-release-default) (default) | 1.38.5-r2 | `~amd64` | `apiv2-cake` or `apiv2-php`, `apiv3` |
| [1.38, live](#138-live-1389999) | 1.38.9999: release-1.38 head at build time | none | same |
| [1.39 snapshots](#139-snapshots-master) | `1.39.41_pre<date>`: pinned master commits | none | same |
| [master, live](#master-live-9999) | 9999: master head at build time | none | same |
| [1.36 release](#136-release) | 1.36.38-r1 | `~amd64` | none: API v2 is CakePHP, no API v3 |
| [1.36, live](#136-live-1369999) | 1.36.9999: release-1.36 head at build time | none | none |

The release branches get tagged releases and a live ebuild. Master, which upstream does not tag, gets dated snapshots that each pin one commit; see [Snapshots](#snapshots). Live ebuilds and snapshots carry no keywords, so a host takes them only through a `**` line for its series, and a sync never moves a host to another series.

### Before switching

Each move to a higher version runs ZoneMinder's database migrations (`zmupdate.pl`), and they only go forward. Back up the database before moving up. To go back down, for example from 1.39 to 1.38, restore that backup.

### 1.38 release (default)

The newest keyworded release. On a `~amd64` host the same line also takes 1.36, but 1.38 is newer.

```shell
echo 'www-misc/zoneminder::oubliette ~amd64' > /etc/portage/package.accept_keywords/zoneminder
rm -f /etc/portage/package.mask/zoneminder
```

### 1.38, live (1.38.9999)

Builds release-1.38's head at each rebuild.

```shell
echo '=www-misc/zoneminder-1.38.9999::oubliette **' > /etc/portage/package.accept_keywords/zoneminder
rm -f /etc/portage/package.mask/zoneminder
```

### 1.39 snapshots (master)

The newest master snapshot, and each newer one as it is added.

```shell
echo '=www-misc/zoneminder-1.39*::oubliette **' > /etc/portage/package.accept_keywords/zoneminder
rm -f /etc/portage/package.mask/zoneminder
```

### master, live (9999)

Builds master's head at each rebuild. Use it for development, not on hosts that should stay where they are.

```shell
echo '=www-misc/zoneminder-9999::oubliette **' > /etc/portage/package.accept_keywords/zoneminder
rm -f /etc/portage/package.mask/zoneminder
```

### 1.36 release

The mask keeps a `~amd64` host off 1.38. The `apiv2-*` and `apiv3` flags do not exist on 1.36.

```shell
echo '=www-misc/zoneminder-1.36*::oubliette ~amd64' > /etc/portage/package.accept_keywords/zoneminder
echo '>=www-misc/zoneminder-1.37' > /etc/portage/package.mask/zoneminder
```

### 1.36, live (1.36.9999)

Builds release-1.36's head at each rebuild.

```shell
echo '=www-misc/zoneminder-1.36.9999::oubliette **' > /etc/portage/package.accept_keywords/zoneminder
echo '>=www-misc/zoneminder-1.37' > /etc/portage/package.mask/zoneminder
```

### 1.36 on a stable host

On an `amd64` (stable) host, both 1.36 ebuilds also need these, on top of the dependency block in [Installing](#installing):

```shell
printf '%s\n' dev-perl/Data-Entropy dev-perl/Data-Float > /etc/portage/package.accept_keywords/zoneminder-1.36
```

### Holding a host at one snapshot

Name the snapshot instead of the series:

```shell
echo '=www-misc/zoneminder-1.39.41_pre20261023::oubliette **' > /etc/portage/package.accept_keywords/zoneminder
```

Or keep the series line and mask what comes after it: `>www-misc/zoneminder-1.39.41_pre20261023` in `/etc/portage/package.mask/zoneminder`.

### API v3

With `apiv3` (1.38 and later), `www-misc/zoneminder` pulls in `www-misc/zm-api`, the Rust API v3 meant to replace API v2 in the long run. Upstream does not tag it yet, so it comes as master snapshots (`3.0.0_alpha1_pre<date>`, each pinning a commit and its crates) and a live 9999. The snapshots are keyworded `~amd64` so that `zoneminder[apiv3]` resolves; a stable host accepts them with:

```shell
echo 'www-misc/zm-api::oubliette ~amd64' >> /etc/portage/package.accept_keywords/zoneminder
```

Or zm-api master's head at each rebuild, which also fetches its crates at build time:

```shell
echo '=www-misc/zm-api-9999::oubliette **' >> /etc/portage/package.accept_keywords/zoneminder
```

To hold zm-api at one snapshot, name it the same way as for ZoneMinder: `=www-misc/zm-api-3.0.0_alpha1_pre20261023::oubliette ~amd64`, and mask what comes after it.

## Maintaining

### Snapshots

Neither upstream tags master. ZoneMinder's `version.txt` says 1.39.45 while the
last 1.39 tag is 1.39.11, and zm-api has no tags at all. A snapshot ebuild pins
one master commit. It is named after the upstream version at that commit and
its commit date in UTC: `zoneminder-1.39.45_pre20261107` is ZoneMinder master
at `855683051`, `zm-api-3.0.0_alpha1_pre20261023` is zm-api master at
`a0b0c53` (Cargo.toml's `3.0.0-alpha.1`). `_pre` sorts a snapshot below a
later tag of that version, so hosts move to the tag if one is made.
ZoneMinder's release branches get tagged releases and `<series>.9999` live
ebuilds instead.

```shell
scripts/snapshot.sh zoneminder               # master head
scripts/snapshot.sh zoneminder 2026-10-18    # last master commit on or before that day (UTC)
scripts/snapshot.sh zm-api 873486b           # that commit
```

The script copies the package's 9999 ebuild, sets the commit (`MY_ZM_COMMIT`,
`ZM_API_COMMIT`) and refreshes the Manifest. For zoneminder it also sets the
submodule pins (`MY_RTSP_V` and friends) from that commit's tree. For zm-api it
fills `CRATES` and the crate `LICENSE+=` line from that commit's `Cargo.lock`
with pycargoebuild, which downloads the crates into `DISTDIR` (`emerge
app-portage/pycargoebuild`, or without root: `python3 -m venv
--system-site-packages ~/.cache/oubliette/pycargoebuild-venv &&
~/.cache/oubliette/pycargoebuild-venv/bin/pip install pycargoebuild`). It then
prints the commit command. It picks commits along first parents, the same as
git-r3's `EGIT_COMMIT_DATE`, so the same date always gives the same commit.
ZoneMinder snapshots get no keywords: a host takes them only through a `**` line (above); zm-api snapshots are `~amd64` (see "API v3").
Upstream is read from a bare clone in `~/.cache/oubliette/<package>.git`.

Keep the last two or three snapshots of each package for rollback, and remove
older ones with `git rm` (then rerun `ebuild … manifest`). Changes to the 9999
ebuild reach new snapshots only; an existing snapshot that needs the change
gets it by hand and a revision bump.

### Security patches (master)

`files/master-security` holds security fixes that upstream master has not
merged yet, one patch each, in the order they merge. The master ebuilds (9999
and the 1.39 snapshots) apply them all in `src_prepare`; 1.36 and 1.38 do not.
The set is empty when everything is merged (it is, as of 2026-11-08), and
`src_prepare` skips it then. To rebuild it after adding or dropping a fix, or
after a new master snapshot, run `scripts/security-patches.sh` (`OURS_LIST`
names the list of pending fixes, one git ref per line). A snapshot that gets
new patches needs a revision bump. When master moves under 9999 so that a
patch no longer applies, 9999 stops at `src_prepare` until a new snapshot is
made and the patches are rebuilt on it.

### Moving the zm-php-api pin

1. Set `ZM_PHP_API_PV` to the new release (its tag is `v${ZM_PHP_API_PV}`), in
   `zoneminder-9999.ebuild`, the release ebuild and the snapshots.
2. Run `ebuild www-misc/zoneminder/zoneminder-1.38.5-r2.ebuild manifest`.
3. Revision-bump the release ebuild and the snapshots.
4. Copy `zoneminder-9999.ebuild` over `zoneminder-1.38.9999.ebuild` (it is the
   same file; the branch comes from the version).

### Checks

This README is in the Manifest. After editing it, run `ebuild
www-misc/zoneminder/zoneminder-9999.ebuild manifest`, or every build of the
package fails its digest check.

```shell
pkgcheck scan --checks=-RedundantVersionCheck --keywords=-PotentialStable
```

`scripts/sandbox-test.sh` checks what a fresh host gets, without root and
without touching the host's portage setup: a private `PORTAGE_CONFIGROOT` under
`~/.cache/oubliette-sandbox`, portage's own git sync of this repository
(`OUBLIETTE_SYNC_URI=file://$PWD` tests a local commit before it is pushed), the
dependency blocks above, each series block, then fetch, unpack and prepare of
the 1.38 and master ebuilds with each API v2 choice, and of 1.36.9999, and of
`www-misc/zm-api`. Nothing is compiled or installed.
