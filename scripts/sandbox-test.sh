#!/bin/sh
# Rootless check of the oubliette README setup: a private PORTAGE_CONFIGROOT with
# the README's repos.conf, portage's own git sync over anonymous https, then
# fetch/unpack/prepare of each USE variant from the synced copy. Writes only
# under $SB (~/.cache: /tmp is noexec). Host gentoo and oubliette repos are
# read, never synced.
set -u
SB=${SB:-$HOME/.cache/oubliette-sandbox}
[ -d "$SB" ] && find "$SB" -mindepth 1 -maxdepth 1 ! -name distfiles -exec rm -rf {} +
mkdir -p "$SB/etc/portage/repos.conf" "$SB/etc/portage/package.accept_keywords" \
	"$SB/etc/portage/package.use" "$SB/repos" "$SB/distfiles" "$SB/tmp"
ln -s "$(readlink -f /etc/portage/make.profile)" "$SB/etc/portage/make.profile"

cat > "$SB/etc/portage/make.conf" <<EOF
DISTDIR="$SB/distfiles"
PORTAGE_TMPDIR="$SB/tmp"
PORTAGE_USERNAME="$(id -un)"
PORTAGE_GRPNAME="$(id -gn)"
FEATURES="-userpriv -usersandbox -usersync -userfetch -sandbox -network-sandbox -ipc-sandbox -pid-sandbox -mount-sandbox -distcc -news"
EOF
cat > "$SB/etc/portage/repos.conf/host.conf" <<EOF
[DEFAULT]
main-repo = gentoo
[gentoo]
location = /var/db/repos/gentoo
auto-sync = no
[oubliette]
location = /var/db/repos/oubliette
auto-sync = no
EOF
# README step 2, location moved into the sandbox (OUBLIETTE_SYNC_URI: test a local
# commit before pushing, e.g. file://$PWD)
cat > "$SB/etc/portage/repos.conf/oubliette.conf" <<EOF
[oubliette]
location = $SB/repos/oubliette
sync-type = git
sync-uri = ${OUBLIETTE_SYNC_URI:-https://github.com/nabbi/oubliette-overlay.git}
auto-sync = yes
priority = 60
EOF
export PORTAGE_CONFIGROOT="$SB" GIT_TERMINAL_PROMPT=0 GIT_SSH_COMMAND=false SSH_AUTH_SOCK=

fail=0
ok()  { echo "  PASS $*"; }
bad() { echo "  FAIL $*"; fail=1; }

echo "== sync (portage git sync, anonymous https)"
emaint sync -r oubliette > "$SB/sync.log" 2>&1
if [ -f "$SB/repos/oubliette/profiles/repo_name" ]; then
	ok "synced $(git -C "$SB/repos/oubliette" log --oneline -1)"
	git -C "$SB/repos/oubliette" remote get-url origin
else
	bad "sync"; tail -20 "$SB/sync.log"; exit 1
fi
R=$SB/repos/oubliette

echo "== resolution (README step 3, fresh stable host)"
README=$R/README.md
[ -n "${README_OVERRIDE:-}" ] && README=$README_OVERRIDE
# the README's dependency block, run against the sandbox instead of /etc/portage
for f in package.accept_keywords/zoneminder-deps package.use/zoneminder-php; do
	sed -n "\#^cat > /etc/portage/$f <<'EOF'#,/^EOF\$/p" "$README"
done | sed "s#/etc/portage#$SB/etc/portage#" > "$SB/deps.sh"
sh "$SB/deps.sh"
[ -s "$SB/etc/portage/package.accept_keywords/zoneminder-deps" ] && [ -s "$SB/etc/portage/package.use/zoneminder-php" ] \
	&& ok "README dependency block applied ($(wc -l < "$SB/etc/portage/package.accept_keywords/zoneminder-deps") keywords, php USE)" \
	|| bad "README dependency block not found"
# newest master snapshots (scripts/snapshot.sh)
newest() { ls "$R"/www-misc/"$1"/"$1"-*_pre*.ebuild 2>/dev/null | sort -V | tail -1 | sed 's#.*/##; s#\.ebuild$##'; }
SMASTER=$(newest zoneminder); SZMAPI=$(newest zm-api)
[ -n "$SMASTER" ] && [ -n "$SZMAPI" ] && ok "master snapshots: $SMASTER, $SZMAPI" || bad "no zoneminder or zm-api snapshot ebuild"
cmp -s "$R/www-misc/zoneminder/zoneminder-9999.ebuild" "$R/www-misc/zoneminder/zoneminder-1.38.9999.ebuild" \
	&& ok "1.38.9999 is a copy of 9999" || bad "1.38.9999 differs from 9999"
# a series block from www-misc/zoneminder/README.md, run against the sandbox
series() {
	awk -v h="## $1" '$0 == h { f = 1; next } f && /^```shell/ { p = 1; next } p && /^```/ { exit } p' \
		"$R/www-misc/zoneminder/README.md" | sed "s#/etc/portage#$SB/etc/portage#g" > "$SB/series.sh"
	[ -s "$SB/series.sh" ] || { bad "no block for series '$1'"; return 1; }
	sh "$SB/series.sh"
}
# ~amd64 profile, as on the hosts these blocks are written for
picks() {
	series "$1" || return
	got=$(ACCEPT_KEYWORDS='~amd64' emerge -pq --nodeps www-misc/zoneminder 2>&1 | sed -n 's#.*www-misc/\(zoneminder-[^ :]*\).*#\1#p' | head -1)
	[ "$got" = "$2" ] && ok "series '$1' selects $2" || bad "series '$1' selects '${got:-nothing}', not $2"
}
mkdir -p "$SB/etc/portage/package.mask"
picks '1.36 release' zoneminder-1.36.38-r1
picks '1.36, live (1.36.9999)' zoneminder-1.36.9999
picks 'master, live (9999)' zoneminder-9999
picks '1.39 snapshots (master)' "$SMASTER"
picks '1.38, live (1.38.9999)' zoneminder-1.38.9999
picks '1.38 release (default)' zoneminder-1.38.5-r2
# full tree, as on a host that never had zoneminder
full() {
	if emerge -pq --autounmask=n "$@" > "$SB/resolve.log" 2>&1; then
		ok "full dependency tree resolves: $* ($(grep -c '^\[ebuild' "$SB/resolve.log") packages)"
	else
		bad "dependency tree: $*"; grep -E '^!!!|masked by|USE changes|^- ' "$SB/resolve.log" | head -8
	fi
}
# 1.36 needs two more keywords on a stable host
series '1.36 on a stable host'
echo '=www-misc/zoneminder-1.36*::oubliette **' > "$SB/etc/portage/package.accept_keywords/zoneminder"
rm -f "$SB/etc/portage/package.mask/zoneminder"
for v in zoneminder-1.36.38-r1 zoneminder-1.36.9999; do full "=www-misc/$v"; done
rm -f "$SB/etc/portage/package.accept_keywords/zoneminder-1.36"
series '1.38 release (default)'
full www-misc/zoneminder
emerge -pv --nodeps www-misc/zoneminder 2>&1 | grep -q 'zoneminder-1.38.5-r2::oubliette .*USE="[^"]*apiv2-cake[^"]*-apiv2-php' \
	&& ok "default: 1.38.5-r2::oubliette, apiv2-cake, -apiv2-php" || bad "default resolution"
USE="apiv2-cake apiv2-php" emerge -pv --nodeps www-misc/zoneminder 2>&1 | grep -q 'unmet requirements' \
	&& ok "both v2 flags rejected" || bad "both v2 flags accepted"
# the guide's first API v3 block: zm-api snapshots
series 'API v3'
echo 'www-misc/zoneminder apiv3' > "$SB/etc/portage/package.use/zoneminder"
full '=www-misc/zoneminder-1.38.5-r2'
grep -q "www-misc/$SZMAPI" "$SB/resolve.log" && ok "1.38.5-r2 apiv3 pulls $SZMAPI" || bad "r2 apiv3 does not pull the zm-api snapshot"
printf '%s\n' '=www-misc/zoneminder-1.38.9999::oubliette **' "=www-misc/$SMASTER::oubliette **" >> "$SB/etc/portage/package.accept_keywords/zoneminder"
full '=www-misc/zoneminder-1.38.9999'
full "=www-misc/$SMASTER"
grep -q "www-misc/$SZMAPI" "$SB/resolve.log" && ok "$SMASTER apiv3 pulls $SZMAPI" || bad "master snapshot apiv3 does not pull the zm-api snapshot"
printf '%s\n' '=www-misc/zoneminder-9999::oubliette **' '=www-misc/zm-api-9999::oubliette **' \
	> "$SB/etc/portage/package.accept_keywords/zoneminder"
full '=www-misc/zoneminder-9999'
grep -q 'www-misc/zm-api-9999' "$SB/resolve.log" && ok "9999 apiv3 pulls www-misc/zm-api-9999" || bad "apiv3 does not pull zm-api"
echo 'www-misc/zoneminder apiv3 apiv2-php -apiv2-cake' > "$SB/etc/portage/package.use/zoneminder"
full '=www-misc/zoneminder-9999'
rm -f "$SB/etc/portage/package.use/zoneminder"

# fetch, unpack, prepare one variant; $1 ebuild, $2 USE, $3 expectation
phase() {
	e=$1; use=$2; want=$3
	echo "== $e USE='$use'"
	log="$SB/$(basename "$e" .ebuild)-$(echo "$use" | tr -c 'a-z0-9\n' _).log"
	if ! USE="$use" ebuild "$R/$e" clean prepare > "$log" 2>&1; then
		bad "prepare failed, $log"; tail -15 "$log"; return
	fi
	pf=$(basename "$e" .ebuild)
	w=$(echo "$SB/tmp/portage/$(dirname "$e" | cut -d/ -f1)/$pf/work")
	# master ebuilds apply every pending security patch, the others none
	np=$(find "$R/www-misc/zoneminder/files/master-security" -name '*.patch' 2>/dev/null | wc -l)
	na=$(grep -cE ' [0-9]{2}-[^ /]*\.patch \.\.\.' "$log")
	case $pf in
	zoneminder-9999|zoneminder-1.39*)
		# an empty set (everything merged upstream) is fine: the ebuild skips eapply then
		if [ "$np" -eq 0 ]; then [ "$na" -eq 0 ] && ok "no pending security patches (set empty)" || bad "$na security patches applied from an empty set"
		else [ "$na" -eq "$np" ] && ok "$na of $np security patches applied" || bad "$na of $np security patches applied"; fi ;;
	*) [ "$na" -eq 0 ] && ok "no security patches (not master)" || bad "$na security patches applied to $pf" ;;
	esac
	# zoneminder-<version>, or zoneminder-<commit> for snapshots; not
	# zoneminder-*_build, CMake's build dir
	src=$(find "$w" -mindepth 1 -maxdepth 1 -type d -name 'zoneminder-*' ! -name '*_build' | head -1)
	[ -d "$src" ] || { bad "no source dir $src"; return; }
	# <series>.9999 must have checked out release-<series> (version.txt, or version on 1.36)
	case $pf in
	*.9999)
		series=${pf#zoneminder-}; series=${series%.9999}
		v=$(cat "$src/version.txt" "$src/version" 2>/dev/null | head -1)
		case $v in "$series".*) ok "checked out release-$series ($v)" ;; *) bad "$pf checked out version '$v'" ;; esac
		;;
	esac
	api=$src/web/api
	case $want in
	cake)
		[ -f "$api/app/Plugin/Crud/composer.json" ] && [ -d "$api/app/Plugin/CakePHP-Enum-Behavior/Model" ] && [ -d "$api/lib/Cake" ] \
			&& ok "CakePHP + Crud + Enum plugins in web/api" || bad "Cake tree incomplete"
		[ ! -e "$w/zm-php-api" ] && ok "zm-php-api not fetched" || bad "zm-php-api present"
		;;
	php)
		[ -f "$api/dispatch.php" ] && [ -f "$api/VERSION" ] && [ ! -d "$api/lib/Cake" ] \
			&& ok "web/api is zm-php-api $(cat "$api/VERSION"), no CakePHP" || bad "zm-php-api not layered"
		grep -q "Plugin/Crud\|CakePHP-Enum" "$src/.gitmodules" 2>/dev/null && bad ".gitmodules still lists Cake plugins" || true
		;;
	esac
	# CxxUrl since 1.37
	if grep -q CxxUrl "$R/$e"; then
		[ -d "$src/dep/RtspServer/src" ] && [ -f "$src/dep/CxxUrl/url.hpp" ] && ok "RtspServer + CxxUrl present" || bad "dep/ incomplete"
	else
		[ -d "$src/dep/RtspServer/src" ] && ok "RtspServer present" || bad "dep/RtspServer incomplete"
	fi
	rm -rf "$SB/tmp/portage"
}

