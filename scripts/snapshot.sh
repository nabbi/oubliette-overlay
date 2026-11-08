#!/bin/sh
# Writes a snapshot ebuild for an untagged upstream master commit, named
# <upstream version>_pre<commit date, UTC>, from the package's 9999 ebuild.
# The same date always gives the same commit and file name.
#
#   scripts/snapshot.sh zoneminder              master head
#   scripts/snapshot.sh zoneminder 2026-10-18   last master commit on or before that day (UTC)
#   scripts/snapshot.sh zm-api 873486b          that commit (must be on master)
#
# zoneminder: version.txt; sets MY_ZM_COMMIT and the submodule pins of that
#   commit. Its release branches get <series>.9999 live ebuilds instead.
# zm-api: Cargo.toml's version (3.0.0-alpha.1 -> 3.0.0_alpha1); sets
#   ZM_API_COMMIT and fills CRATES and the crate LICENSE from that commit's
#   Cargo.lock with pycargoebuild (PYCARGOEBUILD, else on PATH, else
#   ~/.cache/oubliette/pycargoebuild-venv/bin).
#
# Commits are picked along first parents, as git-r3's EGIT_COMMIT_DATE does.
# zoneminder snapshots get no KEYWORDS: hosts opt in with ** on a version atom, see
# www-misc/zoneminder/README.md. Upstream is read from a bare clone in
# ~/.cache/oubliette/<package>.git.
set -eu

top=$(git -C "$(dirname "$0")" rev-parse --show-toplevel)
cache=${XDG_CACHE_HOME:-$HOME/.cache}/oubliette
usage() { sed -n '2,21p' "$0" | sed 's/^# \{0,1\}//'; exit "$1"; }
case ${1:-} in
zoneminder) url=https://github.com/ZoneMinder/zoneminder; var=MY_ZM_COMMIT ;;
zm-api) url=https://github.com/SteveGilvarry/zm-api; var=ZM_API_COMMIT ;;
-h|--help) usage 0 ;;
*) usage 2 ;;
esac
name=$1
pick=${2:-}
pkg=$top/www-misc/$name
tpl=$pkg/$name-9999.ebuild
branch=master

up=$cache/$name.git
[ -d "$up" ] || git clone -q --bare --filter=blob:none "$url" "$up"
git -C "$up" fetch -q origin "+refs/heads/$branch:refs/heads/$branch"

if [ -z "$pick" ]; then
	commit=$(git -C "$up" rev-parse "refs/heads/$branch")
elif git -C "$up" rev-parse -q --verify "$pick^{commit}" >/dev/null; then
	commit=$(git -C "$up" rev-parse "$pick^{commit}")
	git -C "$up" merge-base --is-ancestor "$commit" "refs/heads/$branch" \
		|| { echo "$pick is not on $branch" >&2; exit 1; }
else
	commit=$(git -C "$up" rev-list -1 --first-parent --before="$pick 23:59:59 +0000" "refs/heads/$branch")
	[ -n "$commit" ] || { echo "no $branch commit on or before $pick" >&2; exit 1; }
fi

case $name in
zoneminder) ver=$(git -C "$up" show "$commit:version.txt" | tr -d '[:space:]') ;;
# the [package] version; semver pre-releases in Gentoo form
zm-api) ver=$(git -C "$up" show "$commit:Cargo.toml" \
	| sed -n '/^\[package\]/,/^\[/s/^version *= *"\(.*\)"/\1/p' | head -1 \
	| sed -E 's/-(alpha|beta|rc)\.?([0-9]*)$/_\1\2/') ;;
