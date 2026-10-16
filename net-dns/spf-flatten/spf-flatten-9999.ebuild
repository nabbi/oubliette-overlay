# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

CRATES="
	anstream@1.0.0
	anstyle-parse@1.0.0
	anstyle-query@1.1.5
	anstyle-wincon@3.0.11
	anstyle@1.0.14
	anyhow@1.0.104
	async-trait@0.1.92
	autocfg@1.5.1
	bit-set@0.11.1
	bit-vec@0.10.1
	bitflags@2.13.2
	borsh-derive@1.8.1
	borsh@1.8.1
	bumpalo@3.20.3
	bytes@1.12.1
	cc@1.8.0
	cfg-if@1.0.5
	cfg_aliases@0.2.2
	chacha20@0.10.2
	clap@4.6.7
	clap_builder@4.6.7
	clap_derive@4.6.7
	clap_lex@1.1.1
	colorchoice@1.0.5
	combine@4.6.9
	core-foundation-sys@0.8.7
	core-foundation@0.9.4
	core_detect@1.0.0
	cpufeatures@0.3.1
	critical-section@1.2.0
	crossbeam-channel@0.5.17
	crossbeam-epoch@0.9.21
	crossbeam-utils@0.8.23
	data-encoding@2.11.1
	displaydoc@0.2.7
	either@1.19.0
	equivalent@1.0.3
	errno@0.3.14
	fastrand@2.5.0
	find-msvc-tools@0.1.14
	fnv@1.0.7
	form_urlencoded@1.2.2
	futures-channel@0.3.34
	futures-core@0.3.34
	futures-io@0.3.34
	futures-macro@0.3.34
	futures-task@0.3.34
	futures-util@0.3.34
	getrandom@0.2.17
	getrandom@0.4.3
	hashbrown@0.17.1
	heck@0.5.0
	hickory-net@0.26.3
	hickory-proto@0.26.3
	hickory-resolver@0.26.3
	icu_collections@2.3.0
	icu_locale_core@2.3.0
	icu_normalizer@2.3.0
	icu_normalizer_data@2.3.0
	icu_properties@2.3.0
	icu_properties_data@2.3.0
	icu_provider@2.3.1
	idna@1.1.0
	idna_adapter@1.2.2
	indexmap@2.14.2
	ipconfig@0.3.4
	ipnet@2.12.2
	is_terminal_polyfill@1.70.2
	itoa@1.0.18
	jni-macros@0.22.4
	jni-sys-macros@0.4.1
	jni-sys@0.4.1
	jni@0.22.4
	js-sys@0.3.106
	libc@0.2.190
	linux-raw-sys@0.12.1
	litemap@0.8.3
	lock_api@0.4.14
	log@0.4.34
	memchr@2.8.3
	mio@1.2.4
	moka@0.12.16
	ndk-context@0.1.1
	num-traits@0.2.19
	once_cell@1.21.4
	once_cell_polyfill@1.70.2
	parking_lot@0.12.5
	parking_lot_core@0.9.12
	percent-encoding@2.3.2
	pin-project-lite@0.2.17
	portable-atomic@1.15.0
	potential_utf@0.1.6
	prefix-trie@0.8.4
	proc-macro-crate@3.5.0
	proc-macro2@1.0.107
	proptest@1.12.0
	quick-error@1.2.3
	quote@1.0.47
	r-efi@6.0.0
	rand@0.10.3
	rand_core@0.10.1
	rand_xorshift@0.5.0
	redox_syscall@0.5.18
	regex-syntax@0.8.11
	resolv-conf@0.7.6
	ring@0.17.14
	route-summarization@0.1.0
	rustc_version@0.4.1
	rustix@1.1.5
	rustversion@1.0.23
	rusty-fork@0.3.1
	same-file@1.0.6
	scopeguard@1.2.0
	semver@1.0.28
	serde@1.0.229
	serde_core@1.0.229
	serde_derive@1.0.229
	serde_json@1.0.154
	serde_spanned@1.1.2
	shlex@2.0.1
	simd_cesu8@1.2.0
	simdutf8@0.1.5
	slab@0.4.12
	smallvec@1.16.3
	socket2@0.6.5
	stable_deref_trait@1.2.1
	strsim@0.11.1
	syn@2.0.119
	syn@3.0.9
	synstructure@0.14.0
	system-configuration-sys@0.6.0
	system-configuration@0.7.0
	tagptr@0.2.0
	tempfile@3.27.0
	thiserror-impl@2.0.21
	thiserror@2.0.21
	tinystr@0.8.4
	tinyvec@1.13.3
	tokio-macros@2.7.2
	tokio@1.53.3
	toml@1.1.8+spec-1.1.0
	toml_datetime@1.1.2+spec-1.1.0
	toml_edit@0.25.17+spec-1.1.0
	toml_parser@1.1.5+spec-1.1.0
	toml_writer@1.1.3+spec-1.1.0
	tracing-core@0.1.36
	tracing@0.1.44
	unarray@0.1.4
	unicode-ident@1.0.27
	untrusted@0.9.0
	url@2.5.8
	utf8_iter@1.0.4
	utf8parse@0.2.2
	uuid@1.26.1
	wait-timeout@0.2.1
	walkdir@2.5.0
	wasi@0.11.1+wasi-snapshot-preview1
	wasm-bindgen-macro-support@0.2.129
	wasm-bindgen-macro@0.2.129
	wasm-bindgen-shared@0.2.129
	wasm-bindgen@0.2.129
	widestring@1.2.1
	winapi-util@0.1.11
	windows-link@0.2.1
	windows-registry@0.6.1
	windows-result@0.4.1
	windows-strings@0.5.1
	windows-sys@0.52.0
	windows-sys@0.61.2
	windows-targets@0.52.6
	windows_aarch64_gnullvm@0.52.6
	windows_aarch64_msvc@0.52.6
	windows_i686_gnu@0.52.6
	windows_i686_gnullvm@0.52.6
	windows_i686_msvc@0.52.6
	windows_x86_64_gnu@0.52.6
	windows_x86_64_gnullvm@0.52.6
	windows_x86_64_msvc@0.52.6
	winnow@1.0.4
	writeable@0.6.4
	yoke-derive@0.8.4
	yoke@0.8.3
	zerofrom-derive@0.1.8
	zerofrom@0.1.8
	zerotrie@0.2.5
	zerovec-derive@0.11.6
	zerovec@0.11.8
	zmij@1.0.23
"
RUST_MIN_VER="1.88.0"

inherit cargo

DESCRIPTION="Flatten SPF records to stay within the RFC 7208 DNS lookup and size limits"
HOMEPAGE="https://github.com/nabbi/spf-flatten"

if [[ ${PV} == 9999 ]] ; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/nabbi/${PN}.git"
else
	KEYWORDS="~amd64"
	SRC_URI="
		https://github.com/nabbi/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz
		${CARGO_CRATE_URIS}
	"
fi

LICENSE="GPL-3+"
# Dependent crate licenses
LICENSE+=" Apache-2.0 GPL-3+ ISC MIT Unicode-3.0"
SLOT="0"

RESTRICT="mirror"

src_unpack() {
	if [[ ${PV} == 9999 ]] ; then
		git-r3_src_unpack
		cargo_live_src_unpack
	else
		cargo_src_unpack
	fi
}

src_configure() {
	# Upstream release profile strips; leave that to portage
	export CARGO_PROFILE_RELEASE_STRIP=false
	cargo_src_configure
}

src_install() {
	cargo_src_install
	dodoc README.md docs/*.md
	docinto examples
	dodoc examples/spf.toml
	docompress -x /usr/share/doc/${PF}/examples
}
