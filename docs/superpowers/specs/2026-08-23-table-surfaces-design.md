# 表格五面对齐（本体 / 把手 / 工具条 / 选格弹层 / 模态） — 设计文档

- 日期：2026-08-23
- 状态：已确认，待转实现计划
- 分支：`release/1.2.0`（本 worktree 内直接实施，不另建 worktree）
- 范围文件：`blue-topaz.css`、`blue-topaz-dark.css`、`dev/color-mapping.md`、`TODO.md`（主仓软链，记账）

## 1. 背景与目标

表格本体在 7 月已按 Obsidian Blue Topaz 移植过三轮，但 Typora 专属的表格 chrome（入焦工具条、行列选格弹层、插入表格模态、行列拖拽把手）仍是出厂 Bootstrap 形态 + 硬编码浅色值，在暗色下尤其突兀（深色面板里一块浅灰网格、Bootstrap 蓝按钮、方框感的当前对齐态）。用户要求"不打补丁，整体看本体与控件和 Obsidian 是否观感一致、设置合理"。

目标：

1. 本体按 Obsidian 实测逐值复核，修正剩余差异。
2. Typora 独有 chrome 按 Obsidian 最近亲缘物实测定值，落到本主题已有 token，形态可变。
3. 三个 Bootstrap 模态的框体一并按 Obsidian `.modal` 对齐。

## 2. 调研结论

两路调研（Typora：main.js 模板 + 出厂 CSS 全量；Obsidian：BT 主题规则 + 实机 computed + 截图）的关键事实：

### 2.1 本体对表

| 项 | Obsidian（阅读视图，亮/暗） | Typora 现状 | 结论 |
|---|---|---|---|
| 宽度 / 居中 | shrink-to-fit，`margin: 20px auto` | 同 | 一致 |
| 上下间距 | 20px（前段 16 与表 20 塌陷） | **39.2px**（figure 出厂 1.2em 外距 + 表 20，figure 是 BFC 不塌陷） | 修 |
| th/td 内距、顶对齐、border none | `4px 10px`、top、none | 同 | 一致 |
| td 字号 / th 字重 / th 底 | 15px / 600 / accent 10% | 同 | 一致 |
| 斑马 / tr·td·th hover | 六值 | 逐字节同 | 一致 |
| 阴影 / 行高 | `1px 1px 0 rgba(0,0,0,.1)` / 1.3 | 同 | 一致 |
| 单元格最小宽 | `6ch`（核心 app.css） | `32px`（`table.md-table td`） | 修 |
| 悬停 resize 手柄 | BT `table:hover{overflow:hidden;resize:both!important}` | 无 | **不搬**（纯视图层、`overflow:hidden` 裁光标与阴影、WebKit 对 table resize 不可靠） |
| 单元格 `text-overflow:ellipsis; overflow:hidden` | 有（`max-width:none` 时无可见效果） | 无 | **不搬**（会裁光标） |
| `white-space` | `break-spaces` | `pre-wrap` | 不动（只差行尾空格折行） |

环境注记：用户库 BT 为 2026081501、Obsidian 1.13.7，Style Settings 未装（所见为无 body class 基线）；表格六值与 v1.0 移植逐字节同，无上游漂移。

### 2.2 编辑态

- Obsidian LP：光标所在格**无**标记；`is-selected`（拖选多格）= accent 10% 底 + 2px accent 描边 + 4px 圆角。行/列把手 `.table-row/col-drag-handle`：贴表格左缘/上缘外侧 14px（16 − 2 描边）、grip 图标、`--text-faint`、5px 圆角、`opacity:0` 悬停自身才显形，`:active` accent 实底 + 白色图标 + 2px accent 描边、`cursor:grab/grabbing`；落点 `.table-drag-target` 2px accent 线；幽灵 `.table-col-drag-ghost` accent 实底白字。
- Typora：光标格无类；`#typora-table-row-tracker` / `#typora-table-col-tracker`（body 级）在鼠标进入任一 th/td 时定位到该行左上 / 该列左上，内部 `.typora-table-drag-area` 12×8、`left:-6px` / `top:-4px`、`opacity:0`，另一维由 JS 设为行高 / 列宽；拖动时先给被拖行/列加 `typora-on-moving`（`color:transparent; background:#c7c5c5; opacity:.5`）**再**克隆做幽灵，幽灵带同一个类；落点 `#typora-table-row/col-insert-marker` 被 JS 拉到整表宽/高，内含两枚 `fa-caret`。无加行/加列按钮 DOM。

