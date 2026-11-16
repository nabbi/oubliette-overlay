# www-apps/netbox

[NetBox](https://github.com/netbox-community/netbox), the network source of
truth (IPAM/DCIM), packaged with its Python dependencies and the official
plugins. Everything ::gentoo lacks is carried in this overlay.

| Version | Source |
|---------|--------|
| `4.7.5` | PyPI sdist: the full source tree plus the pre-rendered documentation site |
| `9999`  | `main` from GitHub; no pre-rendered docs site (in-app model help still works) |

## Layout

NetBox is installed in upstream's source-checkout layout (the production
install method; upstream's pip-package layout is experimental in 4.7):

| Path | Contents |
|------|----------|
| `/opt/netbox/netbox` | Application code, run by the selected `PYTHON_SINGLE_TARGET` |
| `/opt/netbox/docs` | Documentation sources (`DOCS_ROOT`, in-app model help) |
| `/etc/netbox/configuration.py` | Configuration (`root:netbox`, `0640`), symlinked into the tree |
| `/etc/netbox/ldap_config.py` | LDAP settings with `USE=ldap`; you create it |
| `/etc/netbox/gunicorn.py` | Gunicorn settings (listens on `127.0.0.1:8001`) |
| `/var/lib/netbox/{media,reports,scripts,static}` | Instance data, symlinked into the tree |
| `/var/log/netbox` | OpenRC service logs |

`netbox-manage` runs `manage.py` with the right interpreter; run it as the
`netbox` user.

## USE flags

| Flag | Effect |
|------|--------|
| `apache2` | `/etc/apache2/vhosts.d/70_netbox.conf`, gated by `-D NETBOX` |
| `nginx` | `/etc/netbox/nginx.conf`, to `include` from the `http {}` block |
| `ldap` | `django-auth-ldap` |
| `saml2` | `python3-saml` |
| `sentry` | `sentry-sdk` |
| `s3` | `boto3` (S3 data sources and storage) |
| `swift` | `django-storage-swift` |
| `git` | `dulwich` (git data sources) |

`apache2` and `nginx` are mutually exclusive. With `apache2`, add
`-D NETBOX -D SSL -D PROXY` to `APACHE2_OPTS` in `/etc/conf.d/apache2`, and
build apache with `apache2_modules_proxy apache2_modules_proxy_http`.

## Install

On a stable host, keyword the ::gentoo dependencies that are still testing
(the oubliette packages are all `~amd64`):

```shell
# /etc/portage/package.accept_keywords/netbox
www-apps/netbox
dev-python/django-auth-ldap
dev-python/django-cors-headers
dev-python/django-debug-toolbar
dev-python/django-filter
dev-python/django-js-asset
dev-python/django-redis
dev-python/django-tables2
dev-python/django-timezone-field
dev-python/djangorestframework
dev-python/svgwrite
```

Then:

1. `emerge www-apps/netbox`
2. Set up PostgreSQL 15+ and Redis 6+ (local or remote), creating the database
   and role as in the
   [upstream guide](https://netboxlabs.com/docs/netbox/installation/1-postgresql/).
3. Set `ALLOWED_HOSTS`, `DATABASES` and `REDIS` in `/etc/netbox/configuration.py`.
4. `emerge --config www-apps/netbox`. This fills an empty `SECRET_KEY` and
   `API_TOKEN_PEPPERS`, then runs `manage.py upgrade --no-input` (migrations,
   `collectstatic`, reindex and so on) as `netbox`.
5. `su -s /bin/sh -c 'netbox-manage createsuperuser' netbox`
6. Start `netbox` and `netbox-rq` (OpenRC or systemd) and the web server.

After every NetBox upgrade, run `emerge --config www-apps/netbox` again and
restart both services.

## Plugins

Plugins are separate packages built for NetBox's single Python target. Each
one depends on the NetBox range it supports (or `9999`). Installing one does
not enable it: add it to `PLUGINS` in `/etc/netbox/configuration.py`, then run
`emerge --config www-apps/netbox`.

| Package | `PLUGINS` entry |
|---------|-----------------|
| `dev-python/netbox-acls` | `netbox_acls` |
| `dev-python/netbox-bgp` | `netbox_bgp` |
| `dev-python/netbox-floorplan-plugin` | `netbox_floorplan` |
| `dev-python/netbox-healthcheck-plugin` | `netbox_healthcheck_plugin` |
| `dev-python/netbox-napalm-plugin` | `netbox_napalm_plugin` |
| `dev-python/netbox-qrcode` | `netbox_qrcode` |
| `dev-python/netbox-reorder-rack` | `netbox_reorder_rack` |
| `dev-python/netbox-scripts` | `netbox_scripts` |
| `dev-python/netbox-topology-views` | `netbox_topology_views` |
| `dev-python/netboxlabs-diode-netbox-plugin` | `netbox_diode_plugin` |
| `dev-python/netboxlabs-netbox-branching` | `netbox_branching` |
| `dev-python/netboxlabs-netbox-custom-objects` | `netbox_custom_objects` |

The three `netboxlabs-*` plugins are under the NetBox Limited Use License 1.0
(no redistribution, internal use only). Accept it explicitly:

```shell
# /etc/portage/package.license/netbox
dev-python/netboxlabs-* NetBox-Limited-Use-1.0
```

## Dependency versions

Version constraints follow upstream's `base_requirements.txt`, the ranges
NetBox declares support for. Packages that only this overlay carries are at
the version NetBox tests with (`requirements.txt`). Two ::gentoo packages
also have a copy here:

* `dev-python/django-prometheus-2.4.0`, because NetBox requires `<2.5`
* `dev-python/django-taggit-7.0.0`, the first release that supports Django 6.x

The `custom-objects` plugin is held at `0.7.2`, the range NetBox's own
`custom-objects` extra pins.
