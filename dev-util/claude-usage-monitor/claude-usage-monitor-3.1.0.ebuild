# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_12 python3_13 )

inherit distutils-r1

DESCRIPTION="Real-time terminal monitoring tool for Claude AI token usage"
HOMEPAGE="https://github.com/Maciek-roboblog/Claude-Code-Usage-Monitor"
SRC_URI="https://github.com/Maciek-roboblog/Claude-Code-Usage-Monitor/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

S="${WORKDIR}/Claude-Code-Usage-Monitor-${PV}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	dev-python/numpy[${PYTHON_USEDEP}]
	dev-python/pydantic[${PYTHON_USEDEP}]
	dev-python/pydantic-settings[${PYTHON_USEDEP}]
	dev-python/pytz[${PYTHON_USEDEP}]
	dev-python/pyyaml[${PYTHON_USEDEP}]
	dev-python/rich[${PYTHON_USEDEP}]
"
