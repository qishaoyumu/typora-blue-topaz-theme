# Obsidian → Typora Color Mapping

## Light Mode

| Obsidian Variable | Value | Typora Variable |
|---|---|---|
| `--background-primary` | `#ffffff` | `--bg-color` |
| `--background-secondary` | `#fcfcfc` | `--side-bar-bg-color` |
| `--menu-background` (= `--background-secondary`) | `#fcfcfc` | `--menu-bg-color` — context menu, dropdown menus, the recent-files dropdown; one notch off the page like the sidebar (was `--bg-color`) |
| `--status-bar-bg` | `#f3f3f3` | Not taken: the reference's status bar is a corner box, Typora's `footer.ty-footer` (Windows/Linux) is a width-driven band/float; the band states read `--side-bar-bg-color` (`--background-secondary`) to join the sidebar footer, the floating states stay transparent. The word-count popup stays a `--bg-color` panel |
| `--scrollbar-active-thumb-bg` | `#ddddddd9` | `::-webkit-scrollbar-thumb:hover` and `:active`, one shared step (were `#ccc` / `#bbb`); the resting thumb keeps `#dcdcdcbe` |
| `--text-normal` | `#0e0e0e` | `--text-color` |
| `--background-modifier-border` | `#dddddd` | `--ui-border-color` — generic 1px UI hairline (window, panels, inputs, fence language chip) |
| `--background-modifier-border-focus` | `#bdbdbd` (core `--color-base-40`; the theme leaves it unset) | `--ui-border-focus-color` — text-input focus in the reference's grammar: the border steps one notch to neutral, no accent, no ring (app.css `input[type=text]:focus { border-color }`; Blue Topaz zeroes the focus-visible box-shadow). Consumers: `#file-library-search-input:focus`, `#recent-file-panel-search-input:focus` (the fence language chip tried this step first and moved to the has-focus accent, see Fence chrome). Other stock inputs (in-document search, table-resize `3 x 5`, megamenu filters) still take Typora's accent focus — deliberately left for a later pass |
| `--color-accent` | `hsl(207, 77%, 54%)` | `--primary-color` |
| (link text) | `hsl(207, 77%, 54%)` | `--link-color` = `var(--primary-color)`; the 2026-06 `#1a79c6` AA deepening was reverted for fidelity in 2026-07 (measured: links are the accent itself) |
| `--interactive-accent` | `rgb(65, 159, 231)` | `--interactive-accent` — the reference's hsl-calc-brightened accent: blockquote bar and checked-checkbox fill (same family as `--file-icon-color`). Paired with `--interactive-accent-hover`, the accent-2 token, light `hsl(204, 78.5%, 62.1%)` = hsl(H−3, S×1.02, L×1.15), live-verified `rgb(82,174,234)`: the checked-hover fill, which a `hue-rotate(160deg)` filter spins to the salmon uncheck warning — the reference defines no salmon literal. Both restored by the 2026-08 checkbox redo (had left with revert `111cd76`) |
| `--text-folder-file` | `#272727` | `--file-text-color` |
| `--accent-em` | `#088743` | em color (deepened from upstream `#099d4e` for WCAG AA) |
| `--accent-strong` | `#000000` | strong color |
| `--text-color-code` | `#e95d00` | code color; the reference's measured value (the 2026-06 `#b34800` AA deepening was reverted for fidelity in 2026-07) |
| `--background-code` | `#e6e6e671` | code block bg (Typora `.md-fences` pre-blends it on white as `#f4f4f4`) |
| `--background-code-2` | `#cccccc62` | inline code background |
| `--background-blockquote` | `#d5d5d52c` | blockquote bg |
| `--text-selection` | `#a9d1c859` | `--select-text-bg-color` |
| `--h1-color` | `hsl(216, 88%, 26%)` | h1 color (darkest blue) |
| `--h2-color` | `hsl(212, 100%, 33%)` | h2 color |
| `--h3-color` | `hsl(210, 86%, 39%)` | h3 color |
| `--h4-color` | `hsl(208, 58%, 49%)` | h4 color |
| `--h5-color` | `hsl(209, 70%, 58%)` | h5 color |
| `--h6-color` | `hsl(209, 65%, 58%)` | h6 color (lightest blue) |

The `--h1-color` .. `--h6-color` tokens are a single source of truth: base
headings, focus mode, and both print paths read them through `var()` rather
than repeating the literals. Dark overrides the six values to its rainbow
palette in its own `:root`, so dark export prints the rainbow headings too; the
dark print block no longer hard-codes light-blue heading literals.

### Sidebar & File Tree (Light)

