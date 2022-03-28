# Copyright 2019-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit acct-user

DESCRIPTION="User for mail-filter/openarc"

ACCT_USER_ID=617	#RFC 8617
ACCT_USER_GROUPS=( openarc )

ACCT_USER_HOME="/var/lib/openarc"
ACCT_USER_HOME_PERMS=0700

acct-user_add_deps
