# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_SINGLE_IMPL=1
DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="Custom Scripts for NetBox"
HOMEPAGE="
	https://netbox-community.github.io/netbox-scripts/
	https://github.com/netbox-community/netbox-scripts/
	https://pypi.org/project/netbox-scripts/
"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"
# Tests need a configured NetBox instance with PostgreSQL and Redis
RESTRICT="test"

RDEPEND="
	|| (
		(
			>=www-apps/netbox-4.7.5[${PYTHON_SINGLE_USEDEP}]
			<www-apps/netbox-4.8[${PYTHON_SINGLE_USEDEP}]
		)
		~www-apps/netbox-9999[${PYTHON_SINGLE_USEDEP}]
	)
	$(python_gen_cond_dep '
		dev-python/django-pgware[${PYTHON_USEDEP}]
	')
"
