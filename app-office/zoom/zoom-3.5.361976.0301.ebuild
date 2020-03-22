# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

inherit desktop gnome2-utils xdg-utils

IUSE="gnome"

DESCRIPTION="Zoom Meeting Linux Client"
HOMEPAGE="https://zoom.us/"
SRC_URI="https://d11yldzmag5yn.cloudfront.net/prod/${PV}/${PN}_x86_64.tar.xz -> ${P}.tar.xz"
LICENSE="all-rights-reserved"
SLOT="0"
KEYWORDS="amd64"

RDEPEND="
	app-arch/bzip2
	app-arch/snappy
	app-arch/xz-utils
	app-crypt/mit-krb5
	dev-libs/double-conversion
	dev-libs/expat
	dev-libs/fribidi
	dev-libs/glib
	dev-libs/gmp
	dev-libs/icu
	dev-libs/jansson
	dev-libs/libbsd
	dev-libs/libcroco
	dev-libs/libevent
	dev-libs/libffi
	dev-libs/libpcre
	dev-libs/libpcre2
	dev-libs/libtasn1
	dev-libs/libunistring
	dev-libs/libxml2
	dev-libs/libxslt
	dev-libs/nettle
	dev-libs/nspr
	dev-libs/nss
	dev-libs/openssl
	dev-libs/re2
	dev-qt/qtcore
	dev-qt/qtdbus
	dev-qt/qtdeclarative
	dev-qt/qtgui
	dev-qt/qtnetwork
	dev-qt/qtpositioning
	dev-qt/qtprintsupport
	dev-qt/qtscript
	dev-qt/qtwebchannel
	dev-qt/qtwebengine
	dev-qt/qtwidgets
	gnome-base/librsvg
	media-gfx/graphite2
	media-libs/alsa-lib
	media-libs/fontconfig
	media-libs/freetype
	media-libs/harfbuzz
	media-libs/lcms
	media-libs/libglvnd
	media-libs/libjpeg-turbo
	media-libs/libogg
	media-libs/libpng
	media-libs/libvorbis
	media-libs/libvpx
	media-libs/libwebp
	media-libs/opus
	media-libs/x264
	media-libs/xvid
	media-sound/lame
	media-video/ffmpeg
	net-dns/libidn2
	net-fs/samba
	net-libs/gnutls
	net-libs/libnsl
	net-libs/libtirpc
	net-nds/openldap
	sys-apps/dbus
	sys-apps/keyutils
	sys-apps/util-linux
	sys-libs/e2fsprogs-libs
	sys-libs/ldb
	sys-libs/libcap
	sys-libs/talloc
	sys-libs/tdb
	sys-libs/tevent
	sys-libs/zlib
	x11-libs/cairo
	x11-libs/gdk-pixbuf
	x11-libs/libdrm
	x11-libs/libva
	x11-libs/libvdpau
	x11-libs/libX11
	x11-libs/libXau
	x11-libs/libxcb
	x11-libs/libXcomposite
	x11-libs/libXdamage
	x11-libs/libXdmcp
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libXrender
	x11-libs/libXScrnSaver
	x11-libs/libXtst
	x11-libs/pango
	x11-libs/pixman
	x11-libs/xcb-util
	x11-libs/xcb-util-image
	x11-libs/xcb-util-keysyms
"
DEPEND=""
PDEPEND=""
RESTRICT="mirror strip"

S="${WORKDIR}/${PN}"

src_install() {
	dodir /usr/share/zoom
	insinto /usr/share/zoom
	doins -r "${S}"/{json,sip,timezones,translations}
	doins "${S}"/*.{dat,pak,pcm,pem,properties,sh,txt}

	# fix launcher path, no /opt stuff needed
	sed -i -e 's,/opt/zoom,/usr/bin,' "${S}"/zoomlinux || die

	exeinto /usr/bin
	doexe "${S}"/{zoom,ZoomLauncher,zoomlinux}

	make_desktop_entry "${PN}linux" "Zoom" "${PN}" "AudioVideo;Network" \
		"Version=1.0\nTerminal=false\nStartupNotify=true\nStartupWMClass=Zoom\nMimeType=x-scheme-handler/zoom\nX-KDE-Protocols=zoom"
}

pkg_preinst() {
	use gnome && gnome2_icon_savelist
}

pkg_postinst() {
	xdg_desktop_database_update
	xdg_mimeinfo_database_update
	xdg_icon_cache_update
	use gnome && gnome2_icon_cache_update
}

pkg_postrm() {
	xdg_desktop_database_update
	xdg_icon_cache_update
	use gnome && gnome2_icon_cache_update
}

pkg_setup() {
	QA_PREBUILT="usr/bin/zoom"
}
