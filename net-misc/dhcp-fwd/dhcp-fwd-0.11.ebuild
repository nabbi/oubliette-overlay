# Copyright 2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PSRC="dhcp-forwarder-${PV}"
DESCRIPTION="Forwards DHCP messages between subnets with different sublayer broadcast domains"
HOMEPAGE="https://www.nongnu.org/dhcp-fwd/"
SRC_URI="https://savannah.nongnu.org/download/${PN}/${PSRC}.tar.xz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="diet logging"

DEPEND="
	acct-group/dhcp-fwd
	acct-user/dhcp-fwd
	diet? ( dev-libs/dietlibc )"
RDEPEND="${DEPEND}"

S="${WORKDIR}/${PSRC}"

src_prepare() {
	unpack ${A}
	cd "${S}"
	eapply "${FILESDIR}/${PN}-0.8-gentoo.patch"
	eapply_user
}

src_compile() {
	local myconf="--target=${CHOST}"

	#prefers dietlibc by default
	if ! use diet ; then
		myconf="${myconf} --disable-dietlibc"
	fi

	if use logging ; then
		myconf="${myconf} --enable-logging"
	fi

}

src_configure() {
	econf ${myconf} || die
	emake || die
}

src_install() {
	emake DESTDIR="${D}" install || die
	newinitd "${FILESDIR}/dhcp-fwd.initd" dhcp-fwd
	newconfd "${FILESDIR}/dhcp-fwd.confd" dhcp-fwd
	insinto /etc
	newins contrib/dhcp-fwd.conf dhcp-fwd.conf
}
