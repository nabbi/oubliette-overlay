# Copyright 2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="SLASH'EM Extended (a SLASH'EM fork) Sadistic Levels of Endless X-Citement"
HOMEPAGE="https://github.com/SLASHEM-Extended/SLASHEM-Extended"
if [[ "${PV}" == "9999" ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/SLASHEM-Extended/SLASHEM-Extended"
else
	SRC_URI="https://github.com/SLASHEM-Extended/SLASHEM-Extended/archive/slex-${PV}.tar.gz"
fi

LICENSE="nethack"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}"
BDEPEND=""

if [[ ! "${PV}" == "9999" ]]; then
	S="${WORKDIR}/SLASHEM-Extended-slex-${PV}"
fi

src_prepare() {
	eapply "${FILESDIR}/${PN}-2.6.0-fprintf-security.patch"
	eapply "${FILESDIR}/${PN}-2.6.0-integer-format.patch"
	eapply "${FILESDIR}/${PN}-2.6.0-ncurses-tinfo.patch"
	eapply_user
}

src_configure() {
	./sys/unix/setup.sh
}

src_compile() {
	make -f sys/unix/GNUmakefile
}

src_install() {
	make -f sys/unix/GNUmakefile install
}
