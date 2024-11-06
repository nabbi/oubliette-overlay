# Copyright 2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit toolchain-funcs

DESCRIPTION="Swap endianness of a cram filesystem (cramfs)"
HOMEPAGE="https://github.com/julijane/cramfsswap"
if [[ ${PV} == 9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/nabbi/${PN}.git"
	EGIT_BRANCH="void-write"
fi

LICENSE="GPL-2"
SLOT="0"

RDEPEND="${DEPEND}"

#S="${WORKDIR}/cramfs-tools-${PV}"

src_compile() {
	emake CFLAGS="${CFLAGS}" CC="$(tc-getCC)" debian
}

src_install() {
	into /
	dosbin cramfsswap
	dodoc README
}
