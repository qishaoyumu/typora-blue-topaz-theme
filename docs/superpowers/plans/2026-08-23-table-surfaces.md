# 表格五面对齐 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 把 Typora 表格的本体、拖拽把手、入焦工具条、行列选格弹层和三个 Bootstrap 模态按 Obsidian Blue Topaz 的实测值对齐。

**Architecture:** 纯 CSS 主题，无构建步骤：改 `blue-topaz.css`（亮）与 `blue-topaz-dark.css`（`@import` 亮色后只写差异）。每个任务先写一个离屏 WKWebView 的 HTML fixture 当"测试"——fixture 把 `getBoundingClientRect` / `getComputedStyle` 读数放进 `window.__readout`，harness 把它打印到 stdout——先跑一次记下出厂值（红），改 CSS 后再跑（绿），三路同步，提交。

**Tech Stack:** CSS；`xcrun swift` 离屏 WKWebView（Typora macOS 是 WebKit，不能用 Chrome 验像素）；bash / python3 做文件操作；`obsidian` CLI 只在需要对照时用。

**Spec:** `docs/superpowers/specs/2026-08-23-table-surfaces-design.md`

## Global Constraints

- 全程留在本 worktree：`/Users/cyrus/projects/typora/typora-blue-topaz-theme/.claude/worktrees/release-1.2.0`，分支 `release/1.2.0`。不新建、不进入别的 worktree。
- 本会话的 Bash hook 会拒绝：含 `eval` 字样的命令、heredoc（`<<'EOF'`）、过长的复合命令、`cd` 到别处。**写文件一律用 Write 工具**，跑命令用单条简单命令；要跑 Obsidian eval 就把整条命令写进 `.sh` 文件再 `bash 文件`。
- `TODO.md` 在 worktree 里是软链，Edit 工具会拒绝；用 python 脚本改（任务 7 给了脚本）。
- 提交遵循 Conventional Commits，非琐碎改动必须写 body，不用 emoji。
- 改了颜色变量必须同时更新 `dev/color-mapping.md`（任务 3、5 内含）。
- 每次改完 CSS 都要三路同步（任务 1 的 `sync.sh`）；Typora 不热重载，用户实机看之前要切主题或 Cmd+Q。
- 亮色文件用编号段头 `/* ========== 12. Table ========== */`，暗色文件用无编号段头 `/* ========== Table ========== */`；暗色只写与亮色不同的值，不重复亮色规则。
- 表格皮肤选择器必须带 `:not(.md-reset)` 守卫（选格网格本身是 `<table>`，每个元素带 `md-reset`），亮暗两边守卫要一致。
- 参照值（来自 spec §2，直接用，不要重测）：Obsidian 空 td 的 `min-width` 计算值 56.69px（6ch @ 15px）、空 th 63.10px（6ch @ 16px），`box-sizing: border-box`。
- 工作目录：`SCRATCH=/private/tmp/claude-501/-Users-cyrus-projects-typora-typora-blue-topaz-theme--claude-worktrees-release-1-2-0/def17dc2-855e-46f7-84e8-4a63c4943811/scratchpad/tbl`（下文简写 `$SCRATCH`，写命令时要展开成绝对路径）。

---

## File Structure

| 文件 | 职责 |
|---|---|
| `blue-topaz.css` §12 Table（约 531–592 行） | 本体：figure 间距与收缩、单元格最小宽 |
| `blue-topaz.css` §13 Table edit UI（约 594–611 行，本计划扩写） | 工具条、选格弹层、拖拽把手、拖动态、落点线 |
| `blue-topaz.css` §3 :root（约 51–60 行附近） | 新 token：`--ui-muted-color`、`--ui-faint-color`、`--table-drag-src-bg`、`--grid-current-bg`、`--grid-current-bg-strong`、`--grid-select-bg-strong` |
| `blue-topaz.css` §26（约 3384–3416 行） | 三个模态的框体、按钮、插入表格表单 |
| `blue-topaz-dark.css` 对应段 | 仅暗色差异值；打印块守卫 |
| `dev/color-mapping.md` | 六个新 token 的 Light / Dark 表行 |
| `TODO.md`（主仓，gitignored） | 推迟项、不搬清单、边界、尾项 |
| `$SCRATCH/wk-snap.swift`、`render.sh`、`sync.sh` | harness 与同步工具（会话本地，不入库） |
| `$SCRATCH/body.html`、`drag.html`、`toolbar.html`、`popover.html`、`modal.html` | 五个 fixture |

每个 fixture 的头部（Typora 真实加载顺序）都是下面这九行；`blue-topaz-THEME.css` 是占位，`render.sh` 会替换成亮/暗两份：

```html
<!DOCTYPE html>
<html lang="en"><head><meta charset="utf-8">
<link rel="stylesheet" href="file:///Applications/Typora.app/Contents/Resources/TypeMark/lib/bootstrape/css/bootstrap.css">
<link rel="stylesheet" href="file:///Applications/Typora.app/Contents/Resources/TypeMark/style/font-awesome-4.1.0/css/font-awesome.min.css">
<link rel="stylesheet" href="file:///Applications/Typora.app/Contents/Resources/TypeMark/style/typora-icon/style.css">
<link rel="stylesheet" href="file:///Applications/Typora.app/Contents/Resources/TypeMark/style/base.css">
<link rel="stylesheet" href="file:///Applications/Typora.app/Contents/Resources/TypeMark/style/base-control.css">
<link rel="stylesheet" href="file:///Applications/Typora.app/Contents/Resources/TypeMark/style/mac.css">
<link rel="stylesheet" href="file:///Applications/Typora.app/Contents/Resources/TypeMark/style/codemirror.css">
<link rel="stylesheet" href="file:///Users/cyrus/projects/typora/typora-blue-topaz-theme/.claude/worktrees/release-1.2.0/blue-topaz-THEME.css">
</head><body class="os-mac html-for-mac">
```

---

### Task 1: Harness 与同步工具

**Files:**
- Create: `$SCRATCH/wk-snap.swift`
- Create: `$SCRATCH/render.sh`
- Create: `$SCRATCH/sync.sh`
- Create: `$SCRATCH/smoke.html`

**Interfaces:**
- Produces: `bash $SCRATCH/render.sh <fixture.html> [w] [h]` → 为 fixture 生成 `<name>-light.html/.png` 与 `<name>-dark.html/.png`，并在 stdout 打印两行 `READOUT {json}`（fixture 里 `window.__readout` 的内容）。
- Produces: `bash $SCRATCH/sync.sh` → 三路同步并打印 md5。
- 后续任务全部依赖这两个脚本。

- [ ] **Step 1: 写 harness（用 Write 工具，路径展开 `$SCRATCH`）**

`$SCRATCH/wk-snap.swift`：

```swift
// Offscreen WKWebView snapshot + readout.
// usage: xcrun swift wk-snap.swift <input.html> <out.png> [width] [height] [scale]
// After load it prints JSON.stringify(window.__readout) to stdout, then snapshots the page.
import Foundation
import WebKit
import AppKit

let args = CommandLine.arguments
guard args.count >= 3 else { print("usage: wk-snap <input.html> <out.png> [w] [h] [scale]"); exit(2) }
let input = args[1]
let out = args[2]
let w = args.count > 3 ? Double(args[3])! : 900
let h = args.count > 4 ? Double(args[4])! : 600
let scale = args.count > 5 ? Double(args[5])! : 2

let url = input.hasPrefix("file://") ? URL(string: input)! : URL(fileURLWithPath: input)
let app = NSApplication.shared
app.setActivationPolicy(.prohibited)

final class Delegate: NSObject, WKNavigationDelegate {
    let web: WKWebView
    init(_ web: WKWebView) { self.web = web }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            webView.evaluateJavaScript("JSON.stringify(window.__readout === undefined ? null : window.__readout)") { res, err in
                if let s = res as? String { print("READOUT " + s) } else { print("READOUT null \(String(describing: err))") }
                let cfg = WKSnapshotConfiguration()
                cfg.snapshotWidth = NSNumber(value: w * scale)
                webView.takeSnapshot(with: cfg) { img, err in
                    guard let img = img, let tiff = img.tiffRepresentation,
                          let rep = NSBitmapImageRep(data: tiff),
                          let png = rep.representation(using: .png, properties: [:]) else {
                        print("snapshot failed: \(String(describing: err))"); exit(1)
                    }
                    try! png.write(to: URL(fileURLWithPath: out))
                    print("wrote \(out) \(rep.pixelsWide)x\(rep.pixelsHigh)")
                    exit(0)
                }
            }
        }
    }
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("nav failed: \(error)"); exit(1)
    }
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print("provisional nav failed: \(error)"); exit(1)
    }
}

let cfg = WKWebViewConfiguration()
cfg.preferences.setValue(true, forKey: "allowFileAccessFromFileURLs")
let web = WKWebView(frame: NSRect(x: 0, y: 0, width: w, height: h), configuration: cfg)
let window = NSWindow(contentRect: web.frame, styleMask: [.borderless], backing: .buffered, defer: false)
window.contentView = web
let delegate = Delegate(web)
web.navigationDelegate = delegate
web.loadFileURL(url, allowingReadAccessTo: URL(fileURLWithPath: "/"))
DispatchQueue.main.asyncAfter(deadline: .now() + 15) { print("timeout"); exit(1) }
app.run()
```

`$SCRATCH/render.sh`：

```bash
#!/bin/bash
# usage: bash render.sh <fixture.html> [width] [height]
set -e
DIR="$(cd "$(dirname "$0")" && pwd)"
FIX="$1"; W="${2:-1100}"; H="${3:-900}"
BASE="$(basename "$FIX" .html)"
for MODE in light dark; do
  if [ "$MODE" = light ]; then THEME=blue-topaz; else THEME=blue-topaz-dark; fi
  sed "s/blue-topaz-THEME\.css/$THEME.css/" "$FIX" > "$DIR/$BASE-$MODE.html"
  echo "== $MODE"
  xcrun swift "$DIR/wk-snap.swift" "$DIR/$BASE-$MODE.html" "$DIR/$BASE-$MODE.png" "$W" "$H" 2 | grep -v '^wrote'
done
```

`$SCRATCH/sync.sh`：

```bash
#!/bin/bash
# Three-way sync: Desktop/bt-sync copies + the v1.2.0 wrapper pair in Typora's theme folder.
set -e
REPO=/Users/cyrus/projects/typora/typora-blue-topaz-theme/.claude/worktrees/release-1.2.0
T="$HOME/Library/Application Support/abnerworks.Typora/themes"
cp "$REPO/blue-topaz.css" "$HOME/Desktop/bt-sync/blue-topaz.css"
cp "$REPO/blue-topaz-dark.css" "$HOME/Desktop/bt-sync/blue-topaz-dark.css"
cp "$REPO/blue-topaz.css" "$T/blue-topaz-v1.2.0.css"
sed 's/@import "blue-topaz.css";/@import "blue-topaz-v1.2.0.css";/' "$REPO/blue-topaz-dark.css" > "$T/blue-topaz-v1.2.0-dark.css"
echo "light:"; md5 -q "$REPO/blue-topaz.css" "$HOME/Desktop/bt-sync/blue-topaz.css" "$T/blue-topaz-v1.2.0.css"
echo "dark:";  md5 -q "$REPO/blue-topaz-dark.css" "$HOME/Desktop/bt-sync/blue-topaz-dark.css"
echo "wrapper import lines:"; grep -c 'blue-topaz-v1.2.0.css' "$T/blue-topaz-v1.2.0-dark.css"
```

`$SCRATCH/smoke.html`（九行头部 + 下面的 body）：

```html
<div id="write" style="width:720px"><p class="md-end-block" id="p">smoke</p></div>
<script>
window.__readout = { bg: getComputedStyle(document.body).backgroundColor, text: getComputedStyle(document.getElementById("p")).color };
</script></body></html>
```

- [ ] **Step 2: 跑 smoke**

