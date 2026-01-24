# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DIST_AUTHOR="ROBF"

inherit perl-module

DESCRIPTION="Perl X10 module"
HOMEPAGE="https://metacpan.org/release/Device-X10"
LICENSE="|| ( Artistic GPL-1+ )"

SLOT="0"
KEYWORDS="~amd64 ~x86"

RDEPEND="
	dev-perl/Time-ParseDate
	dev-perl/Device-SerialPort
"
