# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=poetry
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="Template Text Parser"
HOMEPAGE="
	https://ttp.readthedocs.io/
	https://github.com/dmulyalin/ttp/
	https://pypi.org/project/ttp/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
