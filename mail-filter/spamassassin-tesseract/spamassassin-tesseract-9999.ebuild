# Copyright 2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Tesseract OCR Plugin for Spamassassin"
HOMEPAGE=""
if [[ ${PV} == 9999 ]]; then
    inherit git-r3
    EGIT_REPO_URI="https://github.com/nabbi/Mail-SpamAssassin-TesseractOcr.git"
else
    KEYWORDS="~amd64 ~arm ~arm64 ~hppa ~ppc ~ppc64 ~x86"
    SRC_URI="https://github.com/nabbi/Mail-SpamAssassin-TesseractOcr/archive/refs/tags/version-${PV}.tar.gz"
fi

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS=""

DEPEND="
	media-libs/opencv
	app-text/tesseract"
RDEPEND="${DEPEND}"
BDEPEND=""

src_configure() {
	perl Makefile.PL || die
}

src_compile() {
	emake CXXFLAGS+=-std=c++11
}

src_install () {
	default
}

