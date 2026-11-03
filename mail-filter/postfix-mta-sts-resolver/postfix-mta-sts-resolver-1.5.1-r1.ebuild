# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..15} )

inherit distutils-r1 systemd

DESCRIPTION="MTA-STS (RFC 8461) TLS policy daemon for Postfix, via socketmap"
HOMEPAGE="
	https://github.com/Snawoot/postfix-mta-sts-resolver/
	https://pypi.org/project/postfix-mta-sts-resolver/
"

# The PyPI sdist lacks the tests' reference data
SRC_URI="
	https://github.com/Snawoot/postfix-mta-sts-resolver/archive/refs/tags/v${PV}.tar.gz
		-> ${P}.gh.tar.gz
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE="redis sqlite uvloop"

RDEPEND="
	acct-group/mta-sts
	acct-user/mta-sts
	>=dev-python/aiodns-1.1.1[${PYTHON_USEDEP}]
	>=dev-python/aiohttp-3.4.4[${PYTHON_USEDEP}]
	>=dev-python/pyyaml-3.12[${PYTHON_USEDEP}]
	redis? ( >=dev-python/redis-4.2.0[${PYTHON_USEDEP}] )
	sqlite? ( >=dev-python/aiosqlite-0.10.0[${PYTHON_USEDEP}] )
	uvloop? ( >=dev-python/uvloop-0.11.0[${PYTHON_USEDEP}] )
"
BDEPEND="
	test? (
		dev-python/aiosqlite[${PYTHON_USEDEP}]
	)
"

EPYTEST_PLUGINS=( pytest-asyncio pytest-timeout )
distutils_enable_tests pytest

EPYTEST_IGNORE=(
	# upstream runs these against dnsmasq serving the *.loc test zones,
	# nginx with generated certificates and tinyproxy
	tests/test_proactive_fetcher.py
	tests/test_resolver.py
	tests/test_responder.py
	tests/test_responder_expiration.py
	tests/test_responder_nosni.py
	tests/test_responder_strict.py
	tests/test_responder_volatile.py
	# the event_loop fixture, gone since pytest-asyncio 1.0
	tests/test_asdnotify.py
)

python_test() {
	# conftest.py checks that uvloop is in use exactly when TOXENV says so
	local -x TOXENV=py$(usex uvloop -uvloop '')
	# the redis and postgres caches need running servers
	epytest -k "not redis and not postgres"
}

src_install() {
	distutils-r1_src_install

	newinitd "${FILESDIR}"/mta-sts.initd mta-sts
	newconfd "${FILESDIR}"/mta-sts.confd mta-sts
	systemd_dounit "${FILESDIR}"/mta-sts.service

	insinto /etc
	doins "${FILESDIR}"/mta-sts-daemon.yml
}

pkg_postinst() {
	if [[ -z ${REPLACING_VERSIONS} ]]; then
		elog "Point Postfix at the daemon (main.cf), then start mta-sts:"
		elog "  smtp_tls_policy_maps = socketmap:inet:127.0.0.1:8461:postfix"
		elog "A domain's own DANE policy should come first (a texthash map"
		elog "before the socketmap): the daemon answers 'secure' for any"
		elog "domain with an MTA-STS policy, which would override 'dane'."
		elog "While mta-sts is stopped, Postfix defers outbound mail."
	fi
}
