# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit autotools multilib systemd

DESCRIPTION="Open source ARC implementation"
HOMEPAGE="https://github.com/trusteddomainproject/OpenARC"
if [[ ${PV} == 9999 ]]; then
	inherit git-r3
	EGIT_BRANCH="develop"
	EGIT_REPO_URI="https://github.com/trusteddomainproject/OpenARC.git"
else
	SRC_URI="https://github.com/trusteddomainproject/OpenARC/archive/rel-${PN}-${PV//./-}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~ia64 ~ppc ~ppc64 ~sparc ~x86"
	S=${WORKDIR}/OpenARC-rel-${PN}-${PV//./-}
fi

LICENSE="BSD"
SLOT="0/3"  # 1.4 has API breakage with 1.3, yet uses same soname
IUSE="static-libs"

DEPEND="
	mail-filter/libmilter:="
RDEPEND="${DEPEND}
	acct-user/openarc"

PATCHES=(
	"${FILESDIR}/openarc-issue137.patch"
)

src_prepare() {
	default

	if [[ ${PV} == 9999 ]]; then
		sed -i -e "s:v%s\\\n:v%s $(git rev-parse --short HEAD)-${EGIT_BRANCH}-gentoo\\\n:" openarc/openarc.c || die
	fi

	eautoreconf
}

src_configure() {
	econf \
		$(use_enable static-libs static)
}

src_install() {
	default
	find "${ED}" -name '*.la' -type f -delete || die

	newinitd "${FILESDIR}"/openarc.initd openarc
	newconfd "${FILESDIR}"/openarc.confd openarc
	systemd_dounit "${FILESDIR}/${PN}.service"

	dodir /etc/openarc

	# create config file
	# OpenARC does not have a default port, we picked 8895 to avoid conflicts with OpenDKIM and OpenDMARC
	sed \
		-e 's:^# UserID\s.*:UserID openarc:' \
		-e "s:^# PidFile\s.*:PidFile ${EPREFIX}/var/run/openarc/openarc.pid:" \
		-e 's/^Socket\s.*/Socket inet:8895@localhost/' \
		-e "s:^KeyFile\s.*:KeyFile ${EPREFIX}/etc/openarc/example.private:" \
		-e "s:^# InternalHosts\s.*:InternalHosts ${EPREFIX}/etc/openarc/internalhosts:" \
		-e "s:^FinalReceiver:#FinalReceiver:" \
		"${S}"/openarc/openarc.conf.sample \
		> "${ED}"/etc/openarc/openarc.conf \
		|| die
}
