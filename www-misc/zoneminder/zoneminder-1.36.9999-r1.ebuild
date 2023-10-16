# Copyright 2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit perl-functions readme.gentoo-r1 cmake flag-o-matic systemd optfeature

MY_CRUD_V="3.0"
MY_CAKEPHP_V="master"
MY_RTSP_V="master"

DESCRIPTION="full-featured, open source, state-of-the-art video surveillance software system"
HOMEPAGE="http://www.zoneminder.com/"

MY_PV_MM=$(ver_cut 1-2)
MY_PV_P=$(ver_cut 3-)
if [[ ${PV} == 9999 || ${MY_PV_P} == 9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/ZoneMinder/zoneminder"
	if [[ "${MY_PV_MM}" == 1.36 ]]; then
		EGIT_BRANCH="release-${MY_PV_MM}"
	fi
else
	SRC_URI="
		https://github.com/ZoneMinder/${PN}/archive/refs/tags/${PV}.tar.gz -> ${P}.tar.gz
		https://github.com/FriendsOfCake/crud/archive/${MY_CRUD_V}.tar.gz -> Crud-${MY_CRUD_V}.tar.gz
		https://github.com/ZoneMinder/CakePHP-Enum-Behavior/archive/${MY_CAKEPHP_V}.tar.gz -> \
			CakePHP-Enum-Behavior-${MY_CAKEPHP_V}.tar.gz
		https://github.com/ZoneMinder/RtspServer/archive/${MY_RTSP_V}.tar.gz -> RtspServer-${MY_RTSP_V}.tar.gz"
	KEYWORDS="~amd64"
fi

LICENSE="GPL-2"
IUSE_WEB_SERVER="apache2 nginx"
IUSE="curl gcrypt gnutls +mmap +ssl vlc +apache2 nginx"
SLOT="0"
REQUIRED_USE="
	|| ( ssl gnutls )
	^^ ( ${IUSE_WEB_SERVER} )
"

DEPEND_WEB_SERVER="
apache2? ( www-servers/apache )
nginx? (
	www-servers/nginx:*
	www-misc/fcgiwrap
	www-servers/spawn-fcgi
	www-servers/multiwatch
)
"

DEPEND="
app-eselect/eselect-php
dev-lang/perl:=
dev-lang/php:*[curl,gd,inifile,intl,pdo,mysql,mysqli,sockets,sysvipc]
dev-libs/libpcre
dev-perl/Archive-Zip
dev-perl/Class-Std-Fast
dev-perl/Data-Dump
dev-perl/Date-Manip
dev-perl/Data-UUID
dev-perl/DBD-mysql
dev-perl/DBI
dev-perl/IO-Socket-Multicast
dev-perl/SOAP-WSDL
dev-perl/Sys-CPU
dev-perl/Sys-MemInfo
dev-perl/URI-Encode
dev-perl/libwww-perl
dev-perl/Number-Bytes-Human
dev-perl/JSON-MaybeXS
dev-perl/Crypt-Eksblowfish
dev-perl/Data-Entropy
dev-perl/HTTP-Lite
dev-perl/MIME-Lite
dev-perl/MIME-tools
dev-perl/X10
dev-perl/DateTime
dev-perl/Device-SerialPort
dev-php/pecl-apcu:*
sys-auth/polkit
sys-libs/zlib
>=media-video/ffmpeg-5[x264,x265,jpeg2k]
virtual/httpd-php:*
media-libs/libjpeg-turbo:0
virtual/perl-ExtUtils-MakeMaker
virtual/perl-Getopt-Long
virtual/perl-Sys-Syslog
virtual/perl-Time-HiRes
curl? ( net-misc/curl )
gcrypt? ( dev-libs/libgcrypt:0= )
gnutls? (
		net-libs/gnutls
		dev-libs/libjwt[gnutls,ssl?]
)
mmap? ( dev-perl/Sys-Mmap )
ssl? ( dev-libs/openssl:0= )
vlc? ( media-video/vlc[live] )
${DEPEND_WEB_SERVER}
"
# webserver is a build time depend; we need the user/group to already exist

RDEPEND="${DEPEND}"

MY_ZM_WEBDIR=/usr/share/zoneminder/www

PATCHES=(
	"${FILESDIR}/${PN}-1.34.17_dont_gz_man.patch"
)

pkg_setup() {
	if use nginx ; then
		MY_WEB_USER=nginx
		MY_WEB_GROUP=nginx
		MY_WEB_INITD=nginx
	elif use apache2 ; then
		MY_WEB_USER=apache
		MY_WEB_GROUP=apache
		MY_WEB_INITD=apache2
	fi
	# allow the user to override
	[[ -n "${ZM_WEBSRV_USER}" ]] && MY_WEB_USER=${ZM_WEBSRV_USER}
	[[ -n "${ZM_WEBSRV_GROUP}" ]] && MY_WEB_GROUP=${ZM_WEBSRV_GROUP}
	[[ -n "${ZM_WEBSRV_INITD}" ]] && MY_WEB_INITD=${ZM_WEBSRV_INITD}
	# bail if web user:group not set
	if [[ -z "${MY_WEB_USER}" || -z "${MY_WEB_GROUP}" ]]; then
		die "no web server configured"
	fi

	export MY_WEB_USER MY_WEB_GROUP MY_WEB_INITD
}

src_prepare() {
	cmake_src_prepare

	if ! [[ ${PV} == 9999 || ${MY_PV_P} == 9999 ]]; then
		rmdir "${S}/web/api/app/Plugin/Crud" || die
		mv "${WORKDIR}/crud-${MY_CRUD_V}" "${S}/web/api/app/Plugin/Crud" || die

		rmdir "${S}/web/api/app/Plugin/CakePHP-Enum-Behavior" || die
		mv "${WORKDIR}/CakePHP-Enum-Behavior-${MY_CAKEPHP_V}" "${S}/web/api/app/Plugin/CakePHP-Enum-Behavior" || die

		rmdir "${S}/dep/RtspServer" || die
		mv "${WORKDIR}/RtspServer-${MY_RTSP_V}" "${S}/dep/RtspServer" || die
	fi
}

src_configure() {
	append-cxxflags -D__STDC_CONSTANT_MACROS
	perl_set_version
	export TZ=UTC # bug 630470

	if ! use gcrypt; then
		sed -i '/find_library(GCRYPT_LIBRARIES/d' CMakeLists.txt
	fi
	if ! use gnutls; then
		sed -i '/find_library(GNUTLS_LIBRARIES/d' CMakeLists.txt
	fi

	mycmakeargs=(
		-DZM_TMPDIR=/var/tmp/zm
		-DZM_SOCKDIR=/run/zm
		-DZM_RUNDIR=/run/zm
		-DZM_PATH_ZMS="/zm/cgi-bin/nph-zms"
		-DZM_LOGDIR=/var/log/zm
		-DZM_CACHEDIR=/var/cache/zoneminder
		-DZM_CONTENTDIR=/var/lib/zoneminder
		-DZM_CONFIG_DIR="/etc/zm"
		-DZM_CONFIG_SUBDIR="/etc/zm/conf.d"
		-DZM_WEB_USER=${MY_WEB_USER}
		-DZM_WEB_GROUP=${MY_WEB_GROUP}
		-DZM_WEBDIR=${MY_ZM_WEBDIR}
		-DZM_NO_MMAP="$(usex mmap OFF ON)"
		-DZM_NO_X10=OFF
		-DZM_NO_CURL="$(usex curl OFF ON)"
		-DZM_NO_LIBVLC="$(usex vlc OFF ON)"
		-DZM_NO_RTSPSERVER=OFF
		-DCMAKE_DISABLE_FIND_PACKAGE_OpenSSL="$(usex ssl OFF ON)"
	)

	cmake_src_configure

}

src_install() {
	cmake_src_install

	# the log directory, can contain passwords - limit access
	keepdir /var/log/zm
	fperms 0750 /var/log/zm
	fowners ${MY_WEB_USER}:${MY_WEB_GROUP} /var/log/zm

	# the logrotate script
	insinto /etc/logrotate.d
	newins distros/ubuntu2004/zoneminder.logrotate zoneminder

	# now we duplicate the work of zmlinkcontent.sh
	keepdir /var/lib/zoneminder /var/lib/zoneminder/images /var/lib/zoneminder/events

	# set perms/owners per dir, to keep .keep files root owned
	fperms 0775 /var/lib/zoneminder /var/lib/zoneminder/images /var/lib/zoneminder/events
	fowners ${MY_WEB_USER}:${MY_WEB_GROUP} /var/lib/zoneminder /var/lib/zoneminder/images /var/lib/zoneminder/events

	# the configuration file
	fperms 0640 /etc/zm/zm.conf
	fowners root:${MY_WEB_GROUP} /etc/zm/zm.conf
	## can't use fperms / fowners with file globs
	chmod 0640 "${ED}"/etc/zm/conf.d/*.conf
	chown root:${MY_WEB_GROUP} "${ED}"/etc/zm/conf.d/*.conf

	# init scripts etc
	cp "${FILESDIR}"/init.d-r1 "${T}"/init.d || die
	sed -i "${T}"/init.d -e "s:%WWW_SERVER%:${MY_WEB_INITD}:g" \
		-e "s/%ZM_OWNER%/${MY_WEB_USER}:${MY_WEB_GROUP}/g" || die
	newinitd "${T}"/init.d zoneminder

	# systemd unit file
	# Requires -> Wants for weak depend, don't mess with the TZ Environment
	sed -i "${BUILD_DIR}"/misc/zoneminder.service -e 's/Requires=/Wants=/' -e '/Environment=TZ=:/d' || die
	systemd_newunit "${BUILD_DIR}"/misc/zoneminder.service zoneminder.service

	# apache2 conf file
	if use apache2; then
		cp "${FILESDIR}"/zoneminder_vhost.include "${T}"/zoneminder_vhost.include || die
		sed -i "${T}"/zoneminder_vhost.include -e "s:%ZM_WEBDIR%:${MY_ZM_WEBDIR}:g" || die
		dodoc "${FILESDIR}"/zoneminder_vhost.conf "${T}"/zoneminder_vhost.include
	fi

	# nginx conf files
	if use nginx; then
		dodoc "${FILESDIR}"/zoneminder.nginx.conf "${FILESDIR}"/zoneminder.php-fpm.conf
		newconfd "${FILESDIR}"/spawn-fcgi.zoneminder.confd spawn-fcgi.zoneminder
		newinitd "${FILESDIR}"/spawn-fcgi.zoneminder.initd spawn-fcgi.zoneminder
	fi

	dodoc CHANGELOG.md CONTRIBUTING.md README.md

	perl_delete_packlist

	README_GENTOO_SUFFIX="-r1"
	readme.gentoo_create_doc
}

pkg_postinst() {
	readme.gentoo_print_elog

	if [[ -z "${REPLACING_VERSIONS}" ]]; then
			elog "Fresh installs of zoneminder require a few additional steps. Please read the README.gentoo"
			elog ""
			elog "This package requires access to a Mysql compatible database server"
			elog "ZoneMinder can connect to a remote database if desired"
			optfeature_header "Mysql compatible database server"
			optfeature "Install if you don't already have one" virtual/mysql
			elog ""
			elog "There are optional features/enhancements that can be added"
			optfeature_header "Onvif Access"
			optfeature "Verbose responses from camera" dev-perl/XML-LibXML
			optfeature "Event monitoring" dev-perl/SOAP-Lite
			optfeature_header "Email"
			optfeature "Older email package (if new one isn't working)" dev-perl/MIME-tools
			optfeature_header "Event creation enhancements"
			optfeature "Retrieves image size" dev-perl/Image-Info
			optfeature_header "Storage"
			optfeature "Archive to SFTP server" dev-perl/Net-SFTP-Foreign
			optfeature "Copy to Amazon S3 bucket" dev-perl/Net-Amazon-S3 dev-perl/File-Slurp
	else
		local v
		for v in ${REPLACING_VERSIONS}; do
			if ver_test ${PV} -gt ${v}; then
				elog "You have upgraded zoneminder and may have to upgrade your database now using the 'zmupdate.pl' script."
			fi
		done
	fi

	# 2023-06-20 apache2 config no longer installed by default
	# avoid breaking an existing install, advise user to migrate
	if use apache2; then
		if [[ -f "/etc/apache2/vhosts.d/10_zoneminder.conf" ]]; then
			ewarn ""
			ewarn "This ZoneMinder package no longer installs 10_zoneminder.conf under /etc/apache2/vhosts.d"
			ewarn ""
			ewarn "Example apache configs have been placed under /usr/share/doc/${PF}"
			ewarn ""
			ewarn "Your old configuration should be reviewed"
			ewarn "To suppresee this message, name your local configuraiton file something else"
			ewarn ""
		fi
	fi

	# 2022-02-10 The original ebuild omitted ZM_CONFIG_* at build time
	# Check if user needs to migrate configs from /etc to /etc/zm
	local legacy="/etc/zm.conf /etc/conf.d/01-system-paths.conf /etc/conf.d/02-multiserver.conf /etc/conf.d/zmcustom.conf"
	local lf
	local lfwarn=0
	for lf in ${legacy}; do
		if [[ -f "${lf}" ]]; then
			ewarn "Found deprecated ZoneMinder config ${lf}"
			lfwarn=1
		fi
	done
	if [ ${lfwarn} -ne 0 ]; then
		ewarn ""
		ewarn "Gentoo's ebuild previously installed ZoneMinder's configurations directly into /etc"
		ewarn "This conflicts with OpenRC /etc/conf.d as ZoneMinder also has its own conf.d subdirectory"
		ewarn "Your newly compiled ZoneMinder now looks for configurations under /etc/zm"
		ewarn ""
		ewarn "    Please merge your local changes into /etc/zm/conf.d/99-local.conf"
		ewarn "    This includes any user created *.conf files for ZM within /etc/conf.d/"
		ewarn "    Then remove those old files to complete the migration."
		ewarn ""
		elog ""
		elog "Remember to set appropriate permisions on user created files (i.e. /etc/zm/conf.d/*.conf):"
		elog "    chmod 640 local.conf"
		elog "    chown root:${MY_WEB_GROUP} local.conf"
		elog ""
		ewarn ""
		ewarn "ZoneMinder will **NO LONGER FUNCTION UNTIL** these configuration items have been migrated!"
		ewarn "In particular, ensuring the database hostname and credentials are defined within the new locations."
		ewarn ""
	fi
}
