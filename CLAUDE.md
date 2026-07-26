# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

A Typora port of the Obsidian [Blue Topaz](https://github.com/PKM-er/Blue-Topaz_Obsidian-css) theme (based on v2025052001). There is no build step: the CSS files you edit are exactly what ships, and Typora loads them directly. The only non-CSS code is `scripts/`, the one-line installer, plus the CI workflow that smoke-tests it.

## Theme Architecture

- `blue-topaz.css`: light theme, full styles (30+ sections)
- `blue-topaz-dark.css`: dark theme that **imports the light theme, then overrides only what must differ**
- `blue-topaz/`: bundled fonts (Inter, JetBrains Mono) and `font.css`

The dark theme `@import`s `blue-topaz.css`, then overrides the `:root` variables and the section-specific rules that need a different value or selector in dark mode. Nearly every section has a dark override. **Do not duplicate light-theme rules that need no change in dark mode.**

## CSS Conventions

### Section Headers

The light theme uses numbered section headers:
```css
/* ========== 7. Headings h1~h6 ========== */
```

The dark theme uses named section headers (no numbers):
```css
/* ========== Headings ========== */
```

New sections follow the format of the file they belong to. In the light theme, sections added after the numbered ones (1 to 30) stay unnumbered.

### CSS Variables

- Built-in Typora variables: `--bg-color`, `--text-color`, `--primary-color`, `--side-bar-bg-color`, etc.
- Variable mapping: see `dev/color-mapping.md`
- When changing a color variable, update `dev/color-mapping.md` at the same time

### Code Highlighting

Code highlighting uses CodeMirror 5 token classes scoped to `.cm-s-inner`, not CodeMirror 6. Examples include `.cm-keyword`, `.cm-string`, and `.cm-property`. For the color strategy, see the Code Highlighting section of `dev/color-mapping.md`.

### Typora-Specific Selectors and Directives

This project uses Typora's proprietary CSS selectors and directives, which differ from generic web CSS:
- `#write`: main editing area
- `.md-expand`: an inline element in its editing state
- `#md-notification`: notification area
- `.megamenu-*`: preferences panel
- `@include-when-export`: directive for export-only styles (cannot bundle fonts into exported HTML; see Font Strategy)

## Font Strategy

- Body font stack: Inter → LXGW WenKai GB → LXGW WenKai → -apple-system → BlinkMacSystemFont → Segoe UI → Microsoft YaHei → sans-serif. Inter covers Latin, LXGW WenKai covers CJK, the rest are system fallbacks.
- Code font stack: `--monospace` is defined in `:root` as JetBrains Mono → Fira Code → Cascadia Code → Menlo → Consolas → Sarasa Mono SC → monospace
- Inter and JetBrains Mono are bundled as WOFF2 in `blue-topaz/`

**Export font behavior**: HTML export strips the theme's `@font-face` rules: the `@import` is emptied to `@import "";`, and any `@font-face` written directly into the main CSS is removed too. Exported HTML falls back to system fonts when Inter or JetBrains Mono is not installed, while PDF export embeds the font subsets. This is a Typora platform limitation that guards against `file://` path leaks, so do not try Base64 inlining or `@include-when-export`; both were verified ineffective. See `dev/color-mapping.md`.

## Testing

No automated tests. Open `test/test-document.md` in Typora for visual verification; it covers headings, lists, code blocks, tables, math formulas, Mermaid diagrams, and more.

**For export and print changes, verify both PDF and HTML exports.** Screen verification alone is not enough: Typora's export renders differently from the screen. For example, a `transparent` gradient stop turns black, and HTML export strips `@font-face`.

## File Distribution

To install the theme, copy these into Typora's theme folder:
- `blue-topaz.css`
- `blue-topaz-dark.css`
- `blue-topaz/` (the font directory)

Keep these filenames and this directory structure; renames break installation.

## Install Scripts

`scripts/` holds the one-line installers the READMEs advertise: `install.sh` / `uninstall.sh` for macOS, Linux, snap, Git Bash, and WSL, and `install.ps1` / `uninstall.ps1` for native Windows PowerShell. Install and update are the same operation, so re-running an installer is the update path.

Rules that must survive any edit:

- **Never create the theme folder.** Only ever write into a directory that already exists. A folder created at a guessed path looks like a successful install while Typora keeps reading somewhere else.
- **Symlink guard.** Abort if a target entry is a symlink or junction: development setups link the theme folder back into this repository, and copying through the link would rewrite the repo's own source files.
- **Guard before writing.** All checks run before the first write, so an abort leaves the theme folder untouched.
- **Never touch `*.user.css`.** `base.user.css` and `blue-topaz.user.css` are user data, both on install and on uninstall.
- **Install reads its file list from the downloaded archive**, so adding a bundled file needs no script change. Uninstall hardcodes the three items above, because it has no archive to read.
- `install.sh` must stay compatible with **bash 3.2**, which is what macOS ships and what `| bash` actually runs.
- All user-visible output is **English only**: an English-locale Windows console cannot render Chinese.
- Escape hatch for snap, Flatpak, and custom locations: `TYPORA_THEME_DIR`.

`.github/workflows/install-scripts.yml` runs `.github/scripts/smoke.{sh,ps1}` on Linux, macOS, Windows PowerShell 5.1, PowerShell 7, and Git Bash. The commands point at `raw.githubusercontent.com` on the default branch, which is served with `cache-control: max-age=300`, so a broken script stays broken for up to five minutes after a revert. **Do not merge a script change to the default branch without green CI.**

## Release Process

Releases are tagged `vX.Y.Z` (semver: backward-compatible features bump the minor, fixes bump the patch). The repo holds no version string; the README badge and download link read GitHub's `releases/latest`, so releasing needs no in-repo version edit.

1. Build the zip, named exactly `blue-topaz-typora.zip`:
   ```bash
   zip -r -X blue-topaz-typora.zip blue-topaz.css blue-topaz-dark.css blue-topaz -x '*.DS_Store'
   ```
   It must contain only the three install items above, flat at the archive root, and nothing else. This is no longer just a convention: `scripts/install.sh` and `scripts/install.ps1` install exactly the archive's top-level entries, so anything extra in the zip lands in every user's theme folder.
2. Tag, push, and publish with bilingual notes (English block, `---`, Chinese block), matching the previous release:
   ```bash
   git tag -a vX.Y.Z -m "Blue Topaz for Typora vX.Y.Z"
   git push origin vX.Y.Z
   gh release create vX.Y.Z blue-topaz-typora.zip --title "Blue Topaz for Typora vX.Y.Z" --notes-file <notes>
   ```

**The gallery download is dynamic.** The theme.typora.io entry links to `releases/latest/download/blue-topaz-typora.zip`, which always serves the newest release. Every release MUST attach an asset with that exact filename, or the gallery download breaks. Never put the version in the asset filename.
