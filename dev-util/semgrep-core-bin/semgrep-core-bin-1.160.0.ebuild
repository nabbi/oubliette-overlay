# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Lightweight static analysis for many languages (prebuilt semgrep-core)"
HOMEPAGE="https://github.com/semgrep/semgrep"

WHEEL="semgrep-${PV}-cp310.cp311.cp312.cp313.cp314.py310.py311.py312.py313.py314-none-manylinux_2_35_x86_64.whl"
SRC_URI="
	https://files.pythonhosted.org/packages/db/17/1f71ccd8541b836d6509bf05a81033307b4f30a9c76695c18ee53580fc79/${WHEEL} -> ${P}.whl.zip
"
S="${WORKDIR}/semgrep-${PV}.data"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64"

BDEPEND="app-arch/unzip"

# Mark the shipped semgrep-core binary from the wheel as prebuilt for QA
QA_PREBUILT="usr/bin/semgrep-core"

src_install() {
	dobin purelib/semgrep/bin/semgrep-core
}
