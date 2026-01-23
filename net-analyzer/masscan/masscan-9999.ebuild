# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit toolchain-funcs

DESCRIPTION="Mass IP port scanner"
HOMEPAGE="https://github.com/robertdavidgraham/masscan"

if [[ ${PV} == 9999 ]] ; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/robertdavidgraham/masscan.git"
	EGIT_BRANCH="master"
	KEYWORDS=""
else
	SRC_URI="https://github.com/robertdavidgraham/masscan/archive/${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64 ~x86"
fi

SLOT="0"
LICENSE="AGPL-3"

RDEPEND="net-libs/libpcap"

src_prepare() {
	default

	sed -i \
		-e '/$(CC)/s!$(CFLAGS)!$(LDFLAGS) $(CFLAGS)!g' \
		-e '/^SYS/s|gcc|$(CC)|g' \
		-e '/^CFLAGS =/{s,=,+=,;s,-g -ggdb,,;s,-O3,,;}' \
		-e '/^CC =/d' \
		Makefile || die

	# Tarballs: no .git, so prevent broken/incorrect git versioning
	if [[ ${PV} != 9999 ]]; then
		sed -i -e '/^GITVER :=/s!= .*=!=!g' Makefile || die
	fi

	tc-export CC
}

src_install() {
	dobin bin/masscan

	insinto /etc/masscan
	doins data/exclude.conf
	doins "${FILESDIR}"/masscan.conf

	dodoc doc/bot.html *.md
	doman doc/masscan.8
}