Run: `bash $SCRATCH/render.sh $SCRATCH/smoke.html 400 200`
Expected:
```
== light
READOUT {"bg":"rgb(255, 255, 255)","text":"rgb(14, 14, 14)"}
== dark
READOUT {"bg":"rgb(32, 32, 32)","text":"rgb(198, 198, 198)"}
```

- [ ] **Step 3: 跑 sync 确认三路当前一致**

Run: `bash $SCRATCH/sync.sh`
Expected: light 三个 md5 相同；dark 两个相同；wrapper import lines 为 `1`。

（工具不入库，无提交。）

---

### Task 2: 本体——间距挂 figure、收缩居中、最小宽 6ch

**Files:**
- Modify: `blue-topaz.css` §12 Table（`#write table:not(.md-reset)` 规则与其上方注释、`#write th:not(.md-reset), #write td:not(.md-reset)` 规则）
- Create: `$SCRATCH/body.html`

**Interfaces:**
- Produces: `#write figure.table-figure { position: relative; width: fit-content; margin: 20px auto }` —— 任务 4 的工具条靠它做等宽包含块。

- [ ] **Step 1: 写 fixture `$SCRATCH/body.html`**（九行头部 + 以下）

```html
<div id="write" style="width:720px">
<h3 class="md-end-block" id="h">Table</h3>
<figure class="md-table-fig table-figure" id="fig1"><table class="md-table" id="t1"><thead><tr class="md-end-block"><th><span class="td-span">Feature</span></th><th style="text-align:center;"><span class="td-span">Light Mode</span></th><th style="text-align:right;"><span class="td-span">Dark Mode</span></th></tr></thead><tbody><tr class="md-end-block"><td><span class="td-span">Background</span></td><td style="text-align:center;"><span class="td-span">White</span></td><td style="text-align:right;"><span class="td-span">Dark</span></td></tr><tr class="md-end-block"><td><span class="td-span">Headings</span></td><td style="text-align:center;"><span class="td-span">Blue gradient</span></td><td style="text-align:right;"><span class="td-span">Rainbow</span></td></tr></tbody></table></figure>
<p class="md-end-block" id="p1">Paragraph after the table.</p>
<figure class="md-table-fig table-figure" id="fig2"><table class="md-table" id="t2"><thead><tr class="md-end-block"><th><span class="td-span">a</span></th><th><span class="td-span"></span></th></tr></thead><tbody><tr class="md-end-block"><td><span class="td-span">b</span></td><td><span class="td-span"></span></td></tr></tbody></table></figure>
<p class="md-end-block" id="p2">After the small table.</p>
<figure class="md-table-fig table-figure" id="fig3"><table class="md-table" id="t3"><thead><tr class="md-end-block"><th><span class="td-span" style="white-space:nowrap">a very long header cell that keeps going and going and going and going and going and going and going and going and going and going and going</span></th><th><span class="td-span">b</span></th></tr></thead><tbody><tr class="md-end-block"><td><span class="td-span">x</span></td><td><span class="td-span">y</span></td></tr></tbody></table></figure>
<p class="md-end-block" id="p3">After the wide table.</p>
</div>
<script>
const R = e => e.getBoundingClientRect();
const g = id => document.getElementById(id);
const cs = (e, p) => getComputedStyle(e)[p];
const r2 = v => Math.round(v * 100) / 100;
const W = R(g("write"));
const T1 = R(g("t1"));
window.__readout = {
  gapHeadingToTable: r2(T1.top - R(g("h")).bottom),
  gapTableToP: r2(R(g("p1")).top - T1.bottom),
  gapPToTable: r2(R(g("t2")).top - R(g("p1")).bottom),
  figureWidth: r2(R(g("fig1")).width), tableWidth: r2(T1.width),
  centeredDelta: r2((T1.left - W.left) - (W.right - T1.right)),
  figurePosition: cs(g("fig1"), "position"),
  emptyTh: r2(R(g("t2").querySelectorAll("th")[1]).width),
  emptyTd: r2(R(g("t2").querySelectorAll("td")[1]).width),
  tdMinWidth: cs(g("t2").querySelector("td"), "minWidth"),
  thMinWidth: cs(g("t2").querySelector("th"), "minWidth"),
  wideFigureWidth: r2(R(g("fig3")).width), wideScrollWidth: g("fig3").scrollWidth, wideOverflowX: cs(g("fig3"), "overflowX"),
  thBg: cs(g("t1").querySelector("th"), "backgroundColor"),
  tableShadow: cs(g("t1"), "boxShadow"),
  tdPadding: cs(g("t1").querySelector("td"), "padding"),
  tdFontSize: cs(g("t1").querySelector("td"), "fontSize")
};
</script></body></html>
```

- [ ] **Step 2: 跑一次记下出厂值（红）**

Run: `bash $SCRATCH/render.sh $SCRATCH/body.html 1100 900`
Expected（亮暗同）：`gapHeadingToTable` ≈ 39.19，`gapTableToP` ≈ 39.19，`gapPToTable` ≈ 39.19，`figureWidth` 720 ≠ `tableWidth` ≈ 323，`figurePosition` "static"，`emptyTd` 32，`tdMinWidth` "32px"，`thMinWidth` "0px"，`wideFigureWidth` 736（出厂 `max-width: calc(100% + 16px)`）。

- [ ] **Step 3: 改 `blue-topaz.css` §12**

用 Edit 把这一段（含上方整段注释，从 `/* Shrink-to-fit and centered` 到 `}`）：

```css
/* Shrink-to-fit and centered, as measured in the reference: no width rule
   (Typora base forces width:100%, hence the explicit auto), margin auto,
   20px block margins, 1.3 line-height, and no outer borders — rows
   separate by zebra fills alone, under a 1px hairline shadow. Cells
   anchor to the top (the reference's core does the same), and body cells
   drop to the reference's --table-text-size (text × 0.9375 = 15px) while
   headers keep the full size.
   The :not(.md-reset) guards fence this skin off Typora's in-document UI
   chrome: the table-resize popover's 13px pick-grid is itself a <table>
   appended INSIDE #write, and these (1,0,1) rules would beat its (0,1,1)
   stock rules — .md-reset is Typora's own hands-off marker carried by
   every element of such chrome. The dark overrides repeat the guards:
   they win by load order at equal specificity, so both must match. */
#write table:not(.md-reset) {
    border-collapse: collapse;
    width: auto;
    margin: 20px auto;
    line-height: 1.3;
    box-shadow: 1px 1px 0 rgba(0, 0, 0, 0.1);
}
```

替换为：

```css
/* Typora wraps every table — editor (figure.md-table-fig.table-figure) and
   export (figure.table-figure) alike — in a figure that is a BFC
   (overflow-x:auto), so the stock 1.2em figure margin stacked on the
   table's own 20px for 39px where the reference shows 20 (its table
   margin collapses with the paragraph's 16). The 20px block margin
   therefore lives on the figure and the table goes to 0: the figure's
   margin collapses with its neighbours again. fit-content + auto margins
   shrink the figure onto the centred table so the edit toolbar (section
   13) spans exactly the table's width; wider tables are capped at 100%
   and keep scrolling inside the figure. position:relative gives that
   toolbar its containing block. */
#write figure.table-figure {
    width: -webkit-fit-content;
    width: fit-content;
    max-width: 100%;
    margin: 20px auto;
    position: relative;
}

/* Shrink-to-fit and centered, as measured in the reference: no width rule
   (Typora base forces width:100%, hence the explicit auto), 1.3
   line-height, and no outer borders — rows separate by zebra fills alone,
   under a 1px hairline shadow. Cells anchor to the top (the reference's
   core does the same), and body cells drop to the reference's
   --table-text-size (text × 0.9375 = 15px) while headers keep the full
   size.
   The :not(.md-reset) guards fence this skin off Typora's in-document UI
   chrome: the table-resize popover's 13px pick-grid is itself a <table>
   appended INSIDE #write, and these (1,0,1) rules would beat its (0,1,1)
   stock rules — .md-reset is Typora's own hands-off marker carried by
   every element of such chrome. The dark overrides repeat the guards:
   they win by load order at equal specificity, so both must match. */
#write table:not(.md-reset) {
    border-collapse: collapse;
    width: auto;
    margin: 0;
    line-height: 1.3;
    box-shadow: 1px 1px 0 rgba(0, 0, 0, 0.1);
}
```

再用 Edit 把

```css
#write th:not(.md-reset),
#write td:not(.md-reset) {
    padding: 4px 10px;
    border: none;
    vertical-align: top;
}
```

替换为：

```css
#write th:not(.md-reset),
#write td:not(.md-reset) {
    padding: 4px 10px;
    border: none;
    vertical-align: top;
    /* The reference core's --table-column-min-width (6ch, border-box):
       an empty cell measures 56.7px at the 15px body size there; Typora's
       stock table.md-table td{min-width:32px} made empty cells half as
       wide. */
    min-width: 6ch;
}
```

- [ ] **Step 4: 再跑（绿）**

Run: `bash $SCRATCH/render.sh $SCRATCH/body.html 1100 900`
Expected（亮暗同）：`gapHeadingToTable` 20（若标题自身下外距大于 20 则等于该外距，记下实际值），`gapTableToP` 20，`gapPToTable` 20；`figureWidth` == `tableWidth`（差 < 0.5）；`centeredDelta` 绝对值 < 1；`figurePosition` "relative"；`tdMinWidth` 是 px 值且 `emptyTd` 与之相等，数值在 54–59 之间（Inter 15px 的 6ch；Obsidian 为 56.69）；`emptyTh` 在 60–66 之间；`wideFigureWidth` 720，`wideScrollWidth` > 720，`wideOverflowX` "auto"；`thBg`、`tableShadow`、`tdPadding` "4px 10px"、`tdFontSize` "15px" 与改前相同（回归护栏）。

看一眼 `$SCRATCH/body-dark.png`：三张表居中，宽表在 720 内截断可滚。

- [ ] **Step 5: 同步并提交**

Run: `bash $SCRATCH/sync.sh`（md5 一致）

```bash
git add blue-topaz.css
git commit -m "feat: hang table spacing on the figure and adopt the reference cell minimum

Typora wraps every table in a figure.table-figure that is a BFC, so its
stock 1.2em margin stacked on the table's 20px for 39px of space where
the reference shows 20. The 20px now lives on the figure (collapsing
with the neighbouring paragraph like the reference), the table's own
margin is 0, and the figure shrinks onto the centred table with
fit-content so the edit toolbar can span its width. Cells take the
reference core's 6ch minimum in place of the stock 32px."
```

---

### Task 3: 拖拽把手显形与拖动态

**Files:**
- Modify: `blue-topaz.css` §3 :root（新 token）、§13 Table edit UI（追加子段）
- Modify: `blue-topaz-dark.css` :root overrides（新 token 暗值）
- Modify: `dev/color-mapping.md`（Light / Dark 两张表各加行）
- Create: `$SCRATCH/drag.html`

**Interfaces:**
- Produces token：`--ui-faint-color`（亮 `#7f7f7f` / 暗 `#797979`，Obsidian `--table-drag-handle-color`）、`--table-drag-src-bg`（亮 `#eaf4fc` / 暗 `#212a31`，accent 10% 预混在页色上）。任务 4、5 另外引入 `--ui-muted-color`；两者不同。

- [ ] **Step 1: 写 fixture `$SCRATCH/drag.html`**（九行头部 + 以下；DOM 与 `index.html:733-748` 的 tracker / marker 一致，脚本模拟 main.js 的定位与克隆）

