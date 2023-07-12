# Oubliette Gentoo overlay 

[![gentoo qa-reports](https://img.shields.io/badge/gentoo-QA%20check-6E56AF.svg)](https://qa-reports.gentoo.org/output/repos/oubliette.html)
[![repoman](https://github.com/nabbi/oubliette-overlay/actions/workflows/repoman.yml/badge.svg)](https://github.com/nabbi/oubliette-overlay/actions/workflows/repoman.yml)
[![pkgcheck](https://github.com/nabbi/oubliette-overlay/actions/workflows/pkgcheck.yml/badge.svg)](https://github.com/nabbi/oubliette-overlay/actions/workflows/pkgcheck.yml)
[![mirror](https://img.shields.io/badge/gentoo-mirror-purple)](https://github.com/gentoo-mirror/oubliette)

[Oubliette](https://github.com/nabbi/oubliette-overlay) is my personal unofficial Portage overlay containing forgotten and fixed ebuilds for Gentoo Linux.
* [oubliette-patches](https://github.com/nabbi/oubliette-patches) compliments what this misses.
* [oubliette-overlay-dev](https://github.com/nabbi/oubliette-overlay-dev) is an experimental development sandbox
* [oubliette-ebuild-verbump](https://github.com/nabbi/oubliette-ebuild-verbump) auto version bumps a few packages found here


## Install

To add the overlay using app-eselect/eselect-repository:
```
eselect repository enable oubliette
```
