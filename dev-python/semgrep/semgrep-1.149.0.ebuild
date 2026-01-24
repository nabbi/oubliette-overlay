# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..13} )

inherit distutils-r1

DESCRIPTION="Lightweight static analysis for many languages"
HOMEPAGE="https://github.com/semgrep/semgrep"
LICENSE="LGPL-2.1"
SLOT="0"

if [[ ${PV} == 9999 ]]; then
	PROPERTIES="live"
	EGIT_REPO_URI="https://github.com/semgrep/semgrep.git"
	EGIT_BRANCH="develop"
	inherit git-r3
else
	KEYWORDS="~amd64"
	inherit pypi
fi

RDEPEND="
	>=dev-python/attrs-21.3[${PYTHON_USEDEP}]
	>=dev-python/boltons-21.0[${PYTHON_USEDEP}]
	>=dev-python/click-option-group-0.5[${PYTHON_USEDEP}]
	>=dev-python/click-8.1[${PYTHON_USEDEP}]
	>=dev-python/colorama-0.4.0[${PYTHON_USEDEP}]
	>=dev-python/defusedxml-0.7.1[${PYTHON_USEDEP}]
	>=dev-python/exceptiongroup-1.2.0[${PYTHON_USEDEP}]
	>=dev-python/glom-22.1[${PYTHON_USEDEP}]
	>=dev-python/jsonschema-4.6[${PYTHON_USEDEP}]
	>=dev-python/packaging-21.0[${PYTHON_USEDEP}]
	>=dev-python/peewee-3.14[${PYTHON_USEDEP}]
	>=dev-python/requests-2.22[${PYTHON_USEDEP}]
	>=dev-python/rich-12.6.0[${PYTHON_USEDEP}]
	>=dev-python/ruamel-yaml-0.16.0[${PYTHON_USEDEP}] <dev-python/ruamel-yaml-0.19.0[${PYTHON_USEDEP}]
	>=dev-python/tomli-2.0.1[${PYTHON_USEDEP}]
	>=dev-python/typing-extensions-4.2[${PYTHON_USEDEP}]
	>=dev-python/urllib3-2.0[${PYTHON_USEDEP}]
	>=dev-python/wcmatch-8.3[${PYTHON_USEDEP}]
	dev-python/opentelemetry-api[${PYTHON_USEDEP}]
	dev-python/opentelemetry-exporter-otlp-proto-http[${PYTHON_USEDEP}]
	dev-python/opentelemetry-instrumentation[${PYTHON_USEDEP}]
	dev-python/opentelemetry-instrumentation-requests[${PYTHON_USEDEP}]
	dev-python/opentelemetry-util-http[${PYTHON_USEDEP}]
	dev-python/opentelemetry-test-utils[${PYTHON_USEDEP}]
	dev-python/opentelemetry-instrumentation-threading[${PYTHON_USEDEP}]

	dev-util/semgrep-core-bin
"
DEPEND="${RDEPEND}"

python_prepare_all() {
	# Avoid test installs pulling in extra deps / causing sandbox/network issues.
	# Do not fail if upstream moved/removed tests directory.
	rm -rf tests

	# Old ebuild carried a setup.py constraint relax; keep it only if present.
	if [[ -f setup.py ]]; then
		sed -i -e 's|~=|>=|g' setup.py || die
	fi

	distutils-r1_python_prepare_all
}

python_compile() {
	export SEMGREP_SKIP_BIN=true
	distutils-r1_python_compile
}
