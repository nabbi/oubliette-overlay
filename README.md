# Oubliette Gentoo Overlay

[![gentoo qa-reports](https://img.shields.io/badge/gentoo-QA%20check-6E56AF.svg)](https://qa-reports.gentoo.org/output/repos/oubliette.html)
[![pkgcheck](https://github.com/nabbi/oubliette-overlay/actions/workflows/pkgcheck.yml/badge.svg)](https://github.com/nabbi/oubliette-overlay/actions/workflows/pkgcheck.yml)

**Oubliette** is a personal, unofficial Portage overlay containing forgotten or patched ebuilds that are maintained here for convenience.

Packages with their own notes:

* [www-misc/zoneminder](www-misc/zoneminder/README.md) — ZoneMinder: releases, live branches and master snapshots; API v2 as CakePHP (`apiv2-cake`) or [zm-php-api](https://github.com/nabbi/zm-php-api) (`apiv2-php`), optional API v3 (`apiv3`, `www-misc/zm-api`).
* [www-misc/zm-api](www-misc/zm-api/README.md) — ZoneMinder API v3 (Rust): master snapshots and 9999; pulled in by `zoneminder[apiv3]`.
* [www-apps/netbox](www-apps/netbox/README.md) — NetBox 4.7.5 and 9999 in upstream's source layout, Apache or nginx vhost, the official plugins as separate `dev-python/netbox*` packages, and the dependencies ::gentoo lacks.

Related repositories:

* [oubliette-patches](https://github.com/nabbi/oubliette-patches) — supplemental patches used by some ebuilds.
* [oubliette-overlay-dev](https://github.com/nabbi/oubliette-overlay-dev) — experimental development sandbox.

## Install

Enable via `eselect-repository`:

```shell
eselect repository enable oubliette
emaint sync -r oubliette
```
