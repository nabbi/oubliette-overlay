# Copyright 2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit acct-user

DESCRIPTION="user for c-icap-server"
ACCT_USER_ID=134
ACCT_USER_GROUPS=( cicap )

acct-user_add_deps
