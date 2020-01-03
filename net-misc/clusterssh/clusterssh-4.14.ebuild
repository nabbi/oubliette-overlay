# Copyright 2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

MY_PN="App-ClusterSSH"
MODULE_AUTHOR="DUNCS"
MODULE_VERSION="${PV}"

inherit eutils perl-module

DESCRIPTION="Concurrent Multi-Server Terminal Access"
HOMEPAGE="https://github.com/duncs/clusterssh"
SRC_URI="https://github.com/duncs/clusterssh/archive/v${PV}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="test"
RESTRICT="!test? ( test )"

RDEPEND="
	dev-perl/Exception-Class
	dev-perl/Readonly
	dev-perl/Test-Pod
	dev-perl/Test-Pod-Coverage
	dev-perl/Test-Trap
	dev-perl/Test-DistManifest
	dev-perl/Try-Tiny
	dev-perl/Tk
	dev-perl/Config-Simple
	dev-perl/X11-Protocol
	dev-perl/X11-Protocol-Other
	dev-perl/XML-Simple
	x11-apps/xlsfonts
	x11-terms/xterm"
DEPEND="
	${RDEPEND}
	dev-perl/CPAN-Changes
	dev-perl/File-Slurp
	dev-perl/File-Which
	dev-perl/Module-Build
	dev-perl/Test-Pod
	dev-perl/Test-Differences"

#S="${WORKDIR}"/${MY_P}

SRC_TEST="do parallel"
