# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_SINGLE_IMPL=1
DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="NetBox plugin for graphical floorplans of sites and locations"
HOMEPAGE="
	https://github.com/netbox-community/netbox-floorplan-plugin/
	https://pypi.org/project/netbox-floorplan-plugin/
"

# bundled: fabric.js and jQuery (MIT), htmx 1.9 (BSD-2)
LICENSE="LGPL-3+ BSD-2 MIT"
SLOT="0"
KEYWORDS="~amd64"
# Tests need a configured NetBox instance with PostgreSQL and Redis
RESTRICT="test"

RDEPEND="
	|| (
		(
			>=www-apps/netbox-4.7.0[${PYTHON_SINGLE_USEDEP}]
			<www-apps/netbox-4.8[${PYTHON_SINGLE_USEDEP}]
		)
		~www-apps/netbox-9999[${PYTHON_SINGLE_USEDEP}]
	)
"
