# Copyright 2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

MY_P=${MY_PN}-${MY_PV}

DESCRIPTION="provides UDP sockets for Tcl"
HOMEPAGE="https://core.tcl-lang.org/tcludp/home"
SRC_URI=""

LICENSE="tcltk"
SLOT="0"
#KEYWORDS="~amd64 ~x86"

BDEPEND="
	>=dev-lang/tcl-8.6:0
	dev-vcs/fossil
	"

RDEPEND="
	>=dev-lang/tcl-8.6
	"
DEPEND="${RDEPEND}"

PROPERTIES="live"

S="${WORKDIR}/${PN}"

src_unpack() {
	local distdir="${PORTAGE_ACTUAL_DISTDIR:-${DISTDIR}}"
	local fossil="tcludp.fossil"
	local url="https://core.tcl-lang.org/tcludp"

	addwrite "${distdir}"
	mkdir -p "${distdir}/fossil-src/${PN}" || die

	mkdir "${WORKDIR}/${PN}" || die
	pushd "${WORKDIR}/${PN}" > /dev/null || die
	if [[ ! -f "${distdir}/fossil-src/${PN}/sqlite.fossil" ]]; then
		einfo fossil clone --verbose ${url} ${fossil}
		fossil clone --verbose ${url} ${fossil} || die
		echo
	else
		cp -p "${distdir}/fossil-src/${PN}/sqlite.fossil" . || die
		einfo fossil pull --repository ${fossil} --verbose ${url}
		fossil pull --repository ${fossil} --verbose ${url} || die
		echo
	fi
	mv ${fossil} "${distdir}/fossil-src/${PN}" || die
	einfo fossil open --quiet ${fossil}
	fossil open --quiet "${distdir}/fossil-src/${PN}/${fossil}" || die
	echo
	popd > /dev/null || die
}

src_configure() {
	econf \
		--with-tcl="${EPREFIX}/usr/$(get_libdir)"
}

src_install() {
	default
}
