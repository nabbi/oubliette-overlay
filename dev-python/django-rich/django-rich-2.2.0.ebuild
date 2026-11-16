# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1

DESCRIPTION="Extensions for using Rich with Django"
HOMEPAGE="
	https://github.com/adamchainz/django-rich/
	https://pypi.org/project/django-rich/
"

SRC_URI="
	https://github.com/adamchainz/django-rich/archive/${PV}.tar.gz
		-> ${P}.gh.tar.gz
"
S=${WORKDIR}/${P}

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	>=dev-python/django-4.2[${PYTHON_USEDEP}]
	>=dev-python/rich-10[${PYTHON_USEDEP}]
"

BDEPEND="
	test? (
		dev-python/rich[${PYTHON_USEDEP}]
	)
"

EPYTEST_PLUGINS=( pytest-django )
distutils_enable_tests pytest
