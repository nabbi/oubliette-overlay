# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit multilib

#2020-06-23
CODE=ea8fd0700d

DESCRIPTION="Collection of utility modules for Tk, and a companion to Tcllib"
HOMEPAGE="http://www.tcl.tk/software/tklib"
SRC_URI="https://core.tcl-lang.org/tklib/tarball/${CODE}/Tk+Library+Source+Code-${CODE}.tar.gz -> ${P}.tar.gz"

SLOT="0"
KEYWORDS="amd64 ~x86"
LICENSE="BSD"
IUSE="doc"

RDEPEND="
	dev-lang/tk:0
	dev-tcltk/tcllib"
DEPEND="${RDEPEND}"

src_unpack() {
	unpack ${A}
	ln -s "${WORKDIR}/Tk_Library_Source_Code-${CODE}" ${P}
}

src_compile() {
	default
	use doc && emake doc
}

src_install() {
	HTML_DOCS=
	if use doc; then
		HTML_DOCS=doc/html/*
	fi
	default
	dodoc DESCRIPTION.txt
	dosym ${PN}${PV} /usr/$(get_libdir)/${PN}

	mv "${ED}"/usr/share/man/mann/datefield{,-${PN}}.n || die
	mv "${ED}"/usr/share/man/mann/menubar{,-${PN}}.n || die
	#mv "${ED}"/usr/bin/dia{,-${PN}} || die
}
