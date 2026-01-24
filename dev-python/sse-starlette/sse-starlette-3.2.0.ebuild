# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{11..14} )
DISTUTILS_USE_PEP517=setuptools

inherit distutils-r1

DESCRIPTION="SSE plugin for Starlette"
HOMEPAGE="
	https://github.com/sysid/sse-starlette
	https://pypi.org/project/sse-starlette/
"

LICENSE="BSD"
SLOT="0"

RESTRICT="test"

if [[ ${PV} == 9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/sysid/sse-starlette.git"
	EGIT_BRANCH="main"
	KEYWORDS=""
else
	inherit pypi
	KEYWORDS="amd64 ~arm64 ~x86"
fi

RDEPEND="
	>=dev-python/starlette-0.49.1[${PYTHON_USEDEP}]
	>=dev-python/anyio-4.7.0[${PYTHON_USEDEP}]
"
DEPEND="${RDEPEND}"