### 2.3 工具条 `.ty-table-edit`

插在 figure 内、table 之前；`position:absolute`；JS 内联 `width = figure 宽 + 10px`、`margin-top = -自高`；五枚 typora-icon 字体图标 12px（macOS 无"更多"按钮，Windows 有且带文字）；当前对齐 `.active` = `--item-hover-bg-color` + Bootstrap 内阴影 + #adadad 边。Obsidian 无工具条；最近亲缘物是 LP 表格边缘控件（贴表格几何、不用时不见、faint → accent）与 `.clickable-icon`（`--icon-s` 16px、内距 4px/6px、7px 圆角、hover 6.7%）。

### 2.4 选格弹层 `.md-table-resize-popover`

挂在 `.md-resize-table-th` 内（包含块 = 工具条）；宽 134、Bootstrap 圆角 6 / 阴影；网格 10×6 个 13px 格、`border-spacing:2px`；三态全部硬编码：`td.md-grid-ext`（表格当前尺寸）#999 / 表头行 #555，`a.md-active`/`a:hover`（新选、悬停与输入共用）#c8caf4 / 表头行 #94a7b9，`tr[row='1']` 整行 #dcdcdc。输入框无 class、焦点取 `--primary-color`（出厂 `input:focus`）；"确定" `#md-resize-grid` 取 `--primary-color`，输入框入焦才显示；"x" 为模板裸文本。网格 `<a>` 是弹层里唯一不带 `md-reset` 的元素，主题 `a:hover{opacity:.8;transition}` 漏入。

### 2.5 模态

`index.html` 共三个 Bootstrap 模态共用框体：`#table-insert-dialog`、`#image-create-folder-confirm`、`#common-dialog`（全局确认）。Obsidian `.modal`：24px 圆角、16px 内距、标题 20px/600、无分隔线、遮罩 rgba(220,220,220,.4) / rgba(10,10,10,.4)、`min-width:560px`（不搬）。Obsidian 输入框：30px 高、`4px 8px`、13px、1px #ddd/#343434、7px 圆角、焦点 `--background-modifier-border-focus`（灰）；`button` #efefef/#2b2b2b、7px、30px；`button.mod-cta` accent 底白字。

### 2.6 其他

- macOS 表格右键是原生 NSMenu，in-DOM `#table-menu` 只在 Windows/Linux 可达 → 右键菜单出局。
- 导出 HTML 的表格标记去掉 `.md-table` / `.td-span` / cid，`figure.table-figure` 与 `#write table/th/td` 保留。
- 暗色 `@media print` 三条表格规则缺 `:not(.md-reset)` 守卫。

## 3. 决策记录（均经用户确认，grilling 三轮）

| 决策点 | 结论 |
|---|---|
| 排期 | 表格控件（工具条 / 弹层 / 插入模态）从"弹层/菜单/footer 专项"拆出随本专项做；菜单 / footer 仍留后续 |
| 定值依据 | Typora 独有 chrome 按 Obsidian 最近亲缘物实测定值、落已有 token、形态可变；尺寸 token 取 Obsidian 值（面板 7、元素 5）而非本主题现行 4px 族 |
| 覆盖面 | 本体阅读态 + 编辑态、工具条、弹层、插入模态（含三个模态框体）、导出看点；右键菜单出局 |
| 本体 | 整体重测；修间距 20px、最小宽 6ch；BT resize 手柄与 ellipsis/overflow 不搬 |
| 光标格 | 不加标记；TODO 记入下个大版本（与模式体系一起议） |
| 把手 | 悬停显形（14px 贴外缘、grip、faint、5px 圆角、按下 accent） |
| 拖动态 | 原位 accent 10% 淡底 + `--text-muted` 文字；幽灵 accent 实底白字；落点 2px accent 线、隐藏三角 |
| 工具条 | 贴上缘横排、无容器、宽随表；图标 16px（OB `--icon-s`）`--text-muted`；hover 6.7% 圆底 5px；当前对齐 accent 图标 + accent 15% 底 |
| 弹层 | 面板 `--menu-bg-color` + 1px 边 + 7px + `--shadow-sm`；网格：空透明 / 当前中性实底 / 新选 accent 15% + accent 边，表头行同态加深一档；输入框 OB 语法、焦点灰 `--ui-border-focus-color`；"确定"= mod-cta |
| 模态 | 控件同弹层语法；三个模态框体通用规则按 OB `.modal`（24 / 16 / 标题 20·600 / 去线 / 遮罩色；宽度与 `min-width` 不搬；去 mac.css 1px 模糊） |

