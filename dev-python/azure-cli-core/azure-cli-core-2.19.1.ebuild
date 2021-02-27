# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{6,7,8} )

inherit distutils-r1

DESCRIPTION="Microsoft Azure Command-Line Tools Core Module"
HOMEPAGE="https://pypi.org/project/azure-cli-core"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

KEYWORDS="~amd64 ~arm ~x86"
LICENSE="MIT"
SLOT="0"

IUSE=""

RDEPEND=">=dev-python/pyopenssl-17.1[${PYTHON_USEDEP}]
	dev-python/pyjwt[${PYTHON_USEDEP}]
	dev-python/paramiko[${PYTHON_USEDEP}]
	>=dev-python/pkginfo-1.5.0.1[${PYTHON_USEDEP}]
	>=dev-python/msrestazure-0.6.4[${PYTHON_USEDEP}]
	>=dev-python/msal-extensions-0.2.2[${PYTHON_USEDEP}]
	>=dev-python/msal-1.4.3[${PYTHON_USEDEP}]
	>=dev-python/knack-0.7.2[${PYTHON_USEDEP}]
	dev-python/humanfriendly[${PYTHON_USEDEP}]
	>=dev-python/azure-cli-telemetry-1.0.6[${PYTHON_USEDEP}]
	>=dev-python/azure-mgmt-core-1.2.0[${PYTHON_USEDEP}]
	>=dev-python/azure-mgmt-resource-10.2.0[${PYTHON_USEDEP}]
	dev-python/pyperclip[${PYTHON_USEDEP}]
	dev-python/asn1crypto[${PYTHON_USEDEP}]"

DEPEND="${RDEPEND}
	dev-python/setuptools[${PYTHON_USEDEP}]"

src_prepare() {
	# user must upgrade with portage, not with azure-cli
	# https://example.org is not reliable for me
	sed -i \
		-e "s: with 'az upgrade':.:" \
		-e "s:example.org:www.linuxunderground.be:" \
		azure/cli/core/util.py || die

	eapply_user
}
