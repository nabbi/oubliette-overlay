# Copyright 2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DIST_AUTHOR="DMAKI"
inherit perl-module

DESCRIPTION="A libzmq 3.x wrapper for Perl"

#LICENSE="|| ( Artistic GPL-1+ )"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="dev-perl/Module-Install"
DEPEND="${RDEPEND}"
