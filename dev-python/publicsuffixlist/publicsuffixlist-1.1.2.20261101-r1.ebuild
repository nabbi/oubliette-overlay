# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=hatchling
PYTHON_COMPAT=( python3_{12..15} )

inherit distutils-r1 pypi

DESCRIPTION="Public Suffix List parser, with the list bundled"
HOMEPAGE="
	https://github.com/ko-zu/psl/
	https://pypi.org/project/publicsuffixlist/
"

LICENSE="MPL-2.0"
SLOT="0"
KEYWORDS="~amd64"

EPYTEST_PLUGINS=()
distutils_enable_tests pytest

src_prepare() {
	distutils-r1_src_prepare

	# publicsuffixlist-download would rewrite the installed list in place;
	# a newer list comes with a newer version of this package
	sed -i -e '/^\[project.scripts\]/,/^$/d' pyproject.toml || die
}

python_test() {
	epytest publicsuffixlist/test.py
}
