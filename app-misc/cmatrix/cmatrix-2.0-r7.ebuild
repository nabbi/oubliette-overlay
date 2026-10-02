# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

FONT_SUFFIX="pcf"

inherit cmake font

DESCRIPTION="An ncurses based app to show a scrolling screen from the Matrix"
HOMEPAGE="https://github.com/abishekvashok/cmatrix"
SRC_URI="https://github.com/abishekvashok/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="+unicode"

DEPEND="sys-libs/ncurses:=[unicode(+)?]"
RDEPEND="${DEPEND}"

PATCHES=(
	"${FILESDIR}"/${P}-cmake4.patch
	# Upstream #118 (post-2.0): stray blocks left behind when shrinking.
	"${FILESDIR}"/${P}-resize-garbage.patch
	# Pending upstream (#108): fd leak on resize, CMake build never resized,
	# and font install that ran mkfontdir on the live system.
	"${FILESDIR}"/${P}-tty-fd-leak.patch
	"${FILESDIR}"/${P}-cmake-resize.patch
	"${FILESDIR}"/${P}-cmake-font-install.patch
)

src_configure() {
	local mycmakeargs=(
		-DCURSES_NEED_WIDE=$(usex unicode)
		-DCMATRIX_CONSOLE_FONTS_DIRS=share/consolefonts
		# The X font is installed via font.eclass instead.
		-DCMATRIX_X_FONTS_DIRS=
	)
	cmake_src_configure
}

src_install() {
	cmake_src_install
	use X && font_src_install
	doman ${PN}.1
}

pkg_postinst() {
	use X && font_pkg_postinst
}

pkg_postrm() {
	use X && font_pkg_postrm
}
