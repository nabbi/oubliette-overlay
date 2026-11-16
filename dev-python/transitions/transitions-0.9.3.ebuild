# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1

DESCRIPTION="Lightweight, object-oriented Python state machine implementation"
HOMEPAGE="
	https://github.com/pytransitions/transitions/
	https://pypi.org/project/transitions/
"

SRC_URI="
	https://github.com/pytransitions/transitions/archive/${PV}.tar.gz
		-> ${P}.gh.tar.gz
"
S=${WORKDIR}/${P}

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	dev-python/six[${PYTHON_USEDEP}]
"

BDEPEND="
	test? (
		dev-python/dill[${PYTHON_USEDEP}]
		dev-python/mock[${PYTHON_USEDEP}]
	)
"

EPYTEST_IGNORE=(
	# pycodestyle, mypy, etc.
	tests/test_codestyle.py
)
EPYTEST_PLUGINS=()
distutils_enable_tests pytest
