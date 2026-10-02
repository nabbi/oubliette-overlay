# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{11..15} )
inherit cmake python-single-r1

DESCRIPTION="The Zeek Network Security Monitor"
HOMEPAGE="https://zeek.org"

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
	static-libs tcmalloc +btest +tools +zeekctl +zeromq"

RDEPEND="
	debug? ( dev-debug/gdb )
	dev-libs/openssl:0=
	net-libs/libpcap
	virtual/zlib:0=
	curl? ( net-misc/curl )
	geoip2? ( dev-libs/libmaxminddb:0= )
	ipsumdump? ( net-analyzer/ipsumdump[ipv6?] )
	jemalloc? ( dev-libs/jemalloc:0= )
	kerberos? ( virtual/krb5 )
	python? ( ${PYTHON_DEPS}
		$(python_gen_cond_dep '>=dev-python/pybind11-2.6.1[${PYTHON_USEDEP}]')
	)
	sendmail? ( virtual/mta )
	tcmalloc? ( dev-util/google-perftools )
	tools? (
		$(python_gen_cond_dep '
			dev-python/gitpython[${PYTHON_USEDEP}]
			dev-python/semantic-version[${PYTHON_USEDEP}]
		')
	)
	zeromq? ( >=net-libs/zeromq-4.3.0 )"

DEPEND="${RDEPEND}"

BDEPEND=">=dev-lang/swig-3.0
	>=sys-devel/bison-2.5"

REQUIRED_USE="tools? ( python )
	zeekctl? ( python )
	python? ( ${PYTHON_REQUIRED_USE} )"

PATCHES=(
	"${FILESDIR}"/${PN}-8.0.10-do-not-strip-broker-binary.patch
	"${FILESDIR}"/${PN}-8.0.10-gentoo-qa-fixes.patch
)

if [[ ! ${PV} == 9999 ]]; then
	S="${WORKDIR}/${MY_P}"
fi

src_prepare() {
	if use python; then
		sed -i 's:.*/3rdparty/pybind11/.*:if(DISABLE_PYTHON_BINDINGS):' \
			auxil/broker/CMakeLists.txt || die
		# The above pybind11-submodule-availability check is a single line in
		# auxil/broker/CMakeLists.txt, but the same substring also appears as
		# part of a two-line target_include_directories() call in
		# bindings/python/CMakeLists.txt (an -I flag for the vendored
		# submodule, which Gentoo doesn't check out). A line-based sed there
		# would delete only the first physical line, leaving the second
		# line's arguments orphaned outside any command -- a cmake parse
		# error. Splice the two lines together instead, dropping just the
		# vendored include path and keeping ${Python_INCLUDE_DIRS}.
		perl -0777 -pe 's#\$\{CMAKE_CURRENT_SOURCE_DIR\}/3rdparty/pybind11/include/\s*\n\s*##' \
			-i auxil/broker/bindings/python/CMakeLists.txt || die
	fi

	if ! use static-libs; then
		sed -i 's:add_library(paraglob STATIC:add_library(paraglob SHARED:' \
			auxil/paraglob/src/CMakeLists.txt || die
		sed -i 's:DESTINATION lib:DESTINATION ${INSTALL_LIB_DIR}:' \
			auxil/paraglob/src/CMakeLists.txt || die
	fi

	if ! use kerberos; then
		eapply "${FILESDIR}/${PN}-8.0.10-disable-kerberos.patch"
	fi

	if [[ ${PV} == 9999 ]]; then
		sed -i "s/$/_$(git rev-parse --short HEAD)-gentoo/" VERSION || die
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
		-DINSTALL_ZEEK_CLIENT=$(usex tools)
		-DDISABLE_PYTHON_BINDINGS=$(usex python no yes)
		-DDISABLE_JAVASCRIPT=yes
		-DENABLE_CLUSTER_BACKEND_ZEROMQ=$(usex zeromq)
		-DPython_EXECUTABLE="${PYTHON}"
		-DZEEK_ETC_INSTALL_DIR="/etc/${PN}"
		-DZEEK_STATE_DIR="/var/lib"
		-DPY_MOD_INSTALL_DIR="$(python_get_sitedir)"
		-DBINARY_PACKAGING_MODE=true
		-DBUILD_SHARED_LIBS=ON
		-DINSTALL_ZKG=$(usex tools)
	)

	use debug && use tcmalloc && mycmakeargs+=( -DENABLE_PERFTOOLS_DEBUG=yes )
	use zeekctl && mycmakeargs+=(
		-DZEEK_LOG_DIR="/var/log/${PN}"
		-DZEEK_SPOOL_DIR="/var/spool/${PN}"
	)

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
	sed -i 's:FLAGS\ =\(.*\);:FLAGS =\1 :' "${BUILD_DIR}/build.ninja" || die
}

src_install() {
	cmake_src_install

	use python && python_optimize "${D}"/usr/$(get_libdir)/zeek/python

	keepdir /var/log/${PN} /var/spool/${PN}/{tmp,brokerstore}
	use tools && keepdir /var/lib/zkg

	# Make sure local config does not get overwritten on reinstalls
	mv "${ED}"/usr/share/zeek/site "${ED}"/etc/zeek/ || die

	# set config paths
	if use zeekctl; then
		sed -i "s:^SitePolicyScripts.*$:SitePolicyScripts = /etc/zeek/site/local.zeek:" \
			"${ED}"/etc/zeek/zeekctl.cfg || die
	fi
	if use tools; then
		sed -i "s:^state_dir.*$:state_dir = /var/lib/zkg:" "${ED}"/etc/zeek/zkg/config || die
	fi
}
