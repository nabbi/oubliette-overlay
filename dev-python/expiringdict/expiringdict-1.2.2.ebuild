# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..15} )

inherit distutils-r1

DESCRIPTION="Dictionary with auto-expiring values for caching purposes"
HOMEPAGE="
	https://github.com/mailgun/expiringdict/
	https://pypi.org/project/expiringdict/
"
# The PyPI sdist has no tests
SRC_URI="
	https://github.com/mailgun/expiringdict/archive/refs/tags/v${PV}.tar.gz
		-> ${P}.gh.tar.gz
"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"

BDEPEND="
	test? (
		$(python_gen_cond_dep '
			dev-python/dill[${PYTHON_USEDEP}]
		' 3.{12..14})
	)
"

PATCHES=(
	"${FILESDIR}"/${P}-no-nose.patch
)

EPYTEST_PLUGINS=()
distutils_enable_tests pytest

EPYTEST_DESELECT=(
	# expects the OrderedDict repr of Python < 3.12
	tests/expiringdict_test.py::test_repr
)

python_test() {
	local tests=( tests/expiringdict_test.py )
	# the pickling tests need dill, which has no python3.15 yet
	python_has_version "dev-python/dill[${PYTHON_USEDEP}]" &&
		tests+=( tests/expiringdict_extended_test.py )
	epytest "${tests[@]}"
}
