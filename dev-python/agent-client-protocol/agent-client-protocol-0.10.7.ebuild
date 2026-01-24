# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{11..14} )
DISTUTILS_USE_PEP517=hatchling

inherit distutils-r1

DESCRIPTION="Agent Client Protocol (ACP) Python implementation"
HOMEPAGE="https://github.com/agentclientprotocol/agent-client-protocol"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RESTRICT="test"

if [[ ${PV} == 9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/agentclientprotocol/agent-client-protocol.git"
	EGIT_BRANCH="main"
	S="${WORKDIR}/${P}/python"
else
	SRC_URI="https://github.com/agentclientprotocol/agent-client-protocol/archive/refs/tags/v${PV}.tar.gz -> ${P}.gh.tar.gz"
	S="${WORKDIR}/agent-client-protocol-${PV}/python"
fi

RDEPEND="
	>=dev-python/pydantic-2[${PYTHON_USEDEP}]
	dev-python/anyio[${PYTHON_USEDEP}]
	dev-python/httpx[${PYTHON_USEDEP}]
"
DEPEND="${RDEPEND}"
