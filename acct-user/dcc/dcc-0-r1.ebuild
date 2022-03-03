# Copyright 2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit acct-user

DESCRIPTION="Distributed Checksum Clearinghouses"
ACCT_USER_ID=
ACCT_USER_GROUPS=( dcc )

acct-user_add_deps
