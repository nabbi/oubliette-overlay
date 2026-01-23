# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=hatchling
PYTHON_COMPAT=( python3_{11..14} )

inherit distutils-r1

DESCRIPTION="OpenTelemetry Python Proto"
HOMEPAGE="https://github.com/open-telemetry/opentelemetry-python"

LICENSE="Apache-2.0"
SLOT="0"

if [[ ${PV} == 9999 ]]; then
	inherit git-r3

	EGIT_REPO_URI="https://github.com/open-telemetry/opentelemetry-python.git"
	EGIT_BRANCH="main"
	EGIT_CHECKOUT_DIR="${WORKDIR}/${P}"

	# This package lives at repo root in monorepo layout
	S="${WORKDIR}/${P}/${PN}"
else
	inherit pypi

	KEYWORDS="~amd64 ~x86"
fi

RDEPEND="
	dev-python/protobuf[${PYTHON_USEDEP}]
"

distutils_enable_tests pytest
