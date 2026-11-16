# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_SINGLE_IMPL=1
DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="A NetBox plugin to create Topology maps"
HOMEPAGE="
	https://github.com/netbox-community/netbox-topology-views/
	https://pypi.org/project/netbox-topology-views/
"

# bundled: vis-network (Apache-2.0 or MIT), device icons (CC-BY-SA-4.0)
LICENSE="Apache-2.0 CC-BY-SA-4.0 || ( Apache-2.0 MIT )"
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
