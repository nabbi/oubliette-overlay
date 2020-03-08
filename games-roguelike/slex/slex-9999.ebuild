# Copyright 2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit flag-o-matic toolchain-funcs

DESCRIPTION="SLASH'EM Extended (a SLASH'EM fork) Sadistic Levels of Endless X-Citement"
HOMEPAGE="https://github.com/SLASHEM-Extended/SLASHEM-Extended"
if [[ "${PV}" == "9999" ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/SLASHEM-Extended/SLASHEM-Extended"
else
	SRC_URI="https://github.com/SLASHEM-Extended/SLASHEM-Extended/archive/slex-${PV}.tar.gz"
fi

LICENSE="nethack"
SLOT="0"
KEYWORDS=""
IUSE=""

DEPEND="
	acct-group/gamestat
	sys-libs/ncurses:0="
RDEPEND="${DEPEND}"
BDEPEND=""

if [[ ! "${PV}" == "9999" ]]; then
	PROPERTIES="live"
	S="${WORKDIR}/SLASHEM-Extended-slex-${PV}"
fi

src_prepare() {
	# adjust pathing
	sed -i -e ":\(^PREFIX\ =\ \).*:d" sys/unix/GNUmakefile
	sed -i -e "s:\(^GAMEDIR\ =\ \).*:\1${ED}/var/games/:" sys/unix/GNUmakefile

	# include tinfo (ncurses)
	sed -i -e "s:\(-lncurses\).*:\1\ -ltinfo:" sys/unix/GNUmakefile

	# bug in make file runs compiler twice
	sed -i -e "s/^install:.*/install:/" sys/unix/GNUmakefile

	eapply "${FILESDIR}/${PN}-2.6.3-fprintf-format-security.patch"
	eapply "${FILESDIR}/${PN}-2.6.3-integer-format.patch"
	eapply_user
}

src_compile() {
	emake -f sys/unix/GNUmakefile all
}

src_install() {
	emake -f sys/unix/GNUmakefile install

	keepdir /var/games/slex/save
}

pkg_preinst() {
	fowners root:gamestat /var/games/slex /var/games/slex/save
	fperms 2770 /var/games/slex /var/games/slex/save
}