phase www-misc/zoneminder/zoneminder-1.38.5-r2.ebuild "apiv2-cake -apiv2-php" cake
phase www-misc/zoneminder/zoneminder-1.38.5-r2.ebuild "apiv2-php -apiv2-cake" php
phase www-misc/zoneminder/zoneminder-9999.ebuild "apiv2-cake -apiv2-php" cake
phase www-misc/zoneminder/zoneminder-9999.ebuild "apiv2-php -apiv2-cake" php
# 1.36 has no apiv2-* flags: CakePHP only
phase www-misc/zoneminder/zoneminder-1.36.9999.ebuild "" cake
for s in zoneminder-1.38.9999 "$SMASTER"; do
	phase "www-misc/zoneminder/$s.ebuild" "apiv2-cake -apiv2-php" cake
	phase "www-misc/zoneminder/$s.ebuild" "apiv2-php -apiv2-cake" php
done

echo "== /api/v3 proxy block in the web server examples (USE=apiv3)"
# the ebuild's own helper, run on copies of the synced files
fd=$R/www-misc/zoneminder/files
for pf in zoneminder-1.38.5-r2 zoneminder-1.38.9999 "$SMASTER" zoneminder-9999; do
	t=$SB/apiv3-$pf; mkdir -p "$t"
	cp "$fd/zoneminder.nginx.conf" "$fd/zoneminder_vhost.include" "$t/"
	(die() { exit 1; }; eval "$(sed -n '/^zm_enable_api_v3()/,/^}/p' "$R/www-misc/zoneminder/$pf.ebuild")"
		zm_enable_api_v3 "$t/zoneminder.nginx.conf" && zm_enable_api_v3 "$t/zoneminder_vhost.include") \
		|| { bad "$pf: zm_enable_api_v3 failed"; continue; }
	if grep -qF '    location ^~ /zm/api/v3/ {' "$t/zoneminder.nginx.conf" && grep -qF '    location ^~ /zm/swagger-ui {' "$t/zoneminder.nginx.conf" && grep -q '^        proxy_pass http://127.0.0.1:8080/api/v3/;$' "$t/zoneminder.nginx.conf" \
		&& grep -q '^    ProxyPass  */zm/api/v3/' "$t/zoneminder_vhost.include" && grep -q '^</IfModule>$' "$t/zoneminder_vhost.include" \
		&& [ "$(sed -n '/# BEGIN api/,/# END api/p' "$t/zoneminder.nginx.conf" | grep -c '^ *#')" -eq 7 ]; then
		ok "$pf: nginx and Apache /api/v3 blocks enabled, prose comments kept"
	else
		bad "$pf: /api/v3 blocks not enabled as expected ($t)"
	fi
