# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit toolchain-funcs udev

DESCRIPTION="A program to read and control device brightness"
HOMEPAGE="https://github.com/Hummer12007/brightnessctl"

if [[ ${PV} == *9999* ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/Hummer12007/brightnessctl.git"
else
	SRC_URI="https://github.com/Hummer12007/brightnessctl/archive/${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64 ~arm64"
fi

LICENSE="MIT"
SLOT="0"
IUSE="elogind systemd udev"
REQUIRED_USE="?? ( elogind systemd )"

DEPEND="
	elogind? ( sys-auth/elogind )
	systemd? ( sys-apps/systemd )
	udev? ( virtual/udev )
"
RDEPEND="${DEPEND}"
BDEPEND="
	elogind? ( virtual/pkgconfig )
	systemd? ( virtual/pkgconfig )
"

src_prepare() {
	default

	# Upstream's Makefile still hardcodes -std=c99, which fails to build
	# brightnessctl.c with modern gcc/glibc (same issue worked around for
	# 0.5.1 via files/brightnessctl-0.5.1-Makefile.patch).
	sed -i '/^CFLAGS/s/-std=c99 //' Makefile || die
}

src_configure() {
	local myconf=(
		--prefix="${EPREFIX}/usr"
		--udev-dir="$(get_udevdir)"
		$(use_enable udev)
	)

	if use systemd; then
		myconf+=( --enable-logind --dbus-provider=systemd )
	elif use elogind; then
		myconf+=( --enable-logind --dbus-provider=elogind )
	else
		myconf+=( --disable-logind )
	fi

	tc-export CC
	./configure "${myconf[@]}" || die
}

src_compile() {
	emake
}

src_install() {
	emake DESTDIR="${D}" install
	dodoc README.md
}

pkg_postinst() {
	use udev && udev_reload
}

pkg_postrm() {
	use udev && udev_reload
}
