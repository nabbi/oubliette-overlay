# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

if [[ ${PV} == 9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/nabbi/yubico-c.git"
	EGIT_BRANCH="nabbi"
else
	SRC_URI="https://github.com/nabbi/yubico-c/archive/refs/tags/${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64 ~arm ~arm64 ~ppc ~ppc64 ~riscv ~sparc ~x86"
	S="${WORKDIR}/yubico-c-${PV}"
fi

inherit autotools

DESCRIPTION="Yubico C low-level library"
HOMEPAGE="https://github.com/nabbi/yubico-c"

LICENSE="BSD-2"
SLOT="0"
IUSE="test"
RESTRICT="!test? ( test )"

DEPEND="app-text/asciidoc"
BDEPEND="${DEPEND}
	test? ( dev-debug/valgrind )"

src_prepare() {
	default
	eautoreconf
}

src_install() {
	default

	# no static archives
	find "${ED}" -name '*.la' -delete || die
}
