# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=7

[[ ${PV} == *9999 ]] && SCM="git-r3"
inherit eutils pam toolchain-funcs $SCM

DESCRIPTION="PAM RADIUS authentication module"
HOMEPAGE="http://www.freeradius.org/pam_radius_auth/"

if [[ ${PV} != *9999 ]]; then
	SRC_URI="ftp://ftp.freeradius.org/pub/radius/${P}.tar.gz"
else
	EGIT_REPO_URI="https://github.com/FreeRADIUS/${PN}.git"
	EGIT_BRANCH=master
fi

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="virtual/pam"
RDEPEND="${DEPEND}"

doecho() {
	echo "$@"
	"$@" || die
}

src_compile() {
	# using the Makefile would require patching it to work properly, so
	# rather simply re-create it here.

	pammod_hide_symbols
	doecho $(tc-getCC) ${CFLAGS} -shared -fPIC ${LDFLAGS} src/*.c -lpam -o pam_radius_auth.so
}

src_install() {
	dopammod pam_radius_auth.so

	insopts -m600
	insinto /etc/raddb
	doins "${FILESDIR}"/server

	dodoc README.rst Changelog USAGE
}

pkg_postinst() {
	elog "Before you can use this you'll have to add RADIUS servers to /etc/raddb/server."
	elog "The usage of pam_radius_auth module is explained in /usr/share/doc/${PF}/USAGE."
}