Translucent variants derived from the light accent `hsl(207, 77%, 54%)`
(aligned with Obsidian's `--accent-h/s/l`), plus a few sidebar-semantic
helpers.

| Typora Variable | Value | Usage |
|---|---|---|
| `--primary-color-01` | `hsla(207, 77%, 54%, 0.1)` | Search-active background (file-row hover/active moved to `--file-active-bg`) |
| `--primary-color-02` | `hsla(207, 77%, 54%, 0.2)` | Search-result highlight (`.ty-file-search-match-text`) |
| `--search-hit-border` | `#b7b7b7` | In-document search candidate-hit outline (2px, no fill, 2px radius). Obsidian core (app.css in obsidian.asar) draws hits as a 2px `var(--text-normal)` ring at opacity 0.3; pre-blended here: `#0e0e0e` × 0.3 over `#ffffff`. Current hit: 3px `--primary-color` (= `var(--text-accent)` at opacity 1 upstream) |
| `--file-active-bg` | `hsla(207, 77%, 54%, 0.1)` | File-row hover and active background, file tree + file list (hover and active share one color, matching Obsidian's single `--theme-color-translucent-01`); same value as `--primary-color-01` in light, split so search/table consumers stay independent |
| `--suggest-active-bg` | `hsla(207, 77%, 54%, 0.15)` | Selected/hovered row in suggestion-style lists: quick-open items, auto-suggest rows. Blue Topaz `.suggestion-item.is-selected` = `--theme-color-translucent-015` (blends to `#e0effb` on white); one state for hover and keyboard selection, and both may show at once |
| `--folder-hover-bg` | `rgba(0, 0, 0, 0.067)` | Neutral-gray folder hover; measured (`--nav-item-background-hover` black 0.067) |
| `--item-hover-bg-color` | `rgba(0, 0, 0, 0.067)` | Generic item hover wash: outline rows, sidebar search hits, sidebar footer items, megamenu rows (hover and active alike, per the reference settings nav) / buttons, unibody settings nav active, the source-mode footer toggle, unibody titlebar buttons, `.btn-default:hover`, dropdown-menu items. Obsidian `--background-modifier-hover` (`rgba(var(--mono-rgb-100), 0.067)`), kept translucent instead of the earlier `#f0f0f0` pre-blend so one token reads the same on `#ffffff`, `#fcfcfc`, and panels; `--toc-hover-bg` (the in-document TOC row hover) now aliases it, replacing the hand-computed `#f3f3f3` |
| `--file-icon-color` | `rgb(65, 159, 231)` | File icon fill; the reference light icon is a brighter blue than the accent (measured `--text-folder-file-icon`), while dark's equals the primary formula |
| `--file-text-color` | `#272727` | Default file-node text color (folders override to `--text-color` for stronger contrast) |
| `--active-file-text-color` | `var(--file-text-color)` | Active row text = normal text, as measured in the reference (only hover brightens); base paints the tree's active text through this variable |
| Hard-coded `#eb7c46` | `#eb7c46` | Active-file icon hover color (Obsidian's signature orange-red), shared between light and dark. A decorative hover accent, not body text; ~2.5:1 on the light background, kept for brand identity |
| `--control-text-color` | `#747474` | File-list-view meta info (parent-loc / summary / time text color); deepened from `#7f7f7f` for AA |
| `--indent-guide-color` | `rgba(0, 0, 0, 0.12)` | Indent guide line for the file tree and nested body lists; matches Obsidian's `rgba(var(--mono-rgb-100), 0.12)` (black in light). The reference draws no body-list guides in reading view (verified live 2026-07-26); ours stay as a user-confirmed deliberate deviation, re-anchored to the drawn-dot geometry (ul −12px / ol −16px) |
| `--outline-guide-color` | `rgba(148, 148, 148, 0.2)` | Outline indent guide; Blue Topaz's own `#94949433` constant, identical in both schemes (measured), so no dark override exists |
| `--indent-guide-active-color` | `hsla(207, 77%, 54%, 0.4)` | Outline indent guide on hover (ancestor-chain highlight); aligned with Obsidian `--theme-color-translucent-04` |

## Dark Mode

| Obsidian Variable | Value | Typora Variable |
|---|---|---|
| `--background-primary` | `#202020` | `--bg-color` |
| `--background-secondary` | `#151515` | `--side-bar-bg-color` |
| `--menu-background` (= `--background-secondary`) | `#151515` | `--menu-bg-color` — context menu, dropdown menus, recent-files dropdown (was `--dark-panel-bg`) |
| `--status-bar-bg` | `#000000` | Not taken (see light); the footer band reads `--side-bar-bg-color` `#151515` |
| `--scrollbar-active-thumb-bg` | `#4d4d4d88` | `::-webkit-scrollbar-thumb:hover` and `:active`, one shared step (were `#555` / `#666`); the resting thumb keeps `#3f3f3f7e` |
| `--text-normal` | `#c6c6c6` | `--text-color` |
| `--text-folder-file` | `#b3b3b3` | `--file-text-color` |
| `--accent-em` | `#a4ca8e` | em color |
| `--accent-strong` | `#e7e7e7` | strong color |
| `--text-color-code` | `#d58000` | code color; the reference's measured value (the 2026-06 `#f49200` AA lightening was reverted for fidelity in 2026-07) |
| `--background-code` | `#1111118c` | code block bg (Typora `.md-fences` pre-blends it on `#202020` as `#181818`) |
| `--background-code-2` | `#4c4c4cb0` | inline code background |
| `--background-blockquote` | `#9191911c` | blockquote bg |
| `--text-selection` | `#3b767160` | `--select-text-bg-color` |
| `--h1-color` | `hsl(78, 62%, 47%)` | h1 color (green) |
| `--h2-color` | `hsl(118, 42%, 49%)` | h2 color (green-cyan) |
| `--h3-color` | `hsl(180, 53%, 48%)` | h3 color (cyan) |
| `--h4-color` | `hsl(216, 69%, 68%)` | h4 color (blue) |
| `--h5-color` | `hsl(258, 79%, 77%)` | h5 color (purple) |
| `--h6-color` | `hsl(290, 85%, 81%)` | h6 color (pink) |

### Sidebar & File Tree (Dark)

The dark translucent variants **deliberately push saturation and lightness
up** (64 → 72, 49 → 58) so the blue still reads as blue on `#151515` /
`#202020` rather than collapsing to gray. The hue stays at 208 to match
`--primary-color`.

A second dark blue formula, `hsla(208, 64%, 49%, a)` (the HSL form of the dark `--primary-color` itself, base saturation/lightness, not the pushed-up 72/58 sidebar variant), is used at lower alpha for `--active-file-bg-color`, the `#write th` header tint, and the code active-line background. Do not "fix" these to 72/58: the base formula and the brightened sidebar formula are intentionally distinct.

| Typora Variable | Value | Usage |
|---|---|---|
| `--primary-color-01` | `hsla(208, 72%, 58%, 0.14)` | Search-active background (file-row hover/active moved to `--file-active-bg`) |
| `--file-active-bg` | `hsla(208, 64%, 49%, 0.1)` | File-row hover and active background, file tree + file list; measured live in the reference vault (`--theme-color-translucent-01` = hsl 208/64/49 at 0.1 — the darker dark-blue formula, not `--primary-color-01`'s 72/58) |
| `--suggest-active-bg` | `hsla(208, 64%, 49%, 0.15)` | Selected/hovered row in quick-open and auto-suggest lists; the base dark formula at 0.15 (`--theme-color-translucent-015`, blends to `#222f3a` on `#202020`) |
| `--primary-color-02` | `hsla(208, 72%, 58%, 0.26)` | Search-result highlight |
| `--search-hit-border` | `#525252` | In-document search candidate-hit outline; the same core formula pre-blended on dark: `#c6c6c6` × 0.3 over `#202020` — reproduces the earlier screenshot-measured value exactly (see the light table row for the formula's source) |
| `--interactive-accent` | `var(--primary-color)` | Dark's measured interactive accent equals the primary formula (blockquote bar, checked-checkbox fill). Paired dark accent-2 hover `hsl(203, 67.2%, 63.2%)` = hsl(208−5, 64%×1.05, 49%×1.29), live-verified `rgb(98,176,224)`; the same `hue-rotate(160deg)` salmon warning rides on it, over the page-background `#202020` check glyph. Both restored by the 2026-08 checkbox redo |
| `--folder-hover-bg` | `rgba(255, 255, 255, 0.067)` | Neutral-gray folder hover; measured live in the reference vault (`--nav-item-background-hover` white 0.067) |
| `--item-hover-bg-color` | `rgba(255, 255, 255, 0.067)` | Generic item hover wash, dark `--background-modifier-hover`. Translucent on purpose: the earlier `#2a2a2a` pre-blend was invisible on the `#2b2b2b` panels (context menu, quick-open, suggest list, `.btn-default`); one alpha now reads on `#151515` and `#202020` alike, and the dark `--toc-hover-bg` override (`#383838`) is gone |
| `--file-text-color` | `#b3b3b3` | Default file-node text color, measured in the reference vault (a brief `#a0a0a0` dimming experiment was reverted — the original really is `#b3b3b3`) |
| `--active-file-text-color` | `var(--file-text-color)` | Active row text = normal text (`#b3b3b3` = the reference's measured 179); only hover brightens |
| Hard-coded `#eb7c46` | `#eb7c46` | Active-file icon hover color, shared with light; clears WCAG AA (>4.5:1) on the dark background |
| `--control-text-color` | `#8a8a8a` | File-list-view meta info (parent-loc / summary / time text color) |
| `--dark-border-color` | `#343434` | Generic 1px border tone for the dark scheme: window, code tooltip, sidebar, search, modals, table edit UI, etc. (the table body's cell dividers use a darker `#1a1a1a`) |
| `--ui-border-focus-color` | `#555555` | Text-input focus step, the reference's dark `--color-base-40` (resting `#343434` → focus `#555555`, the same one-notch delta as light `#ddd` → `#bdbdbd`); consumers listed in the light table |
| `--dark-panel-bg` | `#202020` | Raised-panel fill: editing-control code-tooltip, quick-open, auto-suggest, modal, notification, footer word-count. The reference's `--suggestion-background` / `--modal-background` / `--prompt-background` all resolve to the page colour `#202020`; the panel's shape comes from `--dark-border-color` + `--shadow-sm`, not a lift (the earlier `#2b2b2b` had no reference source). NOT the hover-preview card (`#242424` measured, see below), the menus (`--menu-bg-color`), or the #ty-tooltip accent bubble |
| `--dark-surface-2` | `#1a1a1a` | Recessed dark surface: code block, line-number gutter, meta block, quick-open input, in-document search input (`#md-searchpanel input`, one step under its `#202020` panel), table cell dividers |
| `--indent-guide-color` | `rgba(255, 255, 255, 0.12)` | Indent guide line for the file tree and nested body lists; white tint matching Obsidian's `rgba(var(--mono-rgb-100), 0.12)` on dark (the outline guide keeps light's mode-independent `--outline-guide-color`). Body-list guides are a deliberate deviation, see the light table |
| `--file-icon-color` | `var(--primary-color)` | File icon fill; dark's measured icon blue (rgb 45,130,205) equals the primary formula |
| `--indent-guide-active-color` | `hsla(208, 64%, 49%, 0.4)` | Outline indent guide on hover; the measured dark `--theme-color-translucent-04` (base 64/49 formula, not the brightened 72/58 sidebar variant) |

**Tooltips** follow the upstream split (2026-08, correcting the earlier
all-bubble unification): `#ty-tooltip` UI hints are the accent bubble —
`--interactive-accent` background (upstream `theme.css` paints `.tooltip`
with that token: light `rgb(65,159,231)`, dark aliases the primary
formula), white text, both modes, deliberately no dark-file override
(2026-08-16: was `--primary-color`, which only differed in light). Generic `.md-hover-tip` bubbles (absent in this
macOS build; other builds put link tips on the class) keep the accent
bubble with its accent arrow. `.md-f-tooltip` in-document previews (the
footnote content preview and the undefined-footnote warning) are the
reference's `.popover.hover-popover` card: light `#fafafa` on `1px #ddd`,
dark `#242424` on `#343434`, radius 7px, the measured four-layer shadow,
arrowless like the reference, fixed 450px width, content scaled to
13.125px/1.5 with ~13px vertical inset (captured from a live footnote
hover: the popover's 15px base x 0.875); its content layer goes
transparent so the stock inherit-background never planks over the card's
border. Editing-control `.code-tooltip` (fence language input, math
preview) stays a panel surface. See dev/megamenu.md for the two-system
mechanics.

## Code Highlighting: Light (.cm-s-inner)

Blue Topaz edit-mode effective colors, measured live per token class in the
reference (2026-08-09; Obsidian light, CM6 editor spans). Copied by rendered
value, not by variable name: the reference routes several classes away from
their nominal variables (def/property land on the attribute yellow, number on
the value green, qualifier on an orange none of its variables name), so each
cell below is the measured on-screen color. Classes the reference never colors
in code (header, quote, link, negative, positive, error) keep this port's
previous values. The reference also ships a multi-scheme code palette through
Style Settings (bt-default, Dracula, Gruvbox, Monokai, and more); Typora has
no scheme selector, so this port carries the default scheme only.

All token colors carry `!important`: Typora's base unifies selected code
glyphs to `--select-text-font-color !important`, and the palette must out-rank
it so selection keeps syntax colors, as the reference does.

| Token | Color | Note |
|---|---|---|
| `.cm-keyword` | `#d53984` | keyword (no bold in light) |
| `.cm-type` | `#d53984` | type annotation |
| `.cm-atom` | `#cc7523` | special constants |
| `.cm-number` | `#a3be8c` | number (routed to the value green) |
| `.cm-def` | `#e0ac00` | definition |
| `.cm-property` | `#e0ac00` | property access |
| `.cm-attribute` | `#e0ac00` | attribute name |
| `.cm-variable` | `#f07178` | variable |
| `.cm-variable-2` | `#53ada3` | block-level variable |
| `.cm-variable-3` | `inherit` | unstyled in the reference; CSS pseudos land here |
| `.cm-string` | `#08b94e` | string |
| `.cm-string-2` | `#08b94e` | template string / regex |
| `.cm-operator` | `#5e81ac` | operator |
| `.cm-comment` | `#068a5e` | comment (no italic) |
| `.cm-meta` | `#ffcb6b` | metadata; the reference's own light value, kept by fidelity (user-approved) |
| `.cm-builtin` | `#ffcb6b` | built-in; same |
| `.cm-qualifier` | `#e48100` | CSS qualifier |
| `.cm-bracket` | `#7f7f7f` | bracket |
| `.cm-tag.cm-bracket` | `#7f7f7f` | angle brackets keep the pair-gray over the tag color |
| `.cm-tag` | `#c74df7` | HTML/XML tag |
| `.cm-header` | `#00f` | heading (kept) |
| `.cm-quote` | `#008200` | quote (kept) |
| `.cm-hr` | `#7f7f7f` | horizontal rule (reference stylesheet value) |
| `.cm-link` | `#00c` | link (kept) |
| `.cm-negative` | `#d62727` | negative number (kept) |
| `.cm-positive` | `#1c801c` | positive number (kept) |
| `.cm-error` | `#dc182f` | error (kept) |

In-fence ink is pure black (`.md-fences { color: #000 }`), one notch darker
than `--text-color`, matching the reference.

## Code Highlighting: Dark (.cm-s-inner)

Blue Topaz dark edit-mode effective colors (2026-08-09), measured the same
way, with the same routing caveats. Keyword additionally carries weight 600 -
the reference bolds keywords in dark only.

| Token | Color | Note |
|---|---|---|
| `.cm-keyword` | `#fa99cd` + w600 | keyword, bolded in dark |
| `.cm-type` | `#fa99cd` | type annotation (regular weight) |
| `.cm-operator` | `#a0c7e9` | operator |
| `.cm-atom` | `#da904b` | special constants |
| `.cm-comment` | `#568060` | comment |
| `.cm-meta` / `.cm-builtin` | `#ffcb6b` | metadata / built-in |
| `.cm-bracket` / `.cm-hr` | `#8a8a8a` | bracket / horizontal rule |
| `.cm-tag.cm-bracket` | `#8a8a8a` | angle brackets keep the pair-gray |
| `.cm-number` | `#abd58e` | number (value green) |
| `.cm-def` / `.cm-property` / `.cm-attribute` | `#e0de71` | definition family |
| `.cm-variable` | `#f07178` | variable |
| `.cm-variable-2` | `#53ada3` | block-level variable |
| `.cm-variable-3` | `inherit` (light rule flows through) | unstyled in the reference |
| `.cm-string` / `.cm-string-2` / `.cm-quote` | `#44cf6e` | strings; quote rides string |
| `.cm-link` | `#696d70` | link (reference stylesheet value) |
| `.cm-header` | `#da7dae` | heading (reference stylesheet value) |
| `.cm-qualifier` | `#d6b87f` | CSS qualifier |
| `.cm-tag` | `#db7c84` | HTML/XML tag |
| `.cm-positive` | `#7ee787` | positive number (kept) |
| `.cm-negative` / `.cm-error` | `#ffa198` | negative / error (kept) |

In-fence ink is `#d0d0d0` (`.md-fences { color: #d0d0d0 }`), one step brighter
than `--text-color`.

### Fence chrome shared by both modes

- **Active line**: `#write .md-fences.md-focus .CodeMirror-activeline-background`,
  pre-blended `#f5fafe` light / `#212529` dark. The reference paints a raw 5%
  accent on a line that first sheds the block background, so the raw value is
  invisible over our opaque fence. Typora's stock codemirror.css also kills the
  bare class with `background: inherit` at (0,2,0) - hence the `#write` prefix -
  and `.md-focus` keeps the stripe on the focused block only (CM5 would draw
  one in every unfocused editor). CM hides the stripe while a selection is
  active; the reference does the same.
- **Selection**: in fences the select color lives on the
  `.CodeMirror-selectedtext` spans, which wrap exactly the selected
  characters - reproducing the reference's ragged, text-extent selection -
  while the full-width `.CodeMirror-selected` div is blanked. Typora's base
  coats both layers and unifies selected glyph color (all `!important`), which
  double-painted the wash and greyed the code; the fence rules out-rank it,
  and the token `!important`s keep syntax colors under selection. The span
  color is pre-blended opaque (`--select-text-bg-color` over the fence bg:
  `#dae8e5` light, `#253b3a` dark) with a 1px box-shadow bridge and 1px
  vertical padding (17px glyph box on a 19px line box): translucent span
  tiles rasterize with 1px seams at fractional glyph boundaries and leave
  1px line gaps; opaque paint composites to the same pixels while hiding
  seams and overlap. Recompute both values if the fence bg or the selection
  variable ever changes. The reference's native `::selection` also paints the
  selected line break as a one-column stub past the last glyph of every line
  the selection crosses; CM5's newline has no span carrier, so a
  `:last-child` override widens the shadow to `calc(1ch - 0.5px)` (same
  pre-blended color per mode) - the last token span is `:last-child` exactly
  when the selection crosses the line end, so mid-line selection ends stay
  flush, as in the reference. The block's last line is exempted via
  `.CodeMirror-code > :last-child` (no line break exists inside the fence,
  so the reference never stubs it; the bare `:last-child` also matches
  CM5's lingering classless div line-wrappers left where the cursor
  visited, which a `pre:last-child` selector would miss).
- **Language chip** (`.md-fences .code-tooltip`, the focused fence's
  language editor): one control, one box, one place. Stock hangs the editor
  under the fence's bottom-right corner (`bottom: -2.5em`, outside the block,
  where it lands on the next block's corner and covers its label) and draws a
  bordered card, and inside it a 140px centered contenteditable well that
  grows an accent border on focus (`.code-tooltip .ty-input:focus
  { border-color: var(--primary-color) }`) - a form control on a panel. The
  theme makes the panel itself the chip (4px radius, `--ui-border-color`
  hairline, `--shadow-sm`, `--bg-color` / `--dark-panel-bg`, `padding: 0`)
  and makes the span the whole field (`border: 0`, zero margin, the chip's
  `padding: 3px 10px` on the span itself so every pixel inside the border
  is the contenteditable - one hit target, one I-beam; with the padding on
  the wrapper the rim was dead, since frame.js skips clicks targeting
  `.code-tooltip` and hands nothing to the span; left-aligned, no width
  floor, `max-width: 142px` (= the editing width) with `overflow: hidden` +
  ellipsis, UI face 13px/400 on an 18px line - the reference's
  `--font-ui-small`, what its `input[type=text]` and `.suggestion-item`
  use and what this theme's outline/file-tree rows already are; the badge
  keeps the flair's 12px-class size, they never show together -
  `vertical-align: top`). Hover on an un-edited chip layers
  `--item-hover-bg-color` as a gradient image over the mode's background.
  Ink: idle (block
  focused, chip not) the label's `#95a3b5` at full opacity, so entering the
  block reads as the badge moving down into a chip; editing brightens it to
  `--text-color` over 140ms ease-in-out, on the border's beat. Case and
  weight stay different from the label on purpose: the badge shows the
  reference's canonical display name (uppercase 600, `JS`/`SHELL`/`C#`),
  the field shows the stored id in regular weight, matching what is typed
  and what the suggest list offers.
  Focus = `:focus-within` on the chip with a 140ms border transition. The
  color went through two rounds: first the text-input step
  (`--ui-border-focus-color`), which proved too faint on a small chip amid
  coloured code in both modes; now the reference's has-focus vocabulary for
  small interactive items (`.tree-item-self.has-focus` →
  `color-mix(var(--theme-color), transparent 30%)`), pre-blended over the
  chip's own background: light `#6db3ec` (= `#2f93e4` at 70% over `#ffffff`),
  dark `#296599` (= `rgb(45,130,205)` at 70% over `#202020`; was `#2c689c`
  over the old `#2b2b2b` panel); still 1px, no ring. Width policy: idle
  (block focused, chip not) hugs the value, no floor (a one-letter id is a
  29px chip), capped at 142px with an ellipsis; editing (`:focus-within`)
  and empty both take a fixed 142px field (122px of content; the longest
  localized placeholder measured in Inter 13px is Spanish "lenguaje de
  código" at 117px, Catalan 116.5px; the width is really set by the list
  below, which must fit reStructuredText - see Geometry), `text-overflow: clip` while editing so the caret scrolls the
  hidden overflow instead of growing the box. The expansion snaps: an eased
  opening left the caret painted at its old spot while the box grew
  (WebKit does not repaint the caret per frame during a transition) - the
  "sticky caret" seen in use; only the collapse on blur eases, 140ms on the
  reference's `--anim-motion-swing` curve (cubic-bezier(0, 0.55, 0.45, 1),
  what app.css puts on width transitions). The border color eases 140ms
  ease-in-out, the reference's input-focus beat. The placeholder is an
  absolutely positioned `::after`, so it cannot size the box and the fixed
  field fits the longest localized string; mac.css centers it with `padding-left: 50%
  !important` on the empty span plus `left:0; right:0` on the `::after` -
  the theme sets that padding back to the chip's 10px at equal importance
  and higher specificity ((0,4,0) over (0,3,0)) and pulls the `::after` in
  to `left: 10px; right: 10px`, left-aligned, so the hint reads
  like the value it stands in for and the empty span keeps the 142px rect
  the list is anchored to. frame.js `makeVisible` anchors the auto-suggest
  list once, at first show, to the span's left edge and width, so a
  hugging span slid out from under its list per keystroke and an empty
  chip collapsed on the first key - the fixed field keeps the list seated
  under the chip, edges aligned, at the cost of one expansion on click.
  The hint is `#95a3b5`, the label's family. **Suggest list (2026-08-16,
  round 6)**: `#ty-auto-suggest.auto-suggest-container` is one shared
  `position:fixed` container for every suggest type; the theme restyles it
  for all (page fill, 1px `--ui-border-color` ring drawn as an inset shadow
  plus `--shadow-sm`, 4px radius, `padding: 6px 4px`, 13px/18px type, 26px
  gapless rows with a 5px radius, `.ty-file-icon` column 24px instead of
  stock 38, row text ellipsizes under `calc(100% - 24px)`, hover and
  `.active` both `--suggest-active-bg`, arrow cursor) and fuses the fence
  variant with its chip into one combobox: `#ty-auto-suggest:has(>
  .auto-suggest-for-fences)` gets `margin-top: -5px; margin-left: -1px;
  min-width: 144px !important`, squared top corners, and the chip's focus
  blue (`#6db3ec` / `#296599`) as inset shadows on its sides and bottom;
  `body:has(#ty-auto-suggest.ty-show > .auto-suggest-for-fences) .md-fences
  .code-tooltip:focus-within` squares the chip's bottom corners, turns its
  bottom border into the hairline divider, and drops its shadow. Geometry:
  span 142 × 24 (122 content + 2 x 10 padding, 3px vertical padding) → chip
  144 × 26 (1px border around it), so the span's rect sits 1px inside the
  chip's edge, hence -1px / -5px (6px offset minus the 1px bottom border);
  frame.js `makeVisible` puts the list at `top = span.bottom + 6, left =
  span.left, min-width = span.width` once per show and never flips it,
  hence the fixed margins; frame.js also sets an inline `max-height = 5 *
  first-row clientHeight + 12` once per session, which under border-box
  sizing is exactly five 26px rows plus the 6px paddings - the reason the
  ring is an inset shadow (a border would clip row five) and the rows carry
  no gap. Text area = 144 - 8 container padding - 24 icon column - 6 row
  padding = 106px; the longest id `reStructuredText` = 103.3px at 13px
  Inter, which is what fixes the chip at 144 (the first even width that
  fits it; the placeholder needs only 139);
  the ellipsis only appears when the classic 8px scrollbar shows on hover
  for lists longer than five rows (prefix "r"). Diagram fences (stock chip
  placement) get the same fused list geometry, since the chip's box is the
  same. `:has()` needs WebKit 15.4+ / Chromium 105+; without it the list is
  still styled but detached, and the chip stays rounded. Verified against
  the 2026-08-09 exports: the tooltip element is
  never serialized (its `md-tooltip-remove` class), so no export gate is
  needed. **Placement (2026-08-15, three rounds)**: `.md-fences
  .code-tooltip { bottom: 10px; right: 20px }` seats the chip inside the
  block, bottom-right - Typora's own corner for this control, brought inside
  the box. Round one hung it where stock does (outside, under the corner):
  it read as a gadget and covered the next block's idle label. Round two put
  it top-right on the label's spot (mock-compared against bottom-right and a
  hanging tab): the two-block picture looked most unified, but in use the
  corner morphed three times (label, chip, field) and lured the click that
  merely focuses the block - Typora's editor is two clicks away by design,
  so badge and control must stay apart (which is what the 2026-08-09 call,
  and the reference's clear-flair-on-focus behaviour, had said). Round three
  is the current seat: idle label top-right hides on block focus (one
  representation at a time, the reference's flair yield); the chip appears
  bottom-right inside; the label keeps the reference's own offsets (0.5em
  top, 1.5em-padding-aligned right). Diagram fences keep stock's placement
  (`.enable-diagrams .md-diagram .code-tooltip`, (0,3,0), hangs under the
  diagram panel). Also considered and dropped: making the idle label itself
  the click target (an invisible span over it, Notion-style) - the tooltip
  element is created lazily on a fence's first focus and hidden with inline
  display:none afterwards (main.js), so CSS cannot offer a first-click
  editor, and Typora users would look for the control bottom-right; a tab
  hanging off the bottom edge (still outside, collides with the next block);
  an always-on chip at rest (a box on every block whose text re-sets on
  focus). Known limit, accepted 2026-08-15: while the block is focused the
  chip covers the last ~90px of the block's last line (visible when a long
  last line wraps), and a click there lands in the language field rather
  than the code; every other seat only moves the overlap onto something
  else, and padding the block on focus would break the zero-shift rule.
  The auto-suggest list drops below the chip (and so below the block), as
  stock places it; the theme only fuses it to the chip.
- **Matching brackets**: none. Typora does not ship CodeMirror's matchbrackets
  addon (no `matchBrackets` hit anywhere in TypeMark), so
  `.CodeMirror-matchingbracket` never appears; the old underline rule was dead
  code and was removed on 2026-08-09.

## Source mode (`.cm-s-typora-default`)

Typora's source/editing mode uses a CodeMirror palette separate from the
rendered `.cm-s-inner` tables above. Light is a One-Light-style scheme;
dark is a muted blue-violet scheme. These are editing-surface tokens, not
part of the rendered output.

| Token | Light | Dark |
|---|---|---|
| `.cm-header` / `.cm-property` | `hsl(212, 100%, 33%)` | `#cebcca` |
| `.cm-comment` / `.cm-code` | `#a0a1a7` | `#8aa1e1` |
| `.cm-string` | `#50a14f` | `#A7A7D9` |
| `.cm-atom` / `.cm-number` | `#986801` | `#848695` (italic) |
| `.cm-link` | `--primary-color` | `--primary-color` |
| Active line | `hsla(207, 77%, 54%, 0.05)` | `rgba(51, 51, 51, 0.72)` |
| Cursor | `--text-color` | `#c6c6c6` |

## GFM Alerts

The five GFM Alert backgrounds were promoted from literals to `:root`
variables, giving light and dark a single source of truth. The values are
**opaque, pre-blended** onto the page color (each is the old `rgba(...)` tint
composited onto white / `#202020`). The alert paints them as
`linear-gradient(tint 2.3em, var(--alert-body-bg) 2.3em)`: a tinted title
band over a body that matches the page. They must stay opaque: Typora's PDF
export renders a `transparent` gradient stop as solid black, so
`--alert-body-bg` replaces the old `transparent` body stop and the alert body
prints clean. (See the Print / export path section for the alpha rule.)

The 2026-07 fidelity pass rebuilt the palette on the reference vault's
live-measured callouts: the reference collapses the five GitHub types into
**three visual classes** — note (blue), warning + caution (orange),
important + tip (cyan) — with the type color carried by the icon (lucide
pencil / triangle-alert / flame, masked and tinted with `--alert-*-accent`)
and the title strip (accent at 0.15), while the **label text is neutral**
`--text-color` (the per-type AA-tuned label colors from the 2026-06 pass were
removed together with Typora's built-in octicons).

The 2026-07-26 spacing pass replicated the reference's measured geometry:
the callout has **no alert-specific spacing** — title band 36.8px (= 8px
pads + 20.8px line, our `0.5em + 1em/1.3` title = the 2.3em gradient stop),
then a symmetric 21px above and below the body (content pad 5px + standard
16px block margin), 16px between any two blocks inside (paragraphs, nested
quotes, boxes themselves), body text 14px from the outer edge / 10px right,
icon at 16px, title text at 38px. Implemented as `#write .md-alert > *
{ margin-block: 1em }` (+ first-child 0, list-last-child 0) with box padding
`0 10px 5px 14px`. The newline after `[!NOTE]` survives into the DOM: the
editor keeps it as a `.md-softbreak` span right after the title (main.js
strips it from the alert token only when exporting), export folds it into a
trailing `<br>`. With a block-displayed title either carrier renders as a
phantom blank line (the old top-heavy gap) — both adjacent carriers are
hidden (`.md-alert-text + .md-softbreak` / `+ br`), and the break re-shows
while the title is expanded for editing.

### Light (strips pre-blended on `#ffffff`; accents measured)

| Variable | Value | Usage |
|---|---|---|
| `--alert-note-bg` | `#dae9fa` | Note title band + left bar (accent at 0.15 on white) |
| `--alert-important-bg` | `#d9f5f5` | Important title band + left bar (= tip) |
| `--alert-warning-bg` | `#fcead9` | Warning title band + left bar (= caution) |
| `--alert-tip-bg` | `#d9f5f5` | Tip title band + left bar |
| `--alert-caution-bg` | `#fcead9` | Caution title band + left bar |
| `--alert-note-accent` | `rgb(8, 109, 221)` | Note icon (pencil) |
| `--alert-warning-accent` | `rgb(236, 117, 0)` | Warning + caution icon (triangle-alert) |
| `--alert-tip-accent` | `rgb(0, 191, 188)` | Tip + important icon (flame) |
| `--alert-body-bg` | `#ffffff` | Alert body fill below the title band (was `transparent`) |

### Dark (strips pre-blended on `#202020`; accents measured)

| Variable | Value | Usage |
|---|---|---|
| `--alert-note-bg` | `#1c2e41` | Note title band + left bar |
| `--alert-important-bg` | `#283d3c` | Important title band + left bar (= tip) |
| `--alert-warning-bg` | `#3e3225` | Warning title band + left bar (= caution) |
| `--alert-tip-bg` | `#283d3c` | Tip title band + left bar |
| `--alert-caution-bg` | `#3e3225` | Caution title band + left bar |
| `--alert-note-accent` | `rgb(2, 122, 255)` | Note icon |
| `--alert-warning-accent` | `rgb(233, 151, 63)` | Warning + caution icon |
| `--alert-tip-accent` | `rgb(83, 223, 221)` | Tip + important icon |
| `--alert-body-bg` | `#202020` | Alert body fill below the title band (was `transparent`) |

Each type maps `--alert-bg` / `--alert-accent` / `--alert-icon`; shared
`.md-alert` and `.md-alert::before` rules draw the gradient body and the
4px left bar from them, so the machinery lives in one place.

## Call sites of `--primary-color`

> Selectors below are stable anchors; line numbers drift with every
> refactor so they are intentionally **not** listed here. Use
> `grep -n '<selector>' blue-topaz.css` to locate them when needed.

In the light theme, the main content and editor call sites using `var(--primary-color)`
(= `#2f93e4`) are below. This list is not exhaustive; the variable also drives
the sidebar, buttons, and other UI:

- `a { color }` (via `--link-color: var(--primary-color)` since 2026-07)
- `.cm-s-typora-default .cm-link { color }` (the dark `#95B94B` override
  was removed and now follows the light `var()`)
- `#write .md-search-select { outline }` (current search hit)

No longer on this list since the 2026-07 alignment pass: `blockquote`'s bar
moved to `--interactive-accent`. `sup.md-footnote` went plain ink in that
pass, then returned to the accent (via `--link-color`) in 2026-08: the
"plain ink" reading had measured the sup wrapper, while the reference's
color sits on the `<a>` inside — the ref renders as an accent `[1]` in both
modes (light `#2f93e4`, dark `rgb(45, 130, 205)`, live-measured).

In the dark file these selectors are inherited from light through `@import`;
dark only overrides the value of `--primary-color` in its own `:root` (to
`rgb(45, 130, 205)` — corrected from 204 in 2026-07, the exact rounding of
hsl(208,64%,49%)), so every call site picks up the dark blue automatically.

`--active-file-bg-color` is defined as `var(--file-active-bg)` in both
schemes: Typora base's `.file-tree-node.active` rule paints the active card
itself through this variable (it outranks the theme by load order), so the
variable is the real control surface. `--active-file-border-color` is
`transparent` (light only, no dark override needed): it suppresses base's
4px active accent bar, a Typora idiom absent from the reference file
explorer, where the card alone marks the active file.

Not replaced (kept as literals, by design):

- `:root` variable definition sites in both files
- Alpha variants written as `hsla(...)` (these are stable derivations of
  the primary HSL; promoting them to `--primary-color-NN` is a separate
  exercise)
- mermaid stroke (`.md-diagram-panel .node` block); dark theme does not override stroke
- `@media print` surface literals (see "Print / export path" below); both
  print blocks hard-code their surfaces instead of reading `var(--primary-color)`

## Print / export path (light prints light, dark prints dark)

Each theme prints in its own palette: the light theme exports light, and the
dark theme exports **true dark** (dark surfaces, light ink) rather than being
force-converted to white paper. Typora injects
`@media print { .typora-export * { print-color-adjust: exact } }`, so opaque
backgrounds print, and the page paints from the theme's own
`.typora-export { background: var(--bg-color) }` (plus `body` / `content` /
`#write`), which resolves to the dark `--bg-color` in dark export.

### How the dark print block stays minimal

`blue-topaz-dark.css` opens its print block with the comment
`Print / Export (Dark, keep the dark palette)`. Because the dark file
`@import`s the light one, the light `@media print` block (blue-topaz.css
section 28) is already active in dark export. The dark print block therefore
only **re-asserts the surfaces the light print block forces light** (code,
inline code, quote, and mark) back to opaque dark, plus an opaque dark table
zebra (not an override: the light print sets no table colors, so this just
solidifies the translucent dark screen fills). Everything else (page-breaks,
blockquote border, rainbow `h1~h6` via `var(--hN-color)`, links, code tokens,
alert text) carries through. Per "dark overrides only the diff", it does not
repeat the page-break or border rules.

| Selector (dark print) | Value | Purpose |
|---|---|---|
| `pre, .md-fences { background }` | `#181818` | Dark code surface, = the screen fence pre-blend (overrides light `#f6f8fa`) |
| `#write code { background / color }` | `#3e3e3e` / `#d58000` | Inline-code chip (bg pre-blended on `#202020`, text = the measured screen orange) |
| `blockquote { background / color }` | `#2b2b2b` / `--text-color` | Dark quote fill + light ink |
| `#write th / tbody tr / odd` | `#25303f` / `#202020` / `#1a1a1a` | Opaque dark table zebra |
| `mark { background }` | `#58562e` | Dark olive highlight (overrides the light print peach) |

### Typora export gotchas (verified by real PDF export)

- **`transparent` in a gradient stop prints as solid black.** This is why GFM
  alerts replace the old `transparent` body stop with `--alert-body-bg`. A plain
  `background-color` with an rgba/hsla tint, by contrast, keeps its alpha in
  export (a light table header at `hsla(207, 77%, 54%, 0.1)` prints as a faint
  tint, not a saturated band), so opacity is only mandatory where a gradient or
  the `transparent` keyword is involved.
- **`background-clip:text` gradients survive export**, so the bold-italic
  gradient prints as a gradient in both schemes; no solid-color fallback is
  needed (the old `#1048ff` / `#099d4e` print fallbacks were removed).
- **The mermaid container in export DOM is `.md-diagram-panel`** (no `-preview`
  suffix), which is why the diagram rules target `.md-diagram-panel`.

### Font embedding in export (HTML vs PDF, verified 2026-06)

The bundled faces (`blue-topaz/font.css`: Inter ×4, JetBrains Mono ×2) behave
differently across the two export paths:

- **PDF embeds them.** `pdffonts` on a real export shows all six faces
  subset-embedded (`emb: yes`) in both schemes: PDF renders through Typora's
  internal Chromium where `@import "font.css"` resolves, so the faces load and
  are subset into the file. No action needed.
- **HTML drops them.** Typora strips theme `@font-face` from exported HTML: it
  blanks `@import` to `@import "";`, removes a `@font-face` written directly in
  the main CSS (base64 *or* url), and leaves `@include-when-export` as a literal,
  browser-ignored at-rule. This guards against the old `file://` path leak
  (typora-issues #1980). The only surviving `@font-face` is MathJax's, injected
  into the document DOM at render time, a channel a theme CSS cannot use.

Net: **HTML export cannot self-contain the bundled fonts.** Without Inter /
JetBrains Mono installed, exported HTML falls back to system fonts (document
structure and colors unaffected). Platform limitation, not theme-fixable:
documented as a README Troubleshooting note, with PDF as the reliable-sharing
path. base64-inlining (~840 KB) was tested and rejected as ineffective.

### Modification rule

The two print blocks are no longer a shared "force-readable" white-paper
palette: light prints light, dark prints dark. When changing one, check the
other still makes sense, but do not re-introduce a dark-to-light conversion.

## Mermaid variables (consumed by the Typora engine)

The `--mermaid-*` variables are **read by the Typora engine through
`getComputedStyle()`** and forwarded to mermaid.js's `themeVariables`
config. **They are not consumed through CSS `var()`.**

### Current definitions

| Variable | light | dark | Purpose |
|---|---|---|---|
| `--mermaid-theme` | `default` | `dark` | Mermaid theme preset |
| `--mermaid-font-family` | `inherit` | `inherit` | Mermaid font family |

### Maintenance notes

- **No grep hit at the consumer site is expected**: the CSS layer has no
  `var(--mermaid-...)` reference because Typora consumes the values in
  the JS layer. Do not delete these as dead code.
- **Verification is visual only**: open `test/test-document.md` in Typora
  and inspect the mermaid block (search for the mermaid code fence) for
  actual rendered color.

## Focus-mode muting variables (`--focus-muted-*`)

**Foreground uses opacity-only dimming, with color preserved.** Focus mode
applies a single `opacity: 0.4` to non-focused `.md-end-block`s; every color cue (task
checkmarks, math, code tokens, links, GFM Alert hues, bold-italic
gradients, heading colors) reads through, just dimmer.

This means **prose foreground colors are never overridden in focus mode**;
the old `--focus-muted-color` variable was removed accordingly. The two
`--focus-muted-decoration-*` vars below only cover the cases where
opacity alone is insufficient.

### Variable definitions

| Variable | light | dark | Purpose |
|---|---|---|---|
| `--focus-muted-decoration-bg` | `transparent` | `transparent` | Reset target for mark / GFM Alerts decorative backgrounds. |
| `--focus-muted-decoration-border` | `#e5e5e5` | `#2a2a2a` | Reset target for blockquote left border and footnote top border. |

### Why these decorations need explicit resets

Opacity layering does not neutralize **decorative backgrounds and borders**:
the `mark` yellow, GFM Alert tint, blockquote left bar, and footnote
separator stay visually loud even at 0.4 parent opacity
because they sit on a transparent surface and their alpha multiplies
with the parent. Resetting them to `transparent` / a near-background gray
erases the visual claim.

Mermaid diagrams take a separate path (`filter: grayscale(1)`): a diagram
has many generated SVG fills/strokes, so recoloring each one is brittle.

### Selector pattern (verified against real Typora DOM)

- **`<blockquote>` / `.md-alert` / `.md-task-list-item` themselves carry
  no `.md-end-block` class**; their child `<p>` does, and focus lives on
  the block element, not the container. Use `:not(:has(.md-focus))` to
  skip "containers that hold the focused block".
- **Table rows** (`tr`) are themselves `.md-end-block` elements, so the
  boundary selector is not usable. Hover/stripe backgrounds must be
  neutralized to `transparent` explicitly.
- **TOC inline + dropdown hover** is neutralized because the hover
  effect (the row wash since 2026-08; the 0.8 hover opacity in the
  dropdown) stacks with the focus-mode 0.4 and produces visual jitter.

### Related CSS locations

Focus-mode logic lives in `blue-topaz.css` under the section comment
`/* ========== 22. Focus mode ========== */`. `blue-topaz-dark.css` only
overrides variable values (including `--h1-color..--h6-color`); every
selector, the `.on-focus-mode h1..h6` color rules included, is inherited
through `@import`.

### Export and print never carry focus mode

Focus mode is a live editor state: `enterFocusMode` adds `on-focus-mode` to
`document.body`. The styled export/print paths, by contrast, **rebuild a fresh
export document** whose `<body class='...'>` is a fixed allow-list
(`typora-export`, plus `typora-print` for PDF/print and the outline classes);
they never copy the editor body's classes. (A style-less export emits a
class-less `<body>` and is moot here — it loads no theme CSS.) Verified against
Typora's renderer
(`appsrc/main.js`): the export body is `["typora-export"].join(...)`, and the
three paths — export HTML, export PDF (`export.printToPDF` on a temp export
HTML), and Cmd+P (`export.genPrintView`, also export HTML) — all funnel
through it.

So the export/print DOM **never carries `on-focus-mode`**, and any
`.on-focus-mode …` selector is unmatchable there. The two `@media print`
blocks used to each carry a focus-mode "un-mute" reset (restoring opacity,
mermaid color, and the mark / alert / blockquote / TOC fills); those were
dead code — the trigger never fires — and were removed. The section-22 source
rules stay: they serve the on-screen focus view only.

## Typography fidelity

Heading sizes and body line-height are copied from the Obsidian original
(verified against its `theme.css`):

- `h1..h6` = `1.5625 / 1.4375 / 1.3125 / 1.1875 / 1.0625 / 1` rem (mostly a
  -0.125rem/step descent, with the final h5->h6 step being -0.0625rem),
  matching upstream `--h1-size`..`--h6-size`. This is the upstream design;
  do not "modernize" it to a
  geometric / modular scale.
- Body `line-height: 1.5` matches upstream `--line-height-main: 1.5`.

## Contrast / accessibility notes

A 2026-06 accessibility pass deepened the high-frequency colored text so it
clears WCAG AA (4.5:1 for normal text, 3:1 for large text / headings), while
preserving each hue and saturation (only lightness shifted). The 2026-07
fidelity pass then reverted two of those adjustments back to the reference's
measured values (inline code, alert labels) — fidelity was chosen over AA
there, and their rows below carry the real post-reversion ratios. Everything
else is the post-pass state, measured against the real backgrounds.

| Element | Value (light / dark) | Contrast | Status |
|---|---|---|---|
| Body links | `--link-color` = accent `#2f93e4` / `rgb(45,130,205)` | 3.27 / 4.02 | Below AA (2026-07: reverted to the reference's accent links, fidelity over AA) |
| Inline code | `#e95d00` / `#d58000` on the chip | 2.92 / 3.52 | Below AA (2026-07: the reference's measured oranges, fidelity over AA) |
| Italic / em | `#088743` (light) | 4.61 | AA (dark `#a4ca8e` already ~8.9) |
| h5 / h6 (light) | `hsl(209,70%,58%)` / `hsl(209,65%,58%)` | 3.12 / 3.13 | AA large-text (3:1) |
| Muted UI text | `--control-text-color` `#747474` / `#8a8a8a` | 4.56 / 4.72 | AA |
| Meta text | `--meta-content-color` `#577a87` (light) | 4.61 | AA |
| List markers / done tasks | `#7f7f7f` light; dark `#797979` markers, `#8a8a8a` done text | 4.0 / 3.74 / 4.72 | Measured reference grays (2026-07), decorative / secondary at 3:1+. Since 2026-07-26 the ul dot is a drawn `li::before` bullet glyph (the reference blanks the native marker and draws its own 14.2px left of the text); ol keeps the native decimal marker. List geometry: ul/ol padding 0, li `margin-inline-start: 30.19px` + `padding: 1.2px 0`, all measured |
| Code tokens (light) | reference edit-mode palette on `#f4f4f4` | varies | Fidelity over AA since 2026-08-09; `#ffcb6b` (meta/builtin) is the reference's own light value, user-approved (see Code Highlighting: Light) |
| GFM alert titles | neutral `--text-color` on the tint strips | 15.6+ / 6.7+ | AAA (2026-07: per-tint label colors dropped for the reference's neutral titles) |

`--primary-color` (`#2f93e4` / `rgb(45,130,205)`) drives UI accents (buttons,
borders, icons, focus ring) and, since the 2026-07 fidelity pass, body links
too (`--link-color` aliases it).

Intentionally left below AA (documented, by design, not bugs):
- `#eb7c46` active-file icon hover (~2.5:1 light): a decorative icon hover, not
  body text; kept for Obsidian brand identity.
- Focus mode: non-focused blocks fade to `opacity: 0.4` on purpose.
- Source-mode (`.cm-s-typora-default`) editing tokens: an editing-surface
  palette, not rendered output.

Readers who want still higher contrast can override `--link-color`, `--h5-color`,
`--h6-color`, `--control-text-color`, or the inline-code / em literals in a
personal copy.
