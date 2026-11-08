# www-misc/zoneminder

ZoneMinder for Gentoo: the 1.38 release, live release branches, dated master
snapshots, and 1.36.

## USE flags (1.38 and later)

| Flag | What it does |
| --- | --- |
| `apiv2-cake` (default) | API v2 at `/zm/api` from upstream's CakePHP 2 API |
| `apiv2-php` | API v2 from [zm-php-api](https://github.com/nabbi/zm-php-api), a CakePHP-free drop-in |
| `apiv3` | Adds [`www-misc/zm-api`](../zm-api/README.md), the Rust API v3, next to API v2 |
| `apache2` (default) / `nginx` | Web server |
| `mariadb` | MariaDB Connector/C and DBD::MariaDB (master only) |

Set exactly one of `apiv2-cake` and `apiv2-php`. 1.36 has none of these flags.

## Install

As root:

```shell
eselect repository enable oubliette && emaint sync -r oubliette
mkdir -p /etc/portage/package.{accept_keywords,use,mask}
echo 'www-misc/zoneminder::oubliette ~amd64' > /etc/portage/package.accept_keywords/zoneminder

# optional
#echo 'www-misc/zoneminder apiv2-php -apiv2-cake' >> /etc/portage/package.use/zoneminder
#echo 'www-misc/zoneminder apiv3'                 >> /etc/portage/package.use/zoneminder

emerge -av www-misc/zoneminder
```

Then follow `/usr/share/doc/zoneminder-*/README.gentoo*`. For `apiv3`, see
[www-misc/zm-api](../zm-api/README.md).

### Stable (`amd64`) hosts

Keyword the Perl dependencies and build PHP with what ZoneMinder needs:

```shell
printf '%s\n' dev-perl/Class-Std dev-perl/Class-Std-Fast dev-perl/HTTP-Lite \
  dev-perl/IO-Socket-Multicast dev-perl/SOAP-WSDL dev-perl/Sys-Mmap \
  dev-perl/URI-Encode dev-perl/X10 > /etc/portage/package.accept_keywords/zoneminder-deps
# with USE=nginx, use fpm instead of apache2 on both lines
cat > /etc/portage/package.use/zoneminder-php <<'END'
dev-lang/php apache2 curl gd inifile intl mysql mysqli pdo sockets sysvipc
app-eselect/eselect-php apache2
END
```

For 1.36, also keyword `dev-perl/Data-Entropy` and `dev-perl/Data-Float`.

## Choosing a series

Write the line for your series to `/etc/portage/package.accept_keywords/zoneminder`.
The 1.36 series also need `>=www-misc/zoneminder-1.37` in
`/etc/portage/package.mask/zoneminder`. Remove that file for any other series.

| Series | Line |
| --- | --- |
| 1.38 release (default) | `www-misc/zoneminder::oubliette ~amd64` |
| 1.38 live | `=www-misc/zoneminder-1.38.9999::oubliette **` |
| master snapshots | `=www-misc/zoneminder-1.39*::oubliette **` |
| master live | `=www-misc/zoneminder-9999::oubliette **` |
| 1.36 release | `=www-misc/zoneminder-1.36*::oubliette ~amd64` |
| 1.36 live | `=www-misc/zoneminder-1.36.9999::oubliette **` |

Live ebuilds build the branch head on every rebuild. A snapshot pins one master
commit (`1.39.45_pre20261107`). To hold a host at a snapshot, name it in full:
`=www-misc/zoneminder-1.39.45_pre20261107::oubliette **`.

Database migrations only go forward. Back up the database before moving to a
newer series; going back means restoring that backup.

## Maintaining

- **Snapshots:** `scripts/snapshot.sh zoneminder [date|commit]` copies the 9999
  ebuild, pins the commit and submodules, and refreshes the Manifest. Keep the
  last two or three.
- **Security patches:** `files/master-security` holds unmerged security fixes,
  applied by the master ebuilds only. Rebuild the set with
  `scripts/security-patches.sh`. It is empty as of 2026-11-08.
- **zm-php-api pin:** bump `ZM_PHP_API_PV` in 9999, the release ebuild and the
  snapshots. Then regenerate the Manifest, revision-bump, and copy 9999 over
  1.38.9999 (they are the same file).
- **Checks:** `pkgcheck scan --checks=-RedundantVersionCheck --keywords=-PotentialStable`.
  `scripts/sandbox-test.sh` runs fetch, unpack and prepare on a private
  config root without root. It compiles nothing.

This README is in the Manifest. After editing it, run
`ebuild zoneminder-9999.ebuild manifest`.
