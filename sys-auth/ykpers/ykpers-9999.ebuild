# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

MY_PN="yubikey-personalization"

if [[ ${PV} == 9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/nabbi/${MY_PN}.git"
	EGIT_BRANCH="nabbi"
else
	SRC_URI="https://github.com/nabbi/${MY_PN}/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="amd64 ~arm64 ~ppc64 ~riscv x86"
	S="${WORKDIR}/${MY_PN}-${PV}"
fi

inherit autotools udev

DESCRIPTION="Library and tool for personalization of Yubico's YubiKey"
HOMEPAGE="https://github.com/nabbi/yubikey-personalization"

LICENSE="BSD-2"
SLOT="0"

RDEPEND="dev-libs/json-c:=
	>=sys-auth/libyubikey-1.6
	virtual/libusb:1"
DEPEND="${RDEPEND}"
BDEPEND="app-text/asciidoc
	virtual/pkgconfig"

DOCS=( doc/. AUTHORS NEWS README )

src_prepare() {
	default
	eautoreconf
}

src_configure() {
	local myeconfargs=(
		--libdir=/usr/$(get_libdir)
		--localstatedir=/var
	)
	econf "${myeconfargs[@]}"
}

src_install() {
	default

	udev_dorules 69-yubikey.rules

	find "${D}" -name '*.la' -delete || die
}

pkg_postinst() {
	udev_reload
}

pkg_postrm() {
	udev_reload
}
