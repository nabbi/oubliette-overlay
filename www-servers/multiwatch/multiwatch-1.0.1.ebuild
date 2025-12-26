# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit meson

DESCRIPTION="Forks multiple instances of a program in the same context (spawn-fcgi)"
HOMEPAGE="https://redmine.lighttpd.net/projects/multiwatch"
SRC_URI="https://download.lighttpd.net/multiwatch/releases-1.x/${P}.tar.xz"

LICENSE="BSD GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ppc ~ppc64 ~x86"

RESTRICT="strip"

DEPEND="
	dev-libs/libev
"

src_configure() {
	meson_src_configure
}

src_compile() {
	meson_src_compile
}

src_install() {
	meson_src_install

	dodoc README.md
}
