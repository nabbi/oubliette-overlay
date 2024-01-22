# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake-multilib multibuild

DESCRIPTION="The C++ Actor Framework (CAF)"
HOMEPAGE="https://www.actor-framework.org/"
SRC_URI="https://github.com/actor-framework/actor-framework/archive/${PV}.tar.gz
	-> ${P}.tar.gz"
LICENSE="BSD"
SLOT="0/18.2"
KEYWORDS="~amd64 ~x86"
IUSE="debug doc examples +openssl static-libs test tools"

RDEPEND="
	examples? (
		net-misc/curl dev-libs/protobuf:=
		dev-qt/qtcore:5 )
	openssl? ( dev-libs/openssl:0=[${MULTILIB_USEDEP},static-libs?] )"

DEPEND="${RDEPEND}"

BDEPEND="doc? ( app-text/doxygen[dot]
	app-shells/bash:0
	dev-python/sphinx
	dev-python/sphinx-rtd-theme )"

RESTRICT="!test? ( test )"

S="${WORKDIR}/actor-framework-${PV}"

PATCHES=(
	"${FILESDIR}"/${PN}-use-stable-version.patch
)

multilib_src_configure() {
	local mycmakeargs=(
		-DBUILD_SHARED_LIBS="$(usex static-libs no yes)"
		-DCAF_ENABLE_ACTOR_PROFILER="$(usex debug)"
		-DCAF_ENABLE_OPENSSL_MODULE="$(usex openssl)"
		-DCAF_ENABLE_RUNTIME_CHECKS="$(usex debug)"
		-DCAF_LOG_LEVEL="$(usex debug DEBUG QUIET)"
		-DLIBRARY_OUTPUT_PATH="$(get_libdir)"
	)

	if multilib_is_native_abi; then
		mycmakeargs+=(
			-DCAF_ENABLE_CURL_EXAMPLES="$(usex examples)"
			-DCAF_ENABLE_EXAMPLES="$(usex examples)"
			-DCAF_ENABLE_PROTOBUF_EXAMPLES="$(usex examples)"
			-DCAF_ENABLE_TESTING="$(usex test)"
			-DCAF_ENABLE_TOOLS="$(usex tools)"
		)
		else
		mycmakeargs+=(
			-DCAF_ENABLE_CURL_EXAMPLES=no
			-DCAF_ENABLE_EXAMPLES=no
			-DCAF_ENABLE_PROTOBUF_EXAMPLES=no
			-DCAF_ENABLE_TESTING=no
			-DCAF_ENABLE_TOOLS=no
		)
	fi

	cmake_src_configure
}

multilib_src_compile() {
	cmake_src_compile

	if multilib_is_native_abi && use doc; then
			#cmake_build -C doc doc
			doxygen "${S}"/Doxyfile || die "doxygen failed"
			sphinx-build "${S}"/manual "${S}"/manual/html || die "sphinx failed"
	fi
}

multilib_src_test() {
	if multilib_is_native_abi; then
		local libdir libs
		libdir="$(get_libdir)"
		libs="${BUILD_DIR}/libcaf_core/${libdir}"
		libs="${libs}:${BUILD_DIR}/libcaf_io/${libdir}"

		use openssl && libs="${libs}:${BUILD_DIR}/libcaf_openssl/${libdir}"

		einfo "LD_LIBRARY_PATH is set to ${libs}"
		LD_LIBRARY_PATH="${libs}" cmake_src_test
	fi
}

multilib_src_install() {
	cmake_src_install

	if multilib_is_native_abi && use doc; then
		pwd
		docinto api
		dodoc -r html/*
		docinto manual
		dodoc -r "${S}"/manual/html/*
	fi
}
