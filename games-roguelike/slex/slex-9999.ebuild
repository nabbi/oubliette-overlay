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
	sed -i -e "/^PREFIX\ =\ .*/d" sys/unix/GNUmakefile
	sed -i -e "s:\(^GAMEDIR\ =\ \).*:\1${ED}/var/games/slex:" sys/unix/GNUmakefile
	sed -i -e "s:\(^VARDIR\ =\ \).*:\1${ED}/var/games/slex:" sys/unix/GNUmakefile

	# include tinfo (ncurses)
	sed -i -e "s:\(-lncurses\).*:\1\ -ltinfo:" sys/unix/GNUmakefile

	# bug in make file runs compiler twice
	sed -i -e "s/^install:.*/install:/" sys/unix/GNUmakefile

	# upstream patched out proper FHS support when adding code for PUBLIC_SERVER
	# this adjusts both FILE_AREA_* occurances
	# https://github.com/SLASHEM-Extended/SLASHEM-Extended/commit/64f480857ee34d7b1f7479318bb4c8b34e45dbc5
	sed -i -e "s:\(^#define\ FILE_AREA_VAR\).*:\1\t\"/var/games/slex/\":" include/unixconf.h
	sed -i -e "s:\(^#define\ FILE_AREA_SAVE\).*:\1\t\"/var/games/slex/save/\":" include/unixconf.h
	sed -i -e "s:\(^#define\ FILE_AREA_SHARE\).*:\1\t\"/usr/share/games/slex/\":" include/unixconf.h
	sed -i -e "s:\(^#define\ FILE_AREA_UNSHARE\).*:\1\t\"/usr/$(get_libdir)/games/slex/\":" include/unixconf.h
	sed -i -e "s:\(^#define\ FILE_AREA_DOC\).*:\1\t\"/usr/share/doc/slex/\":" include/unixconf.h
	sed -i -e "s:\(^#define\ FILE_AREA_BONES\).*:\1\t\"/var/games/slex/\":" include/unixconf.h
	sed -i -e "s:\(^#define\ FILE_AREA_LEVL\).*:\1\t\"/var/games/slex/\":" include/unixconf.h

	eapply "${FILESDIR}/${PN}-2.6.3-fprintf-format-security.patch"
	eapply "${FILESDIR}/${PN}-2.6.3-integer-format.patch"
	eapply_user
}

src_compile() {
	emake -f sys/unix/GNUmakefile all
}

src_install() {
	emake -f sys/unix/GNUmakefile install

#	mv "${ED}/var/games/slex/nhdat" "${ED}/var/games/slex/license" "${ED}/usr/$(get_libdir)/slex/" || die "Failed to move lib files"
#	mv "${ED}/var/games/slex/slex" "${ED}/usr/bin/" || die "Faile to move bin files"

	keepdir /var/games/slex/save
}

pkg_preinst() {
	fowners root:gamestat /var/games/slex /var/games/slex/save
	fperms 2770 /var/games/slex /var/games/slex/save
}

pkg_postinst() {
	cd /var/games/slex
	fowners root:gamestat slex livelog logfile perm record xlogfile
	fperms g+s /var/games/slex/slex
}
