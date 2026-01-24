# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{11..14} )

inherit distutils-r1

DESCRIPTION="Consume Server-Sent Event (SSE) messages with HTTPX"
HOMEPAGE="https://github.com/florimondmanca/httpx-sse"

LICENSE="MIT"
SLOT="0"

IUSE="test"
RESTRICT="!test? ( test )"

if [[ ${PV} == 9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/florimondmanca/${PN}.git"
	EGIT_BRANCH="main"
else
	inherit pypi
	KEYWORDS="~amd64 ~arm64 ~x86"
fi

RDEPEND="
	dev-python/httpx[${PYTHON_USEDEP}]
	dev-python/starlette[${PYTHON_USEDEP}]
"
BDEPEND="
	dev-python/setuptools-scm[${PYTHON_USEDEP}]
	test? (
		dev-python/pytest-asyncio[${PYTHON_USEDEP}]
		dev-python/sse-starlette[${PYTHON_USEDEP}]
	)
"

EPYTEST_PLUGINS=( pytest-asyncio )
distutils_enable_tests pytest

src_prepare() {
	default

	if use test && [[ -f setup.cfg ]]; then
		# remove coverage/strict addopts that can break Gentoo test runs
		sed -i '/addopts/,+5d' setup.cfg || die "sed failed"
	fi
}
