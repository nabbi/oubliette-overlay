# Copyright 2022-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake udev linux-info

DESCRIPTION="Provides library functionality for FIDO 2.0"
HOMEPAGE="https://github.com/Yubico/libfido2"
SRC_URI="https://github.com/Yubico/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="BSD-2"
SLOT="0/1"
KEYWORDS="~amd64 ~arm ~arm64 ~loong ~mips ~ppc ~ppc64 ~riscv ~sparc ~x86"
IUSE="hidapi nfc smartcard static-libs test -fuzz"
REQUIRED_USE="fuzz? ( nfc )"
RESTRICT="!test? ( test )"

DEPEND="
	dev-libs/libcbor:=
	dev-libs/openssl:=
	virtual/zlib:=
	virtual/libudev:=
	hidapi? ( dev-libs/hidapi )
	smartcard? ( sys-apps/pcsc-lite )
"
RDEPEND="
	${DEPEND}
	acct-group/plugdev
"
BDEPEND="
	app-text/mandoc
	fuzz? ( llvm-core/clang )
"

PATCHES=(
	"${FILESDIR}"/${PN}-1.12.0-cmakelists.patch
	"${FILESDIR}"/${PN}-1.17.0-cbor-alloc-cap.patch
	"${FILESDIR}"/${PN}-1.17.0-fuzz-export-fido_dev_is_winhello.patch
)

pkg_pretend() {
	CONFIG_CHECK="
		~USB_HID
		~HIDRAW
	"

	check_extra_config
}

src_configure() {
	if use fuzz; then
		# -fsanitize=fuzzer (libFuzzer) is a Clang/LLVM-only sanitizer; GCC's
		# -fsanitize= family doesn't support it, so build with clang.
		export AR=llvm-ar
		export CC=clang
		export CXX=clang++
		export NM=llvm-nm
		export RANLIB=llvm-ranlib
	fi

	local mycmakeargs=(
		-DBUILD_EXAMPLES=OFF
		-DBUILD_STATIC_LIBS=$(usex static-libs)
		-DBUILD_TESTS=$(usex test)
		-DNFC_LINUX=$(usex nfc)
		-DUSE_PCSC=$(usex smartcard)
		-DUSE_HIDAPI=$(usex hidapi)
	)
	if use fuzz; then
		# enable fuzzer for testing yubico/pam-u2f
		mycmakeargs+=(
			-DFUZZ=1 -DFUZZ_LDFLAGS="-fsanitize=fuzzer"
		)
	fi

	cmake_src_configure
}

src_install() {
	cmake_src_install

	udev_newrules udev/70-u2f.rules 70-libfido2-u2f.rules
}

pkg_postinst() {
	udev_reload
}

pkg_postrm() {
	udev_reload
}
