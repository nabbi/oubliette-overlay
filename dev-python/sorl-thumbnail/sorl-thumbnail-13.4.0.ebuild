# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="Thumbnails for Django, rendered on first use with Pillow, libvips and others"
HOMEPAGE="
	https://sorl-thumbnail.readthedocs.io/
	https://github.com/mariocesar/sorl-thumbnail/
	https://pypi.org/project/sorl-thumbnail/
"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64"
# Tests assume WebP/AVIF-enabled Pillow and an unconfigured test database
RESTRICT="test"
