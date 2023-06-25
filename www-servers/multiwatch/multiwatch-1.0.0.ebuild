# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Forks multiple instances of a program in the same context (spawn-fcgi)"
HOMEPAGE="https://redmine.lighttpd.net/projects/multiwatch"
SRC_URI="https://download.lighttpd.net/multiwatch/releases-1.x/${P}.tar.xz"

LICENSE="BSD GPL-2"
SLOT="0"
KEYWORDS="~alpha amd64 arm ~hppa ~ia64 ppc ppc64 sparc x86"

DEPEND="
	dev-libs/libev
"
RDEPEND=""

src_install() {
	default

	dodoc README
}
