# www-misc/zm-api

[zm-api](https://github.com/SteveGilvarry/zm-api) is ZoneMinder's REST API v3,
written in Rust and meant to replace API v2 eventually. It runs as a service on
`127.0.0.1:8080` next to API v2. `www-misc/zoneminder[apiv3]` pulls it in and
turns on the proxy block in the web server examples.

Upstream has no tags yet, so this overlay offers:

| Version | What it is | Keywords |
| --- | --- | --- |
| `3.0.0_alpha1_pre<date>` | snapshot pinning one master commit and its crates | `~amd64` |
| `9999` | master head at build time; fetches crates during unpack | none |

## Install

```shell
# stable hosts only
echo 'www-misc/zm-api::oubliette ~amd64' >> /etc/portage/package.accept_keywords/zoneminder
# or live
#echo '=www-misc/zm-api-9999::oubliette **' >> /etc/portage/package.accept_keywords/zoneminder

echo 'www-misc/zoneminder apiv3' >> /etc/portage/package.use/zoneminder
emerge -av www-misc/zoneminder
```

## First start

1. `emerge --config www-misc/zm-api` creates the JWT keys in `/var/lib/zm-api/keys`.
2. Back up the database, then run `zm-api-db bridge` as root to bring it up to
   zm-api's schema. zm-api only warns at startup when migrations fail.
3. Run `rc-update add zm-api default && rc-service zm-api start`. On systemd, run
   `/usr/share/zm-api/setup-instance.sh` once first.
4. Use zoneminder's web server example, or copy its block between
   `# BEGIN api/v3` and `# END api/v3` into an existing config. Apache also
   needs `mod_proxy`, `mod_proxy_http`, `mod_proxy_wstunnel` (`-D PROXY`) and
   `mod_headers`.

The API is then at `/zm/api/v3`, with docs at `/zm/api-docs/` and Swagger UI at
`/zm/swagger-ui/`.

## Configuration

`/etc/zm-api/zm-api.env` overrides `/etc/zm-api/{base,prod}.toml`. Database
settings come from `/etc/zm/zm.conf`, and the service runs as ZoneMinder's web
user. Main settings:

- `APP_SERVER__ADDR` / `APP_SERVER__PORT`: loopback `:8080` by default.
- `APP_SERVER__PUBLIC_PREFIX=/zm`: the path prefix zm-api uses in the links it
  writes. Clear it when zm-api is served at the site root.
- `APP_DAEMON__ENABLED=false`: passive mode, where `zmdc.pl` keeps control of the
  daemons. `zm-api-takeover` hands that control to zm-api on systemd. On OpenRC,
  stop zoneminder, set the value to `true`, and restart zm-api.

For the database tool, see `man 8 zm-api-db`.

## Maintaining

- **Snapshots:** `scripts/snapshot.sh zm-api [date|commit]` copies 9999, pins
  `ZM_API_COMMIT`, and fills `CRATES` and the crate licenses from that commit's
  `Cargo.lock` with pycargoebuild. Keep the last two or three.
- **Swagger UI:** `SWAGGER_UI_VER` must match what `utoipa-swagger-ui` would
  download. Bump it with that crate.
- **9999:** `cargo_live_src_unpack` runs from `${S}`. The 2026-11-07 cargo.eclass
  runs `cargo fetch` in the current directory, which is WORKDIR.
- Changes to 9999 reach new snapshots only. An existing snapshot gets them by
  hand, with a revision bump.

This README is in the Manifest. After editing it, run
`ebuild zm-api-9999.ebuild manifest`.
