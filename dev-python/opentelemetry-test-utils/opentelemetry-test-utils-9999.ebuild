# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=hatchling
PYTHON_COMPAT=( python3_{11..14} )

DESCRIPTION="Test utilities for OpenTelemetry unit tests"
HOMEPAGE="
	https://pypi.org/project/opentelemetry-test-utils/
	https://github.com/open-telemetry/opentelemetry-python
"

LICENSE="Apache-2.0"
SLOT="0"

if [[ ${PV} == 9999 ]]; then
	inherit git-r3

	EGIT_REPO_URI="https://github.com/open-telemetry/opentelemetry-python.git"
	EGIT_BRANCH="main"

	# Make S= stable/predictable for live ebuilds
	EGIT_CHECKOUT_DIR="${WORKDIR}/${P}"

	# Package lives inside the monorepo under tests/
	S="${WORKDIR}/${P}/tests/${PN}"
else
	inherit pypi

	KEYWORDS="~amd64 ~x86"
fi

inherit distutils-r1

RDEPEND="
	dev-python/asgiref[${PYTHON_USEDEP}]
	dev-python/opentelemetry-api[${PYTHON_USEDEP}]
	dev-python/opentelemetry-sdk[${PYTHON_USEDEP}]
"

distutils_enable_tests pytest
