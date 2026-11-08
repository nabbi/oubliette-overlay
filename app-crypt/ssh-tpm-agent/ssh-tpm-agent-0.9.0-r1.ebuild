# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

VERIFY_SIG_OPENPGP_KEY_PATH=/usr/share/openpgp-keys/foxboron.asc
inherit go-env go-module systemd verify-sig

DESCRIPTION="ssh-agent compatible agent for TPM 2.0 sealed SSH keys"
HOMEPAGE="https://github.com/Foxboron/ssh-tpm-agent"
# The release's .gpg is an inline-signed message that contains the tarball.
SRC_URI="
	!verify-sig? (
		https://github.com/Foxboron/${PN}/releases/download/v${PV}/${PN}-v${PV}.tar.gz
			-> ${P}.tar.gz
	)
	verify-sig? (
		https://github.com/Foxboron/${PN}/releases/download/v${PV}/${PN}-v${PV}.tar.gz.gpg
			-> ${P}.tar.gz.gpg
	)
	https://github.com/nabbi/ssh-tpm-agent/releases/download/v${PV}/${P}-deps.tar.xz
"
S="${WORKDIR}/${PN}-v${PV}"

LICENSE="MIT"
# Go dependencies
LICENSE+=" Apache-2.0 BSD MIT || ( BSD GPL-2 )"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="
	acct-group/tss
"
BDEPEND="
	>=dev-lang/go-1.25
	dev-ruby/asciidoctor
	verify-sig? ( sec-keys/openpgp-keys-foxboron )
"

PATCHES=(
	# upstream 71cf1f39: v0.9.0 overwrites the key even when you answer "n"
	"${FILESDIR}"/${P}-keygen-overwrite-prompt.patch
	# upstream PR #148 (open, fixes #133): -p passed the old and new
	# passphrase to ChangeAuth swapped
	"${FILESDIR}"/${P}-keygen-change-passphrase.patch
)

PROGS=( ssh-tpm-add ssh-tpm-agent ssh-tpm-hostkeys ssh-tpm-keygen )

src_unpack() {
	if use verify-sig; then
		# unpack only what the signature covers: the message, not the file
		verify-sig_verify_message "${DISTDIR}/${P}.tar.gz.gpg" "${WORKDIR}/${P}.tar.gz"
		cd "${WORKDIR}" || die
		unpack "./${P}.tar.gz" "${P}-deps.tar.xz"
		rm "${P}.tar.gz" || die
		cd "${S}" || die
		ego mod verify
		go-env_set_compile_environment
	else
		go-module_src_unpack
	fi
}

src_compile() {
	local prog
	for prog in "${PROGS[@]}"; do
		ego build -o "bin/${prog}" "./cmd/${prog}"
	done

	local page
	for page in man/*.adoc; do
		asciidoctor -b manpage \
			-a mansource="ssh-tpm-agent ${PV}" -a manversion="${PV}" \
			"${page}" || die "asciidoctor failed on ${page}"
	done
}

src_test() {
	# The tests use the in-process TPM simulator from go-tpm-tools, and
	# create agent sockets in t.TempDir(). Under ${T} those paths pass the
	# 108-byte sun_path limit (bind: invalid argument), so run them in a
	# short directory. /var/tmp, not /tmp: the test binaries are executed
	# from there, and /tmp is often noexec.
	local -x TMPDIR
	TMPDIR=$(mktemp -d "/var/tmp/${PN}.XXXXXX") || die
	local -x GOTMPDIR="${TMPDIR}"

	nonfatal ego test ./...
	local ret=$?
	rm -rf "${TMPDIR}" || die
	[[ ${ret} -eq 0 ]] || die "tests failed"
}

src_install() {
	dobin "${PROGS[@]/#/bin/}"
	doman man/*.1
	einstalldocs

	sed -e "s|{{.GoBinary}}|${EPREFIX}/usr/bin/ssh-tpm-agent|" \
		-i contrib/services/user/ssh-tpm-agent.service || die
	systemd_douserunit contrib/services/user/ssh-tpm-agent.{service,socket}
	systemd_dounit contrib/services/system/ssh-tpm-{agent.service,agent.socket,genkeys.service}

	insinto /usr/share/${PN}
	doins contrib/sshd/10-ssh-tpm-agent.conf
}

pkg_postinst() {
	elog "The TPM device /dev/tpmrm0 is root:tss 0660. Add users to the tss group:"
	elog "  gpasswd -a <user> tss"
	elog "Start the agent from the session (no OpenRC script):"
	elog "  ssh-tpm-agent &"
	elog "  export SSH_AUTH_SOCK=\"\$(ssh-tpm-agent --print-socket)\""
}
