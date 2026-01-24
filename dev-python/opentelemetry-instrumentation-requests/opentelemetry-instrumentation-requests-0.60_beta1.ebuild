# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=hatchling
PYTHON_COMPAT=( python3_{11..14} )

DESCRIPTION="OpenTelemetry requests instrumentation"
HOMEPAGE="
	https://pypi.org/project/opentelemetry-instrumentation-requests/
	https://github.com/open-telemetry/opentelemetry-python-contrib
"

LICENSE="Apache-2.0"
SLOT="0"

if [[ ${PV} == 9999 ]]; then
	inherit git-r3

	EGIT_REPO_URI="https://github.com/open-telemetry/opentelemetry-python-contrib.git"
	EGIT_BRANCH="main"

	# Stable, predictable checkout dir
	EGIT_CHECKOUT_DIR="${WORKDIR}/${P}"

	# Package lives under instrumentation/ in the monorepo
	S="${WORKDIR}/${P}/instrumentation/${PN}"
else
	inherit pypi

	KEYWORDS="~amd64 ~x86"
fi

inherit distutils-r1

RDEPEND="
	dev-python/opentelemetry-api[${PYTHON_USEDEP}]
	dev-python/opentelemetry-instrumentation[${PYTHON_USEDEP}]
	dev-python/opentelemetry-semantic-conventions[${PYTHON_USEDEP}]
	dev-python/opentelemetry-util-http[${PYTHON_USEDEP}]
	dev-python/requests[${PYTHON_USEDEP}]
"

BDEPEND="
	test? (
		dev-python/httpretty[${PYTHON_USEDEP}]
		dev-python/opentelemetry-test-utils[${PYTHON_USEDEP}]
	)
"

distutils_enable_tests unittest
