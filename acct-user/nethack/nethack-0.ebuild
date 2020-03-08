# Copyright 2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit acct-user

DESCRIPTION="A user for nethack and forks"

ACCT_USER_GROUPS=( "gamestat" )
ACCT_USER_ID="1982" #devlopment of hack began

acct-user_add_deps
