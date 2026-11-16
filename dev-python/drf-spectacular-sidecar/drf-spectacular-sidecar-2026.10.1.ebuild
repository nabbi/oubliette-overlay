# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="Self-contained Swagger UI and Redoc builds for drf-spectacular"
HOMEPAGE="
	https://drf-spectacular.readthedocs.io/
	https://github.com/tfranzel/drf-spectacular-sidecar/
	https://pypi.org/project/drf-spectacular-sidecar/
"

# bundled: Swagger UI (Apache-2.0), Redoc (MIT)
LICENSE="BSD Apache-2.0 MIT"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	>=dev-python/django-2.2[${PYTHON_USEDEP}]
"
