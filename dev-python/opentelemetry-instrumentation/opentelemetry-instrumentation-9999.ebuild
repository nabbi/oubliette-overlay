# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=hatchling
PYTHON_COMPAT=( python3_{11..13} )

DESCRIPTION="Instrumentation Tools & Auto Instrumentation for OpenTelemetry Python"
HOMEPAGE="
	https://pypi.org/project/opentelemetry-instrumentation/
	https://github.com/open-telemetry/opentelemetry-python-contrib
"

LICENSE="Apache-2.0"
SLOT="0"

# Live vs release sourcing
if [[ ${PV} == 9999 ]]; then
	inherit git-r3

	EGIT_REPO_URI="https://github.com/open-telemetry/opentelemetry-python-contrib.git"
	EGIT_BRANCH="main"

	# Ensure checkout dir matches ${P} so Portage paths are stable
	EGIT_CHECKOUT_DIR="${WORKDIR}/${P}"

	# Package lives inside the monorepo under this subdir
	S="${WORKDIR}/${P}/opentelemetry-instrumentation"
else
	inherit pypi

	KEYWORDS="~amd64 ~x86"
fi

inherit distutils-r1

RDEPEND="
	dev-python/opentelemetry-api[${PYTHON_USEDEP}]
	dev-python/opentelemetry-semantic-conventions[${PYTHON_USEDEP}]
	dev-python/packaging[${PYTHON_USEDEP}]
	dev-python/wrapt[${PYTHON_USEDEP}]
"

BDEPEND="
	test? (
		dev-python/opentelemetry-test-utils[${PYTHON_USEDEP}]
	)
"

distutils_enable_tests pytest
