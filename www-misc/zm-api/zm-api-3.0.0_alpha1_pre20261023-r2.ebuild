# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# Snapshot ebuilds (<Cargo.toml version>_pre<commit date>, scripts/snapshot.sh)
# take an untagged upstream commit, ZM_API_COMMIT, and the crates of its
# Cargo.lock (CRATES, filled by pycargoebuild); 9999 takes master's head.
ZM_API_COMMIT="a0b0c53a46d52821ddc73e7ac166f02b05e52624"
CRATES="
	actix-codec@0.5.4
	actix-http@3.19.0
	actix-router@0.5.4
	actix-rt@2.15.0
	actix-server@2.10.0
	actix-service@2.0.3
	actix-utils@3.0.2
	actix-web@4.17.0
	addr2line@0.25.1
	adler2@2.0.1
	aead@0.5.2
	aead@0.6.1
	aes@0.8.4
	ahash@0.8.12
	aho-corasick@1.1.5
	aliasable@0.1.3
	alloc-no-stdlib@3.0.0
	alloc-stdlib@0.3.0
	allocator-api2@0.2.21
	android_system_properties@0.1.6
	anstream@1.0.0
	anstyle-parse@1.0.0
	anstyle-query@1.1.5
	anstyle-wincon@3.0.11
	anstyle@1.0.14
	anyhow@1.0.104
	arc-swap@1.9.2
	argon2@0.6.0
	arraydeque@0.5.1
	arrayvec@0.7.8
	arrow-arith@60.0.0
	arrow-array@60.0.0
	arrow-buffer@60.0.0
	arrow-cast@60.0.0
	arrow-cmp@60.0.0
	arrow-data@60.0.0
	arrow-ord@60.0.0
	arrow-row@60.0.0
	arrow-schema@60.0.0
	arrow-select@60.0.0
	arrow-string@60.0.0
	arrow@60.0.0
	asn1-rs-derive@0.5.1
	asn1-rs-derive@0.6.0
	asn1-rs-impl@0.2.0
	asn1-rs@0.6.2
	asn1-rs@0.7.2
	assert-json-diff@2.0.2
	async-broadcast@0.7.2
	async-channel@2.5.0
	async-compression@0.4.51
	async-http-codec@0.8.0
	async-io@2.6.0
	async-net@2.0.0
	async-stream-impl@0.3.6
	async-stream@0.3.6
	async-task@4.7.1
	async-trait@0.1.92
	async-web-client@0.6.3
	async_zip@0.0.17
	atoi@2.0.0
	atoi@3.1.1
	atomic-waker@1.1.2
	atomic@0.6.1
	autocfg@1.5.1
	aws-lc-rs@1.18.2
	aws-lc-sys@0.46.0
	axum-core@0.5.6
	axum-extra@0.12.6
	axum-macros@0.5.1
	axum-server@0.8.0
	axum-test@21.1.0
	axum@0.8.9
	backtrace@0.3.76
	base64@0.22.1
	base64@0.23.1
	base64ct@1.8.3
	bcrypt@0.19.3
	bigdecimal@0.4.11
	bindgen@0.73.2
	bit-vec@0.9.1
	bitflags@1.3.2
	bitflags@2.13.2
	bitstream-io@2.6.0
	blake2@0.11.0
	block-buffer@0.10.4
	block-buffer@0.12.1
	block2@0.6.2
	blocking@1.7.0
	blowfish@0.10.0
	borsh-derive@1.8.1
	borsh@1.8.1
	brotli-decompressor@6.0.1
	brotli@9.0.0
	bstr@1.13.1
	bumpalo@3.20.3
	bytecheck@0.8.3
	bytecheck_derive@0.8.3
	bytemuck@1.25.2
	byteorder-lite@0.1.0
	byteorder@1.5.0
	bytes@1.12.1
	bytesize@2.7.0
	bytestring@1.5.1
	castaway@0.2.4
	cc@1.8.0
	ccm@0.5.0
	cexpr@0.6.0
	cfg-if@1.0.5
	cfg_aliases@0.2.2
	chacha20@0.10.2
	chacha20poly1305@0.11.0
	chrono@0.4.45
	cipher@0.4.4
	cipher@0.5.2
	clang-sys@1.9.1
	clap@4.6.7
	clap_builder@4.6.7
	clap_derive@4.6.7
	clap_lex@1.1.1
	cmake@0.1.58
	cmov@0.5.4
	colorchoice@1.0.5
	combine@4.6.9
	compact_str@0.9.1
	compression-codecs@0.4.46
	compression-core@0.4.34
	concurrent-queue@2.5.0
	config@0.15.27
	console@0.16.6
	const-oid@0.10.2
	const-random-macro@0.1.16
	const-random@0.1.18
	convert_case@0.10.0
	convert_case@0.6.0
	cookie@0.18.2
	core-foundation-sys@0.8.7
	core-foundation@0.10.1
	core-foundation@0.9.4
	core_detect@1.0.0
	cpufeatures@0.2.17
	cpufeatures@0.3.1
	crc-catalog@2.5.0
	crc32c@0.6.8
	crc32fast@1.5.2
	crc@3.4.0
	crossbeam-channel@0.5.17
	crossbeam-queue@0.3.14
	crossbeam-utils@0.8.23
	crunchy@0.2.4
	crypto-common@0.1.7
	crypto-common@0.2.2
	ctr@0.9.2
	ctutils@0.4.3
	darling@0.20.11
	darling_core@0.20.11
	darling_macro@0.20.11
	dashmap@6.2.1
	data-encoding@2.11.1
	debugid@0.8.0
	defmt-macros@1.2.0
	defmt-parser@1.1.0
	defmt@1.2.0
	der-parser@10.0.0
	der-parser@9.0.0
	der@0.8.2
	deranged@0.5.9
	derive-where@1.7.0
	derive_more-impl@2.1.1
	derive_more@2.1.1
	deunicode@1.6.2
	diff@0.1.13
	digest@0.10.7
	digest@0.11.3
	dispatch2@0.3.1
	displaydoc@0.2.7
	dlv-list@0.5.2
	dotenvy@0.15.7
	dummy@0.12.0
	dunce@1.0.5
	educe@0.7.6
	either@1.19.0
	email_address@0.2.9
	encode_unicode@1.0.0
	encoding_rs@0.8.42
	enum-ordinalize-derive@4.4.2
	enum-ordinalize@4.4.2
	equivalent@1.0.3
	erased-serde@0.4.10
	errno@0.3.14
	etcetera@0.11.0
	event-listener-strategy@0.5.4
	event-listener@5.4.2
	expect-json-macros@1.11.0
	expect-json@1.11.0
	fake@5.1.0
	fallible-iterator@0.3.0
	fastrand@2.5.0
	fdeflate@0.3.7
	ffmpeg-next@9.0.0
	ffmpeg-sys-next@9.0.1
	find-msvc-tools@0.1.14
	findshlibs@0.10.2
	flate2@1.1.10
	flume@0.12.0
	fnv@1.0.7
	foldhash@0.2.0
	foreign-types-shared@0.1.1
	foreign-types@0.3.2
	form_urlencoded@1.2.2
	forwarded-header-value@0.1.1
	four-cc@0.4.0
	fs-err@3.3.2
	fs_extra@1.3.0
	futures-channel@0.3.34
	futures-core@0.3.34
	futures-executor@0.3.34
	futures-intrusive@0.5.0
	futures-io@0.3.34
	futures-lite@2.6.1
	futures-macro@0.3.34
	futures-rustls@0.26.0
	futures-sink@0.3.34
	futures-task@0.3.34
	futures-timer@3.0.4
	futures-util@0.3.34
	futures@0.3.34
	garde@0.23.0
	garde_derive@0.23.0
	generic-array@0.14.7
	gethostname@0.2.3
	getrandom@0.2.17
	getrandom@0.3.4
	getrandom@0.4.3
	gimli@0.32.3
	glob@0.3.4
	governor@0.10.4
	h264-reader@0.8.0
	h2@0.4.20
	half@2.7.1
	hashbrown@0.14.5
	hashbrown@0.16.1
	hashbrown@0.17.1
	hashlink@0.11.1
	headers-core@0.3.0
	headers@0.4.2
	heck@0.4.1
	heck@0.5.0
	hermit-abi@0.5.3
	hex-slice@0.1.4
	hex@0.4.3
	hkdf@0.13.0
	hmac@0.12.1
	hmac@0.13.0
	hostname@0.4.2
	http-auth@0.1.10
	http-body-util@0.1.5
	http-body@1.1.0
	http-range-header@0.4.2
	http@0.2.12
	http@1.5.0
	httparse@1.10.1
	httpdate@1.0.3
	hybrid-array@0.4.15
	hyper-rustls@0.27.10
	hyper-timeout@0.5.2
	hyper-tls@0.6.0
	hyper-util@0.1.21
	hyper@1.12.0
	iana-time-zone-haiku@0.1.2
	iana-time-zone@0.1.65
	icu_collections@2.3.0
	icu_locale_core@2.3.0
	icu_normalizer@2.3.0
	icu_normalizer_data@2.3.0
	icu_properties@2.3.0
	icu_properties_data@2.3.0
	icu_provider@2.3.1
	ident_case@1.0.1
	idna@1.1.0
	idna_adapter@1.2.2
	image@0.25.10
	impl-more@0.3.10
	indexmap@2.14.2
	indoc@2.0.8
	inout@0.1.4
	inout@0.2.4
	insta@1.49.0
	inventory@0.3.25
	ipnet@2.12.2
	is_terminal_polyfill@1.70.2
	itertools@0.14.0
	itertools@0.15.0
	itoa@1.0.18
	jiff-core@0.1.1
	jiff-static@0.2.38
	jiff-tzdb-platform@0.1.3
	jiff-tzdb@0.1.9
	jiff@0.2.38
	jni-macros@0.22.4
	jni-sys-macros@0.4.1
	jni-sys@0.4.1
	jni@0.22.4
	jobserver@0.1.35
	js-sys@0.3.106
	json5@1.3.2
	jsonwebtoken@11.1.0
	language-tags@0.3.2
	lazy_static@1.5.1
	lexical-core@1.0.6
	lexical-parse-float@1.0.6
	lexical-parse-integer@1.0.6
	lexical-util@1.0.7
	lexical-write-float@1.0.6
	lexical-write-integer@1.0.6
	libc@0.2.191
	libloading@0.8.9
	libm@0.2.16
	libsqlite3-sys@0.30.1
	linux-raw-sys@0.12.1
	litemap@0.8.3
	local-waker@0.1.4
	lock_api@0.4.14
	log@0.4.34
	lru-slab@0.1.3
	mac_address@1.2.1
	matchers@0.2.0
	matchit@0.8.4
	md-5@0.10.6
	md-5@0.11.0
	memchr@2.8.3
	memmap2@0.9.11
	memoffset@0.9.1
	mime@0.3.17
	mime_guess@2.0.5
	minimal-lexical@0.2.1
	miniz_oxide@0.8.9
	miniz_oxide@0.9.1
	mio@1.2.4
	moxcms@0.8.1
	mp4ra-rust@0.3.0
	mpeg4-audio-const@0.2.0
	multiversion_no_op@1.0.0
	munge@0.4.7
	munge_macro@0.4.7
	native-tls@0.2.18
	nix@0.31.3
	nom@7.1.3
	nonempty@0.7.0
	nonzero_ext@0.3.0
	nu-ansi-term@0.50.3
	num-bigint@0.4.8
	num-bigint@0.5.1
	num-complex@0.4.6
	num-conv@0.2.2
	num-integer@0.1.47
	num-iter@0.1.46
	num-rational@0.4.2
	num-traits@0.2.19
	num@0.4.3
	num_cpus@1.17.0
	objc2-cloud-kit@0.3.2
	objc2-core-data@0.3.2
	objc2-core-foundation@0.3.2
	objc2-core-graphics@0.3.2
	objc2-core-image@0.3.2
	objc2-core-location@0.3.2
	objc2-core-text@0.3.2
	objc2-encode@4.1.0
	objc2-foundation@0.3.2
	objc2-io-surface@0.3.2
	objc2-quartz-core@0.3.2
	objc2-ui-kit@0.3.2
	objc2-user-notifications@0.3.2
	objc2@0.6.5
	object@0.37.3
	oid-registry@0.7.1
	oid-registry@0.8.1
	once_cell@1.21.4
	once_cell_polyfill@1.70.2
	openssl-macros@0.1.1
	openssl-probe@0.2.1
	openssl-sys@0.9.117
	openssl@0.10.81
	ordered-float@4.6.0
	ordered-multimap@0.7.3
	os_info@3.15.0
	ouroboros@0.18.5
	ouroboros_macro@0.18.5
	parking@2.2.1
	parking_lot@0.12.5
	parking_lot_core@0.9.12
	password-hash@0.6.1
	paste@1.0.15
	pathdiff@0.2.3
	pem-rfc7468@1.0.0
	pem@3.0.6
	pem@4.0.0
	percent-encoding@2.3.2
	pgvector@0.4.2
	phc@0.6.1
	pin-project-internal@1.1.13
	pin-project-lite@0.2.17
	pin-project@1.1.13
	piper@0.2.5
	pkg-config@0.3.34
	pluralizer@0.5.0
	png@0.18.1
	polling@3.11.0
	poly1305@0.9.1
	portable-atomic-util@0.2.8
	portable-atomic@1.15.0
	potential_utf@0.1.6
	powerfmt@0.2.1
	ppv-lite86@0.2.21
	pretty-hex@0.4.2
	pretty_assertions@1.4.1
	proc-macro-crate@3.5.0
	proc-macro2-diagnostics@0.10.1
	proc-macro2@1.0.107
	ptr_meta@0.3.2
	ptr_meta_derive@0.3.2
	pxfm@0.1.30
	quanta@0.12.6
	quick-xml@0.42.0
	quinn-proto@0.11.19
	quinn-udp@0.5.16
	quinn-udp@0.6.3
	quinn@0.11.12
	quote@1.0.47
	r-efi@5.3.0
	r-efi@6.0.0
	rancor@0.1.3
	rand@0.10.3
	rand@0.8.8
	rand@0.9.5
	rand_chacha@0.3.1
	rand_chacha@0.9.0
	rand_core@0.10.1
	rand_core@0.6.4
	rand_core@0.9.5
	rand_pcg@0.10.2
	raw-cpuid@11.6.0
	rcgen@0.13.2
	rcgen@0.14.10
	redox_syscall@0.5.18
	regex-automata@0.4.18
	regex-lite@0.1.9
	regex-syntax@0.8.11
	regex@1.13.1
	rend@0.5.4
	reqwest@0.13.5
	reserve-port@2.5.0
	retina@0.4.21
	rfc6381-codec@0.2.0
	ring@0.17.14
	rkyv@0.8.18
	rkyv_derive@0.8.18
	ron@0.12.2
	rtc-crypto@0.21.1
	rtc-datachannel@0.21.1
	rtc-dtls@0.21.1
	rtc-ice@0.21.1
	rtc-interceptor@0.21.1
	rtc-mdns@0.21.1
	rtc-media@0.21.1
	rtc-rtcp@0.21.1
	rtc-rtp@0.21.1
	rtc-sctp@0.21.1
	rtc-sdp@0.21.1
	rtc-shared@0.21.1
	rtc-srtp@0.21.1
	rtc-stun@0.21.1
	rtc-turn@0.21.1
	rtc@0.21.1
	rust-ini@0.21.3
	rust-multipart-rfc7578_2@0.9.0
	rust_decimal@1.43.0
	rustc-demangle@0.1.28
	rustc-hash@2.1.3
	rustc_version@0.4.1
	rusticata-macros@4.1.0
	rustix@1.1.5
	rustls-acme@0.15.4
	rustls-native-certs@0.8.5
	rustls-pki-types@1.15.1
	rustls-platform-verifier-android@0.2.0
	rustls-platform-verifier@0.7.1
	rustls-webpki@0.103.15
	rustls@0.23.46
	rustversion@1.0.23
	ryu@1.0.23
	same-file@1.0.6
	sansio@1.0.1
	schannel@0.1.30
	scopeguard@1.2.0
	sdp-types@0.1.8
	sea-bae@0.2.2
	sea-orm-arrow@2.0.0-rc.5
	sea-orm-cli@2.0.4
	sea-orm-macros@2.0.4
	sea-orm-migration@2.0.4
	sea-orm@2.0.4
	sea-query-derive@1.0.0
	sea-query-sqlx@0.9.1
	sea-query@1.0.2
	sea-schema-derive@0.3.0
	sea-schema@0.18.1
	security-framework-sys@2.17.0
	security-framework@3.7.0
	semver@1.0.28
	sentry-actix@0.49.3
	sentry-backtrace@0.49.3
	sentry-contexts@0.49.3
	sentry-core@0.49.3
	sentry-debug-images@0.49.3
	sentry-log@0.49.3
	sentry-panic@0.49.3
	sentry-tracing@0.49.3
	sentry-types@0.49.3
	sentry@0.49.3
	serde-untagged@0.1.9
	serde@1.0.229
	serde_core@1.0.229
	serde_derive@1.0.229
	serde_html_form@0.2.8
	serde_json@1.0.154
	serde_path_to_error@0.1.20
	serde_spanned@1.1.2
	serde_urlencoded@0.7.1
	sha1@0.10.7
	sha1@0.11.0
	sha1_smol@1.0.1
	sha2@0.10.9
	sha2@0.11.1
	sharded-slab@0.1.7
	shlex@2.0.1
	signal-hook-registry@1.4.8
	signature@2.2.0
	simd-adler32@0.3.10
	simd_cesu8@1.2.0
	simdutf8@0.1.5
	similar@2.7.0
	simple_asn1@0.6.4
	slab@0.4.12
	smallvec@1.16.3
	socket2@0.5.10
	socket2@0.6.5
	spin@0.9.9
	spinning_top@0.3.0
	sqlx-core@0.9.0
	sqlx-macros-core@0.9.0
	sqlx-macros@0.9.0
	sqlx-mysql@0.9.0
	sqlx-postgres@0.9.0
	sqlx-sqlite@0.9.0
	sqlx@0.9.0
	stable_deref_trait@1.2.1
	static_assertions@1.1.0
	stringprep@0.1.5
	strsim@0.11.1
	strum@0.28.0
	strum_macros@0.28.0
	substring@1.4.5
	subtle@2.6.1
	symlink@0.1.0
	syn@2.0.119
	syn@3.0.9
	sync_wrapper@1.0.2
	synstructure@0.13.2
	synstructure@0.14.0
	system-configuration-sys@0.6.0
	system-configuration@0.7.0
	tempfile@3.27.0
	test-context-macros@0.5.8
	test-context@0.5.8
	thiserror-impl@1.0.69
	thiserror-impl@2.0.21
	thiserror@1.0.69
	thiserror@2.0.21
	thread_local@1.1.10
	tikv-jemalloc-ctl@0.7.0
	tikv-jemalloc-sys@0.7.1+5.3.1-0-g81034ce1f1373e37dc865038e1bc8eeecf559ce8
	tikv-jemallocator@0.7.0
	time-core@0.1.9
	time-macros@0.2.32
	time@0.3.55
	tiny-keccak@2.0.2
	tinystr@0.8.4
	tinyvec@1.13.3
	tokio-macros@2.7.2
	tokio-native-tls@0.3.1
	tokio-rustls@0.26.6
	tokio-stream@0.1.19
	tokio-tungstenite@0.29.0
	tokio-tungstenite@0.30.0
	tokio-util@0.7.20
	tokio@1.53.3
	toml@1.1.8+spec-1.1.0
	toml_datetime@1.1.2+spec-1.1.0
	toml_edit@0.25.17+spec-1.1.0
	toml_parser@1.1.5+spec-1.1.0
	toml_writer@1.1.3+spec-1.1.0
	tonic@0.14.6
	tower-http@0.6.11
	tower-http@0.7.1
	tower-layer@0.3.3
	tower-service@0.3.3
	tower@0.5.3
	tower_governor@0.8.0
	tracing-appender@0.2.5
	tracing-attributes@0.1.31
	tracing-bunyan-formatter@0.3.11
	tracing-core@0.1.36
	tracing-log@0.1.4
	tracing-log@0.2.0
	tracing-subscriber@0.3.23
	tracing@0.1.44
	try-lock@0.2.5
	tungstenite@0.29.0
	tungstenite@0.30.0
	typed-path@0.12.3
	typeid@1.0.3
	typenum@1.20.1
	typetag-impl@0.2.23
	typetag@0.2.23
	ucd-trie@0.1.7
	uname@0.1.1
	unicase@2.10.0
	unicode-bidi@0.3.18
	unicode-ident@1.0.27
	unicode-normalization@0.1.26
	unicode-properties@0.1.4
	unicode-segmentation@1.13.3
	unicode-xid@0.2.6
	universal-hash@0.6.1
	untrusted@0.7.1
	untrusted@0.9.0
	ureq-proto@0.6.5
	ureq@3.4.2
	url@2.5.8
	urlencoding@2.1.3
	utf8-zero@0.8.1
	utf8_iter@1.0.4
	utf8parse@0.2.2
	utoipa-gen@6.0.1
	utoipa-swagger-ui@10.0.1
	utoipa@6.0.0
	uuid@1.28.0
	valuable@0.1.1
	vcpkg@0.2.15
	version_check@0.9.5
	walkdir@2.5.0
	want@0.3.2
	wasi@0.11.1+wasi-snapshot-preview1
	wasip2@1.0.4+wasi-0.2.12
	wasm-bindgen-futures@0.4.79
	wasm-bindgen-macro-support@0.2.129
	wasm-bindgen-macro@0.2.129
	wasm-bindgen-shared@0.2.129
	wasm-bindgen@0.2.129
	web-sys@0.3.106
	web-time@1.1.0
	webpki-root-certs@1.0.9
	webpki-roots@0.26.11
	webpki-roots@1.0.9
	webrtc@0.21.1
	whoami@2.1.3
	winapi-i686-pc-windows-gnu@0.4.0
	winapi-util@0.1.11
	winapi-x86_64-pc-windows-gnu@0.4.0
	winapi@0.3.9
	windows-core@0.62.2
	windows-implement@0.60.2
	windows-interface@0.59.3
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
	wit-bindgen@0.57.1
	writeable@0.6.4
	x509-parser@0.16.0
	x509-parser@0.18.1
	yaml-rust2@0.11.1
	yansi@1.0.1
	yasna@0.5.2
	yasna@0.6.0
	yoke-derive@0.8.4
	yoke@0.8.3
	zerocopy-derive@0.8.63
	zerocopy@0.8.63
	zerofrom-derive@0.1.8
	zerofrom@0.1.8
	zeroize@1.9.1
	zeroize_derive@1.5.0
	zerotrie@0.2.5
	zerovec-derive@0.11.6
	zerovec@0.11.8
	zip@8.6.0
	zlib-rs@0.6.8
	zmij@1.0.23
	zopfli@0.8.4
	zune-core@0.5.3
	zune-jpeg@0.5.15
