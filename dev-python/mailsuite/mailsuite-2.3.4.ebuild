# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=hatchling
PYTHON_COMPAT=( python3_{12..15} )

inherit distutils-r1

DESCRIPTION="Retrieve, parse, sign and send email: IMAP, Maildir, SMTP, DKIM and ARC"
HOMEPAGE="
	https://github.com/seanthegeek/mailsuite/
	https://pypi.org/project/mailsuite/
"
# The PyPI sdist has no tests
SRC_URI="
	https://github.com/seanthegeek/mailsuite/archive/refs/tags/${PV}.tar.gz
		-> ${P}.gh.tar.gz
"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"

# The Gmail and Microsoft Graph mailboxes (the gmail and msgraph extras)
# are not packaged
RDEPEND="
	>=dev-python/authres-1.2.0[${PYTHON_USEDEP}]
	>=dev-python/cryptography-50.0.0[${PYTHON_USEDEP}]
	>=dev-python/dkimpy-1.1.0[${PYTHON_USEDEP}]
	>=dev-python/dnspython-2.0.0[${PYTHON_USEDEP}]
	~dev-python/expiringdict-1.2.2[${PYTHON_USEDEP}]
	>=dev-python/html2text-2020.1.16[${PYTHON_USEDEP}]
	>=dev-python/imapclient-4.0.0[${PYTHON_USEDEP}]
	>=dev-python/mail-parser-4.6.2[${PYTHON_USEDEP}]
	>=dev-python/publicsuffix2-2.20190812[${PYTHON_USEDEP}]
"

EPYTEST_PLUGINS=()
distutils_enable_tests pytest
