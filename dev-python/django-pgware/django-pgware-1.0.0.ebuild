# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=hatchling
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1

DESCRIPTION="PostgreSQL utilities for Django: advisory locks, GUC management, logging"
HOMEPAGE="
	https://github.com/Xof/django-pgware/
	https://pypi.org/project/django-pgware/
"

SRC_URI="
	https://github.com/Xof/django-pgware/archive/v${PV}.tar.gz
		-> ${P}.gh.tar.gz
"
S=${WORKDIR}/${P}

LICENSE="POSTGRESQL"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	>=dev-python/django-4.2[${PYTHON_USEDEP}]
"

BDEPEND="
	test? (
		dev-python/asgiref[${PYTHON_USEDEP}]
	)
"

EPYTEST_PLUGINS=( pytest-django pytest-asyncio )
distutils_enable_tests pytest
