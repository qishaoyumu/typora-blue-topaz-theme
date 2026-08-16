# Plan: fence-language combobox + background alignment (release/1.2.0)

Date: 2026-08-16. Branch: `release/1.2.0` (worktree `.claude/worktrees/release-1.2.0`), base `b5e86ee`.
All design decisions below were settled in the 2026-08-16 grilling session (Q1–Q23); this file only fixes execution detail. Do not re-decide.

## Approved design summary

- **Building**: (A) five reference-measured background/hover corrections plus a translucent hover token; (B) the fence-language editor (`.md-fences .code-tooltip > .ty-cm-lang-input`) and its auto-suggest list (`#ty-auto-suggest.auto-suggest-container`) become one combobox: left-aligned, width-capped chip that hugs when idle, list seated flush under it with the same width, one blue outline, single-state accent rows, Typora's language icons kept.
- **Not building**: reference chrome with no Typora analogue (black tab strips / ribbon / titlebar), sidebar keyboard-focus row, hover-popover upstream drift (#242424 stays, port pins v2025052001), callout backgrounds (upstream currently broken, ours match intent), matched-substring highlight (Typora renders none), badge (`::before`) width cap (reference flair is unbounded too; only the chip needs a cap because its width feeds the list), placeholder centering hack beyond neutralizing it, any change to badge/two-step entry/last-line occlusion decisions of 2026-08-15 round 4, hiding the list scrollbar (stock hover-only behavior stays), Windows-only megamenu surfaces beyond what the token change carries.
- **Approach**: pure CSS in `blue-topaz.css` (light, full rules) + `blue-topaz-dark.css` (overrides only), tokens first (A) then combobox (B); fusion driven by `:has()` on Typora's own `.ty-show` toggle and compensating margins against `makeVisible`'s one-shot geometry (`top = span.bottom + 6`, `left = span.left`, inline `min-width = span.width`, never repositions, never flips).
- **Key decisions**: translucent 6.7% hover token instead of pre-blends (single layer, correct on every surface); dark panels move to `#202020` (reference `--suggestion/--modal/--prompt-background`) and menus to `--background-secondary` (`#fcfcfc`/`#151515`); list ring drawn with inset box-shadow, not `border`, so Typora's inline `max-height = 5*rowHeight + 12` still fits exactly five gapless 26px rows; rows 12px = chip font, icon column 24px, horizontal inset 4px so all 163 language ids fit in the 134px inner width; chip caps at 9.5em with hidden overflow (idle: ellipsis; editing: clip, caret scrolls).
- **Unknowns**: caret auto-scroll inside `overflow:hidden` contenteditable on WebKit — verify on the first build; fallback `overflow-x:auto` + hidden scrollbar (owner: implementer, step B1 check).

Most fragile assumption: fusion geometry relies on `makeVisible` (Typora 1.14.9 frame.js byte 131331). If a future Typora changes the +6px offset or anchors differently, the list detaches by a few px but stays a styled list; nothing breaks functionally.

Phase independence: A ships alone (tokens/colors). B ships alone visually, but its dark blends assume A's `#202020` panel; land A first (or recompute B's dark literals if A is dropped).

## Values (pre-computed)

