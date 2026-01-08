# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
inherit autotools toolchain-funcs git-r3

DESCRIPTION="Simple screen lock application for X server"
HOMEPAGE="https://github.com/Arkq/alock"

EGIT_REPO_URI="https://github.com/Arkq/${PN}"
EGIT_BRANCH=master

LICENSE="MIT"
SLOT="0"
IUSE="debug imlib pam xbacklight"

DEPEND="
	virtual/libcrypt
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

src_unpack() {
	git-r3_src_unpack
}

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
	# xmlto isn't required, so set to 'true' as dummy program
	# alock.1 is suitable for a manpage
	emake XMLTO=true
}

src_install() {
	dobin src/alock

	doman doc/alock.1

	if ! use pam; then
		# Sets suid so alock can correctly work with shadow
		fperms 4755 /usr/bin/alock
	fi
}
