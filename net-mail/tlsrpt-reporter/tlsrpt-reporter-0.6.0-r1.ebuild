# Copyright 2025-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=hatchling
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 optfeature systemd tmpfiles

DESCRIPTION="Collector, fetcher and report generator for SMTP TLS Reporting (RFC 8460)"
HOMEPAGE="https://github.com/sys4/tlsrpt-reporter"
SRC_URI="https://github.com/sys4/${PN}/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="~amd64"
IUSE="+man +postfix"

RDEPEND="
	acct-group/tlsrpt-reporter
	acct-user/tlsrpt-reporter
	$(python_gen_impl_dep sqlite)
	postfix? ( acct-group/postfix )
"
BDEPEND="man? ( dev-ruby/asciidoctor )"

PATCHES=( "${FILESDIR}"/${P}-invalid-datagram.patch )

DOCS=( CHANGELOG.md README.md RELEASE_NOTES.md contrib/docker/MULTI_COLLECTOR_REPORTING.md )

distutils_enable_tests unittest

# Where the collector listens. With USE=postfix this is the location
# Postfix's TLSRPT_README recommends: under the queue directory, so the
# same smtp_tlsrpt_socket_name works with and without chroot.
_tlsrpt_socket() {
	if use postfix; then
		echo /var/spool/postfix/run/tlsrpt/tlsrpt.sock
	else
		echo /run/tlsrpt-reporter/tlsrpt-collectd.sock
	fi
}

src_compile() {
	distutils-r1_src_compile
	use man && emake -C doc
}

src_install() {
	distutils-r1_src_install
	use man && doman doc/*.1

	local socket=$(_tlsrpt_socket) group=tlsrpt-reporter
	use postfix && group=postfix

	sed -e "s|@SOCKET@|${socket}|" "${FILESDIR}"/${PN}-r1.cfg \
		> "${T}"/${PN}.cfg || die
	sed -e "s|@GROUP@|${group}|" "${FILESDIR}"/tlsrpt-collectd.confd \
		> "${T}"/tlsrpt-collectd.confd || die

	insinto /etc/tlsrpt-reporter
	newins "${T}"/${PN}.cfg ${PN}.cfg

	newinitd "${FILESDIR}"/tlsrpt-collectd.initd tlsrpt-collectd
	newinitd "${FILESDIR}"/tlsrpt-reportd.initd tlsrpt-reportd
	newconfd "${T}"/tlsrpt-collectd.confd tlsrpt-collectd
	newconfd "${FILESDIR}"/tlsrpt-reportd.confd tlsrpt-reportd

	systemd_newunit "${FILESDIR}"/tlsrpt-collectd-r1.service tlsrpt-collectd.service
	systemd_newunit "${FILESDIR}"/tlsrpt-reportd-r1.service tlsrpt-reportd.service

	{
		echo "d /var/lib/tlsrpt-reporter 0751 tlsrpt-reporter tlsrpt-reporter -"
		echo "d /var/log/tlsrpt-reporter 0751 tlsrpt-reporter tlsrpt-reporter -"
		use postfix && echo "d /var/spool/postfix/run 0755 root root -"
		# setgid: the socket inherits the MTA's group
		echo "d ${socket%/*} 2750 tlsrpt-reporter ${group} -"
	} > "${T}"/${PN}.tmpfiles || die
	newtmpfiles "${T}"/${PN}.tmpfiles ${PN}.conf

	insinto /etc/logrotate.d
	newins "${FILESDIR}"/${PN}.logrotate ${PN}
}

pkg_postinst() {
	tmpfiles_process ${PN}.conf

	if [[ -z ${REPLACING_VERSIONS} ]]; then
		elog "Set organization_name, contact_info and sender_address in"
		elog "/etc/tlsrpt-reporter/tlsrpt-reporter.cfg: they go out in every"
		elog "report, and tlsrpt-reportd will not start under OpenRC while"
		elog "they are EXAMPLE.COM."
		if use postfix; then
			elog
			elog "To have Postfix report to the collector:"
			elog "  postconf -e smtp_tlsrpt_enable=yes \\"
			elog "    smtp_tlsrpt_socket_name=run/tlsrpt/tlsrpt.sock"
			elog "  postfix reload"
		else
			elog
			elog "The collector listens on $(_tlsrpt_socket); put your MTA's"
			elog "delivery agent user in the tlsrpt-reporter group, or set"
			elog "TLSRPT_SOCKET_GROUP in /etc/conf.d/tlsrpt-collectd (OpenRC)"
			elog "and the tmpfiles entry (systemd) to its group."
		fi
		elog
		elog "Then enable tlsrpt-collectd and tlsrpt-reportd; tlsrpt-collectd"
		elog "starts before the MTA."
	fi

	# The ::gentoo config shipped this line; CONFIG_PROTECT keeps it.
	local cfg=${EROOT}/etc/tlsrpt-reporter/tlsrpt-reporter.cfg
	if grep -Eqs '^[[:space:]]*fetchers[[:space:]]*=[[:space:]]*tlsrpt-fetcher[[:space:]]*$' "${cfg}"; then
		ewarn "${cfg} runs tlsrpt-fetcher without --config_file, so the"
		ewarn "fetcher does not find the collector's database and every report"
		ewarn "comes out empty. Change it to:"
		ewarn "  fetchers = tlsrpt-fetcher --config_file /etc/tlsrpt-reporter/tlsrpt-reporter.cfg"
	fi

	if use postfix && has_version "mail-mta/postfix[-tlsrpt]"; then
		ewarn "mail-mta/postfix is built without USE=tlsrpt and will not"
		ewarn "report anything to the collector. Rebuild it with USE=tlsrpt."
	fi

	# Any MTA's sendmail will do; virtual/mta itself is rarely installed.
	if [[ ! -x ${EROOT}/usr/sbin/sendmail ]]; then
		elog "tlsrpt-reportd sends reports to mailto: destinations through"
		elog "/usr/sbin/sendmail; install an MTA (virtual/mta) for that."
	fi
	optfeature "uploading reports to https: destinations" net-misc/curl
}
