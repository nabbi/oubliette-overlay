# Copyright 2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit git-r3 autotools

DESCRIPTION="an implementation of an ICAP server written in C"
HOMEPAGE="http://c-icap.sourceforge.net/"
EGIT_REPO_URI="https://github.com/c-icap/c-icap-server"

if [[ ${PV} == 9999 ]]; then
	EGIT_BRANCH="master"
else
	EGIT_COMMIT="C_ICAP_${PV}"
	KEYWORDS="amd64"
fi

LICENSE="LGPL-2.1"
SLOT="0"

DEPEND="
	acct-group/cicap
	acct-user/cicap
	"
RDEPEND="${DEPEND}"
BDEPEND=""

src_prepare() {
	eapply_user

	git branch --list -v | grep -e '^\*' | awk '{print $2"-"$3}'> VERSION.m4
	eautoreconf
}

src_install() {
	default

	# perfrom some cleanups
	rm -r "${ED}/var" || die

	keepdir /var/log/c-icap
	fowners cicap:cicap  /var/log/c-icap

	insinto /etc/
	doins "${FILESDIR}"/${PN}.conf

	doinitd "${FILESDIR}"/${PN}
}