"

# sea-orm 2 and sqlx 0.9
RUST_MIN_VER="1.94.0"
# the Swagger UI that utoipa-swagger-ui's build script would download (its
# SWAGGER_UI_DOWNLOAD_URL default); bump with that crate
SWAGGER_UI_VER="5.32.6"

inherit cargo systemd

DESCRIPTION="ZoneMinder REST API v3 and daemon supervisor (Rust)"
HOMEPAGE="https://github.com/ZoneMinder/zm-api"

if [[ ${PV} == 9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/SteveGilvarry/zm-api.git"
else
	SRC_URI="
		https://github.com/SteveGilvarry/zm-api/archive/${ZM_API_COMMIT}.tar.gz -> ${P}.tar.gz
		${CARGO_CRATE_URIS}
	"
	S="${WORKDIR}/zm-api-${ZM_API_COMMIT}"
	# Keyworded so that www-misc/zoneminder[apiv3] (~amd64) resolves; 9999 is not.
	KEYWORDS="~amd64"
fi
SRC_URI+="
	https://github.com/swagger-api/swagger-ui/archive/refs/tags/v${SWAGGER_UI_VER}.zip
		-> swagger-ui-${SWAGGER_UI_VER}.zip
"

LICENSE="AGPL-3+"
# 9999: crate licenses as of the last snapshot
# Dependent crate licenses
LICENSE+="
	Apache-2.0 BSD CC0-1.0 CDLA-Permissive-2.0 ISC MIT Unicode-3.0
	WTFPL-2 ZLIB
"
SLOT="0"

DEPEND="
	dev-libs/openssl:=
	media-video/ffmpeg:=
"
RDEPEND="
	${DEPEND}
	sys-process/procps
"
# clang for bindgen (ffmpeg-sys-next), cmake for aws-lc-sys
BDEPEND="
	app-arch/unzip
	dev-build/cmake
	llvm-core/clang
	virtual/pkgconfig
"

QA_FLAGS_IGNORED="usr/bin/zm-api.*"

PATCHES=(
	# localhost goes through the MariaDB/MySQL socket, as ZoneMinder does,
	# not TCP as zmuser@127.0.0.1 (#215). Upstream PR #217, unmerged; thanks
	# to Isaac Connor. Drop once it is in master.
	"${FILESDIR}"/${PN}-3.0.0_alpha1-db-socket-pr217.patch
	# APP_SERVER__PUBLIC_PREFIX: links zm-api writes carry the proxy's /zm, so
	# all of API v3 (and its docs) is reached under /zm; local, needs #217 first
	"${FILESDIR}"/${PN}-3.0.0_alpha1-public-prefix.patch
)

src_unpack() {
	if [[ ${PV} == 9999 ]]; then
		git-r3_src_unpack
		cargo_live_src_unpack
	else
		cargo_src_unpack
	fi
}

src_compile() {
	# no network in the build sandbox
	export SWAGGER_UI_DOWNLOAD_URL="file://${DISTDIR}/swagger-ui-${SWAGGER_UI_VER}.zip"
	cargo_src_compile --bin zm-api --bin migrator
}

src_test() {
	export SWAGGER_UI_DOWNLOAD_URL="file://${DISTDIR}/swagger-ui-${SWAGGER_UI_VER}.zip"
	# the suite needs a MySQL/Postgres database and a running ZoneMinder
	cargo_src_test --lib
}

src_install() {
	local target="$(cargo_target_dir)"
	newbin "${target}"/zm-api zm-api
	# built as migrator, too generic a name for /usr/bin (upstream packaging)
	newbin "${target}"/migrator zm-api-db
	newbin packaging/zm-api-takeover.sh zm-api-takeover

	insinto /etc/zm-api
	doins settings/base.toml settings/prod.toml
	newins "${FILESDIR}"/zm-api.env zm-api.env

	newinitd "${FILESDIR}"/zm-api.initd zm-api
	newconfd "${FILESDIR}"/zm-api.confd zm-api

	# upstream's unit runs as zoneminder:zoneminder; setup-instance.sh writes
	# the drop-in that switches it to ZoneMinder's ZM_WEB_USER
	systemd_dounit packaging/systemd/zm-api.service
	exeinto /usr/share/zm-api
	doexe packaging/setup-instance.sh scripts/generate-jwt-keys.sh

	doman packaging/man/*.[58]
	dodoc README.md CHANGELOG.md docs/deployment.md

	# keys and state are created by pkg_config / the init script, owned by
	# ZoneMinder's web user, which is only known once zm.conf exists
	keepdir /var/log/zm-api
}

_zm_api_account() {
	local conf="${EROOT}"/etc/zm/zm.conf
	ZM_API_USER=$(sed -n 's/^ZM_WEB_USER=//p' "${conf}" 2>/dev/null)
	ZM_API_GROUP=$(sed -n 's/^ZM_WEB_GROUP=//p' "${conf}" 2>/dev/null)
	[[ -n ${ZM_API_USER} && -n ${ZM_API_GROUP} ]] || \
		die "no ZM_WEB_USER/ZM_WEB_GROUP in ${conf}; install www-misc/zoneminder first"
}

pkg_config() {
	_zm_api_account
	local keys="${EROOT}"/var/lib/zm-api/keys
	install -d -m 0750 -o "${ZM_API_USER}" -g "${ZM_API_GROUP}" \
		"${EROOT}"/var/lib/zm-api "${keys}" || die

	local k
	for k in access refresh; do
		local priv="${keys}/private_${k}_rsa_key.pem" pub="${keys}/public_${k}_rsa_key.pem"
		if [[ -f ${priv} ]]; then
			einfo "keeping existing ${priv}"
			continue
		fi
		einfo "generating ${priv}"
		( umask 077 && openssl genpkey -algorithm RSA -pkeyopt rsa_keygen_bits:2048 -out "${priv}" ) || die
		openssl rsa -in "${priv}" -pubout -out "${pub}" 2>/dev/null || die
		chown "${ZM_API_USER}:${ZM_API_GROUP}" "${priv}" "${pub}" || die
	done
	chown "${ZM_API_USER}:${ZM_API_GROUP}" "${EROOT}"/var/log/zm-api || die
}

pkg_postinst() {
	if [[ -z ${REPLACING_VERSIONS} ]]; then
		elog "zm-api serves ZoneMinder API v3 on 127.0.0.1:8080; the web server examples publish it"
		elog "at /zm/api/v3, docs at /zm/swagger-ui/ (APP_SERVER__PUBLIC_PREFIX in /etc/zm-api/zm-api.env)."
		elog "It runs passive: ZoneMinder's own zmdc.pl keeps control of the daemons."
		elog ""
		elog "Before the first start:"
		elog "  1. emerge --config =${CATEGORY}/${PF}    (JWT keys in /var/lib/zm-api/keys)"
		elog "  2. back up the database, then bring it up to zm-api's schema:"
		elog "       zm-api-db bridge    (as root: zm.conf's account, and its socket for localhost)"
		elog "     zm-api only warns at startup when migrations fail (man 8 zm-api-db)"
		elog "  3. rc-update add zm-api default && rc-service zm-api start"
		elog "     systemd: run /usr/share/zm-api/setup-instance.sh once for the account drop-in"
		elog ""
		elog "Proxy /zm/api/v3, /zm/api-docs and /zm/swagger-ui to it from the web server: with"
		elog "USE=apiv3 the zoneminder ebuild's examples have this block enabled."
	fi
}
