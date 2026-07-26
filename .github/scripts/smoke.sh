#!/usr/bin/env bash
#
# Smoke test for scripts/install.sh and scripts/uninstall.sh.
#
#   .github/scripts/smoke.sh explicit     # install into a throwaway directory
#   .github/scripts/smoke.sh autodetect   # exercise the platform probe (CI only)
#
# The test needs no Typora installation: the scripts only care whether a theme
# directory exists. It does hit the network, because the point is to exercise
# the real release download.

set -euo pipefail

MODE="${1:-explicit}"
ROOT=$(cd "$(dirname "$0")/../.." && pwd)
INSTALL="$ROOT/scripts/install.sh"
UNINSTALL="$ROOT/scripts/uninstall.sh"

pass() { printf 'ok   %s\n' "$1"; }
fail() {
	printf 'FAIL %s\n' "$1" >&2
	exit 1
}

# Git for Windows does not always ship unzip. Rather than pretend the MINGW path
# was covered, assert the documented degradation and say so loudly.
if ! command -v unzip >/dev/null 2>&1; then
	case "$(uname -s)" in
	MINGW* | MSYS* | CYGWIN*)
		printf '::warning::unzip is unavailable in this shell, so the MINGW install path was not exercised\n'
		set +e
		TYPORA_THEME_DIR="$(mktemp -d)" bash "$INSTALL" >/dev/null 2>&1
		rc=$?
		set -e
		[ "$rc" -eq 2 ] || fail "expected exit code 2 when unzip is missing, got $rc"
		pass "degrades with exit code 2 when unzip is missing"
		exit 0
		;;
	esac
fi

if [ "$MODE" = "autodetect" ]; then
	# Refuse to run outside CI: this mode writes into the machine's real Typora
	# theme folder and would clobber a working installation.
	[ "${CI:-}" = "true" ] || fail "autodetect mode is CI-only (it writes to the real theme folder)"

	case "$(uname -s)" in
	Darwin) THEMES="$HOME/Library/Application Support/abnerworks.Typora/themes" ;;
	Linux) THEMES="$HOME/.config/Typora/themes" ;;
	MINGW* | MSYS* | CYGWIN*) THEMES="$(printf '%s' "$APPDATA" | tr '\\' '/')/Typora/themes" ;;
	*) fail "unsupported platform $(uname -s)" ;;
	esac

	mkdir -p "$THEMES"
	unset TYPORA_THEME_DIR

	out=$(bash "$INSTALL")
	printf '%s' "$out" | grep -qF "$THEMES" || fail "A10 install output did not name $THEMES"
	[ -f "$THEMES/blue-topaz.css" ] || fail "A10 blue-topaz.css did not land in the probed folder"
	pass "A10 probes the platform default folder"

	bash "$UNINSTALL" >/dev/null
	[ ! -e "$THEMES/blue-topaz.css" ] || fail "A10 uninstall left blue-topaz.css behind"
	pass "A10 uninstall works against the probed folder"
	exit 0
fi

THEMES=$(mktemp -d)
export TYPORA_THEME_DIR="$THEMES"

printf '/* mine */\n' >"$THEMES/blue-topaz.user.css"
printf '/* mine */\n' >"$THEMES/base.user.css"

bash "$INSTALL" >/dev/null
[ -f "$THEMES/blue-topaz.css" ] || fail "A1 blue-topaz.css missing"
[ -f "$THEMES/blue-topaz-dark.css" ] || fail "A1 blue-topaz-dark.css missing"
[ -f "$THEMES/blue-topaz/font.css" ] || fail "A1 blue-topaz/font.css missing"
ls "$THEMES/blue-topaz"/*.woff2 >/dev/null 2>&1 || fail "A1 no bundled woff2 fonts"
[ "$(wc -c <"$THEMES/blue-topaz.css")" -gt 10240 ] || fail "A1 blue-topaz.css is suspiciously small"
pass "A1 installs the three shipped items"

[ -f "$THEMES/blue-topaz.user.css" ] || fail "A4 blue-topaz.user.css was removed"
[ -f "$THEMES/base.user.css" ] || fail "A4 base.user.css was removed"
pass "A4 leaves user css alone on install"

printf 'stale\n' >"$THEMES/blue-topaz/zz-stale.txt"
bash "$INSTALL" >/dev/null
[ -f "$THEMES/blue-topaz.css" ] || fail "A2 second run broke the installation"
pass "A2 re-running installs again (update path)"
[ ! -e "$THEMES/blue-topaz/zz-stale.txt" ] || fail "A3 stale file survived the update"
pass "A3 clears files dropped by an older release"

OUTSIDE=$(mktemp -d)
printf 'ORIGINAL\n' >"$OUTSIDE/blue-topaz.css"
rm -f "$THEMES/blue-topaz.css"
ln -s "$OUTSIDE/blue-topaz.css" "$THEMES/blue-topaz.css"
set +e
bash "$INSTALL" >/dev/null 2>&1
rc=$?
set -e
[ "$rc" -ne 0 ] || fail "A5 symlink guard did not abort"
[ "$(cat "$OUTSIDE/blue-topaz.css")" = "ORIGINAL" ] || fail "A5 wrote through the symlink"
pass "A5 refuses to overwrite a symlink and leaves its target intact"
rm -f "$THEMES/blue-topaz.css"

MISSING="$THEMES/nope/deeper"
set +e
TYPORA_THEME_DIR="$MISSING" bash "$INSTALL" >/dev/null 2>&1
rc=$?
set -e
[ "$rc" -ne 0 ] || fail "A6 accepted a non-existent theme folder"
[ ! -e "$MISSING" ] || fail "A6 created the theme folder"
pass "A6 refuses a missing folder without creating it"

bash "$INSTALL" >/dev/null
bash "$UNINSTALL" >/dev/null
[ ! -e "$THEMES/blue-topaz.css" ] || fail "A7 blue-topaz.css survived uninstall"
[ ! -e "$THEMES/blue-topaz-dark.css" ] || fail "A7 blue-topaz-dark.css survived uninstall"
[ ! -e "$THEMES/blue-topaz" ] || fail "A7 blue-topaz/ survived uninstall"
pass "A7 uninstall removes the three shipped items"

[ -f "$THEMES/blue-topaz.user.css" ] || fail "A8 uninstall deleted blue-topaz.user.css"
[ -f "$THEMES/base.user.css" ] || fail "A8 uninstall deleted base.user.css"
pass "A8 uninstall leaves user css alone"

bash "$UNINSTALL" | grep -q 'Nothing to remove' || fail "A9 second uninstall did not report a clean folder"
pass "A9 uninstall is repeatable"

rm -rf "$THEMES" "$OUTSIDE"
printf '\nall assertions passed\n'
