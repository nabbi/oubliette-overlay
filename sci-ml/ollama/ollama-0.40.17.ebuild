# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake go-module systemd

DESCRIPTION="Get up and running with Llama 3, Mistral, Gemma, and other language models"
HOMEPAGE="https://ollama.com"

if [[ ${PV} == *9999* ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/ollama/ollama.git"
	LLAMA_CPP_URI="https://github.com/ggml-org/llama.cpp.git"
else
	# the llama.cpp tag is in the release's LLAMA_CPP_VERSION
	LLAMA_CPP_tag=b12257

	SRC_URI="
		https://github.com/ollama/${PN}/archive/refs/tags/v${PV}.tar.gz -> ${P}.gh.tar.gz
		https://github.com/gentoo-golang-dist/${PN}/releases/download/v${PV}/${P}-deps.tar.xz
		https://github.com/ggml-org/llama.cpp/archive/refs/tags/${LLAMA_CPP_tag}.tar.gz
			-> llama.cpp-${LLAMA_CPP_tag}.tar.gz
	"
	KEYWORDS="~amd64"
fi

LICENSE="MIT"
SLOT="0"
# GPU backends are ggml's: these flags only require ggml to be built with them
IUSE="rocm vulkan"

RESTRICT="mirror test"

DEPEND="
	acct-group/ollama
	acct-user/ollama
	>=sci-ml/ggml-0.29.0:=[rocm?,vulkan?]
"
RDEPEND="
	${DEPEND}
	net-misc/curl:=
"
BDEPEND="
	>=dev-lang/go-1.26.10
	dev-libs/stb
"

PATCHES=(
	"${FILESDIR}"/${PN}-0.31.1-ggml.patch
	"${FILESDIR}"/${PN}-0.34.2-cmake.patch
)

src_unpack() {
	if [[ ${PV} == *9999* ]]; then
		git-r3_src_unpack
		# the llama.cpp tag ollama main builds against
		LLAMA_CPP_tag=$(<"${S}/LLAMA_CPP_VERSION") || die
		LLAMA_CPP_tag=${LLAMA_CPP_tag//[[:space:]]/}
		[[ ${LLAMA_CPP_tag} == b[0-9]* ]] || die "bad LLAMA_CPP_VERSION: ${LLAMA_CPP_tag}"
		einfo "llama.cpp ${LLAMA_CPP_tag}"
		local EGIT_REPO_URI=${LLAMA_CPP_URI}
		local EGIT_CHECKOUT_DIR="${WORKDIR}/llama.cpp-${LLAMA_CPP_tag}"
		local EGIT_COMMIT=${LLAMA_CPP_tag}
		git-r3_src_unpack
		go-module_live_vendor
	else
		go-module_src_unpack
	fi
}

src_prepare() {
	cmake_src_prepare

	local llama_src="${BUILD_DIR}/_deps/llama_cpp-src"
	local llama_patch_dir="${WORKDIR}/${P}/llama/compat"

	mkdir -p "${BUILD_DIR}"/_deps || die

	ln -s "${WORKDIR}"/llama.cpp-${LLAMA_CPP_tag} "${llama_src}" || die

	# Switch to the llama.cpp source directory
	pushd "${llama_src}" > /dev/null || die
	eapply "${llama_patch_dir}"/*.patch

	# Remove vendored
	cmake_comment_add_subdirectory -f vendor stb
	rm -r vendor/stb || die
	sed -i \
		-e "s|vendor::stb ||" \
		tools/mtmd/CMakeLists.txt \
		|| die
	popd > /dev/null || die
}

src_configure() {
	# Configure Embedded local Server
	local llama_src="${BUILD_DIR}/_deps/llama_cpp-src"
	local mycmakeargs=(
		-DCMAKE_INSTALL_PREFIX="${BUILD_DIR}"
		-DOLLAMA_RUNNER_DIR=""
		-DFETCHCONTENT_SOURCE_DIR_LLAMA_CPP="${llama_src}"
		-DOLLAMA_LLAMA_CPP_SKIP_COMPAT_PATCH=ON
		-DBUILD_SHARED_LIBS=ON
		-DLLAMA_USE_SYSTEM_GGML=ON
	)
	local CMAKE_USE_DIR="${S}/llama/server"
	local BUILD_DIR="${BUILD_DIR}/llama-server-local"
	cmake_src_configure
}

src_compile() {
	local SAVE_BUILD_DIR="${BUILD_DIR}"

	# Compile Embedded Local Server
	local BUILD_DIR="${BUILD_DIR}"/llama-server-local
	local cmake_src_compile_opts=(
		--target llama-server
		--target llama-quantize
	)
	cmake_src_compile

	# Install/Stage Local Server Component
	"${CMAKE_BINARY}" \
		--install "${BUILD_DIR}" \
		--prefix "${SAVE_BUILD_DIR}" \
		--component llama-server \
		|| die "Failed to stage server component"

	# Expose CGO to Go and establish compiler optimization paths
	export CGO_ENABLED=1

	# Replicate the linker flags dynamically from your ebuild version
	local VERSION=${PVR}
	if [[ ${PV} == *9999* ]]; then
		VERSION=$(git -C "${S}" describe --tags --always --abbrev=7 | sed -e "s/^v//")
	fi
	local mygoldflags="-X github.com/ollama/ollama/version.Version=${VERSION} \
		-X github.com/ollama/ollama/server.mode=release"

	# Call the Go build engine natively with standard Gentoo flags
	ego build \
		-trimpath \
		-ldflags "${mygoldflags}" \
		-o "${BUILD_DIR}/ollama" \
		. || die "Go build failed"
}

src_install() {
	dobin "${BUILD_DIR}"/llama-server-local/ollama
	insinto usr
	doins -r "${BUILD_DIR}"/lib
	local libdir="/usr/lib/ollama"
	fperms -R +x ${libdir}

	# Symlink system GGML libraries into Ollama's expected path
	# Bug 983804
	for lib in "${EPREFIX}"/usr/$(get_libdir)/libggml*.so; do
		local libname=$(basename "${lib}")
		dosym ../../$(get_libdir)/${libname} /usr/lib/ollama/${libname}
	done

	einstalldocs

	newinitd "${FILESDIR}/ollama.init" "${PN}"
	newconfd "${FILESDIR}/ollama.confd" "${PN}"

	systemd_dounit "${FILESDIR}/ollama.service"
}

pkg_preinst() {
	keepdir /var/log/ollama
	fperms 750 /var/log/ollama
	fowners "${PN}:${PN}" /var/log/ollama
}

pkg_postinst() {
	if [[ -z ${REPLACING_VERSIONS} ]] ; then
		einfo "Quick guide:"
		einfo "\tollama serve"
		einfo "\tollama run llama3:70b"
		einfo
		einfo "See available models at https://ollama.com/library"
	fi

	if use vulkan || use rocm; then
		elog "GPU access: the ${PN} user needs the render group (/dev/dri/renderD*)"
		elog "and, for ROCm, kfd (/dev/kfd); acct-user/${PN} adds neither."
		elog "  usermod -aG render,video ${PN}"
		elog "Vulkan is on by default when ggml[vulkan] is installed; OLLAMA_VULKAN=0"
		elog "turns it off. Without cap_perfmon ollama cannot read the free VRAM and"
		elog "guesses model sizes; see capabilities in /etc/conf.d/${PN}."
		elog
		elog "AMD APU with shared memory (Ryzen AI Max, gfx1151): the GPU may only map"
		elog "what ttm allows. Raise it on the kernel command line for large models,"
		elog "e.g. ttm.pages_limit=41943040 (160 GiB in 4 KiB pages). For ROCm set"
		elog "AMDGPU_TARGETS=\"gfx1151\" for sci-ml/ggml; Vulkan (mesa radv) needs no target."
	fi

	einfo
	einfo "Ollama binds 127.0.0.1 port 11434 by default."
	einfo "Change the bind address with the OLLAMA_HOST environment variable."
	einfo "See https://docs.ollama.com/faq for more info"
	einfo
}
