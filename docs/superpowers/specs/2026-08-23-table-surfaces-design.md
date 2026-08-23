# 表格五面对齐 — 设计文档

本体、拖拽把手、工具条、选格弹层、模态。

- 日期：2026-08-23
- 状态：已确认，待转实现计划
- 分支：`release/1.2.0`。在本 worktree 内直接实施，不另建 worktree。
- 范围文件：`blue-topaz.css`、`blue-topaz-dark.css`、`dev/color-mapping.md`、`TODO.md`（主仓软链，只记账）

## 1. 背景与目标

表格本体在 7 月已按 Obsidian Blue Topaz 移植过三轮。Typora 专属的表格控件没有跟上：入焦工具条、行列选格弹层、插入表格模态、行列拖拽把手仍是出厂 Bootstrap 形态，配色是硬编码的浅色字面量。暗色下尤其突兀：深色面板里一块浅灰网格，Bootstrap 蓝按钮，带内阴影的方框当前对齐态。用户要求整体审视本体与控件，与 Obsidian 观感一致、设置合理，而不是打补丁。

目标有三：

1. 本体按 Obsidian 实测逐值复核，修正剩余差异。
2. Typora 独有控件按 Obsidian 最近亲缘物的实测值定稿，落到本主题已有 token；形态可以变。
3. 三个 Bootstrap 模态的框体一并按 Obsidian `.modal` 对齐。

## 2. 调研结论

两路调研支撑本文：Typora 侧读 main.js 模板与出厂 CSS 全量；Obsidian 侧读 Blue Topaz 主题规则，并在用户实机读 computed style、截图。

### 2.1 本体对表

| 项 | Obsidian 阅读视图 | Typora 现状 | 结论 |
|---|---|---|---|
| 宽度、居中 | shrink-to-fit，`margin: 20px auto` | 同 | 一致 |
| 上下间距 | 20px：前段 16 与表 20 塌陷 | 39.2px：figure 出厂 1.2em 外距加表 20，figure 是 BFC，两者不塌陷 | 修 |
| th/td 内距、顶对齐、边框 | `4px 10px`、top、none | 同 | 一致 |
| td 字号、th 字重、th 底色 | 15px、600、accent 10% | 同 | 一致 |
| 斑马纹与 tr/td/th hover | 六值 | 逐字节同 | 一致 |
| 阴影、行高 | `1px 1px 0 rgba(0,0,0,.1)`、1.3 | 同 | 一致 |
| 单元格最小宽 | `6ch`（核心 app.css） | `32px`（`table.md-table td`） | 修 |
| 悬停 resize 手柄 | BT `table:hover{overflow:hidden;resize:both!important}` | 无 | 不搬。它只改视图不存数据，`overflow:hidden` 会裁光标与阴影，WebKit 对 table 的 resize 不可靠 |
| 单元格 `text-overflow:ellipsis; overflow:hidden` | 有；`max-width:none` 下无可见效果 | 无 | 不搬，会裁光标 |
| `white-space` | `break-spaces` | `pre-wrap` | 不动，只差行尾空格的折行 |

环境注记：用户库的 Blue Topaz 为 2026081501，Obsidian 1.13.7，Style Settings 未装，所见为无 body class 的基线。表格六值与 v1.0 移植逐字节相同，上游没有漂移。

### 2.2 编辑态

Obsidian Live Preview 不标记光标所在格。`is-selected` 只用于拖选多格：accent 10% 底、2px accent 描边、4px 圆角。行列把手 `.table-row-drag-handle` / `.table-col-drag-handle` 贴在表格左缘、上缘外侧，厚 14px（16 减 2px 描边），grip 图标，`--text-faint` 色，5px 圆角。把手默认 `opacity:0`，悬停到自身才显形；按下时 accent 实底、白色图标、2px accent 描边，光标 `grab` 变 `grabbing`。落点 `.table-drag-target` 是 2px accent 线。幽灵 `.table-col-drag-ghost` 是 accent 实底白字。

Typora 不给光标格加类。鼠标进入任一 th/td 时，body 级的 `#typora-table-row-tracker` 定位到该行左上，`#typora-table-col-tracker` 定位到该列左上。两者内部的 `.typora-table-drag-area` 是把手：12×8，`left:-6px` 或 `top:-4px`，`opacity:0`；另一维由 JS 设为行高或列宽。拖动开始时，JS 先给被拖行列加 `typora-on-moving`（出厂 `color:transparent; background:#c7c5c5; opacity:.5`），再克隆它做跟随鼠标的幽灵，所以幽灵带同一个类，也是没字的灰条。落点标记 `#typora-table-row-insert-marker` / `#typora-table-col-insert-marker` 被 JS 拉到整表宽或高，内含两枚 `fa-caret`。Typora 没有加行、加列按钮的 DOM。

