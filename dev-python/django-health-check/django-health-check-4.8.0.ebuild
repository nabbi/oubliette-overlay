# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=flit_scm
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1

DESCRIPTION="Monitor the health of your Django app and its connected services"
HOMEPAGE="
	https://codingjoe.dev/django-health-check/
	https://github.com/codingjoe/django-health-check/
	https://pypi.org/project/django-health-check/
"

SRC_URI="
	https://github.com/codingjoe/django-health-check/archive/${PV}.tar.gz
		-> ${P}.gh.tar.gz
"
S=${WORKDIR}/${P}

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	>=dev-python/django-5.2[${PYTHON_USEDEP}]
	>=dev-python/dnspython-2.0.0[${PYTHON_USEDEP}]
"

BDEPEND="
	test? (
		dev-python/fakeredis[${PYTHON_USEDEP}]
		dev-python/psutil[${PYTHON_USEDEP}]
		dev-python/redis[${PYTHON_USEDEP}]
		dev-python/django-storages[${PYTHON_USEDEP}]
		dev-python/boto3[${PYTHON_USEDEP}]
		dev-python/moto[${PYTHON_USEDEP}]
	)
"

export SETUPTOOLS_SCM_PRETEND_VERSION=${PV}

EPYTEST_IGNORE=(
	# need dev-python/httpx (deprecated in ::gentoo)
	tests/contrib/test_atlassian.py
	tests/contrib/test_rss.py
)
EPYTEST_PLUGINS=( pytest-django pytest-asyncio )
distutils_enable_tests pytest

python_test() {
	# integration tests start containers (testcontainers)
	epytest -o addopts= -m "not integration"
}