esac
case $ver in
[0-9]*.[0-9]*) ;;
*) echo "cannot read a version at $commit (got '$ver')" >&2; exit 1 ;;
esac
day=$(TZ=UTC git -C "$up" log -1 --date=format-local:%Y%m%d --format=%cd "$commit")
pv=${ver}_pre$day
eb=$pkg/$name-$pv.ebuild
echo "$name $branch $(git -C "$up" rev-parse --short "$commit") $day UTC: $(git -C "$up" log -1 --format=%s "$commit")"
echo "-> $name-$pv"
if [ -e "$eb" ]; then
	grep -q "^	*$var=\"$commit\"" "$eb" && { echo "already there"; exit 0; }
	echo "$eb exists for another commit (two snapshots on one day: pass a commit and rename)" >&2
	exit 1
fi

set -- -e "s/^\(	*\)$var=\".*\"/\1$var=\"$commit\"/"
if [ "$name" = zoneminder ]; then
	# the template's pins, set from the submodule commits at $commit
	for vp in MY_CRUD_V:web/api/app/Plugin/Crud MY_CAKEPHP_V:web/api/app/Plugin/CakePHP-Enum-Behavior \
		MY_RTSP_V:dep/RtspServer MY_CXXURL_V:dep/CxxUrl; do
		pin=${vp%%:*}
		grep -q "^	$pin=" "$tpl" || continue
		v=$(git -C "$up" ls-tree "$commit" "${vp#*:}" | awk '$2 == "commit" { print $3 }')
		[ -n "$v" ] || { echo "${vp#*:} is not a submodule at $commit; check the ebuild's pins by hand" >&2; exit 1; }
		set -- "$@" -e "s/^	$pin=\".*\"/	$pin=\"$v\"/"
	done
fi
sed "$@" "$tpl" > "$eb"
sed -i '/^	*KEYWORDS=/d' "$eb"
# zoneminder snapshots carry no keywords (hosts opt in with **); zm-api snapshots
# are ~amd64 so that www-misc/zoneminder[apiv3] resolves (README, "API v3").
if [ "$name" = zm-api ]; then
	sed -i '/^	S="${WORKDIR}\/zm-api-${ZM_API_COMMIT}"/a\
	# Keyworded so that www-misc/zoneminder[apiv3] (~amd64) resolves; 9999 is not.\
	KEYWORDS="~amd64"' "$eb"
	grep -q '^	KEYWORDS="~amd64"' "$eb" || { rm -f "$eb"; echo "could not keyword the zm-api snapshot; template changed?" >&2; exit 1; }
fi
grep -q "^	*$var=\"$commit\"" "$eb" || { rm -f "$eb"; echo "$var not set; template changed?" >&2; exit 1; }

if [ "$name" = zm-api ]; then
	pce=${PYCARGOEBUILD:-$(command -v pycargoebuild || echo "$cache/pycargoebuild-venv/bin/pycargoebuild")}
	[ -x "$pce" ] || { rm -f "$eb"; echo "no pycargoebuild: emerge app-portage/pycargoebuild, or" \
		"python3 -m venv --system-site-packages $cache/pycargoebuild-venv && $cache/pycargoebuild-venv/bin/pip install pycargoebuild" >&2; exit 1; }
	src=$(mktemp -d "$cache/zm-api-src.XXXXXX")
	trap 'rm -rf "$src" "$src.log"' EXIT
	git -C "$up" archive "$commit" | tar -x -C "$src"
	# CRATES and the crate LICENSE+= line, in place; the crates land in DISTDIR
	"$pce" -C -M -i "$eb" "$src" > "$src.log" 2>&1 || { rm -f "$eb"; tail -20 "$src.log" >&2; exit 1; }
	[ "$(grep -c '^	[A-Za-z0-9_-]*@' "$eb")" -gt 0 ] || { rm -f "$eb"; echo "pycargoebuild left CRATES empty" >&2; exit 1; }
fi

(cd "$pkg" && ebuild "$name-$pv.ebuild" manifest >/dev/null)
echo "wrote $eb, Manifest refreshed"
echo "git add www-misc/$name && git commit -m 'www-misc/$name: snapshot $pv ($branch $(git -C "$up" rev-parse --short "$commit"))'"