### 2.3 工具条 `.ty-table-edit`

工具条插在 figure 内、table 之前，`position:absolute`。JS 写两条内联样式：`width` 等于 figure 宽加 10px，`margin-top` 等于负的自身高度。五枚按钮用 typora-icon 字体图标，12px。macOS 没有"更多"按钮；Windows 有，且带文字。当前对齐态 `.active` 取 `--item-hover-bg-color`，叠 Bootstrap 内阴影与 #adadad 边。

Obsidian 没有工具条。最近亲缘物有两个：Live Preview 表格边缘的控件（贴着表格几何，不用时不见，faint 到 accent），以及 `.clickable-icon`（`--icon-s` 16px 图标，内距 4px/6px，7px 圆角，hover 6.7%）。

### 2.4 选格弹层 `.md-table-resize-popover`

弹层挂在 `.md-resize-table-th` 内，包含块是工具条。宽 134px，Bootstrap 圆角 6px 与阴影。网格 10 行 6 列，每格 13px，`border-spacing:2px`。三态全是硬编码：`td.md-grid-ext` 标表格当前尺寸，#999，表头行 #555；`a.md-active` 与 `a:hover` 标新选尺寸，悬停与输入共用，#c8caf4，表头行 #94a7b9；`tr[row='1']` 整行 #dcdcdc。两个输入框没有 class，焦点取出厂 `input:focus` 的 `--primary-color`。"确定"按钮 `#md-resize-grid` 取 `--primary-color`，输入框入焦才显示。"x" 是模板裸文本。网格里的 `<a>` 是弹层中唯一不带 `md-reset` 的元素，主题的 `a:hover{opacity:.8; transition}` 漏了进去。

### 2.5 模态

`index.html` 有三个 Bootstrap 模态共用一套框体：`#table-insert-dialog`、`#image-create-folder-confirm`、全局确认框 `#common-dialog`。Obsidian `.modal`：24px 圆角，16px 内距，标题 20px/600，无分隔线，遮罩 rgba(220,220,220,.4) 与 rgba(10,10,10,.4)，`min-width:560px`。Obsidian 输入框：30px 高，内距 `4px 8px`，13px，1px 边 #ddd 或 #343434，7px 圆角，焦点边框取灰色 `--background-modifier-border-focus`。`button` 底 #efefef 或 #2b2b2b，7px 圆角，30px 高；`button.mod-cta` accent 底白字。

### 2.6 其他

- macOS 的表格右键是原生 NSMenu。in-DOM 的 `#table-menu` 只在 Windows/Linux 可达。右键菜单出局。
- 导出 HTML 的表格标记去掉了 `.md-table`、`.td-span` 与 cid；`figure.table-figure` 与 `#write table/th/td` 保留。
- 暗色 `@media print` 里三条表格规则缺 `:not(.md-reset)` 守卫。

## 3. 决策记录

以下决策均经用户在三轮 grilling 中确认。

| 决策点 | 结论 |
|---|---|
| 排期 | 工具条、弹层、插入模态从"弹层/菜单/footer 专项"拆出，随本专项做；菜单与 footer 留后续 |
| 定值依据 | Typora 独有控件按 Obsidian 最近亲缘物实测定值，落已有 token，形态可变；尺寸 token 取 Obsidian 值（面板 7px、元素 5px），不取本主题现行的 4px 族 |
| 覆盖面 | 本体阅读态与编辑态、工具条、弹层、插入模态连同三个模态框体、导出看点；右键菜单出局 |
| 本体 | 整体重测；修间距 20px 与最小宽 6ch；不搬 BT resize 手柄与 ellipsis/overflow |
| 光标格 | 不加标记；记入 TODO，留到下个大版本与模式体系一起议 |
| 把手 | 悬停显形：14px 贴外缘，grip，faint 色，5px 圆角，按下 accent |
| 拖动态 | 原位 accent 10% 淡底加 `--text-muted` 文字；幽灵 accent 实底白字；落点 2px accent 线，隐藏三角 |
| 工具条 | 贴上缘横排，无容器，宽随表；图标 16px `--text-muted`；hover 6.7% 圆底 5px；当前对齐 accent 图标加 accent 15% 底 |
| 弹层 | 面板 `--menu-bg-color`、1px 边、7px 圆角、`--shadow-sm`；网格三态：空透明，当前中性实底，新选 accent 15% 加 accent 边，表头行同态各加深一档；输入框走 Obsidian 语法，焦点灰 `--ui-border-focus-color`；"确定"走 mod-cta |
| 模态 | 控件与弹层同语法；三个模态框体用通用规则按 Obsidian `.modal`：24px 圆角、16px 内距、标题 20px/600、去分隔线、遮罩色；不搬宽度与 `min-width`；去掉 mac.css 的 1px 模糊 |

