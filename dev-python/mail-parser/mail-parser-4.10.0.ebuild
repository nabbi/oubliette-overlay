# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=hatchling
PYTHON_COMPAT=( python3_{12..15} )

inherit distutils-r1 pypi

DESCRIPTION="Parse raw email into a Python object, for forensics and threat detection"
HOMEPAGE="
	https://github.com/SpamScope/mail-parser/
	https://pypi.org/project/mail-parser/
"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"

EPYTEST_PLUGINS=( pytest-mock )
distutils_enable_tests pytest

EPYTEST_DESELECT=(
	# needs extract-msg, not packaged
	tests/test_mail_parser.py::test_outlook_backend_parity
)

python_test() {
	# upstream's addopts are coverage and junit output
	epytest -o addopts=
}
