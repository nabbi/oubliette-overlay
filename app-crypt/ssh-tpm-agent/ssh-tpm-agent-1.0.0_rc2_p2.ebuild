# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit go-module systemd

# Built from the nabbi fork: upstream master plus hardening fixes that are
# not upstream. Fork tag v<upstream version>-nabbi<N> is version
# <upstream version>_p<N> here; the fork's CI (projg2/golang-dist-action)
# attaches the Go deps tarball to the release of each tag.
MY_PV="${PV/_rc/-rc}"
MY_PV="${MY_PV/_p/-nabbi}"
MY_P="${PN}-${MY_PV}"

DESCRIPTION="ssh-agent compatible agent for TPM 2.0 sealed SSH keys"
HOMEPAGE="
	https://github.com/nabbi/ssh-tpm-agent
	https://github.com/Foxboron/ssh-tpm-agent
"
SRC_URI="
	https://github.com/nabbi/${PN}/archive/refs/tags/v${MY_PV}.tar.gz
		-> ${P}.tar.gz
	https://github.com/nabbi/${PN}/releases/download/v${MY_PV}/${MY_P}-deps.tar.xz
		-> ${P}-deps.tar.xz
"
S="${WORKDIR}/${MY_P}"

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
"

PROGS=( ssh-tpm-add ssh-tpm-agent ssh-tpm-hostkeys ssh-tpm-keygen )

src_compile() {
	local prog
	for prog in "${PROGS[@]}"; do
		ego build -o "bin/${prog}" "./cmd/${prog}"
	done

	local page
	for page in man/*.adoc; do
		asciidoctor -b manpage \
			-a mansource="ssh-tpm-agent ${MY_PV}" -a manversion="${MY_PV}" \
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
