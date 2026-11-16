# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1

DESCRIPTION="Connection Pool for Psycopg"
HOMEPAGE="
	https://www.psycopg.org/psycopg3/docs/advanced/pool.html
	https://github.com/psycopg/psycopg/
	https://pypi.org/project/psycopg-pool/
"

SRC_URI="
	https://github.com/psycopg/psycopg/archive/pool-${PV}.tar.gz
		-> ${P}.gh.tar.gz
"
S=${WORKDIR}/psycopg-pool-${PV}

LICENSE="LGPL-3"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	>=dev-python/typing-extensions-4.6[${PYTHON_USEDEP}]
"

BDEPEND="
	test? (
		dev-python/anyio[${PYTHON_USEDEP}]
	)
"

BDEPEND+=" test? ( >=dev-db/postgresql-8.1[server(+)] dev-python/psycopg:0[${PYTHON_USEDEP}] )"
EPYTEST_PLUGINS=( anyio )
distutils_enable_tests pytest

python_compile() {
	cd psycopg_pool || die
	distutils-r1_python_compile
	cd .. || die
}

src_test() {
	initdb -D "${T}"/pgsql || die
	pg_ctl -w -D "${T}"/pgsql start -o "-h '' -k '${T}'" || die
	createdb -h "${T}" test || die
	local -x PSYCOPG_TEST_DSN="host=${T} dbname=test"
	distutils-r1_src_test
	pg_ctl -w -D "${T}"/pgsql stop || die
}

python_test() {
	epytest -p no:randomly -m "not timing and not slow and not flakey" tests/pool
}
