# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..14} )

inherit python-single-r1 systemd

if [[ ${PV} == 9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/netbox-community/netbox.git"
	EGIT_BRANCH="main"
else
	inherit pypi
	# The PyPI sdist is the full source tree plus the pre-rendered
	# documentation site, so zensical is not needed to build it.
	KEYWORDS="~amd64"
fi

DESCRIPTION="IP address management (IPAM) and data center infrastructure management (DCIM)"
HOMEPAGE="
	https://netboxlabs.com/oss/netbox/
	https://github.com/netbox-community/netbox/
	https://pypi.org/project/netbox/
"

LICENSE="Apache-2.0"
SLOT="0"
IUSE="apache2 git ldap nginx s3 saml2 sentry swift"
REQUIRED_USE="
	${PYTHON_REQUIRED_USE}
	?? ( apache2 nginx )
"

# Constraints follow upstream base_requirements.txt (what NetBox declares it
# supports); requirements.txt pins are the tested versions and are what the
# oubliette-only packages are carried at.
RDEPEND="
	${PYTHON_DEPS}
	acct-group/netbox
	acct-user/netbox
	$(python_gen_cond_dep '
		dev-python/colorama[${PYTHON_USEDEP}]
		=dev-python/django-6.1*[${PYTHON_USEDEP}]
		dev-python/django-cors-headers[${PYTHON_USEDEP}]
		dev-python/django-debug-toolbar[${PYTHON_USEDEP}]
		dev-python/django-filter[${PYTHON_USEDEP}]
		dev-python/django-htmx[${PYTHON_USEDEP}]
		~dev-python/django-mptt-0.18.0[${PYTHON_USEDEP}]
		dev-python/django-pgware[${PYTHON_USEDEP}]
		>=dev-python/django-prometheus-2.4.0[${PYTHON_USEDEP}]
		<dev-python/django-prometheus-2.5.0[${PYTHON_USEDEP}]
		dev-python/django-redis[${PYTHON_USEDEP}]
		dev-python/django-rich[${PYTHON_USEDEP}]
		dev-python/django-rq[${PYTHON_USEDEP}]
		dev-python/django-storages[${PYTHON_USEDEP}]
		dev-python/django-tables2[${PYTHON_USEDEP}]
		>=dev-python/django-taggit-7.0.0[${PYTHON_USEDEP}]
		dev-python/django-timezone-field[${PYTHON_USEDEP}]
		>=dev-python/djangorestframework-3.18.2[${PYTHON_USEDEP}]
		dev-python/drf-spectacular[${PYTHON_USEDEP}]
		dev-python/drf-spectacular-sidecar[${PYTHON_USEDEP}]
		dev-python/feedparser[${PYTHON_USEDEP}]
		dev-python/jinja2[${PYTHON_USEDEP}]
		dev-python/jsonschema[${PYTHON_USEDEP}]
		dev-python/markdown[${PYTHON_USEDEP}]
		dev-python/netaddr[${PYTHON_USEDEP}]
		dev-python/nh3[${PYTHON_USEDEP}]
		dev-python/pillow[${PYTHON_USEDEP}]
		dev-python/psycopg:0[native-extensions,${PYTHON_USEDEP}]
		dev-python/psycopg-pool[${PYTHON_USEDEP}]
		<dev-python/pymdown-extensions-12.2[${PYTHON_USEDEP}]
		dev-python/pyyaml[${PYTHON_USEDEP}]
		dev-python/redis[${PYTHON_USEDEP}]
		dev-python/requests[${PYTHON_USEDEP}]
		<dev-python/rq-3.0[${PYTHON_USEDEP}]
		<dev-python/social-auth-app-django-7.0.0[${PYTHON_USEDEP}]
		<dev-python/social-auth-core-6.0.0[${PYTHON_USEDEP}]
		dev-python/sorl-thumbnail[${PYTHON_USEDEP}]
		dev-python/strawberry-graphql[${PYTHON_USEDEP}]
		dev-python/strawberry-graphql-django[${PYTHON_USEDEP}]
		dev-python/svgwrite[${PYTHON_USEDEP}]
		dev-python/tablib[${PYTHON_USEDEP}]
		dev-python/tzdata[${PYTHON_USEDEP}]
		www-servers/gunicorn[${PYTHON_USEDEP}]
		git? ( dev-python/dulwich[${PYTHON_USEDEP}] )
		ldap? ( dev-python/django-auth-ldap[${PYTHON_USEDEP}] )
		s3? ( dev-python/boto3[${PYTHON_USEDEP}] )
		saml2? ( dev-python/python3-saml[${PYTHON_USEDEP}] )
		sentry? ( dev-python/sentry-sdk[${PYTHON_USEDEP}] )
		swift? ( dev-python/django-storage-swift[${PYTHON_USEDEP}] )
	')
	apache2? (
		www-servers/apache[apache2_modules_alias,apache2_modules_headers,apache2_modules_proxy,apache2_modules_proxy_http,apache2_modules_rewrite,ssl]
	)
	nginx? ( www-servers/nginx )
"

src_install() {
	# Mutable instance data lives in /var/lib/netbox; the source tree keeps
	# symlinks at the paths NetBox's checkout layout expects.
	local d
	for d in media reports scripts static; do
		rm -rf netbox/${d} || die
		dosym -r /var/lib/netbox/${d} /opt/netbox/netbox/${d}
		keepdir /var/lib/netbox/${d}
		fowners netbox:netbox /var/lib/netbox/${d}
	done
	insinto /var/lib/netbox/reports
	newins - __init__.py < /dev/null
	insinto /var/lib/netbox/scripts
	newins - __init__.py < /dev/null

	insinto /opt/netbox
	# docs/ is DOCS_ROOT (in-app model help) for a checkout layout
	doins -r netbox docs
	fperms 0755 /opt/netbox/netbox/manage.py
	python_fix_shebang "${ED}"/opt/netbox/netbox/manage.py
	python_optimize "${ED}"/opt/netbox/netbox

	insinto /etc/netbox
	newins netbox/netbox/configuration_example.py configuration.py
	doins contrib/gunicorn.py
	fowners root:netbox /etc/netbox /etc/netbox/configuration.py
	fperms 0750 /etc/netbox
	fperms 0640 /etc/netbox/configuration.py
	dosym -r /etc/netbox/configuration.py /opt/netbox/netbox/netbox/configuration.py
	# ldap_config.py is read from beside the active configuration.py
	use ldap && dosym -r /etc/netbox/ldap_config.py /opt/netbox/netbox/netbox/ldap_config.py

	keepdir /var/log/netbox
	fowners netbox:netbox /var/log/netbox
	insinto /etc/logrotate.d
	newins "${FILESDIR}"/netbox.logrotate netbox

	local f
	for f in netbox.service netbox-rq.service netbox.initd netbox-rq.initd; do
		sed "s|@EPYTHON@|${EPYTHON}|g" "${FILESDIR}"/${f} > "${T}"/${f} || die
	done
	systemd_dounit "${T}"/netbox.service "${T}"/netbox-rq.service
	newinitd "${T}"/netbox.initd netbox
	newinitd "${T}"/netbox-rq.initd netbox-rq

	cat > "${T}"/netbox-manage <<-EOF || die
		#!/bin/sh
		# Run NetBox management commands (as the netbox user), e.g.
		#   su -s /bin/sh -c 'netbox-manage createsuperuser' netbox
		cd /opt/netbox/netbox || exit 1
		exec /usr/bin/${EPYTHON} /opt/netbox/netbox/manage.py "\$@"
	EOF
	dobin "${T}"/netbox-manage

	if use apache2; then
		insinto /etc/apache2/vhosts.d
		doins "${FILESDIR}"/70_netbox.conf
	fi
	if use nginx; then
		insinto /etc/netbox
		newins "${FILESDIR}"/netbox-nginx.conf nginx.conf
	fi

	dodoc README.md
	docinto contrib
	dodoc contrib/{apache.conf,nginx.conf,gunicorn.py,uwsgi.ini,netbox.service,netbox-rq.service}
}

pkg_postinst() {
	if [[ -z ${REPLACING_VERSIONS} ]]; then
		elog "NetBox needs PostgreSQL 15+ and Redis 6+ (local or remote)."
		elog "Create the database and role as in the upstream guide:"
		elog "  https://netboxlabs.com/docs/netbox/installation/1-postgresql/"
		elog
		elog "Then set ALLOWED_HOSTS, DATABASES and REDIS in /etc/netbox/configuration.py"
		elog "and run:"
		elog "  emerge --config ${CATEGORY}/${PN}"
		elog "which generates SECRET_KEY / API_TOKEN_PEPPERS when empty and runs"
		elog "'manage.py upgrade' (migrations, collectstatic, reindex, ...)."
		elog
		elog "Create an admin account with:"
		elog "  su -s /bin/sh -c 'netbox-manage createsuperuser' netbox"
		elog
		elog "Plugins are separate packages (dev-python/netbox-*, dev-python/netboxlabs-*)."
		elog "Enable them in PLUGINS in /etc/netbox/configuration.py."
	else
		elog "Run 'emerge --config ${CATEGORY}/${PN}' to apply migrations and"
		elog "collect static files, then restart netbox and netbox-rq."
	fi
	if use apache2; then
		elog
		elog "Apache: edit /etc/apache2/vhosts.d/70_netbox.conf and add"
		elog "'-D NETBOX -D SSL -D PROXY' to APACHE2_OPTS in /etc/conf.d/apache2."
	fi
	if use nginx; then
		elog
		elog "nginx: edit /etc/netbox/nginx.conf and add"
		elog "'include /etc/netbox/nginx.conf;' to the http {} block of nginx.conf."
	fi
	if use ldap; then
		elog
		elog "LDAP: create /etc/netbox/ldap_config.py (root:netbox, 0640) as described in"
		elog "  https://netboxlabs.com/docs/netbox/installation/6-ldap/"
	fi
}

pkg_config() {
	python_setup

	local conf="${EROOT}"/etc/netbox/configuration.py
	einfo "Checking SECRET_KEY and API_TOKEN_PEPPERS in ${conf}"
	"${EPYTHON}" - "${conf}" "${EROOT}"/opt/netbox/netbox <<-'EOF' || die "failed to update ${conf}"
		import sys
		conf, tree = sys.argv[1], sys.argv[2]
		sys.path.insert(0, tree)
		from utilities.secret_key import generate_secret_key as gen
		lines = open(conf).read().split("\n")
		changed = False
		for i, line in enumerate(lines):
		    if line == "SECRET_KEY = ''":
		        lines[i] = f"SECRET_KEY = {gen()!r}"
		        print(" * generated SECRET_KEY")
		        changed = True
		    elif line == "API_TOKEN_PEPPERS = {}":
		        lines[i] = f"API_TOKEN_PEPPERS = {{1: {gen()!r}}}"
		        print(" * generated API_TOKEN_PEPPERS[1]")
		        changed = True
		if changed:
		    open(conf, "w").write("\n".join(lines))
	EOF

	einfo "Running 'manage.py upgrade --no-input' as netbox"
	su -s /bin/sh \
		-c "cd /opt/netbox/netbox && /usr/bin/${EPYTHON} manage.py upgrade --no-input" \
		netbox || die "manage.py upgrade failed; see the error above (configuration.py, PLUGINS_CONFIG)"
	einfo "Done. Restart netbox and netbox-rq."
}
