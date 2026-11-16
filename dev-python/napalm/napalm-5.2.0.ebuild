# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=uv-build
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1

DESCRIPTION="Multi-vendor network automation and programmability abstraction layer"
HOMEPAGE="
	https://github.com/napalm-automation/napalm/
	https://pypi.org/project/napalm/
"

SRC_URI="
	https://github.com/napalm-automation/napalm/archive/${PV}.tar.gz
		-> ${P}.gh.tar.gz
"
S=${WORKDIR}/${P}

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	>=dev-python/paramiko-3.5.0[${PYTHON_USEDEP}]
	>=dev-python/requests-2.7.0[${PYTHON_USEDEP}]
	>=dev-python/textfsm-1.1.3[${PYTHON_USEDEP}]
	>=dev-python/jinja2-3.1.4[${PYTHON_USEDEP}]
	>=dev-python/netaddr-1.3.0[${PYTHON_USEDEP}]
	>=dev-python/pyyaml-6.0.2[${PYTHON_USEDEP}]
	>=dev-python/pyeapi-1.0.2[${PYTHON_USEDEP}]
	>=dev-python/netmiko-4.4.0[${PYTHON_USEDEP}]
	>=dev-python/junos-eznc-2.7.4[${PYTHON_USEDEP}]
	>=dev-python/lxml-4.3.0[${PYTHON_USEDEP}]
	>=dev-python/ncclient-0.6.16[${PYTHON_USEDEP}]
	>=dev-python/ttp-0.9.5[${PYTHON_USEDEP}]
	>=dev-python/ttp-templates-0.3.7[${PYTHON_USEDEP}]
	>=dev-python/netutils-1.0.0[${PYTHON_USEDEP}]
	>=dev-python/typing-extensions-4.12.2[${PYTHON_USEDEP}]
"

BDEPEND="
	test? (
		dev-python/ddt[${PYTHON_USEDEP}]
		dev-python/mock[${PYTHON_USEDEP}]
	)
"

EPYTEST_PLUGINS=()
distutils_enable_tests pytest