## 4. 范围与非目标

范围：第 3 节全部；顺手修复 `a:hover` 漏入网格与暗色打印块守卫；在 `dev/color-mapping.md` 与 `TODO.md` 记账。

非目标：右键菜单；加行、加列按钮（Typora 无 DOM，CSS 造不出，记为边界）；光标格标记（推迟）；模态的宽度与居中几何；`.modal` 之外的 `.btn-primary` / `.btn-default`（如 megamenu）；`#ty-tooltip` 提示气泡（已主题化）。

## 5. 详细设计

### 5.1 本体

```css
/* 外距挪到 figure，表格归零：前段 16 与 figure 20 塌陷成 20，等于 Obsidian。
   figure 贴着表格收缩居中，于是 figure 宽就是表格宽 —— 这正是 main.js 量来
   给工具条定宽的那个值；宽表仍在 figure 内横向滚动。figure 保持不定位：它是
   滚动容器，滚动容器会裁切，以它作包含块的东西会跟着被裁掉。 */
#write figure.table-figure { margin: 20px auto; width: fit-content; max-width: 100%; }
#write figure.table-figure > table:not(.md-reset) { margin: 0; }
#write th:not(.md-reset), #write td:not(.md-reset) { min-width: 6ch; }   /* 压出厂 table.md-table td{min-width:32px} */
```

- 选择器用 `table-figure`。编辑器里是 `md-table-fig table-figure`，导出里只有 `table-figure`，两态都命中。
- `6ch` 落地前在 Obsidian 实机量一次空 td 的 `offsetWidth`，以实测为准。两边都是 border-box，但字形不同。
- 现有 `#write table:not(.md-reset){margin:20px auto}` 的外距**保留**：编辑器与导出的表格都包在 `figure.table-figure` 里，归零交给上面那条 figure 作用域的规则，间距统一由 figure 承担；泛规则的 `20px auto` 留给没有 figure 的表格 —— 原始 HTML 块会把裸 `<table>` 直接落进 `#write`，那种表格仍要靠它居中和留白。`width:auto`、六值、阴影、守卫不动。

### 5.2 把手与拖动态

```css
/* 把手：只改 CSS 这一维，JS 设的另一维不动 */
#typora-table-row-tracker .typora-table-drag-area { width: 14px; left: -14px; border-radius: 5px 0 0 5px; }
#typora-table-col-tracker .typora-table-drag-area { height: 14px; top: -14px; border-radius: 5px 5px 0 0; }
.typora-table-drag-area { opacity: 0; background: transparent; cursor: grab; }
.typora-table-drag-area:hover { opacity: 1; }
.typora-table-drag-area::before {
  content: ""; position: absolute; inset: 0; margin: auto; width: 8px; height: 12px;   /* 必须是 4px 瓦片的整数倍：2x3 */
  background: radial-gradient(circle, var(--text-muted) 1px, transparent 1.5px) 0 0 / 4px 4px;   /* 两列三行 2px 点阵 */
}
.typora-table-drag-area:active { background: var(--interactive-accent); box-shadow: 0 0 0 2px var(--interactive-accent); cursor: grabbing; }
.typora-table-drag-area:active::before { background-image: radial-gradient(circle, #fff 1px, transparent 1.5px); }
#typora-table-row-tracker, #typora-table-col-tracker { cursor: auto; }   /* 压出厂 ns-resize / ew-resize */

/* 拖动态：同一个类按祖先区分 */
#write .typora-on-moving td, #write .typora-on-moving th,
#write td.typora-on-moving, #write th.typora-on-moving { color: var(--text-muted); background: var(--table-drag-src-bg); opacity: 1; }
.typora-table-tracker .typora-on-moving td, .typora-table-tracker .typora-on-moving th,
.typora-table-tracker td.typora-on-moving, .typora-table-tracker th.typora-on-moving
  { color: #fff; background: var(--interactive-accent); opacity: 1; padding: 4px 10px; }
.typora-table-tracker td.typora-on-moving, .typora-table-tracker .typora-on-moving td { font-size: 15px; }   /* 与表内 td 同；th 的 16px 由继承得到 */

/* 落点：JS 已把 marker 拉到整表宽或高 */
.typora-table-insert-marker .fa { display: none; }
#typora-table-row-insert-marker::before { content: ""; position: absolute; left: 0; right: 0; top: -1px; height: 2px; background: var(--interactive-accent); }
#typora-table-col-insert-marker::before { content: ""; position: absolute; top: 0; bottom: 0; left: -1px; width: 2px; background: var(--interactive-accent); }
```