```html
<div id="write" style="width:720px">
<figure class="md-table-fig table-figure" id="fig"><table class="md-table" id="t"><thead><tr class="md-end-block"><th><span class="td-span">Feature</span></th><th style="text-align:center;"><span class="td-span">Light Mode</span></th><th style="text-align:right;"><span class="td-span">Dark Mode</span></th></tr></thead><tbody><tr class="md-end-block" id="r1"><td><span class="td-span">Background</span></td><td style="text-align:center;"><span class="td-span">White</span></td><td style="text-align:right;"><span class="td-span">Dark</span></td></tr><tr class="md-end-block" id="r2"><td><span class="td-span">Headings</span></td><td style="text-align:center;"><span class="td-span">Blue gradient</span></td><td style="text-align:right;"><span class="td-span">Rainbow</span></td></tr><tr class="md-end-block" id="r3"><td><span class="td-span">Code</span></td><td style="text-align:center;"><span class="td-span">Orange</span></td><td style="text-align:right;"><span class="td-span">Amber</span></td></tr></tbody></table></figure>
</div>
<div id="typora-table-row-tracker" class="md-tooltip-hide typora-table-tracker"><div class="typora-table-drag-area"></div><div class="typora-table-data-area"></div></div>
<div id="typora-table-col-tracker" class="md-tooltip-hide typora-table-tracker"><div class="typora-table-drag-area"></div><div class="typora-table-data-area"></div></div>
<div id="typora-table-row-insert-marker" class="typora-table-insert-marker"><i class="fa fa-caret-left"></i><i class="fa fa-caret-right"></i></div>
<div id="typora-table-col-insert-marker" class="typora-table-insert-marker"><i class="fa fa-caret-down"></i><i class="fa fa-caret-up"></i></div>
<script>
const R = e => e.getBoundingClientRect();
const g = id => document.getElementById(id);
const cs = (e, p, ps) => getComputedStyle(e, ps || null)[p];
const r2 = v => Math.round(v * 100) / 100;
const place = (el, rect) => { el.style.display = "block"; el.style.left = (rect.left + scrollX) + "px"; el.style.top = (rect.top + scrollY) + "px"; };
const t = g("t"), r2el = g("r2"), th2 = t.querySelectorAll("th")[1];
// 1. trackers as main.js places them on mouseenter (row 2 / column 2)
const rowTr = g("typora-table-row-tracker"), colTr = g("typora-table-col-tracker");
place(rowTr, R(r2el)); rowTr.querySelector(".typora-table-drag-area").style.height = (r2el.offsetHeight + 1) + "px";
place(colTr, R(th2)); colTr.querySelector(".typora-table-drag-area").style.width = (th2.offsetWidth + 1) + "px";
const rowAreaRect = R(rowTr.querySelector(".typora-table-drag-area"));   // measured before the tracker is parked aside below
// 2. drag state: source row marked, ghost cloned AFTER marking (as main.js does)
r2el.classList.add("typora-on-moving");
const widths = Array.from(r2el.children).map(td => td.offsetWidth);
rowTr.querySelector(".typora-table-data-area").innerHTML = "<table class='md-table' style='margin:0 ; padding:0; margin-left:0; height:" + r2el.offsetHeight + "px;'><tbody>" + r2el.outerHTML + "</tbody></table>";
rowTr.querySelectorAll(".typora-table-data-area td").forEach((td, i) => { td.style.width = widths[i] + "px"; });
rowTr.style.left = (R(t).right + 40 + scrollX) + "px";   // park the ghost beside the table so both are visible
// 3. drop markers: row marker above row 3, column marker before column 3
const rm = g("typora-table-row-insert-marker"), cm = g("typora-table-col-insert-marker");
place(rm, R(g("r3"))); rm.style.width = t.offsetWidth + "px";
place(cm, R(t.querySelectorAll("th")[2])); cm.style.height = t.offsetHeight + "px";
const ruleOf = sel => { const scan = rules => { for (const r of rules) { if (r.selectorText === sel) return r.style; if (r.styleSheet) { let sub; try { sub = r.styleSheet.cssRules; } catch (e) { continue; } const f = scan(sub); if (f) return f; } } return null; }; for (const s of document.styleSheets) { let rules; try { rules = s.cssRules; } catch (e) { continue; } const f = scan(rules); if (f) return f; } return null; };   // recurses into @import (the dark theme imports the light one)
const hov = ruleOf(".typora-table-drag-area:hover"), act = ruleOf(".typora-table-drag-area:active");
const rowArea = rowTr.querySelector(".typora-table-drag-area"), colArea = colTr.querySelector(".typora-table-drag-area");
const srcTd = r2el.querySelector("td"), ghostTd = rowTr.querySelector(".typora-table-data-area td");
window.__readout = {
  rowHandle: { offsetFromTableLeft: r2(rowAreaRect.left - R(t).left), width: r2(rowAreaRect.width), height: r2(rowAreaRect.height), rowHeight: r2(R(r2el).height) },
  colHandle: { offsetFromTableTop: r2(R(colArea).top - R(t).top), height: r2(R(colArea).height), width: r2(R(colArea).width), colWidth: r2(R(th2).width) },
  handleRest: { opacity: cs(rowArea, "opacity"), cursor: cs(rowArea, "cursor"), radius: cs(rowArea, "borderRadius"), bg: cs(rowArea, "backgroundColor"), gripImage: cs(rowArea, "backgroundImage", "::before").slice(0, 40), gripSize: cs(rowArea, "width", "::before") + " x " + cs(rowArea, "height", "::before") },
  trackerCursor: cs(rowTr, "cursor"),
  hoverRule: hov ? hov.opacity : null,
  activeRule: act ? { bg: act.backgroundColor, shadow: act.boxShadow, cursor: act.cursor } : null,
  source: { color: cs(srcTd, "color"), bg: cs(srcTd, "backgroundColor"), opacity: cs(srcTd, "opacity") },
  ghost: { color: cs(ghostTd, "color"), bg: cs(ghostTd, "backgroundColor"), opacity: cs(ghostTd, "opacity"), padding: cs(ghostTd, "padding"), fontSize: cs(ghostTd, "fontSize") },
  rowMarker: { caretDisplay: cs(rm.querySelector(".fa"), "display"), lineHeight: cs(rm, "height", "::before"), lineBg: cs(rm, "backgroundColor", "::before"), lineTop: cs(rm, "top", "::before"), width: r2(R(rm).width), tableWidth: r2(R(t).width) },
  colMarker: { lineWidth: cs(cm, "width", "::before"), lineBg: cs(cm, "backgroundColor", "::before"), height: r2(R(cm).height), tableHeight: r2(R(t).height) }
};
</script></body></html>
```

- [ ] **Step 2: 跑一次记下出厂值（红）**

Run: `bash $SCRATCH/render.sh $SCRATCH/drag.html 1100 700`
Expected：`rowHandle.offsetFromTableLeft` −6、`width` 12；`colHandle.offsetFromTableTop` −4、`height` 8；`handleRest.opacity` "0"、`cursor` "ns-resize"（继承自 tracker）、`radius` "0px"、`gripImage` "none"；`hoverRule` null；`source` color 透明 `rgba(0, 0, 0, 0)`、bg `rgb(199, 197, 197)`、opacity "0.5"；`ghost` 同 source；`rowMarker.caretDisplay` "inline-block"、`lineHeight` "auto"。

- [ ] **Step 3: 加 token**

`blue-topaz.css` §3，用 Edit 在

```css
    --ui-border-focus-color: #bdbdbd;
```

之后插入：

```css
    /* Faint chrome ink for the table drag handles: the reference's
       --table-drag-handle-color (#7f7f7f light / #797979 dark). */
    --ui-faint-color: #7f7f7f;
    /* Row/column being dragged, in place: the reference's selection tint
       (accent at 0.10) pre-blended on the page so the zebra fill under it
       does not bleed through: #2f93e4 × 0.1 on #ffffff. */
    --table-drag-src-bg: #eaf4fc;
```

`blue-topaz-dark.css` :root overrides，用 Edit 在

```css
    --ui-border-focus-color: #555555;
```

之后插入：

```css
    --ui-faint-color: #797979;
    /* rgb(45,130,205) × 0.1 on #202020. */
    --table-drag-src-bg: #212a31;
```

- [ ] **Step 4: 写把手与拖动态规则**

`blue-topaz.css` §13，在 `.ty-table-edit { ... }` 规则之后（§14 段头之前）追加：

```css
/* --- Row / column drag handles ---------------------------------------
   Typora already lets you drag a row or column: on mouseenter of any cell
   it parks #typora-table-row-tracker at the row's top-left and
   #typora-table-col-tracker at the column's, each holding a
   .typora-table-drag-area grip whose row-height / column-width is set by
   JS — but the grip ships at opacity:0, so only the cursor hints at it.
   The reference's .table-row-drag-handle / .table-col-drag-handle are the
   same idea made visible: 14px (16 − 2 ring) outside the table's left /
   top edge, a grip glyph in faint ink, 5px outer corners, invisible until
   hovered, accent-filled while held. Only the CSS dimension changes; the
   JS-set one stays. */
#typora-table-row-tracker,
#typora-table-col-tracker {
    cursor: auto;
}

#typora-table-row-tracker .typora-table-drag-area {
    width: 14px;
    left: -14px;
    border-radius: 5px 0 0 5px;
}

#typora-table-col-tracker .typora-table-drag-area {
    height: 14px;
    top: -14px;
    border-radius: 5px 5px 0 0;
}

.typora-table-drag-area {
    opacity: 0;
    background: transparent;
    cursor: grab;
}

.typora-table-drag-area:hover {
    opacity: 1;
}

/* Two columns of three 2px dots, the reference's lucide grip. */
.typora-table-drag-area::before {
    content: "";
    position: absolute;
    inset: 0;
    margin: auto;
    width: 6px;
    height: 10px;
    background: radial-gradient(circle, var(--ui-faint-color) 1px, transparent 1.5px) 0 0 / 4px 4px;
}

.typora-table-drag-area:active {
    background: var(--interactive-accent);
    box-shadow: 0 0 0 2px var(--interactive-accent);
    cursor: grabbing;
}

.typora-table-drag-area:active::before {
    background-image: radial-gradient(circle, #fff 1px, transparent 1.5px);
}

/* --- Drag in progress --------------------------------------------------
   main.js marks the dragged row/column .typora-on-moving (stock: transparent
   text on a grey 50% wash) and only then clones it into the tracker as the
   ghost that follows the mouse — so the ghost carries the same class. The
   two are told apart by ancestor: the source stays in #write and takes the
   reference's selection tint with muted text; the ghost lives in the
   body-level tracker and takes the reference's .table-col-drag-ghost look,
   accent fill with white text. The ghost table gets no #write skin, so its
   cell padding and body size are restated here. */
#write .typora-on-moving td,
#write .typora-on-moving th,
#write td.typora-on-moving,
#write th.typora-on-moving {
    color: var(--ui-muted-color);
    background: var(--table-drag-src-bg);
    opacity: 1;
}

.typora-table-tracker .typora-on-moving td,
.typora-table-tracker .typora-on-moving th,
.typora-table-tracker td.typora-on-moving,
.typora-table-tracker th.typora-on-moving {
    color: #fff;
    background: var(--interactive-accent);
    opacity: 1;
    padding: 4px 10px;
}

.typora-table-tracker .typora-on-moving td,
.typora-table-tracker td.typora-on-moving {
    font-size: 15px;
}

/* Drop indicator: JS stretches the marker to the full table width (row) or
   height (column) and parks it on the target edge; the reference draws a
   2px accent line there, so the two stock caret icons go. */
.typora-table-insert-marker .fa {
    display: none;
}

#typora-table-row-insert-marker::before,
#typora-table-col-insert-marker::before {
    content: "";
    position: absolute;
    background: var(--interactive-accent);
}

#typora-table-row-insert-marker::before {
    left: 0;
    right: 0;
    top: -1px;
    height: 2px;
}

#typora-table-col-insert-marker::before {
    top: 0;
    bottom: 0;
    left: -1px;
    width: 2px;
}
```

`--ui-muted-color` 在任务 4 才定义；本任务先在 §3 把它一起加上（任务 4 不再重复）：在刚才插入的 `--ui-faint-color` 之前加

```css
    /* Muted chrome ink: the reference's --text-muted as worn by
       .clickable-icon (#7f7f7f light / #8a8a8a dark). */
    --ui-muted-color: #7f7f7f;
```

暗色 :root 在 `--ui-faint-color: #797979;` 之前加 `--ui-muted-color: #8a8a8a;`。

暗色无需其他规则：把手、拖动态全部通过 token 取值。

