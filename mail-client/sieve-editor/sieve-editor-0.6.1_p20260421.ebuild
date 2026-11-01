# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop pax-utils xdg

# Upstream has not tagged since 0.6.1 (2021-11); master carries years of
# fixes (TLS SNI, SHA512, dark mode, Thunderbird import, Electron bumps).
SIEVE_COMMIT="f08b3172ca6c1f5b016426305cbbc845d2374fb0"

# Upstream pins electron ^35 (EOL 2025-09).  The renderer runs with
# nodeIntegration and without contextIsolation, so stay on a supported
# Chromium.  The main process only uses long-stable APIs.
ELECTRON_PV="45.2.1"
# Versions match upstream's package-lock.json.
BOOTSTRAP_PV="5.3.3"
CODEMIRROR_PV="5.65.18"

DESCRIPTION="Standalone editor for server-side Sieve mail filters (ManageSieve)"
HOMEPAGE="https://github.com/thsmi/sieve"
SRC_URI="
	https://github.com/thsmi/sieve/archive/${SIEVE_COMMIT}.tar.gz -> ${P}.gh.tar.gz
	https://registry.npmjs.org/bootstrap/-/bootstrap-${BOOTSTRAP_PV}.tgz
	https://registry.npmjs.org/codemirror/-/codemirror-${CODEMIRROR_PV}.tgz
	amd64? (
		https://github.com/electron/electron/releases/download/v${ELECTRON_PV}/electron-v${ELECTRON_PV}-linux-x64.zip
	)
	arm64? (
		https://github.com/electron/electron/releases/download/v${ELECTRON_PV}/electron-v${ELECTRON_PV}-linux-arm64.zip
	)
"
S="${WORKDIR}/sieve-${SIEVE_COMMIT}"

LICENSE="AGPL-3 MIT"
# From www-client/chromium for the bundled Electron runtime
LICENSE+=" Apache-2.0 Apache-2.0-with-LLVM-exceptions BSD BSD-2 Base64 Boost-1.0 CC-BY-3.0 CC-BY-4.0 Clear-BSD FFT2D FTL"
LICENSE+=" IJG ISC LGPL-2 LGPL-2.1 MPL-1.1 MPL-2.0 Ms-PL PSF-2 SGI-B-2.0 SSLeay SunSoft Unicode-3.0"
LICENSE+=" Unicode-DFS-2015 Unlicense UoI-NCSA ZLIB libtiff openssl"
# From net-libs/nodejs
LICENSE+=" Apache-1.1 BlueOak-1.0.0"
SLOT="0"
KEYWORDS="-* ~amd64"
RESTRICT="bindist mirror splitdebug test"

RDEPEND="
	>=app-accessibility/at-spi2-core-2.46.0:2
	dev-libs/expat
	dev-libs/glib:2
	dev-libs/nspr
	dev-libs/nss
	media-libs/alsa-lib
	media-libs/mesa[opengl]
	net-print/cups
	sys-apps/dbus
	virtual/udev
	x11-libs/cairo
	x11-libs/gtk+:3
	x11-libs/libdrm
	x11-libs/libX11
	x11-libs/libxcb
	x11-libs/libxkbcommon
	x11-libs/libXcomposite
	x11-libs/libXdamage
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libXrandr
	x11-libs/pango
"
BDEPEND="app-arch/unzip"

APPDIR="opt/${PN}"

QA_PREBUILT="
	${APPDIR}/chrome_crashpad_handler
	${APPDIR}/chrome-sandbox
	${APPDIR}/libffmpeg.so
	${APPDIR}/libvk_swiftshader.so
	${APPDIR}/libvulkan.so.1
	${APPDIR}/sieve
"

src_unpack() {
	local electron_arch=x64
	use arm64 && electron_arch=arm64

	unpack "${P}.gh.tar.gz"

	# Both npm tarballs extract into package/, keep them apart.
	local npm
	for npm in bootstrap-${BOOTSTRAP_PV} codemirror-${CODEMIRROR_PV}; do
		mkdir "${WORKDIR}/${npm%-*}" || die
		tar -xzf "${DISTDIR}/${npm}.tgz" -C "${WORKDIR}/${npm%-*}" \
			--strip-components=1 || die
	done

	mkdir "${WORKDIR}/electron" || die
	cd "${WORKDIR}/electron" || die
	unpack "electron-v${ELECTRON_PV}-linux-${electron_arch}.zip"
}

# Mirrors gulp "app:package" (gulp/gulpfile.app.mjs) without npm/gulp.
src_compile() {
	local res="${WORKDIR}/resources" libs="${WORKDIR}/resources/libs"
	local cm="${WORKDIR}/codemirror" bs="${WORKDIR}/bootstrap/dist"
	local common="${S}/src/common" app="${S}/src/app"

	mkdir -p "${libs}"/{CodeMirror/{addon,mode,theme},bootstrap/{css,js}} || die

	cp package.json LICENSE.md "${res}"/ || die
	cp -r "${common}"/icons "${libs}"/ || die

	cp -r "${cm}"/lib "${cm}"/LICENSE "${cm}"/package.json "${libs}"/CodeMirror/ || die
	cp -r "${cm}"/addon/{edit,search} "${libs}"/CodeMirror/addon/ || die
	cp -r "${cm}"/mode/sieve "${libs}"/CodeMirror/mode/ || die
	cp "${cm}"/theme/{eclipse,material-darker}.css "${libs}"/CodeMirror/theme/ || die

	cp "${bs}"/css/*.min.css "${libs}"/bootstrap/css/ || die
	cp "${bs}"/js/*.bundle.min.js "${libs}"/bootstrap/js/ || die

	# libManageSieve: app-specific files plus the common ones.
	cp -r "${app}"/libs/libManageSieve "${libs}"/ || die
	cp -r "${common}"/libManageSieve/. "${libs}"/libManageSieve/ || die
	rm -rf "${libs}"/libManageSieve/{doc,tests} || die

	cp -r "${common}"/libSieve "${libs}"/ || die
	find "${libs}"/libSieve -name tests -type d -prune -exec rm -r {} + || die
	find "${libs}"/libSieve -name 'rfc*.txt' -delete || die

	cp -r "${common}"/managesieve.ui "${libs}"/ || die
	rm -rf "${libs}"/managesieve.ui/{doc,tests} || die

	# The app sources go last so they win over the common files.
	tar -C "${app}" --exclude=./libs/libManageSieve -cf - . \
		| tar -C "${res}" -xf - || die
}

src_install() {
	local electron="${WORKDIR}/electron"

	# What @electron/packager does: drop the default app, rename the
	# binary, and ship the app unpacked under resources/app.
	rm -f "${electron}"/resources/default_app.asar || die
	mv "${electron}"/electron "${electron}"/sieve || die

	insinto "/${APPDIR}"
	doins -r "${electron}"/.
	insinto "/${APPDIR}/resources/app"
	doins -r "${WORKDIR}"/resources/.

	fperms +x "/${APPDIR}"/{sieve,chrome_crashpad_handler}
	fperms 4711 "/${APPDIR}"/chrome-sandbox
	pax-mark m "${ED}/${APPDIR}"/{sieve,chrome-sandbox,chrome_crashpad_handler}

	dosym "../../${APPDIR}/sieve" "/usr/bin/${PN}"

	newicon -s 64 src/common/icons/linux.png ${PN}.png
	make_desktop_entry "${PN}" "Sieve" "${PN}" "Network;Email;" \
		"StartupWMClass=sieve"

	dodoc README.md CHANGELOG.md
}