- `--table-drag-src-bg` 是 accent 10% 的预混值，亮暗各一，记入 color-mapping。
- 幽灵表格在 body 级，吃不到 `#write` 皮肤，所以补内距与字号。JS 给了列宽与行高。

### 5.3 工具条

```css
#write figure.table-figure > .ty-table-edit {
  /* JS 写的内联宽度（figure 宽加 10px）原样留用，不加 !important：figure 已贴着
     表格收缩，所以那个宽度就是「表格宽 + 10」。条是 figure 的头一个孩子，静态
     位置就在 figure 内容原点（figure 定不定位都一样），10px 于是是纯溢出，左右
     各 5px。下面这三条把溢出摊成对称内距，内容盒正好落在表格两缘：第一个按钮
     贴左缘，垃圾桶贴右缘。-5px 只需压出厂 .ty-table-edit{margin-left:-4px}
     (0,1,0)，本选择器 (1,1,1) 足够。 */
  margin-left: -5px; padding: 0 5px; box-sizing: border-box;
  min-width: max-content;
  transform: translateY(-2px); /* 内联 margin-top:-H 保留，它把条顶到表格上方；再留 2px 缝 */
  background: transparent; border: 0;
  display: flex; align-items: center; gap: 2px;
}
.ty-table-edit .right-th-button { float: none; margin-left: auto; }
#write .ty-table-edit .btn-group > .btn { border-radius: 5px; }   /* (1,3,0) 拆掉 Bootstrap 把三个对齐钮焊成一颗药丸的圆角规则 (0,4,0)/(0,5,0) */
.ty-table-edit .btn-group .btn + .btn { margin-left: 2px; }       /* 与条上的 flex gap 同值 */
.ty-table-edit button { padding: 4px 6px; border: 0; border-radius: 5px; background: transparent; box-shadow: none; color: var(--text-muted); line-height: 1; }
.ty-table-edit .ty-icon { font-size: 16px; line-height: 1; }
.ty-table-edit button:hover { background: var(--item-hover-bg-color); }
.ty-table-edit button.active { color: var(--primary-color); background: var(--suggest-active-bg); box-shadow: none; }
.ty-table-edit button:focus { outline: 0; }
.md-resize-table-th .popover { margin-left: 0; }   /* 弹层对齐网格按钮左缘 */
```

- 按钮 24px 高。间距修到 20px 后，条顶越过前一块的盒底 4px；图标墨迹 16px 居中，离前块盒底还有 4px，不碰文字。
- 条的包含块是 `#write`（出厂的），不是 figure。figure 是滚动容器（出厂 `figure{overflow-x:auto}`，单轴 visible 会算成 auto），一旦让它当包含块，悬在它内容盒上方一整条高度的工具条就落进裁切区里没了；让它不定位，条的包含块是 figure 的祖先，裁切够不着它 —— 宽表照旧在 figure 内滚动，条完整，垃圾桶落在 figure 可见的右缘。
- Windows 的 `.md-table-more` 带文字，随 flex 排在垃圾桶旁。验收放在 Windows VM 尾项。

### 5.4 选格弹层