- [ ] **Step 5: 再跑（绿）**

Run: `bash $SCRATCH/render.sh $SCRATCH/drag.html 1100 700`
Expected（亮 / 暗）：
- `rowHandle.offsetFromTableLeft` −14，`width` 14，`height` == `rowHeight` + 1；`colHandle.offsetFromTableTop` −14，`height` 14，`width` == `colWidth` + 1。
- `handleRest`：`opacity` "0"，`cursor` "grab"，`radius` "5px 0px 0px 5px"，`bg` `rgba(0, 0, 0, 0)`，`gripImage` 以 `radial-gradient` 开头，`gripSize` "6px x 10px"；`trackerCursor` "auto"；`hoverRule` "1"；`activeRule.bg` 含 `var(--interactive-accent)`，`cursor` "grabbing"。
- `source`：亮 `color rgb(127, 127, 127)`、`bg rgb(234, 244, 252)`；暗 `rgb(138, 138, 138)`、`rgb(33, 42, 49)`；`opacity` "1"。
- `ghost`：`color rgb(255, 255, 255)`，`bg` 亮 `rgb(65, 159, 231)` / 暗 `rgb(45, 130, 205)`，`padding` "4px 10px"，`fontSize` "15px"。
- `rowMarker.caretDisplay` "none"，`lineHeight` "2px"，`lineBg` accent，`lineTop` "-1px"，`width` == `tableWidth`；`colMarker.lineWidth` "2px"，`height` == `tableHeight`。

看 `drag-light.png` / `drag-dark.png`：表左有淡色源行，右侧 40px 处是 accent 幽灵行，第 3 行上方一条 accent 横线，第 3 列左一条竖线（把手静息不可见属正常）。

- [ ] **Step 6: 记 color-mapping**

`dev/color-mapping.md`：Light Mode 主表（`--suggest-active-bg` 那一行之后）加三行：

```markdown
| `--text-muted` (as worn by `.clickable-icon`) | `#7f7f7f` | `--ui-muted-color` — muted chrome ink: table edit-toolbar icons, the size picker's "x" and labels, the in-place text of a row/column being dragged |
| `--table-drag-handle-color` | `#7f7f7f` | `--ui-faint-color` — grip dots of the table drag handles (`.typora-table-drag-area::before`) |
| `--table-selection` (accent 0.10) | `#eaf4fc` (pre-blended on `#ffffff`) | `--table-drag-src-bg` — the row/column being dragged, in place; pre-blended so the zebra fill beneath does not bleed through |
```

Dark Mode 主表（`--suggest-active-bg` 暗行之后）加：

```markdown
| `--text-muted` (`.clickable-icon`) | `#8a8a8a` | `--ui-muted-color` |
| `--table-drag-handle-color` | `#797979` | `--ui-faint-color` |
| `--table-selection` (accent 0.10) | `#212a31` (pre-blended on `#202020`) | `--table-drag-src-bg` |
```

- [ ] **Step 7: 同步并提交**

Run: `bash $SCRATCH/sync.sh`

```bash
git add blue-topaz.css blue-topaz-dark.css dev/color-mapping.md
git commit -m "feat: surface the table drag handles and paint the drag states

Typora's row/column drag grips ship at opacity 0, so only the cursor
hinted that tables can be reordered; they now sit 14px outside the
table edge as the reference's drag handles do, show a dotted grip in
faint ink on hover, and fill with the accent while held. The dragged
row/column keeps its text in muted ink on the selection tint instead of
vanishing into a grey bar, the mouse-following ghost takes the
reference's accent-on-white ghost look, and the drop target is a 2px
accent line in place of the two caret icons. Adds --ui-muted-color,
--ui-faint-color and --table-drag-src-bg."
```

---

### Task 4: 工具条

**Files:**
- Modify: `blue-topaz.css` §13（`.ty-table-edit` 规则替换 + 按钮规则）
- Modify: `blue-topaz-dark.css` Table edit UI 段（删 `.ty-table-edit` 暗覆盖）
- Create: `$SCRATCH/toolbar.html`

**Interfaces:**
- Consumes: 任务 2 的 `#write figure.table-figure { position: relative; width: fit-content }`；任务 3 的 `--ui-muted-color`。
- Produces: 工具条按钮几何 24px 高；弹层（任务 5）挂在 `.md-resize-table-th` 下，包含块仍是 `.ty-table-edit`。

- [ ] **Step 1: 写 fixture `$SCRATCH/toolbar.html`**（九行头部 + 以下；工具条 DOM 来自 main.js `showTableEdit` 模板，脚本模拟 `resizeTableEdit` 的两条内联样式与 `showAlignCol` 的 `.active`）

```html
<div id="write" style="width:720px">
<p class="md-end-block" id="p0">Paragraph before the table.</p>
<figure class="md-table-fig table-figure" id="fig"><div class="ty-table-edit md-table-edit md-tooltip-remove" id="bar" contenteditable="false"><span class="md-th-button btn-group-xs md-resize-table-th"><button type="button" class="btn btn-default md-resize-table" ty-hint="Resize Table"><span class="ty-icon ty-menu"></span></button></span><span class="btn-group btn-group-xs md-align-gp"><button type="button" class="btn btn-default md-align-left" ty-hint="Align Left"><span class="ty-icon ty-left-alignment"></span></button><button type="button" class="btn btn-default md-align-center active" ty-hint="Align Center"><span class="ty-icon ty-justify-align"></span></button><button type="button" class="btn btn-default md-align-right" ty-hint="Align Right"><span class="ty-icon ty-right-alignment"></span></button></span><span class="md-th-button right-th-button btn-group-xs"><button type="button" class="btn btn-default md-delete-table" ty-hint="Delete Table"><span class="ty-icon ty-delete"></span></button></span></div><table class="md-table" id="t"><thead><tr class="md-end-block"><th><span class="td-span">Feature</span></th><th style="text-align:center;"><span class="td-span">Light Mode</span></th><th style="text-align:right;"><span class="td-span">Dark Mode</span></th></tr></thead><tbody><tr class="md-end-block"><td><span class="td-span">Background</span></td><td style="text-align:center;"><span class="td-span">White</span></td><td style="text-align:right;"><span class="td-span">Dark</span></td></tr><tr class="md-end-block"><td><span class="td-span">Headings</span></td><td style="text-align:center;"><span class="td-span">Blue gradient</span></td><td style="text-align:right;"><span class="td-span">Rainbow</span></td></tr></tbody></table></figure>
<p class="md-end-block" id="p1">Paragraph after the table.</p>
<figure class="md-table-fig table-figure" id="fig2"><div class="ty-table-edit md-table-edit md-tooltip-remove" id="bar2" contenteditable="false"><span class="md-th-button btn-group-xs md-resize-table-th"><button type="button" class="btn btn-default md-resize-table"><span class="ty-icon ty-menu"></span></button></span><span class="btn-group btn-group-xs md-align-gp"><button type="button" class="btn btn-default md-align-left"><span class="ty-icon ty-left-alignment"></span></button><button type="button" class="btn btn-default md-align-center"><span class="ty-icon ty-justify-align"></span></button><button type="button" class="btn btn-default md-align-right"><span class="ty-icon ty-right-alignment"></span></button></span><span class="md-th-button right-th-button btn-group-xs"><button type="button" class="btn btn-default md-delete-table"><span class="ty-icon ty-delete"></span></button></span></div><table class="md-table" id="t2"><thead><tr class="md-end-block"><th><span class="td-span">a</span></th><th><span class="td-span">b</span></th></tr></thead><tbody><tr class="md-end-block"><td><span class="td-span">c</span></td><td><span class="td-span">d</span></td></tr></tbody></table></figure>
<p class="md-end-block" id="p2">After the small table.</p>
</div>
<script>
const R = e => e.getBoundingClientRect();
const g = id => document.getElementById(id);
const cs = (e, p) => getComputedStyle(e)[p];
const r2 = v => Math.round(v * 100) / 100;
// resizeTableEdit(): margin-top = -own height, width = figure width + 10
for (const [barId, figId] of [["bar", "fig"], ["bar2", "fig2"]]) {
  const bar = g(barId), fig = g(figId);
  bar.style.marginTop = "-" + R(bar).height + "px";
  bar.style.width = (R(fig).width + 10) + "px";
}
const ruleOf = sel => { const scan = rules => { for (const r of rules) { if (r.selectorText === sel) return r.style; if (r.styleSheet) { let sub; try { sub = r.styleSheet.cssRules; } catch (e) { continue; } const f = scan(sub); if (f) return f; } } return null; }; for (const s of document.styleSheets) { let rules; try { rules = s.cssRules; } catch (e) { continue; } const f = scan(rules); if (f) return f; } return null; };   // recurses into @import (the dark theme imports the light one)
const bar = g("bar"), t = g("t"), first = bar.querySelector(".md-resize-table"), active = bar.querySelector(".md-align-center"), del = bar.querySelector(".md-delete-table");
const hov = ruleOf(".ty-table-edit button:hover");
window.__readout = {
  bar: { leftVsTable: r2(R(bar).left - R(t).left), rightVsTable: r2(R(bar).right - R(t).right), gapToTable: r2(R(t).top - R(bar).bottom), height: r2(R(bar).height), bg: cs(bar, "backgroundColor"), borderWidth: cs(bar, "borderTopWidth"), display: cs(bar, "display"), overlapPrevBlock: r2(R(g("p0")).bottom - R(bar).top) },
  button: { height: r2(R(first).height), width: r2(R(first).width), padding: cs(first, "padding"), radius: cs(first, "borderRadius"), border: cs(first, "borderTopWidth"), color: cs(first, "color"), bg: cs(first, "backgroundColor"), shadow: cs(first, "boxShadow") },
  icon: { fontSize: cs(first.querySelector(".ty-icon"), "fontSize"), lineHeight: cs(first.querySelector(".ty-icon"), "lineHeight") },
  active: { color: cs(active, "color"), bg: cs(active, "backgroundColor"), shadow: cs(active, "boxShadow"), border: cs(active, "borderTopWidth") },
  hoverRule: hov ? hov.backgroundColor : null,
  deleteRightVsTable: r2(R(del).right - R(t).right),
  small: { barWidth: r2(R(g("bar2")).width), tableWidth: r2(R(g("t2")).width), barLeftVsTable: r2(R(g("bar2")).left - R(g("t2")).left) }
};
</script></body></html>
```

- [ ] **Step 2: 跑一次记下出厂值（红）**

Run: `bash $SCRATCH/render.sh $SCRATCH/toolbar.html 1100 700`
Expected：`bar.leftVsTable` 约 −4（条从 figure 左缘起，figure 已收缩）、`rightVsTable` 约 +6、`gapToTable` 0、`height` ≈ 26、`bg` 不透明页色、`borderWidth` "1px"；`button.height` 21，`padding` "1px 5px"；`icon.fontSize` "12px"；`active.shadow` 含 `inset`，`active.border` "1px"；`hoverRule` null。

- [ ] **Step 3: 改 `blue-topaz.css` §13**

用 Edit 把

```css
.ty-table-edit {
    background: var(--bg-color);
    border: 1px solid var(--ui-border-color);
}
```

替换为：

