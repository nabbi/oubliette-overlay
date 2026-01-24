# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=hatchling
PYTHON_COMPAT=( python3_{11..14} )

DESCRIPTION="Web util for OpenTelemetry"
HOMEPAGE="
	https://pypi.org/project/opentelemetry-util-http/
	https://github.com/open-telemetry/opentelemetry-python-contrib
"

LICENSE="Apache-2.0"
SLOT="0"

IUSE="test"
RESTRICT="!test? ( test )"

if [[ ${PV} == 9999 ]]; then
	inherit git-r3

	EGIT_REPO_URI="https://github.com/open-telemetry/opentelemetry-python-contrib.git"
	EGIT_BRANCH="main"

	# Make S= stable/predictable for live ebuilds
	EGIT_CHECKOUT_DIR="${WORKDIR}/${P}"

	# Package lives inside the monorepo under util/
	S="${WORKDIR}/${P}/util/${PN}"
else
	inherit pypi

	KEYWORDS="~amd64 ~x86"
fi

inherit distutils-r1

# NOTE: keeping deps minimal since PyPI doesn't expose Requires-Dist cleanly in the
# non-JS page capture here; adjust if your overlay already pins exact deps.
RDEPEND="
	dev-python/opentelemetry-api[${PYTHON_USEDEP}]
	dev-python/opentelemetry-semantic-conventions[${PYTHON_USEDEP}]
"

BDEPEND="
	test? (
		dev-python/opentelemetry-instrumentation[${PYTHON_USEDEP}]
		dev-python/opentelemetry-test-utils[${PYTHON_USEDEP}]
	)
"

distutils_enable_tests unittest
