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
	KEYWORDS="amd64 ~arm ~x86"
fi

LICENSE="LGPL-2.1"
SLOT="0"
IUSE="berkdb ldap ipv6 logrotate"

DEPEND="
	acct-group/cicap
	acct-user/cicap
	berkdb? ( sys-libs/db:* )
	ldap? ( net-nds/openldap )
	"
RDEPEND="${DEPEND}"
BDEPEND=""

src_prepare() {
	eapply_user

	git branch --list -v | grep -e '^\*' | awk '{print $2"-"$3}'> VERSION.m4
	eautoreconf
}

src_configure() {
	econf \
		--sysconfdir=/etc/${PN} \
		--disable-dependency-tracking \
		--disable-maintainer-mode \
		--disable-static \
		--enable-large-files \
		$(use_enable ipv6) \
		$(use_with berkdb bdb) \
		$(use_with ldap)
}

src_install() {
	default

	# perfrom some cleanups of log and run dirs
	rm -r "${ED}/var" || die

	find "${ED}" -name '*.la' -delete || die

	keepdir /var/log/c-icap
	fowners cicap:cicap  /var/log/c-icap

	insinto /etc/${PN}
	doins "${FILESDIR}"/${PN}.conf

	newinitd "${FILESDIR}/${PN}-init" ${PN}
	newconfd "${FILESDIR}/${PN}-confd" ${PN}

	if use logrotate ; then
		insopts -m0644
		insinto /etc/logrotate.d
		newins "${FILESDIR}"/${PN}.logrotate ${PN}
	fi

	dodoc AUTHORS README TODO ChangeLog
}

pkg_postinst() {
	elog "To enable Squid to call the ICAP modules from a local server you should set"
	elog "the following in your squid.conf:"
	elog ""
	elog "    icap_enable on"
	elog ""
	elog "    # not strictly needed, but some modules might make use of these"
	elog "    icap_send_client_ip on"
	elog "    icap_send_client_username on"
	elog ""
	elog "    icap_service service_req reqmod_precache bypass=1 icap://localhost:1344/service"
	elog "    adaptation_access service_req allow all"
	elog ""
	elog "    icap_service service_resp respmod_precache bypass=0 icap://localhost:1344/service"
	elog "    adaptation_access service_resp allow all"
	elog ""
	elog "You obviously will have to replace \"service\" with the actual ICAP service to"
	elog "use."
}