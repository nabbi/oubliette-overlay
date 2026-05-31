# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

if [[ ${PV} == 9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/nabbi/yubico-pam.git"
	EGIT_BRANCH="nabbi"
else
	SRC_URI="https://github.com/nabbi/yubico-pam/archive/refs/tags/${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64 ~x86"
	S="${WORKDIR}/yubico-pam-${PV}"
fi

inherit autotools pam

DESCRIPTION="Library for authenticating against PAM with a Yubikey"
HOMEPAGE="https://github.com/nabbi/yubico-pam"

LICENSE="BSD"
SLOT="0"
IUSE="ldap test"
RESTRICT="!test? ( test )"

RDEPEND="
	sys-libs/pam
	sys-auth/libyubikey
	>=sys-auth/ykclient-2.15
	>=sys-auth/ykpers-1.6
	ldap? ( net-nds/openldap:= )"
DEPEND="${RDEPEND}
	app-text/asciidoc
	test? ( dev-perl/Net-LDAP-Server )"

src_prepare() {
	default
	eautoreconf
}

src_configure() {
	#challenge response could be optional but that seems horribly dangerous to me
	local myeconfargs=(
		--with-cr
		--with-pam-dir="$(getpam_mod_dir)"
		$(use_with ldap)
	)
	econf "${myeconfargs[@]}"
}

src_install() {
	default
	dodoc doc/*
	find "${D}" -name '*.la' -delete || die
}
