# Obsidian → Typora Color Mapping

## Light Mode

| Obsidian Variable | Value | Typora Variable |
|---|---|---|
| `--background-primary` | `#ffffff` | `--bg-color` |
| `--background-secondary` | `#fcfcfc` | `--side-bar-bg-color` |
| `--text-normal` | `#0e0e0e` | `--text-color` |
| `--color-accent` | `hsl(207, 77%, 54%)` | `--primary-color` |
| `--text-folder-file` | `#272727` | `--file-text-color` |
| `--accent-em` | `#099d4e` | em color |
| `--accent-strong` | `#000000` | strong color |
| `--text-color-code` | `#e95d00` | code color |
| `--background-code` | `#e6e6e671` | code block bg (Typora `.md-fences` adapts to `#f5f5f5`) |
| `--background-code-2` | `#cccccc62` | inline code background |
| `--background-blockquote` | `#d5d5d52c` | blockquote bg |
| `--text-selection` | `#a9d1c859` | `--select-text-bg-color` |
| `--h1-color` | `hsl(216, 88%, 26%)` | h1 color (darkest blue) |
| `--h2-color` | `hsl(212, 100%, 33%)` | h2 color |
| `--h3-color` | `hsl(210, 86%, 39%)` | h3 color |
| `--h4-color` | `hsl(208, 58%, 49%)` | h4 color |
| `--h5-color` | `hsl(209, 70%, 62%)` | h5 color |
| `--h6-color` | `hsl(209, 65%, 72%)` | h6 color (lightest blue) |

The `--h1-color` .. `--h6-color` tokens are a single source of truth: base
headings, focus mode, and the light print path all read them through `var()`
rather than repeating the literals. Dark overrides the six values to its
rainbow palette in its own `:root`; only the dark print path keeps the light
blue literals, since it cannot use the rainbow `var()` (see the print-path
section).

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
| `--control-text-color` | `#7f7f7f` | File-list-view meta info (parent-loc / summary / time text color) |

## Dark Mode

| Obsidian Variable | Value | Typora Variable |
|---|---|---|
| `--background-primary` | `#202020` | `--bg-color` |
| `--background-secondary` | `#151515` | `--side-bar-bg-color` |
| `--text-normal` | `#c6c6c6` | `--text-color` |
| `--text-folder-file` | `#b3b3b3` | `--file-text-color` |
| `--accent-em` | `#a4ca8e` | em color |
| `--accent-strong` | `#e7e7e7` | strong color |
| `--text-color-code` | `#d58000` | code color |
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

## Code Highlighting: Light (.cm-s-inner)

Based on CodeMirror's classic default palette (not GitHub Light), with two
tweaked tokens (operator `#981a1a`, error `#e93147`). The Obsidian original
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
| `.cm-variable-3` | `#085` | type reference |
| `.cm-string` | `#a11` | string |
| `.cm-string-2` | `#f50` | template string |
| `.cm-property` | `#000` | property access |
| `.cm-operator` | `#981a1a` | operator |
| `.cm-comment` | `#a50` | comment |
| `.cm-meta` | `#555` | metadata |
| `.cm-qualifier` | `#555` | CSS qualifier |
| `.cm-builtin` | `#30a` | built-in |
| `.cm-bracket` | `#997` | bracket |
| `.cm-tag` | `#170` | HTML/XML tag |
| `.cm-attribute` | `#00c` | attribute name |
| `.cm-header` | `#00f` | heading |
| `.cm-quote` | `#090` | quote |
| `.cm-hr` | `#999` | horizontal rule |
| `.cm-link` | `#00c` | link |
| `.cm-negative` | `#d44` | negative number |
| `.cm-positive` | `#292` | positive number |
| `.cm-type` | `#085` | type annotation |
| `.cm-error` | `#e93147` | error |

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
| `.cm-variable-3` | `#ff7b72` red | type reference |
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

The five GFM Alert backgrounds (translucent fills) were promoted from
literals to `:root` variables, giving light and dark a single source of
truth.

### Light

| Variable | Value | Usage |
|---|---|---|
| `--alert-note-bg` | `rgba(9, 105, 218, 0.10)` | Note alert background + left bar |
| `--alert-important-bg` | `rgba(130, 80, 223, 0.10)` | Important alert background + left bar |
| `--alert-warning-bg` | `rgba(154, 103, 0, 0.10)` | Warning alert background + left bar |
| `--alert-tip-bg` | `rgba(31, 136, 61, 0.10)` | Tip alert background + left bar |
| `--alert-caution-bg` | `rgba(207, 34, 46, 0.10)` | Caution alert background + left bar |

