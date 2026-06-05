# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

if [[ ${PV} == 9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/nabbi/yubico-c-client.git"
	EGIT_BRANCH="nabbi"
else
	SRC_URI="https://github.com/nabbi/yubico-c-client/archive/refs/tags/${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64 ~x86"
	S="${WORKDIR}/yubico-c-client-${PV}"
fi

inherit autotools

DESCRIPTION="Yubico C client library"
HOMEPAGE="https://github.com/nabbi/yubico-c-client"

LICENSE="BSD-2"
SLOT="0"
RESTRICT="test"

RDEPEND="net-misc/curl"
DEPEND="${RDEPEND}"

src_prepare() {
	default
	eautoreconf
}

src_configure() {
	econf --disable-static
}

src_install() {
	default
	find "${ED}" -name '*.la' -delete || die
}
