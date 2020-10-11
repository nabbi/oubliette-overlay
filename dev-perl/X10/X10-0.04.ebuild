# Copyright 2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DIST_AUTHOR="ROBF"
inherit perl-module

DESCRIPTION="Perl X10 module"

#LICENSE="|| ( Artistic GPL-1+ )"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="
	dev-perl/Time-ParseDate
	dev-perl/Device-SerialPort"
DEPEND="${RDEPEND}"
