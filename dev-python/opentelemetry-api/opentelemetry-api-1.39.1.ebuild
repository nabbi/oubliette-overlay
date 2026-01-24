# Copyright 2024-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=hatchling
PYTHON_COMPAT=( python3_{11..14} )

DESCRIPTION="OpenTelemetry Python API"
HOMEPAGE="
	https://opentelemetry.io/
	https://pypi.org/project/opentelemetry-api/
	https://github.com/open-telemetry/opentelemetry-python/
"

LICENSE="Apache-2.0"
SLOT="0"

if [[ ${PV} == 9999 ]]; then
	inherit git-r3

	EGIT_REPO_URI="https://github.com/open-telemetry/opentelemetry-python.git"
	EGIT_BRANCH="main"

	# Make paths predictable so S= and python_test() can find sibling dirs
	EGIT_CHECKOUT_DIR="${WORKDIR}/${P}"

	OTEL_ROOT="${WORKDIR}/${P}"
	S="${OTEL_ROOT}/${PN}"
else
	inherit distutils-r1

	MY_P="opentelemetry-python-${PV}"
	SRC_URI="
		https://github.com/open-telemetry/opentelemetry-python/archive/refs/tags/v${PV}.tar.gz
			-> ${MY_P}.gh.tar.gz
	"
	OTEL_ROOT="${WORKDIR}/${MY_P}"
	S="${OTEL_ROOT}/${PN}"

	KEYWORDS="amd64 arm64 x86"
fi

inherit distutils-r1

RDEPEND="
	>=dev-python/importlib-metadata-6.0[${PYTHON_USEDEP}]
	>=dev-python/typing-extensions-4.5.0[${PYTHON_USEDEP}]
"
BDEPEND="
	test? (
		dev-python/typing-extensions[${PYTHON_USEDEP}]
	)
"

EPYTEST_PLUGINS=()
distutils_enable_tests pytest

src_prepare() {
	default

	# Unnecessary restriction
	sed -i -e '/importlib-metadata/s:, < [0-9.]*::' pyproject.toml || die
}

python_test() {
	cp -a "${BUILD_DIR}"/{install,test} || die
	local -x PATH=${BUILD_DIR}/test/usr/bin:${PATH}

	for dep in opentelemetry-semantic-conventions opentelemetry-sdk \
		tests/opentelemetry-test-utils
	do
		pushd "${OTEL_ROOT}/${dep}" >/dev/null || die
		distutils_pep517_install "${BUILD_DIR}"/test
		popd >/dev/null || die
	done

	epytest
}
