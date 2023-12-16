# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{10..12} )
inherit cmake python-single-r1

DESCRIPTION="The Zeek Network Security Monitor"
HOMEPAGE="https://www.zeek.org"

if [[ ${PV} == 9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/zeek/zeek"
else
	MY_P="${PN}-${PV/_/-}"
	MY_PV="${PV/_/-}"
	SRC_URI="https://github.com/zeek/zeek/releases/download/v${MY_PV}/${MY_P}.tar.gz"
	KEYWORDS="~amd64 ~x86"
fi

LICENSE="BSD"
SLOT="0"
IUSE="curl debug geoip2 ipsumdump ipv6 jemalloc kerberos +python sendmail
	static-libs tcmalloc +btest +tools +zeekctl caf nodejs"

RDEPEND="
	caf? ( >=dev-libs/caf-0.18.2:0= )
	debug? ( sys-devel/gdb )
	dev-libs/openssl:0=
	net-libs/libpcap
	sys-libs/zlib:0=
	curl? ( net-misc/curl )
	geoip2? ( dev-libs/libmaxminddb:0= )
	ipsumdump? ( net-analyzer/ipsumdump[ipv6?] )
	jemalloc? ( dev-libs/jemalloc:0= )
	kerberos? ( virtual/krb5 )
	nodejs? ( net-libs/nodejs )
	python? ( ${PYTHON_DEPS}
		$(python_gen_cond_dep '>=dev-python/pybind11-2.6.1[${PYTHON_USEDEP}]')
	)
	sendmail? ( virtual/mta )
	tcmalloc? ( dev-util/google-perftools )
	tools? (
		dev-python/semantic-version
		dev-python/GitPython )"

DEPEND="${RDEPEND}"

BDEPEND=">=dev-lang/swig-3.0
	>=sys-devel/bison-2.5"

REQUIRED_USE="zeekctl? ( python )
	python? ( ${PYTHON_REQUIRED_USE} )"

PATCHES=(
	"${FILESDIR}"/${PN}-3.2-do-not-strip-broker-binary.patch
	"${FILESDIR}"/${PN}-6.1.0-gentoo-qa-fixes.patch
)

if [[ ! ${PV} == 9999 ]]; then
	S="${WORKDIR}/${MY_P}"
fi

src_prepare() {
	if use caf; then
		rm -rf auxil/broker/caf || die
		rm -rf auxil/broker/caf-incubator || die
	fi

	if use python; then
		sed -i 's:.*/3rdparty/pybind11/.*:if(DISABLE_PYTHON_BINDINGS):' \
			auxil/broker/CMakeLists.txt || die
		sed -i 's:.*/3rdparty/pybind11/.*::' \
			auxil/broker/bindings/python/CMakeLists.txt || die
	fi

	if ! use static-libs; then
		sed -i 's:add_library(paraglob STATIC:add_library(paraglob SHARED:' \
			auxil/paraglob/src/CMakeLists.txt
		sed -i 's:DESTINATION lib:DESTINATION ${INSTALL_LIB_DIR}:' \
			auxil/paraglob/src/CMakeLists.txt
	fi

	if ! use kerberos; then
		eapply "${FILESDIR}/${PN}-6.1.0-disable-kerberos.patch"
	fi

	if [[ ${PV} == 9999 ]]; then
		suffix="$(git rev-parse --short HEAD)-gentoo"
		sed -i "s/$/_$(git rev-parse --short HEAD)-gentoo/" VERSION	|| die "version sed failed"
	fi

	cmake_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-DENABLE_DEBUG=$(usex debug)
		-DENABLE_JEMALLOC=$(usex jemalloc)
		-DENABLE_PERFTOOLS=$(usex tcmalloc)
		-DENABLE_STATIC=$(usex static-libs)
		-DBUILD_STATIC_BROKER=$(usex static-libs)
		-DBUILD_STATIC_BINPAC=$(usex static-libs)
		-DINSTALL_ZEEKCTL=$(usex zeekctl)
		-DINSTALL_AUX_TOOLS=$(usex tools)
		-DINSTALL_ZEEK_ARCHIVER=$(usex tools)
		-DDISABLE_PYTHON_BINDINGS=$(usex python no yes)
		-DPYTHON_EXECUTABLE="${PYTHON}"
		-DZEEK_ETC_INSTALL_DIR="/etc/${PN}"
		-DZEEK_STATE_DIR="/var/lib"
		-DPY_MOD_INSTALL_DIR="$(python_get_sitedir)"
		-DBINARY_PACKAGING_MODE=true
		-DBUILD_SHARED_LIBS=ON
		-DINSTALL_ZKG=ON
	)

	use debug && use tcmalloc && mycmakeargs+=( -DENABLE_PERFTOOLS_DEBUG=yes )
	use zeekctl && mycmakeargs+=(
		-DZEEK_LOG_DIR="/var/log/${PN}"
		-DZEEK_SPOOL_DIR="/var/spool/${PN}"
	)
	use caf &&  mycmakeargs+=( -DCAF_ROOT="${EPREFIX}/usr/include/caf" )

	if ! use btest; then
		mycmakeargs+=(
			-DBROKER_DISABLE_TESTS=true
			-DBROKER_DISABLE_DOC_EXAMPLES=true
			-DINSTALL_BTEST=false
			-DINSTALL_BTEST_PCAPS=false
			-DENABLE_ZEEK_UNIT_TESTS=false
		)
	fi

	cmake_src_configure

	# TODO: cmake target_compile_options appends priv_cflags without removing semicolon
	# submodule impacted https://github.com/simonfxr/fiber
	sed -iE 's:FLAGS\ =\(.*\);:FLAGS =\1 :' "${BUILD_DIR}/build.ninja" || die
}

src_install() {
	cmake_src_install

	use python && python_optimize \
		"${D}"/usr/"$(get_libdir)"/zeek/python/ \
		"${D}"/usr/"$(get_libdir)"/zeek/python/broker \
		"${D}"/usr/"$(get_libdir)"/zeek/python/zeekctl/ZeekControl \
		"${D}"/usr/"$(get_libdir)"/zeek/python/zeekctl/plugins

	keepdir \
		/var/log/"${PN}" \
		/var/spool/"${PN}"/{tmp,brokerstore} \
		/var/lib/zkg

	# Make sure local config does not get overwritten on reinstalls
	mv "${ED}"/usr/share/zeek/site "${ED}"/etc/zeek/ || die

	# set config paths
	sed -i "s:^SitePolicyScripts.*$:SitePolicyScripts = /etc/zeek/site/local.zeek:" "${ED}"/etc/zeek/zeekctl.cfg || die
	sed -i "s:^state_dir.*$:state_dir = /var/lib/zkg:" "${ED}"/etc/zeek/zkg/config || die
}
