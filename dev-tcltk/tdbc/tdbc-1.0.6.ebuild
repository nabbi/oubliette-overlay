# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=5

inherit eutils virtualx
MY_PN="TDBC"
#This is the 1.0.6 commit version
MY_PV="2386d26cfb"
MY_P=${MY_PN}-${MY_PV}

DESCRIPTION="Tcl Database Connectivity"
HOMEPAGE="http://tdbc.tcl.tk/"
SRC_URI="http://tdbc.tcl.tk/index.cgi/tarball/${MY_PV}/${MY_P}.tar.gz
	https://core.tcl.tk/tclconfig/tarball/0a530cebd7/TEA+%28tclconfig%29+Source+Code-0a530cebd7.tar.gz"

LICENSE="OTHER"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~hppa ~ia64 ~mips ~ppc ~x86 ~amd64-fbsd ~x86-fbsd ~amd64-linux ~x86-linux ~x86-macos"

RDEPEND="
	>=dev-lang/tcl-8.6
	"
DEPEND="${RDEPEND}"

S="${WORKDIR}/${MY_PN}"

src_unpack() {
	unpack ${A}
	echo ${WORKDIR}
	ln -s "${WORKDIR}/TDBC-2386d26cfb" ${MY_PN}
	ln -s "${WORKDIR}/TEA__tclconfig__Source_Code-0a530cebd7" ${MY_PN}/tclconfig
}

#src_compile() {
#	make all || die
#}
