# Copyright 2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit go-module

MY_PN="buildx"
DESCRIPTION="Docker CLI plugin for extended build capabilities with BuildKit"
HOMEPAGE="https://github.com/docker/buildx"
SRC_URI="https://github.com/docker/buildx/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"

DEPEND=""
RDEPEND="${DEPEND}"
BDEPEND=""

S="${WORKDIR}/${MY_PN}-${PV}"

src_compile() {

	go build -mod=vendor -o docker-buildx ./cmd/buildx || die

}

src_install() {

	insinto /usr/libexec/docker/cli-plugins
	doins docker-buildx
	fperms 0755 /usr/libexec/docker/cli-plugins/docker-buildx

	dodoc README.md
}
