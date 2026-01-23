# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{11..14} )
DISTUTILS_USE_PEP517=hatchling

DOCS_BUILDER="mkdocs"
DOCS_DEPEND="
	>=dev-python/mkdocs-pymdownx-material-extras-2.0
	dev-python/mkdocs-material
	dev-python/mkdocs-git-revision-date-localized-plugin
	dev-python/mkdocs-minify-plugin
	dev-python/pyspelling
"

inherit distutils-r1 docs

DESCRIPTION="Wildcard/glob file name matcher"
HOMEPAGE="
	https://github.com/facelessuser/wcmatch/
	https://pypi.org/project/wcmatch/
"
LICENSE="MIT"
SLOT="0"
KEYWORDS="amd64 ~arm arm64 ~ppc ~ppc64 ~riscv x86"

if [[ ${PV} == 9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/facelessuser/wcmatch.git"
	EGIT_BRANCH="main"
	PROPERTIES="live"
	KEYWORDS=""
else
	SRC_URI="https://github.com/facelessuser/wcmatch/archive/refs/tags/${PV}.tar.gz -> ${P}.gh.tar.gz"
fi

RDEPEND="
	>=dev-python/bracex-2.1.1[${PYTHON_USEDEP}]
"

BDEPEND="
	doc? ( dev-vcs/git )
	test? ( dev-vcs/git )
"

distutils_enable_tests pytest

python_prepare_all() {
	export HOME="${T}"

	# tests require some files in homedir
	> "${HOME}"/test1.txt || die
	> "${HOME}"/test2.txt || die

	# mkdocs-git-revision-date-localized-plugin needs a git repo.
	# For 9999 we already have one; for tarballs, initialize a minimal repo.
	if use doc && [[ ${PV} != 9999 ]]; then
		git init || die
		git config user.email "larry@gentoo.org" || die
		git config user.name "Larry the Cow" || die
		git add . || die
		git commit -m 'init' || die
	fi

	distutils-r1_python_prepare_all
}

