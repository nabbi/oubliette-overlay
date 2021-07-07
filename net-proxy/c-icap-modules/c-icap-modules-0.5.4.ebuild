# Copyright 2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit git-r3 autotools

DESCRIPTION="an implementation of an ICAP server written in C"
HOMEPAGE="http://c-icap.sourceforge.net/"
EGIT_REPO_URI="https://github.com/c-icap/c-icap-modules"

if [[ ${PV} == 9999 ]]; then
	EGIT_BRANCH="master"
else
	EGIT_COMMIT="C_ICAP_MODULES_${PV}"
	KEYWORDS="amd64 ~arm ~x86"
fi

LICENSE="LGPL-2.1"
SLOT="0"
IUSE="berkdb clamav"

DEPEND="
	berkdb? ( sys-libs/db:* )
	clamav? ( app-antivirus/clamav )
	net-proxy/c-icap
	"
RDEPEND="${DEPEND}"
BDEPEND=""

src_prepare() {
	eapply_user

	git branch --list -v | grep -e '^\*' | awk '{print $2"-"$3}'> VERSION.m4
	eautoreconf
}

src_configure() {
	econf --sysconfdir=/etc/c-icap \
		--disable-dependency-tracking \
		--disable-maintainer-mode \
		--disable-static \
		$(use_with berkdb bdb) \
		$(use_with clamav)
}

src_install() {
	default

	dodoc AUTHORS README ChangeLog

	find "${ED}" -name '*.la' -delete || die
}
