# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=hatchling
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="Multi-vendor library to simplify legacy CLI connections to network devices"
HOMEPAGE="
	https://github.com/ktbyers/netmiko/
	https://pypi.org/project/netmiko/
"

# netmiko/_telnetlib is a copy of the stdlib telnetlib
LICENSE="MIT PSF-2"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	>=dev-python/ntc-templates-3.1.0[${PYTHON_USEDEP}]
	>=dev-python/paramiko-3.5.1[${PYTHON_USEDEP}]
	>=dev-python/pyserial-3.3[${PYTHON_USEDEP}]
	>=dev-python/pyyaml-6.0.2[${PYTHON_USEDEP}]
	>=dev-python/rich-13.8[${PYTHON_USEDEP}]
	>=dev-python/scp-0.13.6[${PYTHON_USEDEP}]
	>=dev-python/textfsm-1.1.3[${PYTHON_USEDEP}]
"

EPYTEST_PLUGINS=()
distutils_enable_tests pytest

python_test() {
	local EPYTEST_DESELECT=(
		# opens a TCP connection
		tests/unit/test_connection.py::test_connecthandler_auth_failure
		# need Cisco pyATS/Genie
		tests/unit/test_utilities.py::test_get_structured_data_genie
		'tests/unit/test_utilities.py::test_parsing_errors_genie'
	)
	# everything outside tests/unit needs real network devices
	epytest tests/unit
}
