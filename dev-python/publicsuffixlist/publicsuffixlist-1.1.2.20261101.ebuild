# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=hatchling
PYTHON_COMPAT=( python3_{12..15} )

inherit distutils-r1 pypi

DESCRIPTION="Public Suffix List parser, reading the system list"
HOMEPAGE="
	https://github.com/ko-zu/psl/
	https://pypi.org/project/publicsuffixlist/
"

LICENSE="MPL-2.0"
SLOT="0"
KEYWORDS="~amd64"

# The list comes from net-misc/publicsuffix-db instead of the copy bundled
# in each (daily) upstream release, so this needs no bump to stay current
RDEPEND="
	net-misc/publicsuffix-db
"
BDEPEND="
	test? (
		net-misc/publicsuffix-db
	)
"

EPYTEST_PLUGINS=()
distutils_enable_tests pytest

src_prepare() {
	distutils-r1_src_prepare

	rm publicsuffixlist/public_suffix_list.dat || die
	sed -i \
		-e 's|^PSLFILE = .*|PSLFILE = "'"${EPREFIX}"'/usr/share/publicsuffix/public_suffix_list.dat"|' \
		publicsuffixlist/__init__.py || die
	grep -q '^PSLFILE = "'"${EPREFIX}"'/usr/share/publicsuffix/' \
		publicsuffixlist/__init__.py || die "PSLFILE not replaced"

	# publicsuffixlist-download would rewrite the system list in place;
	# portage updates it (net-misc/publicsuffix-db)
	sed -i -e '/^\[project.scripts\]/,/^$/d' pyproject.toml || die
}

python_test() {
	epytest publicsuffixlist/test.py
}