### Dark

| Variable | Value | Note |
|---|---|---|
| `--alert-note-bg` | `rgba(58, 150, 255, 0.14)` | RGB brightened, alpha lifted |
| `--alert-important-bg` | `rgba(163, 130, 240, 0.14)` | Same treatment |
| `--alert-warning-bg` | `rgba(210, 167, 60, 0.14)` | Same treatment |
| `--alert-tip-bg` | `rgba(63, 185, 95, 0.12)` | RGB brightened, alpha lifted only slightly to 0.12 |
| `--alert-caution-bg` | `rgba(248, 81, 73, 0.14)` | Same treatment |

`.md-alert-text-*` foreground colors stay as literals (dark uses different
RGB) and are intentionally not promoted to variables.

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
- mermaid stroke (`.md-diagram-panel-preview .node` block); dark theme does not override stroke
- `@media print` rules that deliberately decouple from the runtime theme
  (see "Print-path exception" below)

## Print-path exception (force-readable design)

The `@media print` blocks in both light and dark themes deliberately use
**light-style blue / orange / green literals**, decoupled from the
runtime theme. This is intentional, and these literals **must not be
replaced with `var(--primary-color)` or other dark-semantic variables**.

### Design rationale

Print output is a traditional white-paper + black-ink visual environment:

- Dark theme on-screen colors (deep blue, dim gray) lose contrast on
  white paper.
- Forcing the light theme palette (bright-blue link, orange highlight,
  green italic) keeps ink-printed output legible.
- The dark print block opens with a `Print (Dark, force readable)`
  comment that records this intent.

### Literals retained in the dark print path

All inside the `@media print` block at the bottom of
`blue-topaz-dark.css` (search for `Print (Dark, force readable)`):

| Selector | Literal | Purpose |
|---|---|---|
| `blockquote { border-left }` | `#2f93e4` | Light theme blue |
| `a { color }` | `hsl(207, 77%, 54%)` | Same blue, expressed in hsl |
| `mark { background }` | `hsla(34, 100%, 80%, 0.85)` | mark highlight orange |
| `#write em, #write i { color }` | `#099d4e` | em italic green |

### Light print path shares the palette

The light `@media print` block (also at the bottom of `blue-topaz.css`)
uses the same `#2f93e4` and light-style literals, so both print paths
share the paper-output palette. The dark block additionally resets
dark-only screen surfaces (table fills, code tokens, alert text) back to
ink on white.

### Modification rule

Future changes to the print palette **must touch both the light and dark
print blocks together** to keep the force-readable design consistent. Do
not migrate the dark print block to dark variables in isolation.

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

Blue Topaz inherits a bright, saturated palette from the Obsidian original.
Many foreground colors sit below the WCAG AA bar (4.5:1 for normal text,
3:1 for large text) by design. This is faithful to upstream, not an
oversight. The table below is representative, not exhaustive:

| Element | Value | ~Contrast | Note |
|---|---|---|---|
| Links (light) | `--primary-color` `#2f93e4` | 3.3:1 | Brand blue; prose links also underline |
| Links (dark) | `--primary-color` | ~4.0:1 base, ~3.0:1 hover | `a:hover` dims via opacity |
| h5 / h6 (light) | `--h5-color` / `--h6-color` | 2.8:1 / 2.1:1 | Lowest cascade levels, faded by design |
| Inline code | `#e95d00` (light) / `#d58000` (dark) | 2.9:1 / 3.5:1 | Brand orange (upstream `--text-color-code`) |
| Italic / em (light) | `#099d4e` | 3.5:1 | Brand green (upstream `--accent-em`) |

The same holds for other inherited, non-body surfaces: rendered code-block
tokens and source-mode (`.cm-s-typora-default`) tokens (the CodeMirror
default and One-Light-style palettes), de-emphasized UI text (sidebar meta
`--control-text-color`, dimmed file extensions), footnote references, and
GFM alert titles all sit near or below AA in one or both schemes. Focus
mode is intentionally low-contrast: it fades non-focused blocks to
`opacity: 0.4`.

All of these are upstream design choices kept for fidelity. Body text
(`--text-color`) clears AA in both schemes, and large headings (h1-h4)
clear the 3:1 large-text bar. Readers who need higher contrast can override
the relevant variables (`--primary-color`, `--h5-color`, `--h6-color`,
`--control-text-color`) or the inline-code / em literals in a personal copy.
