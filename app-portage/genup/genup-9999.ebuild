# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Update Portage tree, all installed packages, and kernel"
HOMEPAGE="https://github.com/nabbi/genup"

LICENSE="GPL-3"
SLOT="0"
if [[ ${PV} == 9999* ]] ; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/nabbi/${PN}"
else
	KEYWORDS="~amd64 ~x86"
	SRC_URI="https://github.com/nabbi/${PB}/archive/${PV}.tar.gz"
fi

RESTRICT="mirror"

DEPEND="
	app-portage/eix
	app-portage/gentoolkit
"
src_install () {
	dosbin "${PN}"
	doman "${PN}.8"

	insinto /etc/logrotate.d
	newins "logrotate" genup

	insinto /etc/cron.d
	newins "crontab" genup
}
