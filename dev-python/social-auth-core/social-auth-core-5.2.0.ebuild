# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="Python social authentication made simple"
HOMEPAGE="
	https://github.com/python-social-auth/social-core/
	https://pypi.org/project/social-auth-core/
"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	>=dev-python/cryptography-46.0.7[${PYTHON_USEDEP}]
	>=dev-python/defusedxml-0.7.1[${PYTHON_USEDEP}]
	>=dev-python/oauthlib-3.3.1[${PYTHON_USEDEP}]
	>=dev-python/pyjwt-2.13.0[${PYTHON_USEDEP}]
	>=dev-python/python3-openid-3.2.0[${PYTHON_USEDEP}]
	>=dev-python/requests-oauthlib-2.0.0[${PYTHON_USEDEP}]
	>=dev-python/requests-2.34.0[${PYTHON_USEDEP}]
"

BDEPEND="
	test? (
		dev-python/responses[${PYTHON_USEDEP}]
		dev-python/lxml[${PYTHON_USEDEP}]
		dev-python/xmlsec[${PYTHON_USEDEP}]
	)
"

EPYTEST_IGNORE=(
	# ShopifyAPI is not packaged in ::gentoo
	social_core/tests/backends/test_shopify.py
	# dev-python/google-auth is optional and not pulled in here
	social_core/tests/backends/test_google.py
)
EPYTEST_PLUGINS=()
distutils_enable_tests pytest

python_test() {
	epytest -o addopts= social_core/tests
}
