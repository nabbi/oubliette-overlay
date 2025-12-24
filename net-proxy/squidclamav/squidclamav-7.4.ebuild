# Copyright 2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="SquidClamAv is a dedicated ClamAV antivirus redirector for Squid"
HOMEPAGE="https://squidclamav.darold.net/"

if [[ ${PV} == 9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/darold/squidclamav"
	EGIT_BRANCH="master"
else
	SRC_URI="https://github.com/darold/squidclamav/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="amd64 ~arm ~x86"
fi

LICENSE="GPL-3"
SLOT="0"
IUSE=""

DEPEND="
	net-proxy/c-icap
	app-antivirus/clamav
	app-arch/libarchive
	"
RDEPEND="${DEPEND}"
BDEPEND=""

src_configure() {
	econf \
		--disable-dependency-tracking \
		--disable-maintainer-mode \
		--disable-static \
		--enable-shared \
		--with-c-icap \
		--with-libarchive
}

src_install() {
	default

	find "${ED}" -name '*.la' -delete || die
}

pkg_postinst() {
	elog "To enable the service, you should add this to your c-icap.conf file:"
	elog ""
	elog "    Service clamav squidclamav.so"
	elog ""
	elog "And then this to squid.conf (for a local ICAP server):"
	elog ""
	elog "    icap_enable on"
	elog ""
	elog "    # not strictly needed, but useful for special access"
	elog "    icap_send_client_ip on"
	elog "    icap_send_client_username on"
	elog ""
	elog "    icap_service clamav respmod_precache bypass=0 icap://localhost:1344/clamav"
	elog "    adaptation_access clamav allow all"
}
