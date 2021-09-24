# Copyright 2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
inherit flag-o-matic toolchain-funcs

DESCRIPTION="NetHack 3.6 variant features GruntHack, SporkHack and others with custom content"
HOMEPAGE="https://nethackwiki.com/wiki/EvilHack"
if [[ "${PV}" == "9999" ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/k21971/EvilHack.git"
else
	SRC_URI="https://github.com/k21971/EvilHack/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64 ~arm ~arm64 ~hppa ~ppc ~ppc64 ~riscv ~x86"
	S="${WORKDIR}/EvilHack-${PV}"
fi

LICENSE="nethack"
SLOT="0"

RDEPEND="acct-group/gamestat
	sys-libs/ncurses:0=
	sys-devel/gdb"
DEPEND="${RDEPEND}
	"
BDEPEND="virtual/pkgconfig"

src_prepare() {
	eapply "${FILESDIR}/nethack-3.6.3-recover.patch"
	eapply_user

	cp "${FILESDIR}/evilhack-hint-tty.1" hint || die "Failed to copy hint file"

	sed -i "s:@HACKDIR@:${EPREFIX}/usr/$(get_libdir)/evilhack:" hint || die
	sed -i "s:@SHELLDIR@:${EPREFIX}/usr/bin:" hint || die
	sed -i "s:@VARDIR@:${EPREFIX}/var/games/evilhack:" hint || die
	sed -i "s:@WINTTYLIB@:$($(tc-getPKG_CONFIG) --libs ncurses):" hint || die

	sys/unix/setup.sh hint || die "Failed to run setup.sh"
}

src_compile() {

# evilhack sys/unix/hints/linux-debug
	append-cflags -I../include -DNOTPARMDECL -fno-common
	append-cflags -DDLB
	append-cflags "-DCOMPRESS=\\\"${EPREFIX}/bin/gzip\\\"" '-DCOMPRESS_EXTENSION=\".gz\"'
##	append-cflags -DGCC_WARN -Wall -Wextra -Wformat=2 #-Werror
##	append-cflags -Wimplicit -Wreturn-type -Wunused -Wswitch -Wshadow -Wwrite-strings
##	append-cflags -Wno-format-nonliteral
##	append-cflags -Wno-stringop-truncation
##	append-cflags -Wno-missing-field-initializers
##	append-cflags -Wno-format-overflow -Wno-stringop-overflow
	append-cflags -DSYSCF "-DSYSCF_FILE=\\\"${EPREFIX}/etc/evilhack.sysconf\\\"" -DSECURE
	append-cflags -DTIMED_DELAY
	append-cflags "-DHACKDIR=\\\"${EPREFIX}/usr/$(get_libdir)/evilhack\\\""
	append-cflags "-DVAR_PLAYGROUND=\\\"${EPREFIX}/var/games/evilhack\\\""
	append-cflags -DCONFIG_ERROR_SECURE=FALSE
	append-cflags -DCURSES_GRAPHICS
	append-cflags -DPANICLOG_FMT2
	append-cflags -DTTY_TILES_ESCCODES
	append-cflags -DDGAMELAUNCH
	append-cflags -DLIVELOG_ENABLE
	append-cflags -DDUMPLOG
	append-cflags -DDUMPHTML

	# Upstream still has some parallel compilation bugs
	emake -j1 all
}

src_install() {

	sed -i "s:^HACKDIR=.*:HACKDIR=/usr/$(get_libdir)/evilhack:" sys/unix/nethack.sh || die
	sed -i "s:^HACK=.*:HACK=\$HACKDIR/evilhack:" sys/unix/nethack.sh || die
	newbin sys/unix/nethack.sh evilhack

	newbin util/recover recover-evilhack

	dodir /usr/$(get_libdir)/evilhack
	for f in cmdhelp help hh history keyhelp license nhdat opthelp symbols wizhelp; do
		mv "${S}/dat/${f}" "${ED}/usr/$(get_libdir)/evilhack/${f}" || die
	done

	mv src/evilhack "${ED}/usr/$(get_libdir)/evilhack/" || die

	newman doc/nethack.6 evilhack.6
	newman doc/recover.6 recover-evilhack.6
	dodoc doc/Guidebook.txt

	insinto /etc
	newins sys/unix/sysconf evilhack.sysconf

	insinto /etc/skel
	newins "${FILESDIR}/nethack-3.6.0-nethackrc" .evilhackrc

	keepdir /var/games/evilhack/save
	keepdir /var/games/evilhack/whereis
}

pkg_preinst() {
	fowners root:gamestat /var/games/evilhack /var/games/evilhack/save /var/games/evilhack/whereis
	fperms 2770 /var/games/evilhack /var/games/evilhack/save /var/games/evilhack/whereis

	fowners root:gamestat "/usr/$(get_libdir)/evilhack/evilhack"
	fperms g+s "/usr/$(get_libdir)/evilhack/evilhack"
}

pkg_postinst() {
	cd "${EROOT}/var/games/evilhack" || die "Failed to enter ${EROOT}/var/games/evilhack directory"

	# Those files can't be created earlier because we don't want portage to wipe them during upgrades
	( umask 007 && touch livelog logfile perm record wishtracker xlogfile ) || die "Failed to create log files"

	# Instead of using a proper version header in its save files, evilhack checks for incompatibilities
	# by comparing the mtimes of save files and its own binary. This would require admin interaction even
	# during upgrades which don't change the file format, so we'll just touch the files and warn the admin
	# manually in case of compatibility issues.
	(
		shopt -s nullglob
		local saves=( bones* save/* )
		[[ -n "${saves[*]}" ]] && touch -c "${saves[@]}"
	) # non-fatal

	elog "A minimal default .evilhackrc has been placed in /etc/skel/"
	elog "The sysconf file is at /etc/evilhack.sysconf"
}
