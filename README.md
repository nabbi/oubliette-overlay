# Oubliette Gentoo Overlay

[![gentoo qa-reports](https://img.shields.io/badge/gentoo-QA%20check-6E56AF.svg)](https://qa-reports.gentoo.org/output/repos/oubliette.html)
[![repoman](https://github.com/nabbi/oubliette-overlay/actions/workflows/repoman.yml/badge.svg)](https://github.com/nabbi/oubliette-overlay/actions/workflows/repoman.yml)
[![pkgcheck](https://github.com/nabbi/oubliette-overlay/actions/workflows/pkgcheck.yml/badge.svg)](https://github.com/nabbi/oubliette-overlay/actions/workflows/pkgcheck.yml)

**Oubliette** is a personal, unofficial Portage overlay containing forgotten or patched ebuilds that are maintained here for convenience.

Packages with their own notes:

* [www-misc/zoneminder](www-misc/zoneminder/README.md) — ZoneMinder: releases, live branches and master snapshots; API v2 as CakePHP (`apiv2-cake`) or [zm-php-api](https://github.com/nabbi/zm-php-api) (`apiv2-php`), optional API v3 (`apiv3`, `www-misc/zm-api`).

Related repositories:

* [oubliette-patches](https://github.com/nabbi/oubliette-patches) — supplemental patches used by some ebuilds.
* [oubliette-overlay-dev](https://github.com/nabbi/oubliette-overlay-dev) — experimental development sandbox.

## Install

Enable via `eselect-repository`:

```shell
eselect repository enable oubliette
emaint sync -r oubliette
```
