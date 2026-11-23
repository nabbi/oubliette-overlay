# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

CRATES="
	adler2@2.0.1
	autocfg@1.5.1
	bitflags@2.13.2
	bytemuck@1.25.2
	byteorder-lite@0.1.0
	cfg-if@1.0.5
	crc32fast@1.5.5
	errno@0.3.14
	fdeflate@0.3.7
	flate2@1.1.11
	gethostname@1.1.0
	image@0.25.10
	libc@0.2.191
	linux-raw-sys@0.12.1
	miniz_oxide@0.8.9
	miniz_oxide@0.9.1
	moxcms@0.8.1
	num-traits@0.2.19
	png@0.18.1
	pxfm@0.1.30
	rustix@1.1.6
	simd-adler32@0.3.10
	windows-link@0.2.1
	windows-sys@0.61.2
	x11rb@0.14.0
	x11rb-protocol@0.14.0
	zeroize@1.9.1
	zlib-rs@0.6.8
	zune-core@0.5.3
	zune-jpeg@0.5.15
"
RUST_MIN_VER="1.88.0"

inherit cargo

DESCRIPTION="X11 screen locker with software ARGB cursor and animated console theme"
HOMEPAGE="https://github.com/nabbi/alock-rs"

if [[ ${PV} == 9999 ]] ; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/nabbi/${PN}.git"
else
	KEYWORDS="~amd64"
	SRC_URI="
		https://github.com/nabbi/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz
		${CARGO_CRATE_URIS}
	"
fi

LICENSE="MIT"
# Dependent crate licenses
LICENSE+=" Apache-2.0 ZLIB"
SLOT="0"

RESTRICT="mirror"

DEPEND="sys-libs/pam"
RDEPEND="${DEPEND}"

QA_FLAGS_IGNORED="usr/bin/alock-rs"

src_unpack() {
	if [[ ${PV} == 9999 ]] ; then
		git-r3_src_unpack
		cargo_live_src_unpack
	else
		cargo_src_unpack
	fi
}

src_configure() {
	# Upstream release profile strips; leave that to portage
	export CARGO_PROFILE_RELEASE_STRIP=false
	cargo_src_configure
}

src_install() {
	cargo_src_install
	dodoc README.md docs/*.md
}
