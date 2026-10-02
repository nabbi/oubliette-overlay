# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

FONT_SUFFIX="pcf"

inherit cmake font

DESCRIPTION="An ncurses based app to show a scrolling screen from the Matrix"
HOMEPAGE="https://github.com/abishekvashok/cmatrix"

if [[ ${PV} == *9999* ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/abishekvashok/cmatrix.git"
else
	SRC_URI="https://github.com/abishekvashok/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64 ~x86"
fi

LICENSE="GPL-3+"
SLOT="0"

# CMakeLists.txt forces CURSES_NEED_WIDE, so ncursesw is always required.
DEPEND="sys-libs/ncurses:=[unicode(+)]"
RDEPEND="${DEPEND}"

# These patches are not tied to a version, so this ebuild can be copied to a
# future release (e.g. cmatrix-2.1.ebuild) as-is. When doing so, drop every
# patch whose upstream PR has been merged, and the cmake 4 sed once
# CMakeLists.txt requires >= 3.5.
PATCHES=(
	# Ours, pending upstream.
	# https://github.com/abishekvashok/cmatrix/pull/217 (issue #215)
	"${FILESDIR}"/${PN}-cmake-ncursesw-header.patch
	# https://github.com/abishekvashok/cmatrix/pull/218 (issue #216)
	"${FILESDIR}"/${PN}-cmake-font-install.patch
	# https://github.com/abishekvashok/cmatrix/pull/219 (issue #108)
	"${FILESDIR}"/${PN}-cmake-resize.patch
	"${FILESDIR}"/${PN}-tty-fd-leak.patch
	# https://github.com/abishekvashok/cmatrix/pull/220 (issue #174)
	"${FILESDIR}"/${PN}-term-unset-segfault.patch
	# https://github.com/abishekvashok/cmatrix/pull/221
	"${FILESDIR}"/${PN}-init-and-small-term.patch

	# Others', pending upstream.
	# https://github.com/abishekvashok/cmatrix/pull/192
	"${FILESDIR}"/${PN}-c_die-exit-status.patch
	# -c: draw the head character with addwstr() too (issues #202, #206).
	# cmatrix.c part only; its configure.ac change doesn't affect cmake.
	# https://github.com/abishekvashok/cmatrix/pull/213
	"${FILESDIR}"/${PN}-kana-head-addwstr.patch
)

src_prepare() {
	# cmake_minimum_required(VERSION 2.8) is rejected by cmake 4.
	# https://github.com/abishekvashok/cmatrix/pull/201
	sed -i 's/cmake_minimum_required(VERSION 2.8)/cmake_minimum_required(VERSION 3.10)/' \
		CMakeLists.txt || die

	cmake_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-DCMATRIX_CONSOLE_FONTS_DIRS=share/consolefonts
		# The X font is installed via font.eclass instead.
		-DCMATRIX_X_FONTS_DIRS=
	)
	cmake_src_configure
}

src_install() {
	cmake_src_install
	use X && font_src_install
}

pkg_postinst() {
	use X && font_pkg_postinst
}

pkg_postrm() {
	use X && font_pkg_postrm
}
