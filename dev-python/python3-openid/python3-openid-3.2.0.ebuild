# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYPI_NO_NORMALIZE=1
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="OpenID support for modern servers and consumers"
HOMEPAGE="
	https://github.com/necaris/python3-openid/
	https://pypi.org/project/python3-openid/
"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"
# The test suite imports psycopg2/psycopg2cffi and MySQLdb backends unconditionally
RESTRICT="test"

RDEPEND="
	dev-python/defusedxml[${PYTHON_USEDEP}]
"
