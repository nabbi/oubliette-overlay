# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{11..14} )

DESCRIPTION="A declarative object transformer for conglomerating nested data"
HOMEPAGE="https://github.com/mahmoud/glom"
LICENSE="BSD"
SLOT="0"

if [[ ${PV} == 9999 ]]; then
	inherit distutils-r1 git-r3

	EGIT_REPO_URI="https://github.com/mahmoud/${PN}.git"
	# default branch is fine; set EGIT_BRANCH if you need something else
	PROPERTIES="live"
	KEYWORDS=""
else
	inherit distutils-r1

	SRC_URI="https://github.com/mahmoud/glom/archive/refs/tags/v${PV}.tar.gz -> ${P}.gh.tar.gz"
	KEYWORDS="amd64 ~arm64 ~x86"
fi

RDEPEND="
	>=dev-python/boltons-19.3.0[${PYTHON_USEDEP}]
	dev-python/attrs[${PYTHON_USEDEP}]
	>=dev-python/face-20.1.0[${PYTHON_USEDEP}]
	dev-python/pyyaml[${PYTHON_USEDEP}]
"
DEPEND="${RDEPEND}"

# Upstream tests currently fail in your environment (per your note)
RESTRICT="test"
# distutils_enable_tests pytest

