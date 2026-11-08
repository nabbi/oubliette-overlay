# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# Snapshot ebuilds (<Cargo.toml version>_pre<commit date>, scripts/snapshot.sh)
# take an untagged upstream commit, ZM_API_COMMIT, and the crates of its
# Cargo.lock (CRATES, filled by pycargoebuild); 9999 takes master's head.
ZM_API_COMMIT=""
CRATES=""

# sea-orm 2 and sqlx 0.9
RUST_MIN_VER="1.94.0"
# the Swagger UI that utoipa-swagger-ui's build script would download (its
# SWAGGER_UI_DOWNLOAD_URL default); bump with that crate
SWAGGER_UI_VER="5.32.6"

inherit cargo systemd

DESCRIPTION="ZoneMinder REST API v3 and daemon supervisor (Rust)"
HOMEPAGE="https://github.com/SteveGilvarry/zm-api"

if [[ ${PV} == 9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/SteveGilvarry/zm-api.git"
else
	SRC_URI="
		https://github.com/SteveGilvarry/zm-api/archive/${ZM_API_COMMIT}.tar.gz -> ${P}.tar.gz
		${CARGO_CRATE_URIS}
	"
	S="${WORKDIR}/zm-api-${ZM_API_COMMIT}"
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

# No patches on master. Both that the 3.0.0_alpha1 snapshot still carries are
# merged upstream (checked 2026-11-08 against zm-api master 03bf7b6):
#   db-socket (#217, merged 2026-10-25, a0376ab): localhost through the
#     MariaDB/MySQL socket, as ZoneMinder does
#   public-prefix (our #223, merged 2026-10-25, 7237108; follow-up #233):
#     APP_SERVER__PUBLIC_PREFIX, so API v3 and its docs are reached under /zm
# The snapshot pins a0b0c53 (2026-10-23), before both merges, so it keeps them.
PATCHES=()

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
