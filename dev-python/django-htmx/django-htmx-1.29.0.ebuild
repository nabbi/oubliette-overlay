# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=uv-build
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1

DESCRIPTION="Extensions for using Django with htmx"
HOMEPAGE="
	https://django-htmx.readthedocs.io/
	https://github.com/adamchainz/django-htmx/
	https://pypi.org/project/django-htmx/
"

SRC_URI="
	https://github.com/adamchainz/django-htmx/archive/${PV}.tar.gz
		-> ${P}.gh.tar.gz
"
S=${WORKDIR}/${P}

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	>=dev-python/asgiref-3.6[${PYTHON_USEDEP}]
	>=dev-python/django-5.2[${PYTHON_USEDEP}]
"

EPYTEST_PLUGINS=( pytest-django )
distutils_enable_tests pytest
