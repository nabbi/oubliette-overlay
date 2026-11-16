# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=poetry
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="Template Text Parser Templates collections"
HOMEPAGE="
	https://dmulyalin.github.io/ttp_templates/
	https://github.com/dmulyalin/ttp_templates/
	https://pypi.org/project/ttp-templates/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	>=dev-python/ttp-0.10.0[${PYTHON_USEDEP}]
	>=dev-python/pydantic-2.0[${PYTHON_USEDEP}]
"
