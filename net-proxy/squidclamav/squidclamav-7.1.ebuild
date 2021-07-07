# Copyright 2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit git-r3 autotools

DESCRIPTION="SquidClamAv is a dedicated ClamAV antivirus redirector for Squid"
HOMEPAGE="https://squidclamav.darold.net/"
EGIT_REPO_URI="https://github.com/darold/squidclamav"

if [[ ${PV} == 9999 ]]; then
	EGIT_BRANCH="master"
else
	EGIT_COMMIT="v${PV}"
	KEYWORDS="amd64 ~arm ~x86"
fi

LICENSE="GPL-3"
SLOT="0"
IUSE=""

DEPEND="
	net-proxy/c-icap
	app-antivirus/clamav
	"
RDEPEND="${DEPEND}"
BDEPEND=""

src_configure() {
	econf \
		--disable-static \
		--enable-shared
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
