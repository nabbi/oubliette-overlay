# Oubliette Gentoo Overlay

[![gentoo qa-reports](https://img.shields.io/badge/gentoo-QA%20check-6E56AF.svg)](https://qa-reports.gentoo.org/output/repos/oubliette.html)
[![repoman](https://github.com/nabbi/oubliette-overlay/actions/workflows/repoman.yml/badge.svg)](https://github.com/nabbi/oubliette-overlay/actions/workflows/repoman.yml)
[![pkgcheck](https://github.com/nabbi/oubliette-overlay/actions/workflows/pkgcheck.yml/badge.svg)](https://github.com/nabbi/oubliette-overlay/actions/workflows/pkgcheck.yml)

**Oubliette** is a personal, unofficial Portage overlay containing forgotten or patched ebuilds that are maintained here for convenience.

Related repositories:

* [oubliette-patches](https://github.com/nabbi/oubliette-patches) — supplemental patches used by some ebuilds.
* [oubliette-overlay-dev](https://github.com/nabbi/oubliette-overlay-dev) — experimental development sandbox.
* [oubliette-ebuild-verbump](https://github.com/nabbi/oubliette-ebuild-verbump) — small helper scripts for automated version bumps.

## Install

Enable via `eselect-repository`:

```shell
eseselect repository enable oubliette
emaint sync -r oubliette
```
