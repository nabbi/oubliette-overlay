# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=hatchling
# upstream tests and classifies up to 3.14
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 optfeature

DESCRIPTION="Parse DMARC aggregate, failure and SMTP TLS (TLSRPT) reports"
HOMEPAGE="
	https://domainaware.github.io/parsedmarc/
	https://github.com/domainaware/parsedmarc/
	https://pypi.org/project/parsedmarc/
"
# The PyPI sdist has no tests or sample reports
SRC_URI="
	https://github.com/domainaware/parsedmarc/archive/refs/tags/${PV}.tar.gz
		-> ${P}.gh.tar.gz
"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"

# The core: file, IMAP, Maildir and mbox input; JSON/CSV, Splunk HEC,
# webhook, syslog and PostgreSQL output. dnspython[https] only for DNS over
# HTTPS nameservers (optfeature).
RDEPEND="
	>=dev-python/dnspython-2.7.0[${PYTHON_USEDEP}]
	>=dev-python/expiringdict-1.1.4[${PYTHON_USEDEP}]
	>=dev-python/httpx-0.25[${PYTHON_USEDEP}]
	>=dev-python/lxml-4.4.0[${PYTHON_USEDEP}]
	>=dev-python/mailsuite-2.3.4[${PYTHON_USEDEP}]
	>=dev-python/maxminddb-2.0.0[${PYTHON_USEDEP}]
	>=dev-python/publicsuffixlist-0.10.0[${PYTHON_USEDEP}]
	>=dev-python/python-dateutil-2.8.0[${PYTHON_USEDEP}]
	>=dev-python/pyyaml-6.0.3[${PYTHON_USEDEP}]
	>=dev-python/tqdm-4.31.1[${PYTHON_USEDEP}]
	>=dev-python/xmltodict-0.12.0[${PYTHON_USEDEP}]
"
BDEPEND="
	test? (
		dev-python/pytz[${PYTHON_USEDEP}]
	)
"

EPYTEST_PLUGINS=()
distutils_enable_tests pytest

EPYTEST_IGNORE=(
	# the output backends and mailboxes that are not packaged, or (cli)
	# imported unconditionally by the tests: Azure, Microsoft Graph,
	# Elasticsearch < 9, Kafka, GELF, OpenSearch, S3
	tests/test_cli.py
	tests/test_elastic.py
	tests/test_gelf.py
	tests/test_kafkaclient.py
	tests/test_loganalytics.py
	tests/test_opensearch.py
	tests/test_s3.py
)

EPYTEST_DESELECT=(
	# the Gmail and Microsoft Graph mailboxes (mailsuite extras)
	tests/test_init.py::TestEmailResultsViaMsGraph::testEmailResultsViaMsGraphAppendsZipExtension
	tests/test_init.py::TestEmailResultsViaMsGraph::testEmailResultsViaMsGraphBuildsSameContentAsEmailResults
	tests/test_mail.py::Test::test_full_dependencies_re_export_the_real_objects
	tests/test_mail.py::Test::test_the_two_extras_are_guarded_independently
)

pkg_postinst() {
	optfeature "DNS over HTTPS nameservers" "dev-python/dnspython[https]"
	optfeature "OpenSearch output" "dev-python/opensearch-py dev-python/boto3"
	optfeature "S3 output" dev-python/boto3
	optfeature "PostgreSQL output" dev-python/psycopg:0
}
