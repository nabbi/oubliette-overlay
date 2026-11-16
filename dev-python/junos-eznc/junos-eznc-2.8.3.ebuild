# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1

DESCRIPTION="Junos 'EZ' automation for non-programmers"
HOMEPAGE="
	https://github.com/Juniper/py-junos-eznc/
	https://pypi.org/project/junos-eznc/
"

SRC_URI="
	https://github.com/Juniper/py-junos-eznc/archive/${PV}.tar.gz
		-> ${P}.gh.tar.gz
"
S=${WORKDIR}/py-${P}

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	>=dev-python/lxml-3.2.4[${PYTHON_USEDEP}]
	>=dev-python/ncclient-0.7.0[${PYTHON_USEDEP}]
	>=dev-python/scp-0.7.0[${PYTHON_USEDEP}]
	>=dev-python/jinja2-3.1.6[${PYTHON_USEDEP}]
	>=dev-python/pyyaml-5.1[${PYTHON_USEDEP}]
	>=dev-python/paramiko-3.5.0[${PYTHON_USEDEP}]
	dev-python/six[${PYTHON_USEDEP}]
	dev-python/pyserial[${PYTHON_USEDEP}]
	dev-python/yamlloader[${PYTHON_USEDEP}]
	dev-python/pyparsing[${PYTHON_USEDEP}]
	dev-python/transitions[${PYTHON_USEDEP}]
"

BDEPEND="
	test? (
		dev-python/mock[${PYTHON_USEDEP}]
		dev-python/nose2[${PYTHON_USEDEP}]
	)
"

EPYTEST_PLUGINS=()
distutils_enable_tests pytest

python_test() {
	local EPYTEST_DESELECT=(
		# expects field names from an older ntc-templates
		tests/unit/factory/test_cmdtable.py::TestFactoryCMDTable::test_textfsm_table_mutli_key
	)
	epytest tests/unit
}