```css
/* --- Edit toolbar -------------------------------------------------------
   Typora appends div.ty-table-edit inside the figure, before the table,
   absolutely positioned, and sets two inline styles: width = figure width
   + 10px and margin-top = -own height (so it hangs just above the table).
   The reference has no toolbar; its nearest kin are the Live Preview
   edge controls that hug the table and its .clickable-icon buttons. So
   the bar is an uncontained strip exactly as wide as the table (the
   figure shrink-wraps it since section 12): icons on the left, the
   delete button flush right, no background, no border. width:auto
   !important is the one exception to the no-!important habit — it exists
   solely to beat that inline width; left/right then span the figure. The
   inline margin-top stays, a 2px translate adds the breathing gap. */
#write figure.table-figure > .ty-table-edit {
    width: auto !important;
    left: 0;
    right: 0;
    margin-left: 0;
    min-width: max-content;
    transform: translateY(-2px);
    background: transparent;
    border: 0;
    display: flex;
    align-items: center;
    gap: 2px;
}

.ty-table-edit .right-th-button {
    float: none;
    margin-left: auto;
}

.ty-table-edit .btn-group .btn + .btn {
    margin-left: 0;
}

/* Buttons in the reference's .clickable-icon grammar: 16px glyph
   (--icon-s, the size its table controls use), 4px/6px inset, 5px
   corners, muted ink; hover the 6.7% wash; the current alignment reads as
   accent ink on the accent-15% selection tint, with Bootstrap's inset
   shadow and #adadad border gone. */
.ty-table-edit button {
    padding: 4px 6px;
    border: 0;
    border-radius: 5px;
    background: transparent;
    box-shadow: none;
    color: var(--ui-muted-color);
    line-height: 1;
}

.ty-table-edit .ty-icon {
    font-size: 16px;
    line-height: 1;
}

.ty-table-edit button:hover {
    background: var(--item-hover-bg-color);
    color: var(--ui-muted-color);
}

.ty-table-edit button.active,
.ty-table-edit button.active:hover {
    color: var(--primary-color);
    background: var(--suggest-active-bg);
    box-shadow: none;
}

.ty-table-edit button:focus {
    outline: 0;
}

/* The size picker hangs under the grid button; stock shifts it 10px left
   of the button, which now has nothing to the left of it. */
.md-resize-table-th .popover {
    margin-left: 0;
}
```

`blue-topaz-dark.css` Table edit UI 段，用 Edit 删除

```css
.ty-table-edit {
    background: var(--bg-color);
    border-color: var(--dark-border-color);
}
```

（暗色不再需要：条透明无边，按钮全走 token。）

- [ ] **Step 4: 再跑（绿）**

Run: `bash $SCRATCH/render.sh $SCRATCH/toolbar.html 1100 700`
Expected（亮 / 暗）：`bar.leftVsTable` 0（±0.5），`rightVsTable` 0，`gapToTable` 2，`height` 24，`bg` `rgba(0, 0, 0, 0)`，`borderWidth` "0px"，`display` "flex"，`overlapPrevBlock` ≤ 6；`button.height` 24，`width` 28，`padding` "4px 6px"，`radius` "5px"，`border` "0px"，`color` 亮 `rgb(127, 127, 127)` / 暗 `rgb(138, 138, 138)`，`shadow` "none"；`icon.fontSize` "16px"；`active.color` 亮 `rgb(47, 147, 228)` / 暗 `rgb(45, 130, 205)`，`active.bg` 亮 `rgba(47, 147, 228, 0.15)` / 暗 `rgba(45, 130, 205, 0.15)`（hsla 会被序列化成 rgba），`active.shadow` "none"，`active.border` "0px"；`hoverRule` 含 `var(--item-hover-bg-color)`；`deleteRightVsTable` 0（±0.5）；`small.barWidth` ≥ `small.tableWidth`，`small.barLeftVsTable` 0。

看 `toolbar-light.png` / `toolbar-dark.png`：五枚图标落在表格正上方两端，居中对齐按钮带淡蓝底，无框线。

- [ ] **Step 5: 同步并提交**

Run: `bash $SCRATCH/sync.sh`

```bash
git add blue-topaz.css blue-topaz-dark.css
git commit -m "feat: lay the table toolbar out as an edge strip of icon buttons

The edit toolbar used to be a bordered bar spanning the whole editing
column, detached from the centred table, with Bootstrap's inset shadow
boxing the current alignment. It now spans exactly the table (the
figure shrink-wraps the table, and width:auto !important beats the
inline width Typora sets), carries no background or border, and its
buttons follow the reference's clickable-icon grammar: 16px glyphs in
muted ink, a 6.7% wash on hover, accent ink on the selection tint for
the current alignment."
```

---

### Task 5: 选格弹层

**Files:**
- Modify: `blue-topaz.css` §3 :root（三个网格 token）、§13（弹层规则替换 + 网格 / 输入 / 按钮规则）
- Modify: `blue-topaz-dark.css` :root overrides（三个 token 暗值）、Table edit UI 段（`.md-table-resize-popover` 暗覆盖改边框即可）
- Modify: `dev/color-mapping.md`
- Create: `$SCRATCH/popover.html`

**Interfaces:**
- Consumes: 任务 4 的工具条几何（弹层的包含块）；`--ui-muted-color`。
- Produces token：`--grid-current-bg`（亮 `#c0c0c0` / 暗 `#414141`）、`--grid-current-bg-strong`（亮 `#9d9d9d` / 暗 `#5c5c5c`）、`--grid-select-bg-strong`（亮 `#bedcf5` / 暗 `#1c364c`）。

预混公式（写进 color-mapping 行里）：菜单底亮 `#fcfcfc`、暗 `#151515`；文字色亮 `#0e0e0e`、暗 `#c6c6c6`；accent 亮 `#2f93e4`、暗 `rgb(45,130,205)`。
- current = 文字 25%：亮 252 + (14−252)×0.25 = 192.5 → `#c0c0c0`；暗 21 + (198−21)×0.25 = 65 → `#414141`。
- current-strong = 文字 40%：亮 156.8 → `#9d9d9d`；暗 91.8 → `#5c5c5c`。
- select-strong = accent 30%：亮 (190, 220, 245) → `#bedcf5`；暗 (28, 54, 76) → `#1c364c`。

- [ ] **Step 1: 写 fixture `$SCRATCH/popover.html`**（九行头部 + 以下；弹层 DOM 来自 main.js 模板，10×6 网格由脚本生成；状态模拟：表格当前 3 列 × 3 行正文 → `md-grid-ext` 占 `tr:nth-child(-n+4) > td:nth-child(-n+3)`；悬停新选 4 列 × 5 行 → `md-active` 占 `tr:nth-child(-n+5) > td:nth-child(-n+4) > a`；"确定"强制显示）

```html
<div id="write" style="width:720px">
<figure class="md-table-fig table-figure" id="fig"><div class="ty-table-edit md-table-edit md-tooltip-remove" id="bar" contenteditable="false"><span class="md-th-button btn-group-xs md-resize-table-th" id="th"><button type="button" class="btn btn-default md-resize-table"><span class="ty-icon ty-menu"></span></button></span><span class="btn-group btn-group-xs md-align-gp"><button type="button" class="btn btn-default md-align-left"><span class="ty-icon ty-left-alignment"></span></button><button type="button" class="btn btn-default md-align-center"><span class="ty-icon ty-justify-align"></span></button><button type="button" class="btn btn-default md-align-right"><span class="ty-icon ty-right-alignment"></span></button></span><span class="md-th-button right-th-button btn-group-xs"><button type="button" class="btn btn-default md-delete-table"><span class="ty-icon ty-delete"></span></button></span></div><table class="md-table" id="t"><thead><tr class="md-end-block"><th><span class="td-span">Feature</span></th><th><span class="td-span">Light Mode</span></th><th><span class="td-span">Dark Mode</span></th></tr></thead><tbody><tr class="md-end-block"><td><span class="td-span">Background</span></td><td><span class="td-span">White</span></td><td><span class="td-span">Dark</span></td></tr><tr class="md-end-block"><td><span class="td-span">Headings</span></td><td><span class="td-span">Blue gradient</span></td><td><span class="td-span">Rainbow</span></td></tr><tr class="md-end-block"><td><span class="td-span">Code</span></td><td><span class="td-span">Orange</span></td><td><span class="td-span">Amber</span></td></tr></tbody></table></figure>
<p class="md-end-block">Paragraph after the table.</p>
</div>
<script>
const R = e => e.getBoundingClientRect();
const g = id => document.getElementById(id);
const cs = (e, p) => getComputedStyle(e)[p];
const r2 = v => Math.round(v * 100) / 100;
const bar = g("bar"), fig = g("fig");
bar.style.marginTop = "-" + R(bar).height + "px";
bar.style.width = (R(fig).width + 10) + "px";
let rows = "";
for (let r = 1; r <= 10; r++) { rows += "<tr class='md-reset' row='" + r + "'>"; for (let c = 1; c <= 6; c++) rows += "<td class='md-reset' col='" + c + "'><a href='#'></a></td>"; rows += "</tr>"; }
g("th").insertAdjacentHTML("beforeend",
  "<div class='popover bottom md-table-resize-popover' id='pop' style='display:block; bottom:auto; top:20px; margin-left:-10px;' contenteditable='false'><div class='arrow' style='left:20px;'></div><div class='md-grid-board-wrap md-reset code-tooltip-content'><table role='grid' class='md-grid-board md-reset' id='grid'><tbody>" + rows + "</tbody></table><div class='popover-title' id='title'><input id='md-grid-width' type='text' max='20' size='2' min='1' value='4' /> x <input id='md-grid-height' maxlength='2' size='2' min='1' value='5'/><button id='md-resize-grid' class='btn btn-primary btn-xs' style='display:inline-block'>OK</button></div></div></div>");
const grid = g("grid");
grid.querySelectorAll("tr:nth-child(-n+4) > td:nth-child(-n+3)").forEach(td => td.classList.add("md-grid-ext"));
grid.querySelectorAll("tr:nth-child(-n+5) > td:nth-child(-n+4) > a").forEach(a => a.classList.add("md-active"));
const cell = (r, c) => grid.querySelector("tr:nth-child(" + r + ") > td:nth-child(" + c + ")");
const state = (r, c) => { const td = cell(r, c), a = td.querySelector("a"); return { tdBg: cs(td, "backgroundColor"), aBg: cs(a, "backgroundColor"), aBorder: cs(a, "borderTopColor"), aRadius: cs(a, "borderRadius"), aOpacity: cs(a, "opacity"), aTransition: cs(a, "transitionDuration"), size: r2(R(a).width) + "x" + r2(R(a).height) }; };
const ruleOf = sel => { const scan = rules => { for (const r of rules) { if (r.selectorText === sel) return r.style; if (r.styleSheet) { let sub; try { sub = r.styleSheet.cssRules; } catch (e) { continue; } const f = scan(sub); if (f) return f; } } return null; }; for (const s of document.styleSheets) { let rules; try { rules = s.cssRules; } catch (e) { continue; } const f = scan(rules); if (f) return f; } return null; };   // recurses into @import (the dark theme imports the light one)
const pop = g("pop"), inp = g("md-grid-width"), btn = g("md-resize-grid"), title = g("title");
const focusRule = ruleOf(".md-grid-board-wrap input:focus"), hoverA = ruleOf(".md-grid-board a:hover");
window.__readout = {
  panel: { bg: cs(pop, "backgroundColor"), border: cs(pop, "borderTopColor") + " " + cs(pop, "borderTopWidth"), radius: cs(pop, "borderRadius"), shadow: cs(pop, "boxShadow"), width: r2(R(pop).width), leftVsBar: r2(R(pop).left - R(bar).left), arrow: cs(pop.querySelector(".arrow"), "display") },
  headerRowBg: cs(cell(1, 6).parentElement, "backgroundColor"),
  empty: state(8, 6),
  currentBody: state(3, 2),
  currentHeader: state(1, 1),
  selectBody: state(3, 4),
  selectHeader: state(1, 4),
  headerOnlySelectedIsAlsoCurrent: state(1, 2),
  input: { border: cs(inp, "borderTopColor") + " " + cs(inp, "borderTopWidth"), radius: cs(inp, "borderRadius"), height: r2(R(inp).height), bg: cs(inp, "backgroundColor"), color: cs(inp, "color") },
  inputFocusRule: focusRule ? focusRule.borderColor : null,
  hoverARule: hoverA ? hoverA.opacity : null,
  title: { borderTop: cs(title, "borderTopColor") + " " + cs(title, "borderTopWidth"), color: cs(title, "color") },
  button: { bg: cs(btn, "backgroundColor"), color: cs(btn, "color"), radius: cs(btn, "borderRadius"), height: r2(R(btn).height), border: cs(btn, "borderTopWidth"), fontSize: cs(btn, "fontSize") }
};
</script></body></html>
```