```css
.md-table-resize-popover { background: var(--menu-bg-color); border: 1px solid var(--ui-border-color); border-radius: 7px; box-shadow: var(--shadow-sm); }
.md-grid-board a { border: 1px solid var(--ui-border-color); border-radius: 2px; background: transparent; opacity: 1; transition: none; }
.md-grid-board a:hover { opacity: 1; }                                   /* (0,2,1) 压主题 a:hover 的 0.8 */
.md-grid-board tr[row='1'] { background: transparent; }                  /* 去掉整行 #dcdcdc */
.md-grid-board .md-grid-ext { background: var(--grid-current-bg); }      /* 文字色约 25% 预混 */
.md-grid-board tr[row='1'] .md-grid-ext { background: var(--grid-current-bg-strong); }   /* 约 40% */
.md-grid-board a.md-active, .md-grid-board a:hover { background: var(--suggest-active-bg); border-color: var(--primary-color); }
.md-grid-board tr[row='1'] a.md-active, .md-grid-board tr[row='1'] a:hover { background: var(--grid-select-bg-strong); }   /* accent 约 30% */
.md-resize-table-th .popover { width: 144px; }    /* 压出厂 134px，见下 */
.md-grid-board-wrap { width: auto; }              /* 压出厂 100px，否则网格在加宽后的面板里偏心 */
/* 出厂把这行排成受 text-align 牵引的 inline-block，再靠按钮上的 1ch 外距分隔，
   "确定"一现身就顶出面板右缘。改成居中 flex 行，间距全交给一个 4px gap；
   Bootstrap .popover-title 继承来的 14px 左右内距去掉，让 wrap 自己的 1ch 成为
   这一行唯一的横向内缩 —— 面板宽度正是按这个量出来的。 */
.md-grid-board-wrap .popover-title { border-top: 1px solid var(--ui-border-color); color: var(--text-muted); display: flex; align-items: center; justify-content: center; gap: 4px; padding: 8px 0; }
.md-grid-board-wrap input { border: 1px solid var(--ui-border-color); border-radius: 7px; background: var(--bg-color); height: 22px; width: 4ch; padding: 0 4px; color: var(--text-color); }
.md-grid-board-wrap input:focus { border-color: var(--ui-border-focus-color); }   /* (0,2,1) 压出厂 input:focus */
#md-resize-grid { background: var(--interactive-accent); color: #fff; border: 0; border-radius: 7px; height: 22px; margin: 0; padding: 0 8px; font-size: 12px; }
```

- 暗色覆盖：三个网格 token 与 `--table-drag-src-bg` 各给暗值。边框不必单列 —— 亮色那条读的是 `--ui-border-color`，暗色 `:root` 已把它别名到 `--dark-border-color`。
- 面板**定宽**，不随内容收缩："确定"随输入框入焦显隐，宽度会跳的面板比略宽的面板更糟。所以按最宽态量：确定可见、两格都填两位数（出厂 `max` / `maxlength` 的上限）。max-content 克隆实测（亮暗一致，Inter 14px，1ch = 8.67px）：标题行内容 121.72 + wrap 左右各 1ch 17.34 + 面板边框 2 + 面板内距 2 = 143.03 → **144px**。出厂 134px 挂在 `.md-resize-table-th .popover` (0,2,0)，覆盖必须同选择器、靠加载顺序取胜。
- 输入框 `4ch` 而非出厂 `3ch`：左右各 4px 内距吃掉内容盒后，两位数会被切掉 3px。
- 出厂行为不碰："确定"默认 `display:none`，输入框入焦时 `.show()`，悬停网格时 `.hide()`。两个输入框向"x"对齐的出厂规则保留。

### 5.5 模态

```css
.modal-content { border-radius: 24px; padding: 16px; border: 1px solid var(--ui-border-color); box-shadow: var(--shadow-md); }
.modal-header, .modal-footer { border: 0; }
.modal-title { font-size: 20px; font-weight: 600; }
/* opacity:1 不可省：出厂 bootstrap 的 .modal-backdrop.in{opacity:.5} 会把上面这个
   0.4 再折一半成 0.2。mac.css 自带一条 opacity:1，所以 macOS 上它是空操作，真正
   受益的是不加载 mac.css 的 Windows / Linux。 */
.modal-backdrop.in { background: rgba(220,220,220,.4); opacity: 1; backdrop-filter: none; -webkit-backdrop-filter: none; }
/* 暗色：.modal-content 底 --dark-panel-bg，边 --dark-border-color；遮罩 rgba(10,10,10,.4)；Windows 的 .unibody-window .modal-backdrop 同步改色 */

#table-insert-dialog .input-group { display: flex; align-items: center; }
#table-insert-dialog .input-group-addon { background: transparent; border: 0; color: var(--text-muted); padding: 0 8px 0 0; }
#table-insert-dialog .form-control { height: 30px; padding: 4px 8px; font-size: 13px; border: 1px solid var(--ui-border-color); border-radius: 7px; background: var(--bg-color); box-shadow: none; color: var(--text-color); }
#table-insert-dialog .form-control:focus { border-color: var(--ui-border-focus-color); box-shadow: none; }
.modal .btn-default { background: #efefef; border: 0; border-radius: 7px; height: 30px; padding: 4px 12px; font-size: 13px; color: var(--text-color); }
.modal .btn-primary { background: var(--interactive-accent); border: 0; border-radius: 7px; height: 30px; padding: 4px 12px; font-size: 13px; color: #fff; }
/* hover：btn-default 取 --item-hover-bg-color 的预混值（亮 #dfdfdf / 暗 #393939，见下）；btn-primary 沿用现有的深一档；暗色 btn-default 底 #2b2b2b */
```

