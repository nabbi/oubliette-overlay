# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="Python module for parsing semi-structured text into python tables"
HOMEPAGE="
	https://github.com/google/textfsm/
	https://pypi.org/project/textfsm/
"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"

src_prepare() {
	# do not install the test suite as a top-level "tests" package
	sed -i 's/find_packages()/find_packages(exclude=["tests", "tests.*"])/' setup.py || die
	distutils-r1_src_prepare
}

EPYTEST_PLUGINS=()
distutils_enable_tests pytest
