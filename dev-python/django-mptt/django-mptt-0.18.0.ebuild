# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=hatchling
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="Modified Preorder Tree Traversal (MPTT) for Django models"
HOMEPAGE="
	https://github.com/django-mptt/django-mptt/
	https://pypi.org/project/django-mptt/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
# Tests need model-bakery and mock-django, which are not packaged in ::gentoo;
# MPTT is exercised by www-apps/netbox's own test suite instead
RESTRICT="test"

RDEPEND="
	dev-python/django-js-asset[${PYTHON_USEDEP}]
"
