# Windows Unibody Megamenu

Typora's megamenu (full-window file menu + preferences) and the unibody
title bar exist only on Windows/Linux; macOS loads `mac.css` instead of
`window.css`/`megamenu.css` and never renders these elements (verified:
`index.html` in the macOS bundle links `mac.css`, the Linux `window.html`
links `window.css` + `megamenu.css`). All megamenu rules in this theme are
therefore inert on macOS. Reported in issue #1; themed in v1.2.0.

## Design Language Mapping

The megamenu ships with Typora's stock look (40px/300 display headings,
300px button slabs, 44px full-bleed sidebar rows). The theme restyles it as
a Blue Topaz system page. Anchor values were measured live in Obsidian's
settings dialog under Blue Topaz (`obsidian eval` computed styles,
2026-07-25); geometry is mode-independent, colors resolve through the
theme's own variables.

| Element | Typora default | Theme | Anchor (measured) |
|---|---|---|---|
| Panel h1 (page/section title) | 40px / 300 | 22px / 600, margin 0 0 16px | settings section title 15px/600, one step up for the full-window layout; h1 doubles as a section title on the export page |
| Panel h2 (subsection title) | 30px / 300 | 15px / 600, margin 0 0 12px | settings section title 15px/600, margin-bottom 16px |
| Panel rhythm | margin-left 30px, 64px between panels | margin-left 48px, 32px between panels, content padding-top 32px | settings content padding 32px 48px |
| `.long-btn` cards | 18px text, 12/20 padding, solid primary (theme bug) | bordered card, 14px/1.5, 8/16 padding, 16px primary icon, muted 12px inline hint | settings buttons 13px, 4/12 padding, 30px tall; cards sized one step up |
| `.megamenu-menu-panel .btn` | 12/20 padding, `#aaa` border | 4/12 padding, 13px, `--ui-border-color` | settings buttons 13px / 30px |
| Sidebar rows (>=531px) | 44px full-bleed strip, inherited size | 32px inset rounded items (margin 1px 8px, radius 5px, 14px), icons shown | settings nav items 14px, 30px rows, radius 5px, inset active overlay |
| Sidebar rows (<=530px) | 60px icon rail, 24px centered icons | untouched (media-scoped) | Typora's own narrow form factor |
| Sidebar header title | 18px | 15px / 600 | settings-adjacent; absolute layout kept |
| Recent-files table | 10pt / 300 (`!important` in default) | 13px `!important` / 400, th 600, themed row hover | settings body 15px, description 12px; tables take the compact step |
| Search input | 34px tall | 30px, 13px, 12px padding | settings search input 13px / 30px |

Interaction states use the existing tokens throughout: `--item-hover-*`,
`--active-file-*`, `--control-text-color` for muted/disabled text.

## Platform Facts

- **Load order**: `window.css` and `megamenu.css` load *before* the theme
  (`window.html` link order), so same-specificity theme rules win without
  `!important`. The only exception is the default's own `!important`
  (`.megamenu-menu-panel table { font-size: 10pt !important }`).
- **`.unibody-window` body class**: set only on Windows/Linux unibody
  windows; used to scope fixes for class names that also exist on macOS
  (`.modal-backdrop`, `.menu-style-btn.disabled`, `.context-menu … :focus`).
- **`.megamenu-menu-section` is dead** in current builds: the DOM uses
  `.megamenu-section` (JS-toggled, no stylesheet rule) and
  `.megamenu-menu-content-section`. The theme's transparent override is kept
  only as old-build insurance.
- **Bundled bootstrap is trimmed**: no `.table` / `.table-striped` /
  `.table-hover` rules survive, so the recent-files zebra and hover come
  from `megamenu.css` and the theme, not bootstrap.
- **Sidebar wrapper**: newer builds wrap the rail in `#megamenu-menu-sidebar`,
  older ones use `.megamenu-menu` alone; both get the sidebar background.
- **Narrow breakpoints** in the default sheet: 660px (menu docks right),
  586px (header title hidden), 530px (60px icon rail, 24px icons), 400px
  (full-width cards, path column hidden).
- **Saved-row anatomy**: `#m-save` and `#m-saved` share one `li`; JS toggles
  `li.saved` to swap them, and `#m-saved`'s check icon is a right-floating
  status badge (`float:right`, opacity fade-in) rather than a leading icon.
  With the theme revealing leading icons, the check is un-floated on wide
  windows (accent-colored, as a state marker). The default shows `#m-saved`
  via an id-strength `display:block`, so any layout change on the row must
  restate itself at `.megamenu-menu-list .saved #m-saved` specificity.
