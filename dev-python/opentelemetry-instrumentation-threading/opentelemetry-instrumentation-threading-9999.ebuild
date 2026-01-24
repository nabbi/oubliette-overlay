# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=hatchling
PYTHON_COMPAT=( python3_{11..13} )

DESCRIPTION="Thread context propagation support for OpenTelemetry"
HOMEPAGE="
	https://pypi.org/project/opentelemetry-instrumentation-threading/
	https://github.com/open-telemetry/opentelemetry-python-contrib
"

LICENSE="Apache-2.0"
SLOT="0"

if [[ ${PV} == 9999 ]]; then
	inherit git-r3

	EGIT_REPO_URI="https://github.com/open-telemetry/opentelemetry-python-contrib.git"
	EGIT_BRANCH="main"

	# Make S= stable/predictable for live ebuilds
	EGIT_CHECKOUT_DIR="${WORKDIR}/${P}"

	# Package lives inside the monorepo under instrumentation/
	S="${WORKDIR}/${P}/instrumentation/${PN}"
else
	inherit pypi

	KEYWORDS="~amd64 ~x86"
fi

inherit distutils-r1

RDEPEND="
	dev-python/opentelemetry-api[${PYTHON_USEDEP}]
	dev-python/opentelemetry-instrumentation[${PYTHON_USEDEP}]
	dev-python/wrapt[${PYTHON_USEDEP}]
"

# If you want tests enabled in your overlay, this is the typical contrib pattern.
# (Upstream test deps can vary; adjust as needed if your test run complains.)
BDEPEND="
	test? (
		dev-python/opentelemetry-test-utils[${PYTHON_USEDEP}]
	)
"

distutils_enable_tests unittest