- [ ] **Step 2: 跑一次记下出厂值（红）**

Run: `bash $SCRATCH/render.sh $SCRATCH/popover.html 1100 800`
Expected：`panel.radius` "6px"、`leftVsBar` −10；`headerRowBg` `rgb(220, 220, 220)`；`currentBody.tdBg` `rgb(153, 153, 153)`；`currentHeader.tdBg` `rgb(85, 85, 85)`；`selectBody.aBg` `rgb(200, 202, 244)`；`selectHeader.aBg` `rgb(148, 167, 185)`；`empty.aOpacity` "1" 但 `hoverARule` "0.8"（主题 `a:hover` 漏入）；`input.radius` "0px"、`inputFocusRule` null、`empty.aTransition` "0.2s"；`button.radius` "4px"（主题 `.btn-primary`）。

- [ ] **Step 3: 加 token**

`blue-topaz.css` §3，在 `--suggest-active-bg: hsla(207, 77%, 54%, 0.15);` 之后插入：

```css
    /* Table size-picker grid (the 3 x 5 popover): Typora ships its three
       cell states as light literals (#999 / #555 / #c8caf4 / #94a7b9 /
       #dcdcdc). The reference has no such control; its selection grammar
       supplies the "new size" state (accent 0.15 + accent border, the
       header row a notch deeper at accent 0.30) and a neutral fill marks
       the table's current size (text ink at 0.25, header row 0.40), all
       pre-blended on the menu colour #fcfcfc. */
    --grid-current-bg: #c0c0c0;
    --grid-current-bg-strong: #9d9d9d;
    --grid-select-bg-strong: #bedcf5;
```

`blue-topaz-dark.css` :root overrides，在 `--suggest-active-bg: hsla(208, 64%, 49%, 0.15);` 之后插入：

```css
    /* Size-picker grid states pre-blended on the dark menu colour #151515:
       text #c6c6c6 at 0.25 / 0.40, accent rgb(45,130,205) at 0.30. */
    --grid-current-bg: #414141;
    --grid-current-bg-strong: #5c5c5c;
    --grid-select-bg-strong: #1c364c;
```

- [ ] **Step 4: 改弹层规则**

`blue-topaz.css` §13，用 Edit 把

```css
.md-table-resize-popover {
    background: var(--bg-color);
    border: 1px solid var(--ui-border-color);
}
```

替换为：

```css
/* --- Size picker --------------------------------------------------------
   A click-invoked dropdown, so it wears the menu colour and the
   reference's .menu frame (7px radius, 1px border, small shadow). Every
   element inside carries .md-reset except the grid's <a> cells, which is
   why the table skin's :not(.md-reset) guards matter and why the theme's
   generic a:hover (opacity .8 + transition) leaked onto hovered cells. */
.md-table-resize-popover {
    background: var(--menu-bg-color);
    border: 1px solid var(--ui-border-color);
    border-radius: 7px;
    box-shadow: var(--shadow-sm);
}

.md-grid-board a {
    border: 1px solid var(--ui-border-color);
    border-radius: 2px;
    background: transparent;
    opacity: 1;
    transition: none;
}

.md-grid-board a:hover {
    opacity: 1;
}

/* Stock paints the whole header row #dcdcdc; the header's meaning is
   carried by its deeper state fills instead. */
.md-grid-board tr[row='1'] {
    background: transparent;
}

/* Current table size (td.md-grid-ext, the <a> on top stays transparent). */
.md-grid-board .md-grid-ext {
    background: var(--grid-current-bg);
}

.md-grid-board tr[row='1'] .md-grid-ext {
    background: var(--grid-current-bg-strong);
}

/* New size: hover preview and typed value share a.md-active. */
.md-grid-board a.md-active,
.md-grid-board a:hover {
    background: var(--suggest-active-bg);
    border-color: var(--primary-color);
}

.md-grid-board tr[row='1'] a.md-active,
.md-grid-board tr[row='1'] a:hover {
    background: var(--grid-select-bg-strong);
}

/* The "3 x 5" row: reference text-input grammar (1px border, 7px radius,
   neutral one-notch focus, no accent), the bare "x" in muted ink, and the
   OK button as the reference's mod-cta. Stock shows OK only while an
   input has focus; that stays. */
.md-grid-board-wrap .popover-title {
    border-top: 1px solid var(--ui-border-color);
    color: var(--ui-muted-color);
}

.md-grid-board-wrap input {
    border: 1px solid var(--ui-border-color);
    border-radius: 7px;
    background: var(--bg-color);
    color: var(--text-color);
    height: 22px;
    padding: 0 4px;
}

.md-grid-board-wrap input:focus {
    border-color: var(--ui-border-focus-color);
}

#md-resize-grid {
    background: var(--interactive-accent);
    border: 0;
    border-radius: 7px;
    color: #fff;
    height: 22px;
    padding: 0 10px;
    font-size: 12px;
    line-height: 22px;
}

#md-resize-grid:hover {
    background: hsl(207, 77%, 44%);
}
```

`blue-topaz-dark.css` Table edit UI 段，用 Edit 把

```css
.md-table-resize-popover {
    background: var(--bg-color);
    border-color: var(--dark-border-color);
}
```

替换为：

```css
.md-table-resize-popover {
    border-color: var(--dark-border-color);
}

#md-resize-grid:hover {
    background: hsl(208, 64%, 39%);
}
```

（暗色底色走 `--menu-bg-color` 的暗值，不再写。）

- [ ] **Step 5: 再跑（绿）**

Run: `bash $SCRATCH/render.sh $SCRATCH/popover.html 1100 800`
Expected（亮 / 暗）：
- `panel.bg` 亮 `rgb(252, 252, 252)` / 暗 `rgb(21, 21, 21)`；`border` 亮 `rgb(221, 221, 221) 1px` / 暗 `rgb(52, 52, 52) 1px`；`radius` "7px"；`shadow` 非 "none"；`width` 134；`leftVsBar` 0；`arrow` "none"。
- `headerRowBg` `rgba(0, 0, 0, 0)`。
- `empty`：`tdBg` 与 `aBg` 均 `rgba(0, 0, 0, 0)`，`aBorder` 亮 `rgb(221, 221, 221)` / 暗 `rgb(52, 52, 52)`，`aRadius` "2px"，`aOpacity` "1"，`aTransition` "0s"，`size` "13x13"。
- `currentBody.tdBg` 亮 `rgb(192, 192, 192)` / 暗 `rgb(65, 65, 65)`，其 `aBg` 透明。
- `currentHeader.tdBg` 亮 `rgb(157, 157, 157)` / 暗 `rgb(92, 92, 92)`。
- `selectBody.aBg` 亮 `rgba(47, 147, 228, 0.15)` / 暗 `rgba(45, 130, 205, 0.15)`，`aBorder` 亮 `rgb(47, 147, 228)` / 暗 `rgb(45, 130, 205)`。
- `selectHeader.aBg` 亮 `rgb(190, 220, 245)` / 暗 `rgb(28, 54, 76)`。
- `headerOnlySelectedIsAlsoCurrent`：`tdBg` = current-strong，`aBg` = select-strong（两态叠放，新选盖住当前）。
- `input`：`border` 亮 `rgb(221, 221, 221) 1px`，`radius` "7px"，`height` 22，`bg` 亮 `rgb(255, 255, 255)` / 暗 `rgb(32, 32, 32)`；`inputFocusRule` 含 `var(--ui-border-focus-color)`；`hoverARule` "1"。
- `title.borderTop` 同边框色 1px，`title.color` 亮 `rgb(127, 127, 127)` / 暗 `rgb(138, 138, 138)`。
- `button`：`bg` 亮 `rgb(65, 159, 231)` / 暗 `rgb(45, 130, 205)`，`color` `rgb(255, 255, 255)`，`radius` "7px"，`height` 22，`border` "0px"，`fontSize` "12px"。

看 `popover-light.png` / `popover-dark.png`：面板挂在网格按钮正下方，左上 3×4 中性格、4×5 淡蓝新选格、表头行两态更深，底部输入行与蓝色 OK。

- [ ] **Step 6: 记 color-mapping**

Light 表（任务 3 加的三行之后）加：

```markdown
| — (no reference control; selection grammar) | `#c0c0c0` (text `#0e0e0e` × 0.25 on menu `#fcfcfc`) | `--grid-current-bg` — size-picker cells marking the table's current size (`td.md-grid-ext`) |
| — | `#9d9d9d` (text × 0.40 on `#fcfcfc`) | `--grid-current-bg-strong` — the same in the picker's header row |
| `--theme-color-translucent-03` analogue | `#bedcf5` (accent `#2f93e4` × 0.30 on `#fcfcfc`) | `--grid-select-bg-strong` — the picker's header-row cell of the new size; body-row new-size cells reuse `--suggest-active-bg` |
```

Dark 表加：

```markdown
| — | `#414141` (text `#c6c6c6` × 0.25 on menu `#151515`) | `--grid-current-bg` |
| — | `#5c5c5c` (text × 0.40 on `#151515`) | `--grid-current-bg-strong` |
| — | `#1c364c` (accent rgb(45,130,205) × 0.30 on `#151515`) | `--grid-select-bg-strong` |
```

并把 Light 表 `--background-modifier-border-focus` 那一行末尾的 "Other stock inputs (in-document search, table-resize `3 x 5`, megamenu filters) still take Typora's accent focus — deliberately left for a later pass" 改为 "The table-resize `3 x 5` inputs and the insert-table dialog inputs joined this step on 2026-08-23; in-document search and megamenu filters still take Typora's accent focus — deliberately left for a later pass"。

- [ ] **Step 7: 同步并提交**

Run: `bash $SCRATCH/sync.sh`

```bash
git add blue-topaz.css blue-topaz-dark.css dev/color-mapping.md
git commit -m "feat: dress the table size picker in the menu vocabulary

