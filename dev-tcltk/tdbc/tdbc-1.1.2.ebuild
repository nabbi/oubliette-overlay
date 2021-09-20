# Copyright 2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

MY_PN="TDBC"
#TDBC - 1.1.2 2020-07-09 commit version
MY_PV="4e6b72e13b"
#TEA tclconfig - 2020-07-03 commit version
TEA_V="fff5880706"
MY_P=${MY_PN}-${MY_PV}

DESCRIPTION="Tcl Database Connectivity Core"
HOMEPAGE="http://tdbc.tcl.tk/"
SRC_URI="http://tdbc.tcl.tk/index.cgi/tarball/${MY_PV}/${MY_P}.tar.gz
	https://core.tcl.tk/tclconfig/tarball/${TEA_V}/TEA+%28tclconfig%29+Source+Code-${TEA_V}.tar.gz"

LICENSE="tcltk"
SLOT="0"
KEYWORDS="amd64 ~hppa ~ia64 ~mips ~ppc ~x86 ~amd64-linux ~x86-linux"

RDEPEND="
	>=dev-lang/tcl-8.6
	"
DEPEND="${RDEPEND}"

S="${WORKDIR}/${MY_PN}"

src_unpack() {
	#this is ugly. tclconfig is packaged seperatly from tdbc
	unpack ${A}
	ln -s "${WORKDIR}/TDBC-${MY_PV}" ${MY_PN}
	ln -s "${WORKDIR}/TEA__tclconfig__Source_Code-${TEA_V}" ${MY_PN}/tclconfig
}
