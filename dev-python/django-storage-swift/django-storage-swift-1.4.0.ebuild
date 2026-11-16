# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="OpenStack Swift storage backend for Django"
HOMEPAGE="
	https://github.com/dennisv/django-storage-swift/
	https://pypi.org/project/django-storage-swift/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	>=dev-python/python-swiftclient-2.2.0[${PYTHON_USEDEP}]
	>=dev-python/python-keystoneclient-0.2.3[${PYTHON_USEDEP}]
	dev-python/six[${PYTHON_USEDEP}]
	>=dev-python/python-magic-0.4.10[${PYTHON_USEDEP}]
"
