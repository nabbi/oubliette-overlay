# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=poetry
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1

DESCRIPTION="TextFSM templates for network devices and a Python wrapper for them"
HOMEPAGE="
	https://ntc-templates.readthedocs.io/
	https://github.com/networktocode/ntc-templates/
	https://pypi.org/project/ntc-templates/
"

SRC_URI="
	https://github.com/networktocode/ntc-templates/archive/v${PV}.tar.gz
		-> ${P}.gh.tar.gz
"
S=${WORKDIR}/${P}

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	>=dev-python/textfsm-1.1.0[${PYTHON_USEDEP}]
"

BDEPEND="
	test? (
		dev-python/ruamel-yaml[${PYTHON_USEDEP}]
		dev-python/pyyaml[${PYTHON_USEDEP}]
	)
"

EPYTEST_IGNORE=(
	# invoke tasks, not tests
	tests/test_tasks.py
)
EPYTEST_PLUGINS=()
distutils_enable_tests pytest
