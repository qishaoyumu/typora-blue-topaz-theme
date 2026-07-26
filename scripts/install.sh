#!/usr/bin/env bash
#
# Blue Topaz for Typora - install / update
#
#   curl -fsSL https://raw.githubusercontent.com/qishaoyumu/typora-blue-topaz-theme/master/scripts/install.sh | bash
#
# Running this again updates an existing installation; it is safe to repeat.
# Works on macOS, Linux (including snap), and Windows through Git Bash or WSL.
# Native Windows PowerShell users should run scripts/install.ps1 instead.
#
# Environment:
#   TYPORA_THEME_DIR  install into this existing directory instead of probing
#
# Exit codes:
#   0  installed
#   1  error
#   2  a required command is missing
#
# Kept compatible with bash 3.2, the version macOS still ships.

set -eu

REPO="qishaoyumu/typora-blue-topaz-theme"
ZIP_URL="https://github.com/$REPO/releases/latest/download/blue-topaz-typora.zip"
MANUAL_URL="https://github.com/$REPO#manual-install"
PS_COMMAND='powershell -ExecutionPolicy ByPass -c "irm https://raw.githubusercontent.com/qishaoyumu/typora-blue-topaz-theme/master/scripts/install.ps1 | iex"'

die() {
	printf 'Error: %s\n' "$1" >&2
	exit "${2:-1}"
}

# Prints the theme directory on stdout, or explains on stderr and returns 1.
# Only ever returns a directory that already exists: creating one would look
# like success while Typora keeps reading somewhere else.
resolve_theme_dir() {
	if [ -n "${TYPORA_THEME_DIR:-}" ]; then
		if [ ! -d "$TYPORA_THEME_DIR" ]; then
			printf 'Error: TYPORA_THEME_DIR is set to "%s", which is not an existing directory.\n' "$TYPORA_THEME_DIR" >&2
			return 1
		fi
		printf '%s' "$TYPORA_THEME_DIR"
		return 0
	fi

	candidates=""
	case "$(uname -s)" in
	Darwin)
		candidates="$HOME/Library/Application Support/abnerworks.Typora/themes"
		;;
	Linux)
		candidates="$HOME/.config/Typora/themes
$HOME/snap/typora/current/.config/Typora/themes"
		;;
	MINGW* | MSYS* | CYGWIN*)
		if [ -n "${APPDATA:-}" ]; then
			# Git Bash hands out a backslash path; bash is happier with slashes.
			candidates="$(printf '%s' "$APPDATA" | tr '\\' '/')/Typora/themes"
		fi
		;;
	esac

	if [ -z "$candidates" ]; then
		printf 'Error: unsupported platform "%s". Set TYPORA_THEME_DIR to your theme folder and run again.\n' "$(uname -s)" >&2
		return 1
	fi

	found=""
	probed=""
	while IFS= read -r candidate; do
		[ -n "$candidate" ] || continue
		probed="$probed
  $candidate"
		if [ -z "$found" ] && [ -d "$candidate" ]; then
			found="$candidate"
		fi
	done <<EOF
$candidates
EOF

	if [ -z "$found" ]; then
		printf 'Error: could not find the Typora theme folder. Looked in:%s\n' "$probed" >&2
		printf 'Run Typora once so it creates the folder, or open Preferences > Appearance > Open Theme Folder\n' >&2
		printf 'to see the real path and pass it in: TYPORA_THEME_DIR="/your/path" ...\n' >&2
		return 1
	fi

	printf '%s' "$found"
}

command -v curl >/dev/null 2>&1 ||
	die "curl is required but was not found. Follow the manual steps instead: $MANUAL_URL" 2

if ! command -v unzip >/dev/null 2>&1; then
	case "$(uname -s)" in
	MINGW* | MSYS* | CYGWIN*)
		die "unzip is not available in this shell. Use the PowerShell command instead:
  $PS_COMMAND" 2
		;;
	*)
		die "unzip is required but was not found. Install it (for example: sudo apt install unzip) and run again, or follow the manual steps: $MANUAL_URL" 2
		;;
	esac
fi

THEME_DIR=$(resolve_theme_dir) || exit $?

tmp=$(mktemp -d 2>/dev/null || mktemp -d -t blue-topaz)
cleanup() { rm -rf "$tmp"; }
trap cleanup EXIT INT TERM

printf 'Theme folder: %s\n' "$THEME_DIR"
printf 'Downloading the latest release...\n'

curl -fsSL --retry 2 --connect-timeout 20 -o "$tmp/theme.zip" "$ZIP_URL" ||
	die "download failed. If your network cannot reach GitHub, follow the manual steps: $MANUAL_URL"

# Best effort only: the tag lives in the first redirect target, since following
# the chain ends up on an asset host that does not carry the version. A missing
# version string must never stop an install.
version=$(curl -fsSI --connect-timeout 10 -o /dev/null -w '%{redirect_url}' "$ZIP_URL" 2>/dev/null |
	sed -n 's|.*/download/\([^/]*\)/.*|\1|p') || version=""

mkdir -p "$tmp/payload"
unzip -q "$tmp/theme.zip" -d "$tmp/payload" ||
	die "could not extract the downloaded archive."

entries=$(ls -A "$tmp/payload")
[ -n "$entries" ] || die "the downloaded archive was empty."

# Guard pass: nothing is written until every entry has been checked, so an
# abort here leaves the theme folder exactly as it was.
while IFS= read -r entry; do
	[ -n "$entry" ] || continue
	case "$entry" in
	*/* | . | .. | -*)
		die "unexpected entry \"$entry\" in the archive; nothing was written."
		;;
	esac
	if [ -L "$THEME_DIR/$entry" ]; then
		die "\"$THEME_DIR/$entry\" is a symlink, which usually means a development setup.
Refusing to overwrite it, because copying through the link would rewrite the file it points at.
Remove the link yourself, or install elsewhere with TYPORA_THEME_DIR."
	fi
done <<EOF
$entries
EOF

[ -w "$THEME_DIR" ] || die "no write permission for $THEME_DIR"

while IFS= read -r entry; do
	[ -n "$entry" ] || continue
	rm -rf "$THEME_DIR/$entry"
	cp -R "$tmp/payload/$entry" "$THEME_DIR/"
	printf '  installed %s\n' "$entry"
done <<EOF
$entries
EOF

if [ -n "$version" ]; then
	printf '\nBlue Topaz %s is installed.\n' "$version"
else
	printf '\nBlue Topaz is installed.\n'
fi

cat <<'EOF'

Next steps:
  1. Quit Typora completely (Cmd+Q on macOS, File > Exit on Windows and Linux).
  2. Reopen it and pick "Blue Topaz" or "Blue Topaz Dark" from the Themes menu.

If the themes do not show up, compare the theme folder printed above with the
one Typora opens from Preferences > Appearance > Open Theme Folder.

Your own tweaks belong in blue-topaz.user.css or base.user.css; this script
never touches those files.
EOF
