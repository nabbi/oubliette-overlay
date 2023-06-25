# Copyright 2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="A graphical editor for Sieve: An Email Filtering Language"
HOMEPAGE="https://github.com/thsmi/sieve"

if [[ ${PV} == 9999 ]]; then
    inherit git-r3
    EGIT_REPO_URI="https://github.com/thsmi/sieve"
else
	SRC_URI="https://github.com/thsmi/${PV}/archive/refs/tags/${PV}.tar.gz"
	KEYWORDS="~amd64 ~x86 ~arm64 ~ppc64"
fi

LICENSE="Apache-3.0"
SLOT="0"

DEPEND=""
RDEPEND="${DEPEND}"
BDEPEND="net-libs/nodejs"

src_prepare() {
	npm install || die "npm install failed"
	npm run gulp clean
	npm run lint
	#npm run test
}