The 3 x 5 picker kept Typora's light literals in both modes: a #dcdcdc
header row, #999/#555 current-size cells, #c8caf4 selection cells, a
Bootstrap popover frame, accent-focused inputs and a Bootstrap OK
button. The panel now wears the menu colour with the reference's 7px
frame; the grid tells the table's current size with a neutral fill and
the new size with the selection tint plus an accent border, the header
row a notch deeper in each; the inputs take the neutral one-notch focus
and OK becomes the reference's mod-cta. Also stops the theme's generic
a:hover opacity from leaking onto hovered cells. Adds the three
--grid-*-bg tokens."
```

---

### Task 6: 模态框体与插入表格表单

**Files:**
- Modify: `blue-topaz.css` §26（`.modal-content` / `.modal-header` / `.modal-footer` 替换，新增模态内按钮与表单规则；删 `.unibody-window .modal-backdrop`）
- Modify: `blue-topaz-dark.css` Preferences, Mega Menu, Modals 段
- Create: `$SCRATCH/modal.html`

**Interfaces:**
- Consumes: `--ui-muted-color`、`--ui-border-focus-color`、`--interactive-accent`、`--shadow-md`。
- Produces: 通用模态框体；`.modal .btn-default` / `.modal .btn-primary` 仅限模态内。

- [ ] **Step 1: 写 fixture `$SCRATCH/modal.html`**（九行头部 + 以下；三个模态 DOM 来自 `index.html`，用内联 `display:block` 和 `.in` 模拟 Bootstrap 打开态，三个并排放以便一图看全）

```html
<div id="write" style="width:720px"><p class="md-end-block">Body text under the backdrop.</p></div>
<div class="modal-backdrop fade in" id="backdrop"></div>
<div class="modal fade in" id="table-insert-dialog" role="dialog" style="display:block"><div class="modal-dialog"><div class="modal-content" id="mc1"><div class="modal-header" id="mh1"><div class="modal-title" id="mt1">Insert Table</div></div><div class="modal-body" id="mb1"><div class="row"><div class="col-lg-6"><div class="input-group" id="ig1"><span class="input-group-addon" id="addon">Columns</span><input id="table-insert-col" class="form-control" value="3" /></div></div><div class="col-lg-6"><div class="input-group"><span class="input-group-addon">Rows</span><input id="table-insert-row" class="form-control" value="4" /></div></div></div></div><div class="modal-footer" id="mf1"><button type="button" class="btn btn-default" id="cancel">Cancel</button><button type="button" class="btn btn-primary" id="ok">OK</button></div></div></div></div>
<div class="modal fade in stopselect" id="common-dialog" role="dialog" style="display:block;left:360px"><div class="modal-dialog"><div class="modal-content" id="mc2"><div class="modal-header"><div class="modal-title">Delete File</div></div><div class="modal-body"><div class="row" id="common-dialog-message">Move "notes.md" to Trash?</div><div class="row" id="common-dialog-checkbox" style="display:none"></div></div><div class="modal-footer"><button type="button" class="btn btn-default">Cancel</button><button type="button" class="btn btn-primary">Move to Trash</button></div></div></div></div>
<div class="modal fade in stopselect" id="image-create-folder-confirm" role="dialog" style="display:block;left:720px"><div class="modal-dialog"><div class="modal-content" id="mc3"><div class="modal-header"><button type="button" class="close">&times;</button><div class="modal-title">Copy Image to…</div></div><div class="modal-body"><div class="row">Typora are trying copy the newly inserted image to folder <code>assets</code>. But the target folder does not exist, create it now?</div></div><div class="modal-footer"><button type="button" class="btn btn-primary">Create Folder</button><button type="button" class="btn btn-default">Cancel</button><button type="button" class="btn btn-default" style="float:left;">Learn More…</button></div></div></div></div>
<script>
const R = e => e.getBoundingClientRect();
const g = id => document.getElementById(id);
const cs = (e, p) => getComputedStyle(e)[p];
const r2 = v => Math.round(v * 100) / 100;
const ruleOf = sel => { const scan = rules => { for (const r of rules) { if (r.selectorText === sel) return r.style; if (r.styleSheet) { let sub; try { sub = r.styleSheet.cssRules; } catch (e) { continue; } const f = scan(sub); if (f) return f; } } return null; }; for (const s of document.styleSheets) { let rules; try { rules = s.cssRules; } catch (e) { continue; } const f = scan(rules); if (f) return f; } return null; };   // recurses into @import (the dark theme imports the light one)
const mc = g("mc1"), inp = g("table-insert-col"), focusRule = ruleOf("#table-insert-dialog .form-control:focus");
window.__readout = {
  content: { radius: cs(mc, "borderRadius"), padding: cs(mc, "padding"), border: cs(mc, "borderTopColor") + " " + cs(mc, "borderTopWidth"), shadow: cs(mc, "boxShadow"), bg: cs(mc, "backgroundColor"), width: r2(R(mc).width) },
  header: { borderBottom: cs(g("mh1"), "borderBottomWidth"), padding: cs(g("mh1"), "padding") },
  footer: { borderTop: cs(g("mf1"), "borderTopWidth"), padding: cs(g("mf1"), "padding") },
  body: { padding: cs(g("mb1"), "padding") },
  title: { fontSize: cs(g("mt1"), "fontSize"), fontWeight: cs(g("mt1"), "fontWeight") },
  backdrop: { bg: cs(g("backdrop"), "backgroundColor"), filter: cs(g("backdrop"), "webkitBackdropFilter") || cs(g("backdrop"), "backdropFilter"), opacity: cs(g("backdrop"), "opacity") },
  inputGroup: { display: cs(g("ig1"), "display") },
  addon: { bg: cs(g("addon"), "backgroundColor"), border: cs(g("addon"), "borderTopWidth"), color: cs(g("addon"), "color") },
  input: { height: r2(R(inp).height), radius: cs(inp, "borderRadius"), border: cs(inp, "borderTopColor") + " " + cs(inp, "borderTopWidth"), bg: cs(inp, "backgroundColor"), shadow: cs(inp, "boxShadow"), marginLeft: cs(inp, "marginLeft"), fontSize: cs(inp, "fontSize") },
  inputFocusRule: focusRule ? focusRule.borderColor : null,
  cancel: { bg: cs(g("cancel"), "backgroundColor"), border: cs(g("cancel"), "borderTopWidth"), radius: cs(g("cancel"), "borderRadius"), height: r2(R(g("cancel")).height), color: cs(g("cancel"), "color"), fontSize: cs(g("cancel"), "fontSize") },
  ok: { bg: cs(g("ok"), "backgroundColor"), radius: cs(g("ok"), "borderRadius"), height: r2(R(g("ok")).height), color: cs(g("ok"), "color"), marginLeft: cs(g("ok"), "marginLeft") },
  common: { radius: cs(g("mc2"), "borderRadius"), padding: cs(g("mc2"), "padding") },
  image: { radius: cs(g("mc3"), "borderRadius"), padding: cs(g("mc3"), "padding") }
};
</script></body></html>
```

- [ ] **Step 2: 跑一次记下出厂值（红）**

Run: `bash $SCRATCH/render.sh $SCRATCH/modal.html 1100 500`
Expected：`content.radius` "6px"、`padding` "0px"；`header.borderBottom` "1px"；`footer.borderTop` "1px"；`title.fontSize` 约 "14.95px"；`backdrop.filter` 含 `blur`；`inputGroup.display` "table"；`addon.bg` `rgb(238, 238, 238)`；`input.height` 34、`radius` "0px 4px 4px 0px"、`marginLeft` "8px"；`cancel.radius` "4px"、`border` "1px"；`ok.radius` "4px"。

- [ ] **Step 3: 改 `blue-topaz.css` §26**

用 Edit 把

```css
.modal-content {
    background: var(--bg-color);
    border: 1px solid var(--ui-border-color);
    border-radius: 6px;
}

.modal-header {
    border-bottom: 1px solid #eee;
}

.modal-footer {
    border-top: 1px solid #eee;
}
```

替换为：

```css
/* Dialog frame in the reference's .modal grammar — 24px radius, 16px
   inset, 20px/600 title, no header/footer rules, a flat 40% backdrop wash
   with no blur — shared by all three stock dialogs (#table-insert-dialog,
   #common-dialog, #image-create-folder-confirm). mac.css's 300px width,
   top:0 and centred text are platform geometry and stay; the reference's
   560px min-width is not ported. */
.modal-content {
    background: var(--bg-color);
    border: 1px solid var(--ui-border-color);
    border-radius: 24px;
    padding: 16px;
    box-shadow: var(--shadow-md);
}

.modal-header {
    border: 0;
    padding: 0 0 12px;
}

.modal-body {
    padding: 0;
}

.modal-footer {
    border: 0;
    padding: 16px 0 0;
}

.modal-footer .btn + .btn {
    margin-left: 8px;
}

.modal-title {
    font-size: 20px;
    font-weight: 600;
}

.modal-backdrop.in {
    background: rgba(220, 220, 220, 0.4);
    -webkit-backdrop-filter: none;
    backdrop-filter: none;
}

/* Dialog buttons: the reference's plain button (#efefef, 7px, 30px) and
   mod-cta (accent, white). Scoped to .modal so the generic .btn-* rules
   below keep serving the megamenu. */
.modal .btn-default {
    background: #efefef;
    border: 0;
    border-radius: 7px;
    height: 30px;
    padding: 4px 12px;
    font-size: 13px;
    color: var(--text-color);
}

.modal .btn-default:hover {
    background: #e6e6e6;
}

.modal .btn-primary {
    background: var(--interactive-accent);
    border: 0;
    border-radius: 7px;
    height: 30px;
    padding: 4px 12px;
    font-size: 13px;
    color: #fff;
}

.modal .btn-primary:hover {
    background: hsl(207, 77%, 44%);
}

/* Insert-table form: the two number fields in the reference's text-input
   grammar (30px, 4px 8px, 13px, 1px border, 7px radius, neutral focus)
   with "Columns" / "Rows" as plain muted labels instead of Bootstrap's
   boxed add-ons. Flex replaces the table-cell layout that squared the
   field's inner corners. */
#table-insert-dialog .input-group {
    display: flex;
    align-items: center;
}

#table-insert-dialog .input-group-addon {
    display: block;
    background: transparent;
    border: 0;
    padding: 0 8px 0 0;
    font-size: 13px;
    color: var(--ui-muted-color);
}

#table-insert-dialog .form-control {
    display: block;
    flex: 1;
    width: auto;
    margin-left: 0;
    height: 30px;
    padding: 4px 8px;
    font-size: 13px;
    border: 1px solid var(--ui-border-color);
    border-radius: 7px;
    background: var(--bg-color);
    box-shadow: none;
    color: var(--text-color);
}

#table-insert-dialog .form-control:focus {
    border-color: var(--ui-border-focus-color);
    box-shadow: none;
}
```

再用 Edit 删除 `.unibody-window .modal-backdrop { background-color: var(--bg-color); }` 这条规则（`.modal-backdrop.in` 现在在所有平台生效，且比它靠后同特异性），并把其上方注释里的 "the defaults paint light literals (#fff backdrop, #fafafa disabled chip, #ccc focus flash)" 改为 "the defaults paint light literals (#fafafa disabled chip, #ccc focus flash)"。

- [ ] **Step 4: 改 `blue-topaz-dark.css`**

用 Edit 把

```css
.modal-header {
    border-bottom-color: #444;
}

.modal-footer {
    border-top-color: #444;
}
```

替换为：

```css
.modal-backdrop.in {
    background: rgba(10, 10, 10, 0.4);
}

.modal .btn-default {
    background: #2b2b2b;
}

.modal .btn-default:hover {
    background: #373737;
}

.modal .btn-primary:hover {
    background: hsl(208, 64%, 39%);
}
```

（`.modal-content` 的暗覆盖已有：`--dark-panel-bg` 底、`--dark-border-color` 边、`--shadow-md`，不动。）

- [ ] **Step 5: 再跑（绿）**

Run: `bash $SCRATCH/render.sh $SCRATCH/modal.html 1100 500`
Expected（亮 / 暗）：`content.radius` "24px"，`padding` "16px"，`border` 亮 `rgb(221, 221, 221) 1px` / 暗 `rgb(52, 52, 52) 1px`，`shadow` 非 "none"，`bg` 亮 `rgb(255, 255, 255)` / 暗 `rgb(32, 32, 32)`；`header.borderBottom` "0px"，`header.padding` "0px 0px 12px"；`footer.borderTop` "0px"，`footer.padding` "16px 0px 0px"；`body.padding` "0px"；`title.fontSize` "20px"，`fontWeight` "600"；`backdrop.bg` 亮 `rgba(220, 220, 220, 0.4)` / 暗 `rgba(10, 10, 10, 0.4)`，`filter` "none"，`opacity` "1"；`inputGroup.display` "flex"；`addon.bg` `rgba(0, 0, 0, 0)`，`border` "0px"，`color` 亮 `rgb(127, 127, 127)` / 暗 `rgb(138, 138, 138)`；`input.height` 30，`radius` "7px"，`border` 同框边色 1px，`shadow` "none"，`marginLeft` "0px"，`fontSize` "13px"；`inputFocusRule` 含 `var(--ui-border-focus-color)`；`cancel.bg` 亮 `rgb(239, 239, 239)` / 暗 `rgb(43, 43, 43)`，`border` "0px"，`radius` "7px"，`height` 30，`fontSize` "13px"；`ok.bg` 亮 `rgb(65, 159, 231)` / 暗 `rgb(45, 130, 205)`，`radius` "7px"，`height` 30，`color` `rgb(255, 255, 255)`，`marginLeft` "8px"；`common.radius` 与 `image.radius` 均 "24px"，`padding` "16px"。

看 `modal-light.png` / `modal-dark.png`：三个圆角大的对话框，无分隔线，字段圆角、标签无框，按钮成对。

- [ ] **Step 6: 同步并提交**

Run: `bash $SCRATCH/sync.sh`

```bash
git add blue-topaz.css blue-topaz-dark.css
git commit -m "feat: align the Bootstrap dialogs with the reference modal