## 4. 范围与非目标

**范围**：上表全部；顺手修复 `a:hover` 漏入网格、暗色打印块守卫；`dev/color-mapping.md` 与 `TODO.md` 记账。

**非目标**：右键菜单；加行/加列按钮（Typora 无 DOM，CSS 造不出，记边界）；光标格标记（推迟）；模态宽度 / 居中几何；`.btn-primary` / `.btn-default` 在 `.modal` 之外的实例（megamenu 等）；`#ty-tooltip` 提示气泡（已主题化）。

## 5. 详细设计

### 5.1 本体

```css
/* 外距挪到 figure、表格归零：前段 16 与 figure 20 塌陷成 20（= OB）；
   figure 贴表格居中，为工具条提供等宽包含块；宽表仍在 figure 内横向滚动 */
#write figure.table-figure { margin: 20px auto; width: fit-content; max-width: 100%; position: relative; }
#write figure.table-figure > table:not(.md-reset) { margin: 0; }
#write th:not(.md-reset), #write td:not(.md-reset) { min-width: 6ch; }   /* 压 table.md-table td{min-width:32px} */
```

- 选择器用 `table-figure`，编辑器（`md-table-fig table-figure`）与导出（仅 `table-figure`）两态都命中。
- `6ch` 落地前在 Obsidian 实机量一次空 td 的 `offsetWidth`，以实测为准（两边均 border-box，但字形不同）。
- 现有 `#write table:not(.md-reset){margin:20px auto}` 的外距改为 `0`（编辑器与导出两态表格都包在 `figure.table-figure` 里，间距统一由 figure 承担）；`width:auto`、六值、阴影、守卫不动。

### 5.2 把手与拖动态

```css
/* 把手：只改 CSS 维度，JS 设的另一维不动 */
#typora-table-row-tracker .typora-table-drag-area { width: 14px; left: -14px; border-radius: 5px 0 0 5px; }
#typora-table-col-tracker .typora-table-drag-area { height: 14px; top: -14px;  border-radius: 5px 5px 0 0; }
.typora-table-drag-area { opacity: 0; background: transparent; cursor: grab; }
.typora-table-drag-area:hover { opacity: 1; }
.typora-table-drag-area::before { content: ""; position: absolute; inset: 0; margin: auto; width: 6px; height: 10px;
  background: radial-gradient(circle, var(--text-muted) 1px, transparent 1.5px) 0 0 / 4px 4px; /* 两列三行 2px 点阵 */ }
.typora-table-drag-area:active::before { background-image: radial-gradient(circle, #fff 1px, transparent 1.5px); }
.typora-table-drag-area:active { background: var(--interactive-accent); box-shadow: 0 0 0 2px var(--interactive-accent); cursor: grabbing; /* 点改白 */ }
#typora-table-row-tracker, #typora-table-col-tracker { cursor: auto; }   /* 压出厂 ns-/ew-resize */

/* 拖动态：同一个类按祖先区分 */
#write .typora-on-moving td, #write .typora-on-moving th,
#write td.typora-on-moving, #write th.typora-on-moving { color: var(--text-muted); background: var(--table-drag-src-bg); opacity: 1; }
.typora-table-tracker .typora-on-moving td, .typora-table-tracker .typora-on-moving th,
.typora-table-tracker td.typora-on-moving, .typora-table-tracker th.typora-on-moving
  { color: #fff; background: var(--interactive-accent); opacity: 1; padding: 4px 10px; }
.typora-table-tracker td.typora-on-moving, .typora-table-tracker .typora-on-moving td { font-size: 15px; }   /* 与表内 td 同（th 16px 由继承得到） */

/* 落点：JS 已把 marker 拉到整表宽/高 */
.typora-table-insert-marker .fa { display: none; }
#typora-table-row-insert-marker::before { content: ""; position: absolute; left: 0; right: 0; top: -1px; height: 2px; background: var(--interactive-accent); }
#typora-table-col-insert-marker::before { /* 同理竖线 */ }
```

