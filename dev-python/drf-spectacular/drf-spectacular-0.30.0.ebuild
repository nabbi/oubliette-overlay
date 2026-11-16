# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="Sane and flexible OpenAPI 3 schema generation for Django REST framework"
HOMEPAGE="
	https://drf-spectacular.readthedocs.io/
	https://github.com/tfranzel/drf-spectacular/
	https://pypi.org/project/drf-spectacular/
"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64"
# Contrib tests need django-oauth-toolkit and other DRF add-ons not in ::gentoo
RESTRICT="test"

RDEPEND="
	>=dev-python/django-2.2[${PYTHON_USEDEP}]
	>=dev-python/djangorestframework-3.10.3[${PYTHON_USEDEP}]
	>=dev-python/uritemplate-2.0.0[${PYTHON_USEDEP}]
	>=dev-python/pyyaml-5.1[${PYTHON_USEDEP}]
	>=dev-python/jsonschema-2.6.0[${PYTHON_USEDEP}]
	>=dev-python/inflection-0.3.1[${PYTHON_USEDEP}]
"