done
grep -qF '    #location ^~ /zm/api/v3/ {' "$fd/zoneminder.nginx.conf" && ok "without apiv3 the shipped files keep the block commented" || bad "files/ block not commented"

echo "== www-misc/zm-api-9999 unpack (git + cargo crates)"
if ebuild "$R/www-misc/zm-api/zm-api-9999.ebuild" clean unpack > "$SB/zm-api.log" 2>&1; then
	w=$SB/tmp/portage/www-misc/zm-api-9999/work/zm-api-9999
	n=$(ls "$SB/tmp/portage/www-misc/zm-api-9999/work/cargo_home/gentoo" 2>/dev/null | wc -l)
	[ -f "$w/Cargo.lock" ] && [ -f "$w/packaging/systemd/zm-api.service" ] && [ "$n" -gt 100 ] \
		&& ok "source + $n vendored crates" \
		|| bad "zm-api unpack incomplete"
else
	bad "zm-api unpack, $SB/zm-api.log"; tail -15 "$SB/zm-api.log"
fi
rm -rf "$SB/tmp/portage"

echo "== www-misc/$SZMAPI unpack (tarball + listed crates, no network after fetch)"
if FEATURES="network-sandbox" ebuild "$R/www-misc/zm-api/$SZMAPI.ebuild" clean unpack > "$SB/zm-api-snap.log" 2>&1; then
	w=$(find "$SB/tmp/portage/www-misc/$SZMAPI/work" -mindepth 1 -maxdepth 1 -type d -name 'zm-api-*' | head -1)
	n=$(ls "$SB/tmp/portage/www-misc/$SZMAPI/work/cargo_home/gentoo" 2>/dev/null | wc -l)
	c=$(grep -c '^	[A-Za-z0-9_-]*@' "$R/www-misc/zm-api/$SZMAPI.ebuild")
	[ -f "$w/Cargo.lock" ] && [ -f "$w/packaging/systemd/zm-api.service" ] && [ "$n" -eq "$c" ] \
		&& ok "source + $n crates, as listed in CRATES" \
		|| bad "zm-api snapshot unpack incomplete ($n of $c crates)"
else
	bad "zm-api snapshot unpack, $SB/zm-api-snap.log"; tail -15 "$SB/zm-api-snap.log"
fi
rm -rf "$SB/tmp/portage"

echo "== distfiles fetched"
find "$SB/distfiles" -mindepth 1 -maxdepth 1 ! -name 'git3-src' ! -name '.*' ! -name '*.crate' -printf '  %f\n' | sort
echo "  $(find "$SB/distfiles" -maxdepth 1 -name '*.crate' | wc -l) .crate files"
echo
[ $fail -eq 0 ] && echo "ALL PASS" || echo "FAILURES (logs in $SB)"
exit $fail
