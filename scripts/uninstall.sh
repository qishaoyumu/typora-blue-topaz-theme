#!/usr/bin/env bash
#
# Blue Topaz for Typora - uninstall
#
#   curl -fsSL https://raw.githubusercontent.com/qishaoyumu/typora-blue-topaz-theme/master/scripts/uninstall.sh | bash
#
# Removes only the three files the theme ships. Your own blue-topaz.user.css
# and base.user.css are left alone, and so is every other theme.
#
# Environment:
#   TYPORA_THEME_DIR  uninstall from this existing directory instead of probing
#
# Exit codes:
#   0  removed, or nothing was installed
#   1  error
#
# Kept compatible with bash 3.2, the version macOS still ships.

set -eu

REPO="qishaoyumu/typora-blue-topaz-theme"
MANUAL_URL="https://github.com/$REPO#manual-install"

# The three items the release archive installs. Unlike install.sh, which reads
# the entry list out of the archive, uninstall has no archive to read, so this
# list is the contract: renaming any of them breaks installation anyway.
TARGETS="blue-topaz.css
blue-topaz-dark.css
blue-topaz"

die() {
	printf 'Error: %s\n' "$1" >&2
	exit "${2:-1}"
}

# Same probe as install.sh; kept as a copy so each script stays a single file
# that can be piped straight into a shell.
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
		printf 'Open Preferences > Appearance > Open Theme Folder to see the real path and pass it in:\n' >&2
		printf 'TYPORA_THEME_DIR="/your/path" ...\n' >&2
		return 1
	fi

	printf '%s' "$found"
}

THEME_DIR=$(resolve_theme_dir) || exit $?

printf 'Theme folder: %s\n' "$THEME_DIR"

# Guard pass before removing anything.
while IFS= read -r target; do
	[ -n "$target" ] || continue
	if [ -L "$THEME_DIR/$target" ]; then
		die "\"$THEME_DIR/$target\" is a symlink, which usually means a development setup.
Refusing to remove it. Delete the link yourself if that is what you want."
	fi
done <<EOF
$TARGETS
EOF

removed=0
while IFS= read -r target; do
	[ -n "$target" ] || continue
	if [ -e "$THEME_DIR/$target" ]; then
		rm -rf "$THEME_DIR/$target"
		printf '  removed %s\n' "$target"
		removed=$((removed + 1))
	fi
done <<EOF
$TARGETS
EOF

if [ "$removed" -eq 0 ]; then
	printf '\nNothing to remove: Blue Topaz is not installed in that folder.\n'
	exit 0
fi

cat <<'EOF'

Blue Topaz has been removed.

If Typora is still set to Blue Topaz, pick another theme from the Themes menu,
then quit Typora completely and reopen it.

Any blue-topaz.user.css or base.user.css you wrote was left in place.
EOF
