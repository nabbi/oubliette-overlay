# Copyright 2020-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{8..10} )

inherit distutils-r1

DESCRIPTION="Milter for dkimpy; DKIM and ARC email signing and verification"
HOMEPAGE="https://launchpad.net/dkimpy-milter"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64"

RDEPEND="
	acct-user/dkimpy-milter
	dev-python/pymilter[${PYTHON_USEDEP}]
	dev-python/dkimpy[${PYTHON_USEDEP}]
	dev-python/dnspython[${PYTHON_USEDEP}]"
BDEPEND=""

python_install_all() {
	distutils-r1_python_install_all

	# installer placed files here, we use our own anyway
	rm -r "${ED}"/usr/etc || die

	#adjust systemd paths
	sed -i \
		-e 's:/usr/local/:/usr/:g' \
		-e 's:/run/:/var/run/:g' \
		"${ED}"/usr/lib/systemd/system/dkimpy-milter.service \
		|| die

	dodir /etc/dkimpy-milter

	#adjust config
	sed \
		-e 's:/run/:/var/run/:g' \
		-e 's:^UserID.*$:UserID dkimpy:' \
		"${S}"/etc/dkimpy-milter.conf \
		> "${ED}"/etc/dkimpy-milter/dkimpy-milter.conf \
		|| die

	# init.d + conf.d files
	insopts -o root -g root -m 755
	newinitd "${FILESDIR}"/${PN}.initd ${PN}

	insopts -o root -g root -m 640
	newconfd "${FILESDIR}"/${PN}.confd ${PN}

}
