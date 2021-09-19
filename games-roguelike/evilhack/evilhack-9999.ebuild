# Copyright 2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit desktop flag-o-matic toolchain-funcs

DESCRIPTION="NetHack 3.6 variant features GruntHack, SporkHack and others with custom content"
HOMEPAGE="https://nethackwiki.com/wiki/EvilHack"
if [[ "${PV}" == "9999" ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/k21971/EvilHack.git"
else
	SRC_URI=""
fi

LICENSE="nethack"
SLOT="0"
KEYWORDS=""
IUSE=""

RDEPEND="acct-group/gamestat
	sys-libs/ncurses:0=
	sys-devel/gdb"
DEPEND="${RDEPEND}
	"
BDEPEND="virtual/pkgconfig"

if [[ ! "${PV}" == "9999" ]]; then
	PROPERTIES="live"
	S="${WORKDIR}/evilhack-${PV}"
fi

src_prepare() {
	eapply "${FILESDIR}/nethack-3.6.3-recover.patch"
#	eapply "${FILESDIR}/evilhack-wintty.patch"
	eapply_user

	cp "${FILESDIR}/nethack-3.6.3-hint-tty" hint || die "Failed to copy hint file"
	sys/unix/setup.sh hint || die "Failed to run setup.sh"
}

src_compile() {
	append-cflags -I../include -DDLB -DSECURE -DTIMED_DELAY -DVISION_TABLES -DDUMPLOG -DSCORE_ON_BOTL
	append-cflags -DLIVELOG_ENABLE
	append-cflags '-DCOMPRESS=\"${EPREFIX}/bin/gzip\"' '-DCOMPRESS_EXTENSION=\".gz\"'
	append-cflags "-DHACKDIR=\\\"${EPREFIX}/usr/$(get_libdir)/evilhack\\\"" "-DVAR_PLAYGROUND=\\\"${EPREFIX}/var/games/evilhack\\\""
	append-cflags "-DDEF_PAGER=\\\"${PAGER}\\\""
	append-cflags -DSYSCF "-DSYSCF_FILE=\\\"${EPREFIX}/etc/evilhack.sysconf\\\""

	#use X && append-cflags -DX11_GRAPHICS -DUSE_XPM

	LOCAL_MAKEOPTS=(
		CC="$(tc-getCC)" CFLAGS="${CFLAGS}" LFLAGS="${LDFLAGS}"
		WINTTYLIB="$($(tc-getPKG_CONFIG) --libs ncurses)"
		HACKDIR="${EPREFIX}/usr/$(get_libdir)/evilhack" INSTDIR="${D%/}${EPREFIX}/usr/$(get_libdir)/evilhack"
		SHELLDIR="${D%/}${EPREFIX}/usr/bin" VARDIR="${D%/}${EPREFIX}/var/games/evilhack"
		)

	emake "${LOCAL_MAKEOPTS[@]}" evilhack recover Guidebook spec_levs

	# Upstream still has some parallel compilation bugs
	emake -j1 "${LOCAL_MAKEOPTS[@]}" all
}

src_install() {
	emake "${LOCAL_MAKEOPTS[@]}" install

	mv "${ED}/usr/$(get_libdir)/evilhack/recover" "${ED}/usr/bin/recover-evilhack" || die "Failed to move recover-evilhack"

	newman doc/nethack.6 evilhack.6
	newman doc/recover.6 recover-evilhack.6
	dodoc doc/Guidebook.txt

	insinto /etc
	newins sys/unix/sysconf evilhack.sysconf

	insinto /etc/skel
	newins "${FILESDIR}/nethack-3.6.0-nethackrc" .evilhackrc

	rm -r "${ED}/var/games/evilhack" || die "Failed to clean var/games/evilhack"
	keepdir /var/games/evilhack/save
}

pkg_preinst() {
	fowners root:gamestat /var/games/evilhack /var/games/evilhack/save
	fperms 2770 /var/games/evilhack /var/games/evilhack/save

	fowners root:gamestat "/usr/$(get_libdir)/evilhack/evilhack"
	fperms g+s "/usr/$(get_libdir)/evilhack/evilhack"
}

pkg_postinst() {
	cd "${EROOT}/var/games/evilhack" || die "Failed to enter ${EROOT}/var/games/evilhack directory"

	# Those files can't be created earlier because we don't want portage to wipe them during upgrades
	( umask 007 && touch logfile perm record xlogfile ) || die "Failed to create log files"

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
