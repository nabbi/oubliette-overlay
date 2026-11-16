# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=poetry
PYPI_NO_NORMALIZE=1
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="SAML Python toolkit: add SAML single sign-on support to Python software"
HOMEPAGE="
	https://github.com/SAML-Toolkits/python3-saml/
	https://pypi.org/project/python3-saml/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	>=dev-python/isodate-0.6.1[${PYTHON_USEDEP}]
	>=dev-python/lxml-4.6.5[${PYTHON_USEDEP}]
	>=dev-python/xmlsec-1.3.9[${PYTHON_USEDEP}]
"
