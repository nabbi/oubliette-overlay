# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="Python client for Sentry (https://sentry.io)"
HOMEPAGE="
	https://docs.sentry.io/platforms/python/
	https://github.com/getsentry/sentry-python/
	https://pypi.org/project/sentry-sdk/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
# The suite needs many web framework integrations and GDAL; Gentoo dropped the
# package in 2024 for the same flaky tests (bug #937896)
RESTRICT="test"

RDEPEND="
	>=dev-python/urllib3-1.26.11[${PYTHON_USEDEP}]
	dev-python/certifi[${PYTHON_USEDEP}]
"
