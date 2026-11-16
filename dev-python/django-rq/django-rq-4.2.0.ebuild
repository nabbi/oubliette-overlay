# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=hatchling
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1

DESCRIPTION="An app that provides django integration for RQ (Redis Queue)"
HOMEPAGE="
	https://python-rq.org/patterns/django/
	https://github.com/rq/django-rq/
	https://pypi.org/project/django-rq/
"

SRC_URI="
	https://github.com/rq/django-rq/archive/v$(ver_cut 1-2).tar.gz
		-> ${P}.gh.tar.gz
"
S=${WORKDIR}/${PN}-$(ver_cut 1-2)

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	>=dev-python/django-4.2[${PYTHON_USEDEP}]
	>=dev-python/redis-3.5[${PYTHON_USEDEP}]
	>=dev-python/rq-2.6.1[${PYTHON_USEDEP}]
"

BDEPEND="
	test? (
		dev-python/django-redis[${PYTHON_USEDEP}]
		dev-python/prometheus-client[${PYTHON_USEDEP}]
	)
"

BDEPEND+=" test? ( dev-db/redis )"
EPYTEST_PLUGINS=( pytest-django )
distutils_enable_tests pytest

src_test() {
	local port=16379
	redis-server --port ${port} --daemonize yes --pidfile "${T}"/redis.pid \
		--dir "${T}" || die
	local -x REDIS_HOST=localhost REDIS_PORT=${port}
	distutils-r1_src_test
	kill "$(<"${T}"/redis.pid)" || die
}
