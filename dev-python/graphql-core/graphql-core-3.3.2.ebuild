# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=uv-build
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="Python port of GraphQL.js, the GraphQL reference implementation"
HOMEPAGE="
	https://graphql-core-3.readthedocs.io/
	https://github.com/graphql-python/graphql-core/
	https://pypi.org/project/graphql-core/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

BDEPEND="
	test? (
		dev-python/anyio[${PYTHON_USEDEP}]
		dev-python/pytest-describe[${PYTHON_USEDEP}]
		dev-python/pytest-timeout[${PYTHON_USEDEP}]
	)
"

EPYTEST_IGNORE=(
	# pytest-benchmark is not packaged in ::gentoo
	tests/benchmarks
)
EPYTEST_PLUGINS=( anyio pytest-asyncio pytest-describe pytest-timeout )
distutils_enable_tests pytest

python_test() {
	epytest -o addopts=
}
