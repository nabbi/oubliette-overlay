# Copyright 2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit acct-user

DESCRIPTION="User for mail-filter/dkimpy-milter"
ACCT_USER_ID=618
ACCT_USER_GROUPS=( dkimpy-milter )

acct-user_add_deps
