#!/bin/sh
# Rebuilds www-misc/zoneminder/files/master-security: our pending security
# fixes, one patch each, for the master ebuilds (9999 and the 1.39 snapshots).
# The fixes listed in OURS_LIST are merged in order onto the commit the
# newest master snapshot pins (or BASE), and each merge becomes one patch, so
# they apply in sequence. Patches are named after the list's comments; the
# advisory ids are not written anywhere.
#
#   scripts/security-patches.sh          rebuild against the newest snapshot
#   BASE=<commit> scripts/security-patches.sh
#
# OURS_LIST: one ref per line, # comments (default: zm-holodeck's
#   tools/combos/ours.txt); ghsa-<id> is advisory-fix-1 of the private fork
#   ZoneMinder/zoneminder-ghsa-<id> (git over SSH), pr-<N> an upstream PR.
# Then checks that the patches also apply to master's head (9999).
set -eu

top=$(git -C "$(dirname "$0")" rev-parse --show-toplevel)
pkg=$top/www-misc/zoneminder
out=$pkg/files/master-security
list=${OURS_LIST:-$HOME/dev/zm-holodeck/tools/combos/ours.txt}
cache=${XDG_CACHE_HOME:-$HOME/.cache}/oubliette
w=$cache/zm-sec
[ -f "$list" ] || { echo "no list $list (set OURS_LIST)" >&2; exit 1; }

snap=$(ls "$pkg"/zoneminder-1.39*_pre*.ebuild 2>/dev/null | sort -V | tail -1)
base=${BASE:-$(sed -n 's/^	MY_ZM_COMMIT="\(.*\)"/\1/p' "$snap")}
[ -n "$base" ] || { echo "no base commit (no 1.39 snapshot; set BASE)" >&2; exit 1; }

[ -d "$w" ] || git clone -q https://github.com/ZoneMinder/zoneminder "$w"
git -C "$w" fetch -q origin master
refs=$(sed -e 's/#.*//' "$list" | tr -s ' \t' '\n' | grep .)
for r in $refs; do
	case $r in
	ghsa-*) git -C "$w" fetch -q "git@github.com:ZoneMinder/zoneminder-$r.git" "+refs/heads/advisory-fix-1:refs/heads/$r" ;;
	pr-[0-9]*) git -C "$w" fetch -q origin "+pull/${r#pr-}/head:$r" ;;
	*) echo "unknown ref $r" >&2; exit 1 ;;
	esac
done

g() { git -C "$w" -c user.name=oubliette -c user.email=oubliette@localhost "$@"; }
g switch -q -C master-security "$base"
for r in $refs; do
	g merge -q --no-ff --no-edit -m "merge $r" "$r" >/dev/null 2>&1 || {
		echo "$r conflicts on $(git -C "$w" rev-parse --short "$base") + the fixes before it:" >&2
		git -C "$w" diff --name-only --diff-filter=U >&2
		g merge --abort; exit 1; }
done

rm -rf "$out"; mkdir -p "$out"
i=0
for m in $(git -C "$w" rev-list --first-parent --reverse "$base..master-security"); do
	i=$((i + 1))
	r=$(git -C "$w" log -1 --format=%s "$m" | sed 's/^merge //')
	desc=$(grep "^$r" "$list" | sed 's/[^#]*# *//')
	slug=$(echo "$desc" | sed -E 's/\(.*\)//; s/[^A-Za-z0-9]+/-/g; s/^-|-$//g' | tr 'A-Z' 'a-z' | cut -c1-50)
	f=$(printf '%02d-%s.patch' "$i" "$slug")
	{
		echo "Pending security fix: $desc"
		echo "Not in upstream master yet; drop it here once it is."
		echo
		git -C "$w" diff "$m^1" "$m"
	} > "$out/$f"
	echo "$f"
done
# the names and headers written here carry no advisory id (the fixes' own code may)
{ ls "$out"; head -q -n 2 "$out"/*.patch; } | grep -qi 'ghsa-' && { echo "an advisory id ended up in a patch name or header; check $out" >&2; exit 1; }

# 9999 builds master's head: do the patches still apply there?
head=$(git -C "$w" rev-parse --short origin/master)
g switch -q --detach origin/master
ok=1
for p in "$out"/*.patch; do
	git -C "$w" apply --index "$p" 2>/dev/null || { echo "does not apply to master $head: $(basename "$p")" >&2; ok=; break; }
done
g reset -q --hard; g switch -q master-security
[ -n "$ok" ] && echo "all $i apply to $(git -C "$w" rev-parse --short "$base") (snapshot) and master $head (9999)"

(cd "$pkg" && ebuild zoneminder-9999.ebuild manifest >/dev/null)
echo "wrote $out, Manifest refreshed"
