# Oubliette Gentoo Overlay

[![gentoo qa-reports](https://img.shields.io/badge/gentoo-QA%20check-6E56AF.svg)](https://qa-reports.gentoo.org/output/repos/oubliette.html)
[![pkgcheck](https://github.com/nabbi/oubliette-overlay/actions/workflows/pkgcheck.yml/badge.svg)](https://github.com/nabbi/oubliette-overlay/actions/workflows/pkgcheck.yml)

**Oubliette** is a personal, unofficial Portage overlay of forgotten or patched ebuilds. Packages that need more explanation carry a `README.md` in their directory.

Why the packages are here (`scripts/package-metrics -v` lists them):

<!-- package-metrics -->
| | packages |
|---|--:|
| not in ::gentoo | 81 |
| newer than ::gentoo | 10 |
| fixes on top of ::gentoo | 16 |
| acct-group / acct-user | 16 |
| **total** (157 ebuilds) | **123** |
<!-- /package-metrics -->

Related repositories:

* [oubliette-patches](https://github.com/nabbi/oubliette-patches) — supplemental patches used by some ebuilds.
* [oubliette-overlay-dev](https://github.com/nabbi/oubliette-overlay-dev) — experimental development sandbox.

## Install

```shell
eselect repository enable oubliette
emaint sync -r oubliette
```