| Token / literal | Light | Dark | Source |
|---|---|---|---|
| `--item-hover-bg-color` | `rgba(0, 0, 0, 0.067)` | `rgba(255, 255, 255, 0.067)` | OB `--background-modifier-hover` raw |
| `--toc-hover-bg` | `var(--item-hover-bg-color)` | same | wash = same contrast on any surface (replaces hand-computed #f3f3f3/#383838) |
| `--dark-panel-bg` | — | `#202020` | OB `--suggestion/--modal/--prompt-background` |
| `--menu-bg-color` (new) | `#fcfcfc` | `#151515` | OB `--menu-background` = `--background-secondary` |
| `--suggest-active-bg` (new) | `hsla(207, 77%, 54%, 0.15)` | `hsla(208, 64%, 49%, 0.15)` | BT `.suggestion-item.is-selected` = `--theme-color-translucent-015`; blends to #e0effb / #222f3a |
| `footer.ty-footer` background | `#f3f3f3` | `#000000` | OB `--status-bar-bg` |
| tooltip bubbles (`#ty-tooltip`, `.code-tooltip.md-hover-tip`, `.md-hover-tip div.md-arrow:after`) | `var(--interactive-accent)` (rgb 65,159,231) | unchanged (dark aliases) | OB `.tooltip` uses `--interactive-accent` |
| `::-webkit-scrollbar-thumb:hover`, `:active` | `#ddddddd9` (both) | `#4d4d4d88` (both) | OB `--scrollbar-active-thumb-bg` |
| chip focus / list ring blue | `#6db3ec` (unchanged) | `#296599` (= rgb(45,130,205)×0.7 over #202020; was #2c689c over #2b2b2b) | BT has-focus color-mix 70% |
| chip/list divider hairline | `var(--ui-border-color)` #dddddd | `var(--dark-border-color)` #343434 | OB `--background-modifier-border` |
| `#md-searchpanel input` (dark) | — | `var(--dark-surface-2)` #1a1a1a | keeps the field visible on the #202020 panel (same as quick-open input) |

Geometry constants (chip editing state): span `min-width: 9.5em` = 114px; chip = 114 + 2×10 padding + 2×1 border = 136px, height 26px (18 line + 6 + 2). List: `margin-left:-11px`, `margin-top:-2px`, `min-width:136px !important`, inner width 134 (inset ring 1px each side). Row = 4px vertical padding + 18 line = 26px; container padding `6px 4px`; icon column 24px; longest id `reStructuredText` = 95.3px at 12px Inter → 4+24+95.3+6+4 = 133.3 ≤ 134.

## Phase A — background alignment (3 commits)

### A1 `fix: make the item hover wash translucent so it reads on every surface`
- `blue-topaz.css:72` `--item-hover-bg-color: rgba(0, 0, 0, 0.067);`
- `blue-topaz-dark.css:70` `--item-hover-bg-color: rgba(255, 255, 255, 0.067);`
- `blue-topaz.css:1184-1192` `--toc-hover-bg: var(--item-hover-bg-color);` rewrite the comment (wash is the same translucent token, no contrast rebuild needed); `blue-topaz-dark.css:418` delete the dark `--toc-hover-bg` override (light var resolves).
- Consumer audit (all keep the token, all single-layer): outline row hover/active (2178, 2420), search item (2448), sidebar footer item (2486), quick-open item (2568 → moves to `--suggest-active-bg` in A3), megamenu back/tables/btn (2625, 2752, 2756, 2801), unibody titlebar buttons (2880, 2902, 2907), unibody menu focus (2925), `.btn-default:hover` (3018, dark 584), `.dropdown-menu > li > a:hover` (3034). Confirm none paints the token twice on the same box (grep shows one background per rule).
- `dev/color-mapping.md`: add `--item-hover-bg-color` rows (light/dark) with the OB source; note `--toc-hover-bg` now aliases it.
- Body: state the bug (dark #2a2a2a on #2b2b2b panels was invisible: suggest list, context menu, quick open, .btn-default) and the reference token.

### A2 `feat: align dark panels, menus, and the status bar with the reference`
- `blue-topaz-dark.css:59` `--dark-panel-bg: #202020;` update its comment (reference popover/modal/prompt/suggest fill = page color; shape comes from border + shadow).
- New token both files: `--menu-bg-color` (light `:root` near `--side-bar-bg-color`; dark `:root`). Consumers: `blue-topaz.css:3023` `.context-menu, .dropdown-menu { background: var(--menu-bg-color); }`; `blue-topaz-dark.css:587-591` drop the `background` line (keep border-color/shadow); `blue-topaz-dark.css:550-552` `#recent-file-pane .dropdown-menu` → drop its background line (inherits light rule via var) or set `var(--menu-bg-color)`.
- `blue-topaz-dark.css:516-520` `#md-searchpanel input { background: var(--dark-surface-2); }`.
- `blue-topaz.css:2492` `footer.ty-footer { background: #f3f3f3; }` (comment: OB `--status-bar-bg`); `blue-topaz-dark.css` Footer section: add `footer.ty-footer { background: #000000; }`, fix the comment at 501-503 that says no dark block is needed.
- Remaining `--dark-panel-bg` consumers ride the new value: `.md-fences .code-tooltip` (250), `.md-rawblock-tooltip` (263), `#footer-word-count-info` (504), `#typora-quick-open` (527), `.auto-suggest-container` (538), `.modal-content` (554), `#md-notification` (597), `div.code-tooltip` (604) — no edits.
- `dev/color-mapping.md`: rewrite row 103 (`--dark-panel-bg`), add `--menu-bg-color`, footer, search-input rows.

### A3 `fix: light tooltip accent, quick-open selection tint, scrollbar thumb states`
- `blue-topaz.css:3078, 3088, 3147` `var(--primary-color)` → `var(--interactive-accent)`.
- New token `--suggest-active-bg` both `:root`s; `blue-topaz.css:2568-2571` `.typora-quick-open-item:hover, .active { background: var(--suggest-active-bg); }`.
- `blue-topaz.css:3286-3292` both hover/active → `#ddddddd9`; `blue-topaz-dark.css:718-724` both → `#4d4d4d88`.
- `dev/color-mapping.md`: rows for `--suggest-active-bg`, tooltip source, scrollbar active.

## Phase B — combobox (2 commits)

### B1 `feat: left-align and cap the language chip, hug it when idle`
`blue-topaz.css` chip block (576-700), dark 250-260:
- `.md-fences .code-tooltip .ty-cm-lang-input`: remove `min-width: 3em`; add `text-align: left; max-width: 9.5em; overflow: hidden; white-space: nowrap; text-overflow: ellipsis;` (idle long ids ellipsize). Keep font/colour/transition lines.
- `.md-fences .code-tooltip:focus-within .ty-cm-lang-input`: add `text-overflow: clip;` (caret scrolls; ellipsis + caret is wrong). Existing `min-width: 9.5em; transition: min-width 0s` stays.
- New: `.md-fences .code-tooltip .ty-cm-lang-input:empty { padding-left: 0 !important; }` (beats mac.css `.html-for-mac .ty-cm-lang-input:empty{padding-left:50% !important}` by specificity 0,3,0 vs 0,2,0) and `.md-fences .code-tooltip .ty-cm-lang-input:empty::after { text-align: left; }` (mac.css makes it absolute left:0/right:0; keeps the existing `color:#95a3b5`).
- New hover (Q23): `.md-fences .code-tooltip:hover:not(:focus-within) { background-image: linear-gradient(var(--item-hover-bg-color), var(--item-hover-bg-color)); }` — layers the translucent wash over whichever background-color the mode sets.
- Dark: `.md-fences .code-tooltip:focus-within { border-color: #296599; }` (was #2c689c) with the re-blend comment.
- Rewrite the two long comments (centered/3em rationale → left-aligned/hug/cap rationale; keep the makeVisible + snap facts).
- Check on first build: type 30 chars, caret must stay visible (span scrolls). If not, switch the field rule to `overflow-x: auto` and add `.md-fences .code-tooltip .ty-cm-lang-input::-webkit-scrollbar { display: none; }`.

### B2 `feat: fuse the language chip and its suggest list into one combobox`
`blue-topaz.css` section 25 (2573) replaces the 5-line `.auto-suggest-container` rule; dark 538-541 updated:
- Container (all suggest types): `background: var(--bg-color); border: 0; box-shadow: inset 0 0 0 1px var(--ui-border-color), var(--shadow-sm); border-radius: 4px; padding: 6px 4px; font-size: 12px; line-height: 1.5; overflow-x: hidden;` (dark: background `var(--dark-panel-bg)`, ring `var(--dark-border-color)`, shadow `var(--shadow-sm)`).
- Rows: `.auto-suggest-container li { padding: 4px 6px 4px 0; margin: 0; min-width: 0; border-radius: 5px; cursor: default; }` — no 1px gap on purpose: Typora sets inline `max-height = 5*li.clientHeight + 12` (frame.js updateDom), which fits five gapless rows plus 6px top/bottom padding exactly; a gap would clip the fifth row.
- Row text: `.auto-suggest-container li > span { display: inline-block; vertical-align: middle; max-width: calc(100% - 24px); overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }` (graceful when the 8px classic scrollbar appears on hover for lists > 5 rows, e.g. prefix "r").
- Icons: `.auto-suggest-container .ty-file-icon { width: 24px; }` (stock 38; same specificity, theme loads later). Colours untouched (font-baked).
- Selection (single state): `.auto-suggest-container li.active, .auto-suggest-container li:hover { background-color: var(--suggest-active-bg); }` — the two may coexist (Q14 accepted).
- Fence-only fusion, list side: `#ty-auto-suggest:has(> .auto-suggest-for-fences) { margin-top: -2px; margin-left: -11px; min-width: 136px !important; border-top-left-radius: 0; border-top-right-radius: 0; box-shadow: inset 1px 0 0 #6db3ec, inset -1px 0 0 #6db3ec, inset 0 -1px 0 #6db3ec, var(--shadow-sm); }` (dark override colour `#296599`). Comment must record: inline `top/left/minWidth` come from `makeVisible` (`getClientRects()[0]` of the span, `top = bottom + 6`), placed once per show, never flipped — hence the fixed margins; `!important` beats the inline `min-width` and stock `min-width:160px`.
- Fence-only fusion, chip side: `body:has(#ty-auto-suggest.ty-show > .auto-suggest-for-fences) .md-fences .code-tooltip:focus-within { border-bottom-left-radius: 0; border-bottom-right-radius: 0; border-bottom-color: var(--ui-border-color); box-shadow: none; }` (dark: `border-bottom-color: var(--dark-border-color)`). Note `:has` support: WebKit ≥ 15.4 / Chromium ≥ 105; older engines keep the rounded chip and a detached list (graceful).
- Verify z-order on the seam: chip `z-index:20` (stock) vs list `z-index:10`; they touch, no overlap, chip shadow removed while fused so no dark band on the list top.
- `dev/color-mapping.md` code-highlight/chip section (~260-290): update the suggest-list paragraph (fusion, ring, tokens, geometry constants).

## After each commit
- Three-way sync (memory `project_typora_theme_symlink`): `~/Desktop/bt-sync/` + `blue-topaz-v1.2.0.css` copy + `blue-topaz-v1.2.0-dark.css` copy with its `@import` line repointed.
- Typora does not hot-reload: `Cmd+Q`, then `open /Applications/Typora.app` (full path; `open -a Typora` resolves to the Parallels stub).

## Verification

Manual (Typora macOS, `test/test-document.md`, light then dark):
1. A1: dark context menu row hover visible; quick-open row hover visible; outline row hover ≈ folder hover; light TOC hover ≈ #eeeeee.
2. A2: dark right-click menu #151515, modal/quick-open/suggest/notification #202020; search panel input visibly darker than its panel; footer band #f3f3f3 / #000.
3. A3: light `#ty-tooltip` bubble rgb(65,159,231); quick-open selected row blue tint; scrollbar thumb hover single translucent step.
4. B1: click into a fence — chip hugs the id (e.g. "c" ≈ 29×26), text left; hover chip → 6.7% wash; click chip → snaps to 136px, placeholder/text left-aligned, caret at left; paste 30 chars → chip stays 136px, caret visible, no overflow past the block; blur → idle chip shows ellipsis; empty fence: placeholder left.
5. B2: focus chip (empty) → list appears flush under the chip, same width, one blue outline (chip top/sides + list sides/bottom), grey hairline between, no shadow band on the seam; hover a row → accent tint, arrow cursor; ↓ key moves `.active` (both tints may coexist); type "r" → 6 rows, hover shows scrollbar, `reStructuredText` ellipsizes only then; type "zzz" → list gone, chip corners rounded again; pick "python" → chip shows python, list gone; mermaid fence → stock placement, list still styled.
6. Safari Web Inspector (Develop menu, debug mode on): with list open, `getBoundingClientRect` of `.code-tooltip` and `#ty-auto-suggest` — left/right equal within 0.5px, `list.top - chip.bottom` = 0; row `clientHeight` 26, `.ty-file-icon` width 24; computed `background-color` of `li.active` = rgba(47,147,228,0.15) light.
7. Exports (CLAUDE.md rule): HTML light + dark once → grep exported CSS: `ty-auto-suggest`/`code-tooltip` DOM absent (known), no `:has(` rule targets exported markup; PDF light once for sanity (no in-scope surface exports).
8. User screenshot pass (five chip/list states, both modes) before the round is closed; Windows VM re-check rides the existing TODO tail item.

Rollback: every step is CSS-only; `git revert` per commit; A1/A2/A3/B1/B2 are each self-contained.

## TODO.md
- 「代码块体系」: append round 6 (this plan, path, decisions Q3–Q18/Q22–Q23) and set 🟢; keep the 8/15 hard constraints list.
- 「侧栏等背景色 Obsidian 对齐排查」: 🟢, record: sidebar exact match (mismatch = window translucency on the other machine), the 5 fixes + hover token, the not-comparable list, sweep artefact `scratchpad/bg-diff-findings.md` (session-local).
