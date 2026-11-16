# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=hatchling
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="Strawberry GraphQL Django extension"
HOMEPAGE="
	https://strawberry.rocks/docs/django/
	https://github.com/strawberry-graphql/strawberry-django/
	https://pypi.org/project/strawberry-graphql-django/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
# Tests need django-guardian, django-tree-queries, factory-boy and
# pytest-snapshot, which are not packaged in ::gentoo; the GraphQL API of
# www-apps/netbox is built on this and covered by NetBox's own test suite
RESTRICT="test"

RDEPEND="
	>=dev-python/asgiref-3.8[${PYTHON_USEDEP}]
	>=dev-python/django-5.2[${PYTHON_USEDEP}]
	>=dev-python/strawberry-graphql-0.330.3[${PYTHON_USEDEP}]
"