- `--table-drag-src-bg` = accent 10% 预混（亮 / 暗各一），记 color-mapping。
- 幽灵表格在 body 级、吃不到 `#write` 皮肤，故补 padding / 字号使其与表内同尺寸；JS 给了列宽与行高。

### 5.3 工具条

```css
#write figure.table-figure > .ty-table-edit {
  width: auto !important;      /* 例外：压 JS 内联宽度（figure 宽 + 10），注释写明 */
  left: 0; right: 0; margin-left: 0;
  transform: translateY(-2px); /* 内联 margin-top:-H 保留，另留 2px 缝 */
  background: transparent; border: 0;
  display: flex; align-items: center; gap: 2px;
}
.ty-table-edit .right-th-button { float: none; margin-left: auto; }
.ty-table-edit .btn-group .btn + .btn { margin-left: 0; }
.ty-table-edit button { padding: 4px 6px; border: 0; border-radius: 5px; background: transparent; box-shadow: none; color: var(--text-muted); line-height: 1; }
.ty-table-edit .ty-icon { font-size: 16px; line-height: 1; }
.ty-table-edit button:hover { background: var(--item-hover-bg-color); }
.ty-table-edit button.active { color: var(--primary-color); background: var(--suggest-active-bg); box-shadow: none; }
.ty-table-edit button:focus { outline: 0; }
.md-resize-table-th .popover { margin-left: 0; }   /* 弹层对齐网格按钮左缘 */
```

- 按钮 24px 高；间距 20px 后条顶越过前块盒底 4px，图标墨迹离前块盒底 4px，不碰文字。
- Windows 的 `.md-table-more`（带文字）随 flex 排在垃圾桶旁，验收在 VM 尾项。

### 5.4 选格弹层

```css
.md-table-resize-popover { background: var(--menu-bg-color); border: 1px solid var(--ui-border-color); border-radius: 7px; box-shadow: var(--shadow-sm); }
.md-grid-board a { border: 1px solid var(--ui-border-color); border-radius: 2px; background: transparent; opacity: 1; transition: none; }
.md-grid-board a:hover { opacity: 1; }                                   /* (0,2,1) 压主题 a:hover 的 0.8 */
.md-grid-board tr[row='1'] { background: transparent; }                  /* 去整行 #dcdcdc */
.md-grid-board .md-grid-ext { background: var(--grid-current-bg); }      /* 文字色 ≈25% 预混 */
.md-grid-board tr[row='1'] .md-grid-ext { background: var(--grid-current-bg-strong); }   /* ≈40% */
.md-grid-board a.md-active, .md-grid-board a:hover { background: var(--suggest-active-bg); border-color: var(--primary-color); }
.md-grid-board tr[row='1'] a.md-active, .md-grid-board tr[row='1'] a:hover { background: var(--grid-select-bg-strong); }   /* accent ≈30% */
.md-grid-board-wrap .popover-title { border-top: 1px solid var(--ui-border-color); color: var(--text-muted); }
.md-grid-board-wrap input { border: 1px solid var(--ui-border-color); border-radius: 7px; background: var(--bg-color); height: 22px; padding: 0 4px; color: var(--text-color); }
.md-grid-board-wrap input:focus { border-color: var(--ui-border-focus-color); }   /* (0,2,1) 压 input:focus */
#md-resize-grid { background: var(--interactive-accent); color: #fff; border: 0; border-radius: 7px; height: 22px; padding: 0 10px; font-size: 12px; }
```

- 暗色覆盖：边框 `--dark-border-color`，三个网格 token 与 `--table-drag-src-bg` 各给暗值。
- 出厂 `display:none` / 入焦 `.show()` / 悬停 `.hide()` 行为不碰；左右对齐向"x"的出厂规则保留。

### 5.5 模态

