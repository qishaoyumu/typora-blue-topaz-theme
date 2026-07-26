# Blue Topaz Theme for Typora

[![License](https://img.shields.io/github/license/qishaoyumu/typora-blue-topaz-theme?style=flat-square&colorA=1e3a5f&colorB=4394e5)](LICENSE)
[![GitHub stars](https://img.shields.io/github/stars/qishaoyumu/typora-blue-topaz-theme?style=flat-square&colorA=1e3a5f&colorB=4394e5)](https://github.com/qishaoyumu/typora-blue-topaz-theme/stargazers)
[![Release](https://img.shields.io/github/v/release/qishaoyumu/typora-blue-topaz-theme?style=flat-square&colorA=1e3a5f&colorB=4394e5)](https://github.com/qishaoyumu/typora-blue-topaz-theme/releases/latest)

[中文版](README_CN.md) | [View in Typora Themes Gallery](https://theme.typora.io/theme/Obsidian-Blue-Topaz/)

This theme ports the [Blue Topaz](https://github.com/PKM-er/Blue-Topaz_Obsidian-css) Obsidian theme to Typora. It adds colored headings (a blue cascade in light mode, rainbow in dark), code highlighting, and GFM alert styling. If you already use Blue Topaz in Obsidian, it brings the same look to your Typora notes.

### Dark Mode

![Blue Topaz dark theme preview](screenshots/dark.png)

### Light Mode

![Blue Topaz light theme preview](screenshots/light.png)

## Features

- **Light and dark modes**: two theme entries share one source. `blue-topaz-dark.css` imports `blue-topaz.css`, then overrides the dark palette, code highlighting, and print styles.
- **Colored heading cascade**: a blue h1 to h6 gradient in light mode, rainbow hues in dark.
- **GFM alerts**: Note, Tip, Important, Warning, and Caution, matching GitHub.
- **Code highlighting**: `cm-s-inner` tokens are based on CodeMirror's default palette in light mode and GitHub Dark in dark mode.
- **Mermaid diagrams**: accent-blue nodes in light mode, and a dark preset with custom node, edge, and label colors in dark mode.
- **Focus mode**: dims non-focused blocks while keeping their heading and text colors.
- **Print and export**: output follows the selected theme: dark stays dark (dark surfaces, light text), and light stays light.
- **Typora UI theming**: sidebar, file tree, search, Quick Open, preferences, modals, and source mode.
- **Markdown elements**: styled tables, task lists, blockquotes, details/summary, definition lists, multi-color highlights, superscript and subscript, plus reduced-motion handling.
- **Accessibility**: high-frequency colored text (links, inline code, emphasis, headings, and alert labels) meets WCAG AA contrast.
- **Chinese text**: a CJK fallback chain with optional LXGW WenKai, alongside bundled Inter and JetBrains Mono for Latin and code.

## Installation

Requires Typora 1.13 or later (the theme relies on `:has()` and other modern CSS). Update Typora first if the theme does not appear or renders incorrectly. Start Typora at least once before installing, so that the theme folder exists.

### Quick install

macOS and Linux (also Git Bash and WSL on Windows):

```bash
curl -fsSL https://raw.githubusercontent.com/qishaoyumu/typora-blue-topaz-theme/master/scripts/install.sh | bash
```

Windows (PowerShell):

```powershell
powershell -ExecutionPolicy ByPass -c "irm https://raw.githubusercontent.com/qishaoyumu/typora-blue-topaz-theme/master/scripts/install.ps1 | iex"
```

The script downloads the latest release, finds your Typora theme folder, and copies the three theme items into it. It leaves everything else alone, including your other themes and any `base.user.css` or `blue-topaz.user.css` you wrote. Read it first if you prefer: [`install.sh`](scripts/install.sh), [`install.ps1`](scripts/install.ps1).

Then quit Typora completely (`Cmd+Q` on macOS, `File > Exit` elsewhere), reopen it, and choose **Blue Topaz** or **Blue Topaz Dark** from the **Themes** menu.

If the script cannot find the theme folder (a snap or Flatpak build, or a custom location), pass it the path that Typora opens from `Preferences > Appearance > Open Theme Folder`:

```bash
export TYPORA_THEME_DIR="/your/theme/folder"
curl -fsSL https://raw.githubusercontent.com/qishaoyumu/typora-blue-topaz-theme/master/scripts/install.sh | bash
```

### Manual install

1. [**Download**](https://github.com/qishaoyumu/typora-blue-topaz-theme/releases/latest) the latest release and extract it, or clone this repository.
2. Open the theme folder from Typora:
   - macOS: `Typora > Preferences > Appearance > Open Theme Folder`
   - Windows / Linux: `File > Preferences > Appearance > Open Theme Folder`
3. Copy these into the theme folder, keeping the names and layout unchanged (the dark theme imports the light one, and both load fonts from `blue-topaz/`):
   - `blue-topaz.css`
   - `blue-topaz-dark.css`
   - the entire `blue-topaz/` folder (includes `font.css`, the `.woff2` fonts, and font licenses)
4. Restart Typora, then choose **Blue Topaz** or **Blue Topaz Dark** from the **Themes** menu.

### Updating

Run the same install command again; it replaces the three items in place. Manually: download the new version, replace `blue-topaz.css`, `blue-topaz-dark.css`, and the entire `blue-topaz/` folder, then restart Typora.

### Uninstalling

Switch to another theme first, then run:

```bash
curl -fsSL https://raw.githubusercontent.com/qishaoyumu/typora-blue-topaz-theme/master/scripts/uninstall.sh | bash
```

```powershell
powershell -ExecutionPolicy ByPass -c "irm https://raw.githubusercontent.com/qishaoyumu/typora-blue-topaz-theme/master/scripts/uninstall.ps1 | iex"
```

It removes only `blue-topaz.css`, `blue-topaz-dark.css`, and `blue-topaz/`. Manually: delete those three from the theme folder. Either way, restart Typora afterwards.

## Recommended Fonts

The theme bundles **Inter** for Latin body text and **JetBrains Mono** for code. Inter has no Chinese glyphs, so for Chinese text install [LXGW WenKai](https://github.com/lxgw/LxgwWenKai):

- macOS: `brew install --cask font-lxgw-wenkai` (or download the TTF and install it)
- Windows: download the latest TTF from [GitHub Releases](https://github.com/lxgw/LxgwWenKai/releases) and install it
- Debian / Ubuntu: `sudo apt install fonts-lxgw-wenkai`
- Other Linux: install your distro's package, or download the TTF and run `fc-cache -f`

Without LXGW WenKai, Chinese text falls back to the default system font (PingFang SC on macOS, Microsoft YaHei on Windows; on Linux it depends on your fontconfig setup).

## Troubleshooting

- **The theme has no styling, especially the dark one**: `blue-topaz.css` and the `blue-topaz/` folder must sit in the same theme folder as `blue-topaz-dark.css`. The dark theme imports the light one and needs both.
- **The theme is missing from the menu**: make sure the files sit directly in the theme folder, not inside a nested subfolder created when extracting the archive, then restart Typora fully (Cmd+Q on macOS), not just the window.
- **The install command fails**: the scripts fetch the release from GitHub, so a network that cannot reach `github.com` or `raw.githubusercontent.com` will stop them. Use the manual steps above instead; nothing else about the theme needs network access.
- **Keeping your own tweaks**: put custom CSS in `blue-topaz.user.css` or `base.user.css` next to the theme ([Typora docs](https://support.typora.io/Add-Custom-CSS/)). Those files are loaded after the theme, and installing, updating, or uninstalling never touches them, while edits made directly to `blue-topaz.css` are lost on the next update.
- **Text or layout looks wrong**: confirm Typora is 1.13 or later.
- **Exported HTML uses different fonts**: Typora removes the theme's bundled `@font-face` rules during HTML export, so text falls back to system fonts on machines without Inter or JetBrains Mono installed (document structure and colors are unaffected). This is Typora's export behavior, not a theme issue; PDF export embeds the fonts, so use PDF for reliable sharing, or ask recipients to install the fonts.

## Credits

Based on [Blue Topaz](https://github.com/PKM-er/Blue-Topaz_Obsidian-css) v2025052001 by WhyI and the Pkmer community. See [CREDITS.md](CREDITS.md) for details.

## Contributing

Issues and PRs are welcome. When opening a PR, please:

- Keep light and dark behavior in sync and update both README files together.
- Follow the existing CSS section comment style (`/* ========== Section ========== */`).
- For visual changes, attach a before/after screenshot from Typora.

## License

The theme CSS is licensed under the [MIT License](LICENSE). Bundled fonts under `blue-topaz/` use the SIL Open Font License 1.1; see [CREDITS.md](CREDITS.md).
