# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="scp module for paramiko"
HOMEPAGE="
	https://github.com/jbardin/scp.py/
	https://pypi.org/project/scp/
"

LICENSE="LGPL-2.1+"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	dev-python/paramiko[${PYTHON_USEDEP}]
"
