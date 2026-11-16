# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=poetry
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1

DESCRIPTION="Common helper functions useful in network automation"
HOMEPAGE="
	https://netutils.readthedocs.io/
	https://github.com/networktocode/netutils/
	https://pypi.org/project/netutils/
"

SRC_URI="
	https://github.com/networktocode/netutils/archive/v${PV}.tar.gz
		-> ${P}.gh.tar.gz
"
S=${WORKDIR}/${P}

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"

BDEPEND="
	test? (
		dev-python/jsonschema[${PYTHON_USEDEP}]
		dev-python/jinja2[${PYTHON_USEDEP}]
		dev-python/pyyaml[${PYTHON_USEDEP}]
	)
"

EPYTEST_IGNORE=(
	# need dev-python/toml, which is not in ::gentoo
	tests/unit/test_basics.py
	tests/unit/test_version.py
)
EPYTEST_PLUGINS=()
distutils_enable_tests pytest

python_test() {
	epytest -o addopts= tests/unit
}
