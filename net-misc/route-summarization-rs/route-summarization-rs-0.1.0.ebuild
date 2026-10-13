# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# No crate dependencies
CRATES=""
RUST_MIN_VER="1.85.0"

inherit cargo

DESCRIPTION="Aggregate IPv4/IPv6 CIDR prefixes into their minimal covering set"
HOMEPAGE="https://github.com/nabbi/route-summarization-rs"

if [[ ${PV} == 9999 ]] ; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/nabbi/${PN}.git"
else
	KEYWORDS="~amd64"
	SRC_URI="https://github.com/nabbi/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
fi

LICENSE="GPL-3+"
SLOT="0"

RESTRICT="mirror"

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
	dodoc CHANGELOG.md NOTICE README.md docs/*.md
}
