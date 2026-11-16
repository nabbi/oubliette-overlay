# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="Support for many storage backends in Django"
HOMEPAGE="
	https://github.com/jschneier/django-storages/
	https://pypi.org/project/django-storages/
"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64"
# S3 tests use the moto<5 API (mock_s3); Azure, GCS and Dropbox SDKs are not in ::gentoo
RESTRICT="test"

RDEPEND="
	>=dev-python/django-3.2[${PYTHON_USEDEP}]
"
