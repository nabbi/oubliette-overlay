# Copyright 2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit autotools toolchain-funcs

# we need this since there are no tagged releases yet
DESCRIPTION="Simple screen lock application for X server"
HOMEPAGE="https://github.com/Arkq/alock"
SRC_URI="https://github.com/Arkq/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm ~ppc ~x86"
IUSE="debug imlib pam xbacklight"

DEPEND="dev-libs/libgcrypt:0
	x11-libs/libX11
	x11-libs/libXau
	x11-libs/libxcb
	x11-libs/libXcursor
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libXpm
	x11-libs/libXrender
	imlib? ( media-libs/imlib2[X] )
	pam? ( sys-libs/pam )
	xbacklight? ( x11-apps/xbacklight )"
RDEPEND="${DEPEND}"

src_prepare() {
	default

	eautoreconf
}

src_configure() {
	tc-export CC

	econf \
		--prefix=/usr \
		--enable-hash \
		--enable-passwd \
		--enable-xcursor \
		--enable-xpm \
		--enable-xrender \
		$(use_enable debug) \
		$(use_enable imlib imlib2) \
		$(use_enable pam) \
		$(use_with xbacklight)
}

src_compile() {
	emake XMLTO=true
}

src_install() {
	dobin src/alock

	doman doc/alock.1

	if ! use pam; then
		fperms 4755 /usr/bin/alock
	fi
}
