# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Update Portage tree, installed packages, and optionally kernel"
HOMEPAGE="https://github.com/nabbi/genup"

LICENSE="GPL-3"
SLOT="0"

if [[ ${PV} == 9999 ]] ; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/nabbi/${PN}.git"
else
	KEYWORDS="~amd64 ~x86"
	SRC_URI="https://github.com/nabbi/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"
fi

RESTRICT="mirror"

RDEPEND="
	app-portage/eix
	app-portage/gentoolkit
	sys-apps/portage
	app-portage/portage-utils
"
DEPEND="${RDEPEND}"

src_prepare() {
	default

	if [[ ${PV} == 9999 ]] ; then
		local suffix
		suffix="$(git rev-parse --short HEAD)-gentoo" || die
		sed -i -e "s/^\(VERSION=\".*\)\"/\1-${suffix}\"/" genup || die
	fi
}

src_install() {
	dosbin "${PN}"
	doman "${PN}.8"

	insinto /etc/logrotate.d
	newins logrotate "${PN}"

	insinto /etc/cron.d
	newins crontab "${PN}"
}
