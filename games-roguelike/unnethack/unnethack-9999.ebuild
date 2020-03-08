# Copyright 2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="fork of NetHack features more randomnessm levels challenges fun than vanilla"
HOMEPAGE="https://unnethack.wordpress.com"
if [[ "${PV}" == "9999" ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/UnNetHack/UnNetHack"
else
	SRC_URI="https://github.com/UnNetHack/UnNetHack/archive/${PV}.tar.gz"
fi

LICENSE="nethack"
SLOT="0"
KEYWORDS=""
IUSE=""

DEPEND="
	acct-user/nethack
	acct-group/gamestat
	sys-libs/ncurses:0="
RDEPEND="${DEPEND}"
BDEPEND=""

if [[ "${PV}" == "9999" ]]; then
	PROPERTIES="live"
fi

if [[ ! "${PV}" == "9999" ]]; then
	S="${WORKDIR}/UnNetHack-${PV}"
fi

#src_prepare() {
#	eapply_user
#}
src_configure() {
	econf \
		--with-owner=nethack \
		--with-group=gamestat
}

#src_compile() {
#	emake
#}

#src_install() {
#	emake -f sys/unix/GNUmakefile install
#}
