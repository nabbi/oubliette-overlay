# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="Python Social Authentication, Django integration"
HOMEPAGE="
	https://github.com/python-social-auth/social-app-django/
	https://pypi.org/project/social-auth-app-django/
"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	>=dev-python/asgiref-3.8.1[${PYTHON_USEDEP}]
	>=dev-python/django-5.2[${PYTHON_USEDEP}]
	>=dev-python/social-auth-core-5.2.0[${PYTHON_USEDEP}]
	<dev-python/social-auth-core-6.0.0[${PYTHON_USEDEP}]
"

python_test() {
	"${EPYTHON}" manage.py test -v2 tests || die "Tests fail with ${EPYTHON}"
}
