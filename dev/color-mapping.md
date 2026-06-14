# Obsidian → Typora Color Mapping

## Light Mode

| Obsidian Variable | Value | Typora Variable |
|---|---|---|
| `--background-primary` | `#ffffff` | `--bg-color` |
| `--background-secondary` | `#fcfcfc` | `--side-bar-bg-color` |
| `--text-normal` | `#0e0e0e` | `--text-color` |
| `--color-accent` | `hsl(207, 77%, 54%)` | `--primary-color` |
| (link text) | `#1a79c6` | `--link-color` (body/UI link color, deepened from `--primary-color` for AA; `--primary-color` stays for buttons/borders/icons) |
| `--text-folder-file` | `#272727` | `--file-text-color` |
| `--accent-em` | `#088743` | em color (deepened from upstream `#099d4e` for WCAG AA) |
| `--accent-strong` | `#000000` | strong color |
| `--text-color-code` | `#b34800` | code color (deepened from upstream `#e95d00` for AA) |
| `--background-code` | `#e6e6e671` | code block bg (Typora `.md-fences` adapts to `#f5f5f5`) |
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
| `--primary-color-01` | `hsla(207, 77%, 54%, 0.1)` | File hover / active file background / search-active background (hover and active share one color, matching upstream Obsidian) |
| `--primary-color-02` | `hsla(207, 77%, 54%, 0.2)` | Search-result highlight (`.ty-file-search-match-text`) |
| `--folder-hover-bg` | `rgba(0, 0, 0, 0.08)` | Neutral-gray folder hover (aligned with Obsidian `--nav-item-background-active`) |
| `--file-text-color` | `#272727` | Default file-node text color (folders override to `--text-color` for stronger contrast) |
| `--active-file-text-color` | `#0e0e0e` | Retained for Typora base compatibility; the theme's own file-list active rules override the active text color |
| Hard-coded `#eb7c46` | `#eb7c46` | Active-file icon hover color (Obsidian's signature orange-red), shared between light and dark. A decorative hover accent, not body text; ~2.5:1 on the light background, kept for brand identity |
| `--control-text-color` | `#747474` | File-list-view meta info (parent-loc / summary / time text color); deepened from `#7f7f7f` for AA |

## Dark Mode

| Obsidian Variable | Value | Typora Variable |
|---|---|---|
| `--background-primary` | `#202020` | `--bg-color` |
| `--background-secondary` | `#151515` | `--side-bar-bg-color` |
| `--text-normal` | `#c6c6c6` | `--text-color` |
| `--text-folder-file` | `#b3b3b3` | `--file-text-color` |
| `--accent-em` | `#a4ca8e` | em color |
| `--accent-strong` | `#e7e7e7` | strong color |
| `--text-color-code` | `#f49200` | code color (lightened from upstream `#d58000` for AA) |
| `--background-code` | `#1111118c` | code block bg (Typora `.md-fences` adapts to `#1a1a1a`) |
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
| `--primary-color-01` | `hsla(208, 72%, 58%, 0.14)` | File hover / active file background / search-active background (hover and active share one color) |
| `--primary-color-02` | `hsla(208, 72%, 58%, 0.26)` | Search-result highlight |
| `--folder-hover-bg` | `rgba(255, 255, 255, 0.08)` | Neutral-gray folder hover (raised from 0.05 to 0.08 for visibility) |
| `--file-text-color` | `#b3b3b3` | Default file-node text color (folders override to `--text-color`) |
| `--active-file-text-color` | `#e4e4e4` | Retained for Typora base compatibility; the theme's own file-list active rules override it |
| Hard-coded `#eb7c46` | `#eb7c46` | Active-file icon hover color, shared with light; clears WCAG AA (>4.5:1) on the dark background |
| `--control-text-color` | `#8a8a8a` | File-list-view meta info (parent-loc / summary / time text color) |
| `--dark-border-color` | `#343434` | Generic 1px border tone for the dark scheme: window, code tooltip, sidebar, search, modals, table edit UI, etc. (the table body's cell dividers use a darker `#1a1a1a`) |
| `--dark-panel-bg` | `#2b2b2b` | Raised-panel fill: tooltip, search input, quick-open, auto-suggest, modal, context/dropdown menu, notification, footer word-count |
| `--dark-surface-2` | `#1a1a1a` | Recessed dark surface: code block, line-number gutter, TOC content, meta block, quick-open input, table cell dividers |

## Code Highlighting: Light (.cm-s-inner)

Based on CodeMirror's classic default palette (not GitHub Light). A 2026-06 AA
pass deepened several tokens (string-2, bracket, quote, positive, negative,
error, variable-3, type, hr) on the `#f5f5f5` code background, keeping each hue
and only lowering lightness; operator keeps its tweaked `#981a1a`. The line
number gutter (`.CodeMirror-linenumber`) was likewise deepened to `#707070`. The Obsidian original
ships a multi-scheme code palette through Style Settings (bt-default, Dracula,
Gruvbox, Monokai, and more); Typora has no equivalent scheme selector, so this
port keeps the editor's single default palette rather than replicating one of
those schemes.

| Token | Color | Note |
|---|---|---|
| `.cm-keyword` | `#708` | keyword |
| `.cm-atom` | `#219` | special constants |
| `.cm-number` | `#164` | number |
| `.cm-def` | `#00f` | definition |
| `.cm-variable` | `#000` | variable |
| `.cm-variable-2` | `#05a` | block-level variable |
| `.cm-variable-3` | `#008050` | type reference |
| `.cm-string` | `#a11` | string |
| `.cm-string-2` | `#c74200` | template string |
| `.cm-property` | `#000` | property access |
| `.cm-operator` | `#981a1a` | operator |
| `.cm-comment` | `#a50` | comment |
| `.cm-meta` | `#555` | metadata |
| `.cm-qualifier` | `#555` | CSS qualifier |
| `.cm-builtin` | `#30a` | built-in |
| `.cm-bracket` | `#717155` | bracket |
| `.cm-tag` | `#170` | HTML/XML tag |
| `.cm-attribute` | `#00c` | attribute name |
| `.cm-header` | `#00f` | heading |
| `.cm-quote` | `#008200` | quote |
| `.cm-hr` | `#707070` | horizontal rule |
| `.cm-link` | `#00c` | link |
| `.cm-negative` | `#d62727` | negative number |
| `.cm-positive` | `#1c801c` | positive number |
| `.cm-type` | `#008050` | type annotation |
| `.cm-error` | `#dc182f` | error |

## Code Highlighting: Dark (.cm-s-inner)

GitHub Dark-based palette, with a couple of brighter carryover accents
(such as `#50fa7b` and `#ffb86c`) that are not part of GitHub Dark Default.

| Token | Color | Note |
|---|---|---|
| `.cm-keyword` | `#ff7b72` red | keyword |
| `.cm-atom` | `#8b949e` gray | special constants |
| `.cm-number` | `#79c0ff` blue | number |
| `.cm-def` | `var(--text-color)` | definition |
| `.cm-variable` | `var(--text-color)` | variable |
| `.cm-variable-2` | `var(--text-color)` | block-level variable |
| `.cm-variable-3` | `#ffb86c` orange | type reference (now grouped with `.cm-type`, was keyword-red) |
| `.cm-string` | `#a5d6ff` light blue | string |
| `.cm-string-2` | `#a5d6ff` light blue | template string |
| `.cm-property` | `#d2a8ff` purple | property access |
| `.cm-operator` | `#ff7b72` red | operator |
| `.cm-comment` | `#8b949e` gray | comment |
| `.cm-meta` | `#8b949e` gray | metadata |
| `.cm-qualifier` | `#50fa7b` green | CSS qualifier |
| `.cm-builtin` | `#79c0ff` blue | built-in |
| `.cm-bracket` | `#8b949e` gray | bracket |
| `.cm-tag` | `#7ee787` green | HTML/XML tag |
| `.cm-attribute` | `#79c0ff` blue | attribute name |
| `.cm-header` | `#79c0ff` blue | heading |
| `.cm-quote` | `#a5d6ff` light blue | quote |
| `.cm-hr` | `#8b949e` gray | horizontal rule |
| `.cm-link` | `#a5d6ff` light blue | link |
| `.cm-negative` | `#ffa198` light red | negative number |
| `.cm-positive` | `#7ee787` green | positive number |
| `.cm-type` | `#ffb86c` orange | type annotation |
| `.cm-error` | `#ffa198` light red | error |

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
`linear-gradient(tint 2.1em, var(--alert-body-bg) 2.1em)`: a tinted title
band over a body that matches the page. They must stay opaque: Typora's PDF
export renders a `transparent` gradient stop as solid black, so
`--alert-body-bg` replaces the old `transparent` body stop and the alert body
prints clean. (See the Print / export path section for the alpha rule.)

### Light (pre-blended on `#ffffff`)

| Variable | Value | Usage |
|---|---|---|
| `--alert-note-bg` | `#e6f0fb` | Note alert title band + left bar |
| `--alert-important-bg` | `#f3eefc` | Important alert title band + left bar |
| `--alert-warning-bg` | `#f5f0e6` | Warning alert title band + left bar |
| `--alert-tip-bg` | `#e9f3ec` | Tip alert title band + left bar |
| `--alert-caution-bg` | `#fae9ea` | Caution alert title band + left bar |
| `--alert-body-bg` | `#ffffff` | Alert body fill below the title band (was `transparent`) |

### Dark (pre-blended on `#202020`)

| Variable | Value | Note |
|---|---|---|
| `--alert-note-bg` | `#24313f` | was `rgba(58, 150, 255, 0.14)` |
| `--alert-important-bg` | `#322e3d` | was `rgba(163, 130, 240, 0.14)` |
| `--alert-warning-bg` | `#393324` | was `rgba(210, 167, 60, 0.14)` |
| `--alert-tip-bg` | `#243228` | was `rgba(63, 185, 95, 0.12)` |
| `--alert-caution-bg` | `#3e2726` | was `rgba(248, 81, 73, 0.14)` |
| `--alert-body-bg` | `#202020` | Alert body fill below the title band (was `transparent`) |

Each type now only maps `--alert-bg` to its tint; shared `.md-alert` and
`.md-alert::before` rules draw the gradient body and the left bar from it, so
the gradient lives in one place instead of being repeated per color. The
`.md-alert-text-*` label colors stay literals; the 2026-06 AA pass deepened the
light important / warning / tip labels and lightened the dark note / important /
caution labels so every label clears 4.5:1 on its tint (light note + caution and
dark warning + tip already passed and were left unchanged).

## Call sites of `--primary-color`

> Selectors below are stable anchors; line numbers drift with every
> refactor so they are intentionally **not** listed here. Use
> `grep -n '<selector>' blue-topaz.css` to locate them when needed.

In the light theme, the main content and editor call sites using `var(--primary-color)`
(= `#2f93e4`) are below. This list is not exhaustive; the variable also drives
the sidebar, buttons, and other UI:

- `a { color }`
- `blockquote { border-left }`
- `.md-toc-inner { color }`
- `.cm-s-typora-default .cm-link { color }` (the dark `#95B94B` override
  was removed and now follows the light `var()`)
- `sup.md-footnote { color }`

In the dark file these selectors are inherited from light through `@import`;
dark only overrides the value of `--primary-color` in its own `:root` (to
`rgb(45, 130, 204)`), so every call site picks up the dark blue
automatically. The only spot dark still writes `var(--primary-color)`
directly is `--active-file-border-color` in `:root`.

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
| `pre, .md-fences { background }` | `#1a1a1a` | Dark code surface (overrides light `#f6f8fa`) |
| `#write code { background / color }` | `#3e3e3e` / `#f49200` | Inline-code chip (gray + amber), pre-blended on `#202020` |
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
| `--focus-muted-decoration-bg` | `transparent` | `transparent` | Reset target for mark / GFM Alerts decorative backgrounds and TOC inline card. |
| `--focus-muted-decoration-border` | `#e5e5e5` | `#2a2a2a` | Reset target for blockquote left border and footnote top border. |

### Why these decorations need explicit resets

Opacity layering does not neutralize **decorative backgrounds and borders**:
the `mark` yellow, GFM Alert tint, blockquote left bar, TOC card fill,
and footnote separator stay visually loud even at 0.4 parent opacity
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
- **TOC inline + dropdown hover** is neutralized because Typora's
  built-in hover opacity (0.8) stacks with the focus-mode 0.4 and
  produces visual jitter.

### Related CSS locations

Focus-mode logic lives in `blue-topaz.css` under the section comment
`/* ========== 22. Focus mode ========== */`. `blue-topaz-dark.css` only
overrides variable values (including `--h1-color..--h6-color`); every
selector, the `.on-focus-mode h1..h6` color rules included, is inherited
through `@import`.

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
preserving each hue and saturation (only lightness shifted). The values below
are the post-pass state, measured against the real backgrounds.

| Element | Value (light / dark) | Contrast | Status |
|---|---|---|---|
| Body links | `--link-color` `#1a79c6` / `#3a8cd4` | 4.57 / 4.56 | AA (decoupled from `--primary-color`) |
| Inline code | `#b34800` / `#f49200` on the chip | 4.58 / 4.56 | AA |
| Italic / em | `#088743` (light) | 4.61 | AA (dark `#a4ca8e` already ~8.9) |
| h5 / h6 (light) | `hsl(209,70%,58%)` / `hsl(209,65%,58%)` | 3.12 / 3.13 | AA large-text (3:1) |
| Muted UI text | `--control-text-color` `#747474` / `#8a8a8a` | 4.56 / 4.72 | AA |
| Meta text | `--meta-content-color` `#577a87` (light) | 4.61 | AA |
| List markers / done tasks | `#939393` (light) | 3.07 | 3:1 (decorative / secondary) |
| Code tokens (light) | deepened set on `#f5f5f5` | >= 4.5 | AA (see Code Highlighting: Light) |
| GFM alert labels | tuned per tint, both schemes | >= 4.5 | AA |

`--primary-color` (`#2f93e4` / `rgb(45,130,204)`) is kept for UI accents
(buttons, borders, icons, focus ring), which are components or large text where
3:1 is sufficient; only body and link text use the deepened `--link-color`.

Intentionally left below AA (documented, by design, not bugs):

- `#eb7c46` active-file icon hover (~2.5:1 light): a decorative icon hover, not
  body text; kept for Obsidian brand identity.
- Focus mode: non-focused blocks fade to `opacity: 0.4` on purpose.
- Source-mode (`.cm-s-typora-default`) editing tokens: an editing-surface
  palette, not rendered output.

Readers who want still higher contrast can override `--link-color`, `--h5-color`,
`--h6-color`, `--control-text-color`, or the inline-code / em literals in a
personal copy.