Typora's three stock dialogs (insert table, the generic confirm, the
image-folder prompt) share one Bootstrap frame: 6px corners, header and
footer rules, a blurred backdrop, boxed input add-ons and 4px buttons.
The frame now follows the reference's .modal grammar — 24px corners,
16px inset, a 20px/600 title, no rules, a flat 40% backdrop wash — the
buttons become the reference's plain button and mod-cta, and the
insert-table fields take the text-input grammar with plain muted
labels, the same neutral focus step the size picker uses."
```

---

### Task 7: 打印块守卫、TODO 记账

**Files:**
- Modify: `blue-topaz-dark.css` Print / Export 段（三条表格规则）
- Modify: `TODO.md`（主仓软链；python 改）

- [ ] **Step 1: 补守卫**

`blue-topaz-dark.css` 的 `@media print` 块内，用 Edit 把

```css
    #write th {
        background: #25303f !important;
        color: var(--text-color) !important;
    }
    #write tbody tr {
        background: #202020 !important;
    }
    #write tbody tr:nth-child(odd) {
        background: #1a1a1a !important;
    }
```

替换为：

```css
    #write th:not(.md-reset) {
        background: #25303f !important;
        color: var(--text-color) !important;
    }
    #write tbody tr:not(.md-reset) {
        background: #202020 !important;
    }
    #write tbody tr:not(.md-reset):nth-child(odd) {
        background: #1a1a1a !important;
    }
```

- [ ] **Step 2: 验证无其他无守卫的表格皮肤**

Run: `grep -n "#write th \|#write th{\|#write td \|#write tbody tr \|#write tbody tr{" blue-topaz.css blue-topaz-dark.css`
Expected：无输出（所有 `#write th/td/tr` 选择器都带 `:not(.md-reset)`）。

- [ ] **Step 3: 记 TODO.md**

用 Write 工具写 `$SCRATCH/todo-append.py`：

```python
import re
p = "/Users/cyrus/projects/typora/typora-blue-topaz-theme/TODO.md"
s = open(p, encoding="utf-8").read()
entry = """  - **表格五面对齐（2026-08-23，grilling 三轮 + superpowers spec/plan）**：spec `docs/superpowers/specs/2026-08-23-table-surfaces-design.md`，plan `docs/superpowers/plans/2026-08-23-table-surfaces.md`。本体六值复核逐字节同，修两条：上下间距 39.2→20（外距挪到 figure，表格归零，figure fit-content 居中）、单元格最小宽 32px→6ch（OB 空 td 56.69）；把手 14px 贴外缘悬停显形（CSS 点阵 grip、按下 accent）；拖动态原位 accent 10% 淡底 + muted 文字、幽灵 accent 实底白字、落点 2px accent 线；工具条贴上缘横排无容器、宽随表、16px 图标三态；选格弹层菜单色 7px 面板、网格三态 token、输入框灰焦点、OK=mod-cta；三个模态框体按 OB .modal（24/16/20·600/去线/遮罩色）+ 插入表单控件。新 token：`--ui-muted-color` `--ui-faint-color` `--table-drag-src-bg` `--grid-current-bg` `--grid-current-bg-strong` `--grid-select-bg-strong`（color-mapping 已记）。**不搬清单**：BT 悬停 resize 手柄（纯视图层、overflow:hidden 裁光标）、OB 单元格 ellipsis/overflow hidden。**边界**：加行/加列按钮 Typora 无 DOM 造不出；弹层悬在表格左上角之上（同出厂）。**待用户实机**：亮暗各一——表格入焦/hover/切对齐、弹层悬停→输入→确定、拖一次行一次列、三个对话框（插入表格 / 删除文件确认 / 图片建文件夹确认）。**导出四路追加看点**：figure 收缩后表格仍居中且间距 20、无工具条/把手/marker 残留。**Windows VM 尾项追加**：工具条"更多"文字按钮排布、三个模态遮罩、把手。
"""
deferred = """- **🔴 候选：表格光标格标记**（2026-08-23 表格专项 Q2 用户定）：OB LP 光标所在格无标记、`is-selected` 只给拖选多格；Typora 光标格无类（md-focus 落点待核）。用户要求推迟到下个大版本，与"正文活动行高亮"及模式体系一起议；若做，路径是 `td:has(> .td-span.md-focus)` 借 is-selected 语法（accent 10% 底 + 2px accent 边 + 4px 圆角）。
"""
anchor = "- **🔴 候选：正文活动行高亮**"
assert anchor in s, "anchor not found"
s = s.replace(anchor, deferred + anchor, 1)
# append the project entry after the last line that mentions 348740b (yesterday's list-geometry bullet)
lines = s.split("\n")
idx = max(i for i, l in enumerate(lines) if "348740b" in l)
lines.insert(idx + 1, entry.rstrip("\n"))
s = "\n".join(lines)
open(p, "w", encoding="utf-8").write(s)
print("ok")
```

Run: `python3 $SCRATCH/todo-append.py`
Expected：`ok`。然后 `grep -n "表格五面对齐\|表格光标格标记" /Users/cyrus/projects/typora/typora-blue-topaz-theme/TODO.md` 各命中一行。

- [ ] **Step 4: 同步并提交**

Run: `bash $SCRATCH/sync.sh`

```bash
git add blue-topaz-dark.css
git commit -m "fix: guard the dark print table rules against the size-picker grid

The three dark @media print table rules lacked the :not(.md-reset) guard
the screen rules carry, so they could have restyled the table-resize
popover's pick-grid if it were ever printed; they now match."
```

---

### Task 8: 并排合成图与交付清单

**Files:**
- Create: `$SCRATCH/compose.py`
- Read: `$SCRATCH/../ob-table-read-light-crop.png`、`ob-table-read-dark-crop.png`、`ob-table-lp-dark-controls-crop.png`、`ob-table-lp-dark-selected-crop.png`（上一轮 Obsidian 截图，在 `$SCRATCH` 的上级目录）

- [ ] **Step 1: 重跑五个 fixture 拿最终图**

Run（逐条）：
`bash $SCRATCH/render.sh $SCRATCH/body.html 1100 900`
`bash $SCRATCH/render.sh $SCRATCH/drag.html 1100 700`
`bash $SCRATCH/render.sh $SCRATCH/toolbar.html 1100 700`
`bash $SCRATCH/render.sh $SCRATCH/popover.html 1100 800`
`bash $SCRATCH/render.sh $SCRATCH/modal.html 1100 500`
Expected：五组读数与各任务 Step "绿" 的期望一致（回归护栏）。

- [ ] **Step 2: 合成对照图**

用 Write 写 `$SCRATCH/compose.py`：

```python
from PIL import Image, ImageDraw
import os
D = os.path.dirname(os.path.abspath(__file__))
OB = os.path.join(D, "..")
def load(p): return Image.open(p).convert("RGB")
def label(im, text):
    out = Image.new("RGB", (im.width, im.height + 28), (40, 40, 40))
    out.paste(im, (0, 28)); ImageDraw.Draw(out).text((8, 7), text, fill=(230, 230, 230)); return out
def fit(im, w):
    return im.resize((w, int(im.height * w / im.width)))
rows = [
  ("Obsidian reading / light", load(os.path.join(OB, "ob-table-read-light-crop.png"))), ("Typora body / light", load(os.path.join(D, "body-light.png"))),
  ("Obsidian reading / dark", load(os.path.join(OB, "ob-table-read-dark-crop.png"))), ("Typora body / dark", load(os.path.join(D, "body-dark.png"))),
  ("Obsidian LP controls / dark", load(os.path.join(OB, "ob-table-lp-dark-controls-crop.png"))), ("Typora toolbar / dark", load(os.path.join(D, "toolbar-dark.png"))),
  ("Obsidian LP selected / dark", load(os.path.join(OB, "ob-table-lp-dark-selected-crop.png"))), ("Typora drag / dark", load(os.path.join(D, "drag-dark.png"))),
  ("Typora picker / light", load(os.path.join(D, "popover-light.png"))), ("Typora picker / dark", load(os.path.join(D, "popover-dark.png"))),
  ("Typora modals / light", load(os.path.join(D, "modal-light.png"))), ("Typora modals / dark", load(os.path.join(D, "modal-dark.png"))),
]
W = 900
tiles = [label(fit(im, W), t) for t, im in rows]
H = sum(max(tiles[i].height, tiles[i + 1].height) for i in range(0, len(tiles), 2)) + 8 * (len(tiles) // 2)
sheet = Image.new("RGB", (W * 2 + 24, H), (20, 20, 20))
y = 0
for i in range(0, len(tiles), 2):
    sheet.paste(tiles[i], (8, y)); sheet.paste(tiles[i + 1], (W + 16, y))
    y += max(tiles[i].height, tiles[i + 1].height) + 8
sheet.save(os.path.join(D, "table-surfaces-compare.png"))
print("wrote", os.path.join(D, "table-surfaces-compare.png"), sheet.size)
```

Run: `python3 $SCRATCH/compose.py`
Expected：`wrote .../table-surfaces-compare.png (1824, H)`。用 Read 工具看图，确认六组并排无明显走样。

- [ ] **Step 3: 最终三路同步与状态确认**

Run: `bash $SCRATCH/sync.sh` 与 `git status --short` 与 `git log --oneline -8`
Expected：md5 一致；工作树干净；最近 6 笔提交为任务 2–7 的 6 个 commit（顺序：figure 间距 → 把手拖动 → 工具条 → 弹层 → 模态 → 打印守卫）。

- [ ] **Step 4: 向用户交付**

用 SendUserFile 发 `$SCRATCH/table-surfaces-compare.png`，并在正文给出实机验收清单（亮暗各一遍）：
1. 打开 `test/test-document.md` 的 Table 节：表格与前后段落间距、空格宽度（可临时清空一格看）。
2. 点进表格：工具条贴表格宽、无框；hover 按钮；点左/中/右对齐看 accent 态；点网格按钮看弹层——悬停格子、点进输入框（灰焦点、OK 出现）、按 OK。
3. 鼠标移到某行最左 14px 外侧 / 某列上方 14px 外侧看 grip，按住拖一次行、一次列，看原位淡底 + 幽灵 + accent 落点线。
4. 菜单 段落 → 表格 → 插入表格；侧栏删除一个文件看确认框；（可选）图片偏好触发建文件夹确认。
5. 导出 HTML 与 PDF 各一份看表格页（居中、20px、无控件残留）。
6. Windows VM 尾项：工具条"更多"按钮、三个模态遮罩、把手（留到发布前）。

---

## Self-Review

- **Spec 覆盖**：§5.1 → 任务 2；§5.2 → 任务 3；§5.3 → 任务 4；§5.4 与 `a:hover` 漏入 → 任务 5；§5.5 → 任务 6；§5.6 打印守卫与 §8 的 TODO 记账 → 任务 7；§6 验证（harness、合成图、实机清单、导出、Windows）→ 各任务 Step "绿" + 任务 8；§8 color-mapping → 任务 3、5。spec §3 "光标格推迟" → 任务 7 TODO。
- **占位符**：无 TBD / "类似任务 N"；每个 fixture、每条规则、每个期望值都写实。
- **名称一致性**：token 名在任务 3（`--ui-muted-color`、`--ui-faint-color`、`--table-drag-src-bg`）、任务 5（`--grid-current-bg`、`--grid-current-bg-strong`、`--grid-select-bg-strong`）定义，任务 4、6 只消费已定义的；`render.sh` / `sync.sh` 的用法在各任务一致；fixture 的 `ruleOf` 依赖 file:// 样式表可枚举——若 `cssRules` 抛异常导致 `hoverRule` 为 null，改用 `$SCRATCH` 里复制一份主题 CSS 内联进 `<style>` 再读（任务 1 的 smoke 已证明 file:// 读取可用，此为兜底）。
- **与 spec 的已知偏差**：spec 写 `--shadow-lg`，主题无此 token，用现有 `--shadow-md`；spec §5.3 按钮 hover 没写 `.active:hover`，计划里补了（否则 hover 会把 accent 态洗回灰）；`.unibody-window .modal-backdrop` 改为删除而非改色（`.modal-backdrop.in` 已覆盖全平台）。
