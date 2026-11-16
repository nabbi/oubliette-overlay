# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_SINGLE_IMPL=1
DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="NetBox plugin for managing Access Control Lists (ACLs)"
HOMEPAGE="
	https://github.com/netbox-community/netbox-acls/
	https://pypi.org/project/netbox-acls/
"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	|| (
		(
			>=www-apps/netbox-4.7.0[${PYTHON_SINGLE_USEDEP}]
			<www-apps/netbox-4.8[${PYTHON_SINGLE_USEDEP}]
		)
		~www-apps/netbox-9999[${PYTHON_SINGLE_USEDEP}]
	)
"
