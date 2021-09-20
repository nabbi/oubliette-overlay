# Copyright 2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit acct-user

# boostrap protocol port
DESCRIPTION="DHCP Forwarder"
ACCT_USER_ID=67
ACCT_USER_GROUPS=( dhcp-fwd )

acct-user_add_deps