```css
.modal-content { border-radius: 24px; padding: 16px; border: 1px solid var(--ui-border-color); box-shadow: var(--shadow-lg); }
.modal-header, .modal-footer { border: 0; }
.modal-title { font-size: 20px; font-weight: 600; }
.modal-backdrop.in { background: rgba(220,220,220,.4); backdrop-filter: none; -webkit-backdrop-filter: none; }
/* 暗：.modal-content 背景 --dark-panel-bg、边 --dark-border-color；遮罩 rgba(10,10,10,.4)；Windows .unibody-window .modal-backdrop 同步 */

#table-insert-dialog .input-group { display: flex; align-items: center; }
#table-insert-dialog .input-group-addon { background: transparent; border: 0; color: var(--text-muted); padding: 0 8px 0 0; }
#table-insert-dialog .form-control { height: 30px; padding: 4px 8px; font-size: 13px; border: 1px solid var(--ui-border-color); border-radius: 7px; background: var(--bg-color); box-shadow: none; color: var(--text-color); }
#table-insert-dialog .form-control:focus { border-color: var(--ui-border-focus-color); box-shadow: none; }
.modal .btn-default { background: #efefef; border: 0; border-radius: 7px; height: 30px; padding: 4px 12px; font-size: 13px; color: var(--text-color); }
.modal .btn-primary { background: var(--interactive-accent); border: 0; border-radius: 7px; height: 30px; padding: 4px 12px; font-size: 13px; color: #fff; }
/* hover：btn-default 走 --item-hover-bg-color 叠层；btn-primary 走现有深一档；暗 btn-default 底 #2b2b2b */
```

- 宽度 300px、`top:0`、居中等 mac.css 几何不搬。
- 主题现有 `.modal-header{border-bottom:1px solid #eee}` / `.modal-footer{border-top…}` 及暗覆盖删除。

### 5.6 顺手修复

- 暗色 `@media print` 三条表格规则补 `:not(.md-reset)`。
- `a:hover` 漏入网格（5.4 已含）。

## 6. 验证计划

1. **WebKit 离屏 harness**（`wk-snap.swift`，亮暗各一，按 index.html 加载顺序）：
   - 本体：h→表 / 表→段 / 段→表 三种前件均 20px；空格宽 = Obsidian 实测；宽表在 figure 内滚动。
   - 工具条：条宽 = 表宽、条底距表顶 2px、按钮 24 高、三态色；2 行小表与满宽表两种。
   - 弹层：六态（空 / 当前 / 新选 × 正文行 / 表头行）computed 对表；输入框入焦色；确定按钮尺寸。
   - 把手与拖动态：手工构造三种静态 DOM（tracker 显形、原位 + 幽灵、落点线）量位置与色。
   - 模态：index.html 静态 DOM 量圆角 / 内距 / 标题 / 按钮 / 输入框。
   - 输出 Obsidian 截图 vs Typora 的并排合成图。
2. **三路同步**后用户实机（亮暗）：表格入焦、hover、切对齐、弹层悬停→输入→确定、拖一次行一次列、三个对话框（插入表格 / 删除文件确认 / 图片建文件夹确认）。
3. **导出** HTML / PDF 快速抽查表格页（居中、20px、无控件残留）；完整四路并入发布前门。
4. **Windows VM 尾项**追加：工具条"更多"按钮、三个模态遮罩、把手。

## 7. 边界情况

- 加行/加列按钮：Typora 无 DOM，不可造；记 `TODO.md` 边界。
- 把手显形依赖鼠标先进入单元格（Typora 触发条件），与 OB 同为悬停才见。
- 弹层悬在表格左上角之上（与出厂同，菜单覆盖内容）。
- 小表（两列 6ch）工具条内容宽于表格时，条按 `min-width: max-content` 右溢，不收缩按钮。
- 极窄表 + 列把手：把手宽 = 列宽，grip 点阵居中，列宽 < 12px 时点阵被裁（6ch 下限使其不发生）。
- 幽灵幅面由 JS 内联宽高决定，CSS 只补内距与色。

## 8. 涉及文件清单

- `blue-topaz.css`：第 12 节 Table（figure / 最小宽）、第 13 节 Table edit UI（工具条 / 弹层 / 把手 / 拖动态）、模态节（`.modal-content` 等）、`.btn-*` 限 `.modal`。
- `blue-topaz-dark.css`：对应节暗值、打印块守卫。
- `dev/color-mapping.md`：`--grid-current-bg`、`--grid-current-bg-strong`、`--grid-select-bg-strong`、`--table-drag-src-bg`。
- `TODO.md`：光标格标记推迟项、不搬清单、边界、导出四路与 Windows 尾项追加。
- 提交按面拆：本体 / 把手与拖动 / 工具条 / 弹层 / 模态 / 修复，Conventional Commits 带 body。
