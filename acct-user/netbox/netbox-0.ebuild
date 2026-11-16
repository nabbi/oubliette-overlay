# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit acct-user

DESCRIPTION="A user for www-apps/netbox"

ACCT_USER_GROUPS=( "netbox" )
ACCT_USER_HOME="/var/lib/netbox"
ACCT_USER_ID="422"

acct-user_add_deps