- **Sidebar rows are flex**, not line-height centered: CJK fallback fonts
  (Microsoft YaHei on the reporter's VM) sit visibly high in a fixed line
  box; `align-items: center` is the metric-proof way.
- **Tooltips are two systems, unified on the accent bubble** (the upstream
  Blue Topaz language, `theme.css` `.tooltip` → `--interactive-accent`,
  both modes): ① `#ty-tooltip` — one element carrying both the id and the
  `.ty-tooltip` class, present in `window.html` *and* `setting.html`, driven
  by `[ty-hint]`; the id-strength theme rule beats every class-only literal
  (`base-control.css` `#f2f2f2`, `Preferences.css` `hsl(0,0%,95%)`)
  regardless of load order, so one global rule covers all windows.
  ② `.code-tooltip.md-hover-tip` — link/footnote hover previews, stock
  `#000` at (0,2,0); the theme restates the accent at the same specificity
  and wins by load order (theme links last on every platform), with the
  `.md-arrow` painted to match (upstream misses the downward arrow).
  Plain `.code-tooltip` (fence language input, math preview) is an editing
  control and keeps the panel look. The dark file must NOT override any of
  these (a `#555` override and a grouped arrow selector once broke the
  bubble in dark — both removed). Typography is anchored to the live-measured
  Obsidian tooltip (12px / weight 500 / 1.3 / radius 5 / padding 4×8;
  measured 2026-07-26 via an `obsidian eval` constructed-element probe):
  weight lands on 600 because the bundled Inter has no 500 cut and CSS
  font-matching would resolve 500 down to 400. In hover previews only the
  direct-child URL anchor takes the compact type — footnote preview bodies
  keep document rhythm. File-tree hover tooltips remain OS-native `title`
  and untouchable.
- **Undefined default vars**: the theme gallery's active ring/badge read
  `var(--side-bar-menu-active-tint)` and `.btn:focus` reads
  `outline-color: var(--focus-ring-color)`; neither is defined by this theme,
  so they degrade to currentColor / the UA ring. The gallery ring and panel
  button focus are pinned locally; defining `--focus-ring-color` globally
  would touch macOS editor buttons and stays a deliberate non-change.
- **Panel button focus rides `:focus-visible`**, not `:focus`: a mouse click
  parks focus on the button, and a plain-:focus accent border lingers there
  like a stuck pressed state (third VM round finding). Keyboard navigation
  keeps the ring; pointer clicks leave nothing. Inputs deliberately stay on
  `:focus` — an editing caret is a state worth showing. The bubble/panel
  split is likewise deliberate: passive hints (tooltips) are accent bubbles,
  interactive popups (dropdown/context menus) are bordered surface panels,
  matching upstream Obsidian's own tooltip-vs-menu split.

## Mdmdt Coverage Audit (2026-07-26)

The issue #1 reporter pointed to Mdmdt (github.com/cayxc/Mdmdt) as the
best-looking megamenu treatment. A source audit (all three sheets) settled
what to take: **coverage only, no aesthetics** — its look comes from
reshaping footer/menus/tooltips/preferences globally with no platform lock
and ~16% `!important`, which this theme's macOS-fidelity promise rules out.

Adopted (in this theme's own language): back-button hover, pin/fullscreen
caption-popup surfaces, theme-card hover ring one tier below the active
ring, card stacking at the default sheet's 400px breakpoint, the preferences
type-scale extension, and the tooltip dual-selector hint that exposed our
own dead rule. Audited and already covered: Clear Recent Documents (rides
the themed dropdown), 660/586px header forms. Explicitly not taken: footer
pills, menu-item radii, scrollbar hiding, its three-copy file layout
(already drifted internally), bare `.sidebar` selectors, and hard-coded
sidebar colors. The cross-platform popup/menu/footer alignment idea moved
to the Obsidian-alignment backlog (TODO.md) where it can be measured
against Obsidian live values instead.

## Preferences Window

The preferences UI is `page-dist/setting.html` — a React app **shared by
every platform (macOS included)**, so nothing here may hang off
`.unibody-window`. Scope hook: the document root `#root.ty-preferences`.

- **Load order is reversed** vs the frame: the theme (`#user-theme`) loads
  *before* `Preferences.*.css` and the `os-theme` layer (`electron.css` /
  `cocoa.css`). Same-specificity theme rules lose; every override must ride
  `.ty-preferences` for strictly higher specificity.
- Its stylesheets set **no heading colors** (`h2` window title, `h3` page
  titles, `h5.input-group-header` section labels), so the theme's body
  heading palette leaks through unless reset.
- **OS-keyed dark literals**: `Preferences.css` paints `.export-detail`,
  `.export-item.active`, `.export-items-list-control` `#70717d` and
  `.nav-group-item:active/.active` `#4b4b4b` inside
  `@media (prefers-color-scheme: dark)` — keyed to the OS appearance, not
  the active theme. Under a dark OS with a light theme this frankensteins;
  the theme re-pins these to `--active-file-*` (what their base rules use).
  Body `light`/`dark` classes *do* follow the active theme (`setIsDarkMode`),
  only the media blocks follow the OS.
- **Settings harness**: the React app renders fully in plain headless Chrome
  (no Typora bridge needed — `window.isDebug` path). Recipe: copy
  `page-dist/`, rewrite the `#user-theme` href to a local theme copy, load
  `?os=win&theme=dark|light`, and inject a `setTimeout` click on the target
  `.nav-group-item` to reach other panes. Headless Chrome inherits the host
  OS color scheme (verify with a `prefers-color-scheme` probe page).

## Offline Verification Harness

Static render of the real megamenu DOM in headless Chrome; no Windows VM
needed for iteration. Rebuild from scratch (~10 min; keep it in a scratch
directory, not in the repo — Typora's resources are proprietary):

1. Download the Linux build (the package is a plain directory, no asar):
   `curl -L -o typora-linux.tar.gz https://download.typora.io/linux/Typora-linux-x64.tar.gz`
2. Extract the frame layer:
   `tar -xzf typora-linux.tar.gz --strip-components=2 "bin/Typora-linux-x64/resources/window.html" "bin/Typora-linux-x64/resources/style" "bin/Typora-linux-x64/resources/appsrc/window"`
3. Copy `bootstrap.css` from the macOS app
   (`/Applications/Typora.app/Contents/Resources/TypeMark/lib/bootstrape/css/bootstrap.css`)
   next to `window.html` as `lib-bootstrap.css`, and copy the theme files
   into `theme/` beside it.
4. Transform `window.html` into `harness.html`: strip all `<script>` tags,
   **remove every `crossorigin="anonymous"`** (it blocks stylesheets on
   `file://`), point the bootstrap link at `./lib-bootstrap.css`, drop the
   `typora-bg`/mermaid/user-css links, point `#theme_css` at
   `./theme/blue-topaz-dark.css`, then append a setup script that reads
   `?theme=dark|light&section=open|export|theme|preference|about` and:
   swaps the theme href; replaces body class `native-window` with
   `unibody-window megamenu-opened`; shows only `#megamenu-section-<x>`
   (inline `display`, the sections have no CSS toggle); moves `.active` to
   the matching sidebar item (`m-open`/`m-export`/`m-theme`/`m-preference`/
   `m-about`); injects one row into `#recent-document-table tbody`.
5. Screenshot (repeat per state; 832×654 @2x matches the reporter's VM):
   `"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" --headless=new --disable-gpu --hide-scrollbars --force-device-scale-factor=2 --window-size=832,654 --virtual-time-budget=5000 --screenshot=out.png "file://…/harness.html?theme=dark&section=open"`

**Fidelity gate**: before trusting any iteration, the untouched harness must
reproduce the current real-machine screenshots (structure, palette, control
shapes). Passed on 2026-07-25 against the reporter-style Windows VM shots.

**Known harness limits** (JS-populated content is absent): preferences panel
body, theme preview cards, pandoc-dependent export buttons, saved-state
sidebar toggle, localized strings (English only), `typora://` assets (about
logo). These need the real-machine pass.

**Forced-state extensions** (setup-script query params): `tooltip=1` fills
`#ty-tooltip` and forces it visible; `dropdown=1` opens the recent-files
"..." menu; `themecards=1` injects stub `.theme-preview-div` cards — join
the stubs with whitespace, since adjacent inline-blocks with no space
between them have no soft-wrap opportunity and will never wrap.

**Headless Chrome clamps windows to 500px logical width.** A
`--window-size=400` run silently renders a 500px layout (media queries do
not fire), while the screenshot still comes out 800px wide at @2x — it
looks like a 400px render but is not. For true sub-500 viewports, wrap the
harness in an `<iframe style="width:400px">` inside a wider host page; the
iframe is an honest 400px viewport for media queries.

## Open Investigations

- **Left-edge sliver**: the VM screenshots show a ~1-3px strip of colored
  pixels along the window's left edge, in the frame *and* in the separate
  preferences window. `.megamenu-content` does sit inset at `left:1px`
  (paired with the `.paint-border` window-border mode), but the megamenu
  rail paints `left:0` above it, and the preferences window has no megamenu
  at all — so that inset cannot be the whole story, and a blind `left:0`
  override is not applied. Next probe: a maximized-window screenshot on the
  VM. If the sliver vanishes maximized, it is a Parallels/DWM edge artifact
  of non-maximized windows (close as platform); if it stays, it is in-page
  and gets a dedicated hunt.

(Resolved: the "Saved" light tooltip mystery — see the tooltip entry in
Platform Facts; every window and mode now resolves to the accent bubble,
verified by forced-state harness shots and pixel sampling.)
