# Copyright 2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit autotools

DESCRIPTION="an implementation of an ICAP server written in C"
HOMEPAGE="http://c-icap.sourceforge.net/"

if [[ ${PV} == 9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/c-icap/c-icap-modules"
	EGIT_BRANCH="master"
else
	SRC_URI="https://github.com/c-icap/c-icap-modules/archive/refs/tags/C_ICAP_MODULES_${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="amd64 ~arm ~x86"
	S="${WORKDIR}/c-icap-modules-C_ICAP_MODULES_${PV}"
fi

LICENSE="LGPL-2.1"
SLOT="0"
IUSE="berkdb"

DEPEND="
	berkdb? ( sys-libs/db:* )
	app-antivirus/clamav
	net-proxy/c-icap
	"
RDEPEND="${DEPEND}"
BDEPEND=""

src_prepare() {
	eapply_user

	if [[ ${PV} == 9999 ]]; then
		git branch --list -v | grep -e '^\*' | awk '{print $2"-"$3}'> VERSION.m4 || die
	else
		echo ${PV} > VERSION.m4 || die
	fi

	eautoreconf
}

src_configure() {
	econf --sysconfdir=/etc/c-icap \
		--disable-dependency-tracking \
		--disable-maintainer-mode \
		--disable-static \
		--with-c-icap \
		--with-clamav \
		$(use_with berkdb bdb)
}

src_install() {
	dodir /etc/c-icap

	default

	dodoc AUTHORS README ChangeLog

	find "${ED}" -name '*.la' -delete || die
}
