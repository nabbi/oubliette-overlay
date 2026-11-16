# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_SINGLE_IMPL=1
DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="NetBox Labs, Diode NetBox plugin"
HOMEPAGE="
	https://github.com/netboxlabs/diode-netbox-plugin/
	https://pypi.org/project/netboxlabs-diode-netbox-plugin/
"

LICENSE="NetBox-Limited-Use-1.0"
SLOT="0"
KEYWORDS="~amd64"
RESTRICT="bindist mirror"

RDEPEND="
	|| (
		(
			>=www-apps/netbox-4.7.0[${PYTHON_SINGLE_USEDEP}]
			<www-apps/netbox-4.8[${PYTHON_SINGLE_USEDEP}]
		)
		~www-apps/netbox-9999[${PYTHON_SINGLE_USEDEP}]
	)
	$(python_gen_cond_dep '
		dev-python/certifi[${PYTHON_USEDEP}]
		>=dev-python/grpcio-1.76.0[${PYTHON_USEDEP}]
		>=dev-python/protobuf-5.28.1[${PYTHON_USEDEP}]
	')
"
