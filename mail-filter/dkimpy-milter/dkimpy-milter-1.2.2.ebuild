# Copyright 2020-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYPI_NO_NORMALIZE=1
PYTHON_COMPAT=( python3_{10..12} )

inherit distutils-r1 pypi

DESCRIPTION="Domain Keys Identified Mail (DKIM) signing/verifying milter for Postfix/Sendmail"
HOMEPAGE="
	https://launchpad.net/dkimpy-milter/
	https://pypi.org/project/dkimpy-milter/
"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~x86"

RDEPEND="
	acct-user/dkimpy-milter
	dev-python/pymilter[${PYTHON_USEDEP}]
	dev-python/dkimpy[${PYTHON_USEDEP}]
	dev-python/dnspython[${PYTHON_USEDEP}]"

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
		"${S}"/etc/dkimpy-milter.conf \
		> "${ED}"/etc/dkimpy-milter/dkimpy-milter.conf \
		|| die

	# init.d + conf.d files
	insopts -o root -g root -m 755
	newinitd "${FILESDIR}"/${PN}.initd ${PN}

	insopts -o root -g root -m 640
	newconfd "${FILESDIR}"/${PN}.confd ${PN}

}