- mac.css 的宽度 300px、`top:0` 与居中不搬。
- 删除主题现有的 `.modal-header{border-bottom:1px solid #eee}`、`.modal-footer{border-top:…}` 及其暗覆盖。
- 主题只有 `--shadow-sm` / `--shadow-md` 两档，没有 `--shadow-lg`；模态用 `--shadow-md`。
- `btn-default:hover` 用预混值而非叠一层半透明：按钮本身不透明，透明洗色在上面会读成第二种颜色而不是同色深一档。亮 `#efefef` → `#dfdfdf`（239 − 239 × 0.067），暗 `#2b2b2b` → `#393939`（43 + 212 × 0.067）。

### 5.6 顺手修复

- 暗色 `@media print` 的三条表格规则补 `:not(.md-reset)`。
- `a:hover` 漏入网格，5.4 已处理。

## 6. 验证计划

1. WebKit 离屏 harness（`wk-snap.swift`），亮暗各一，按 index.html 的加载顺序：
   - 本体：标题、表格、段落三种前件下的间距均为 20px；空格宽等于 Obsidian 实测；宽表在 figure 内滚动。
   - 工具条：条宽等于表宽；条底距表顶 2px；按钮 24px 高；三态色。两行小表与满宽表各测一次。
   - 弹层：六态（空、当前、新选，各乘正文行、表头行）逐格读 computed；输入框入焦色；"确定"按钮尺寸。
   - 把手与拖动态：手工构造三种静态 DOM，即 tracker 显形、原位加幽灵、落点线，量位置与色。
   - 模态：用 index.html 的静态 DOM 量圆角、内距、标题、按钮、输入框。
   - 输出 Obsidian 截图与 Typora 的并排合成图。
2. 三路同步后用户实机验收，亮暗各一：表格入焦、hover、切换对齐、弹层从悬停到输入到确定、拖一次行与一次列、三个对话框（插入表格、删除文件确认、图片建文件夹确认）。
3. 导出 HTML 与 PDF，抽查表格页：居中、20px、无控件残留。完整四路并入发布前门。
4. Windows VM 尾项追加：工具条"更多"按钮、三个模态的遮罩、把手。

## 7. 边界情况

- 加行、加列按钮：Typora 无 DOM，造不出。记入 `TODO.md` 边界。
- 把手显形要先让鼠标进入单元格，这是 Typora 的触发条件；Obsidian 也是悬停才见。
- 弹层悬在表格左上角之上，与出厂相同；菜单覆盖内容。
- 两列 6ch 的小表比工具条内容窄时，条按 `min-width: max-content` 向右溢出，不收缩按钮。
- 列把手宽等于列宽，grip 点阵居中；列宽小于 12px 时点阵被裁。6ch 下限使这种情况不会发生。
- 幽灵的幅面由 JS 内联宽高决定，CSS 只补内距与色。

## 8. 涉及文件清单

- `blue-topaz.css`：第 12 节 Table（figure、最小宽）；第 13 节 Table edit UI（工具条、弹层、把手、拖动态）；模态节（`.modal-content` 等）；`.btn-*` 限定在 `.modal` 内。
- `blue-topaz-dark.css`：对应节的暗值；打印块守卫。
- `dev/color-mapping.md`：`--grid-current-bg`、`--grid-current-bg-strong`、`--grid-select-bg-strong`、`--table-drag-src-bg`。
- `TODO.md`：光标格标记推迟项、不搬清单、边界、导出四路与 Windows 尾项追加。
- 提交按面拆分：本体、把手与拖动、工具条、弹层、模态、修复。Conventional Commits，带 body。
