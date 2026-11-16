# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_SINGLE_IMPL=1
DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="A plugin to manage custom objects in NetBox"
HOMEPAGE="
	https://github.com/netboxlabs/netbox-custom-objects/
	https://pypi.org/project/netboxlabs-netbox-custom-objects/
"

LICENSE="NetBox-Limited-Use-1.0"
SLOT="0"
KEYWORDS="~amd64"
RESTRICT="bindist mirror"

RDEPEND="
	|| (
		(
			>=www-apps/netbox-4.5.2[${PYTHON_SINGLE_USEDEP}]
			<www-apps/netbox-4.8[${PYTHON_SINGLE_USEDEP}]
		)
		~www-apps/netbox-9999[${PYTHON_SINGLE_USEDEP}]
	)
	$(python_gen_cond_dep '
		dev-python/django[${PYTHON_USEDEP}]
		dev-python/jsonschema[${PYTHON_USEDEP}]
		dev-python/packaging[${PYTHON_USEDEP}]
		dev-python/pyyaml[${PYTHON_USEDEP}]
	')
"
