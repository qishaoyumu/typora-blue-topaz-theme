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

Obsidian Live Preview 不标记光标所在格。`is-selected` 只用于拖选多格：accent 10% 底（`--table-selection`，半透明叠 `mix-blend-mode`）、2px accent 描边**只画选区外沿**、外沿转角 4px 圆角。行列把手 `.table-row-drag-handle` / `.table-col-drag-handle` 贴在表格左缘、上缘外侧，厚 14px（16 减 2px 描边），`--text-faint` 色，5px 圆角。把手默认 `opacity:0`，悬停到自身才显形；按下时 accent 实底、`--text-on-accent` 图标、`0 0 0 2px` accent 外环，光标 `grab` 变 `grabbing`。

把手图标是**两套**，不是一套：行把手用 lucide `grip-vertical`（2 列 × 3 行），列把手用 `grip-horizontal`（3 列 × 2 行），点阵随所拖的轴转向。16px 基准实测：行 点径 2.333 / 横距 3.5 / 纵距 4.083 / 墨迹 5.83×10.5；列 点径 2.667 / 横距 4.667 / 纵距 4.0 / 墨迹 12×6.67。

落点 `.table-drag-target` 元素本身零厚度，靠 `::after` 的 `inset` 两侧各外扩 `--table-drop-indicator-half-width`（2px），所以**视觉是 4px**、圆角 2px；早先记的 2px 是把半宽当了全宽。

**原版没有拖拽幽灵**：拖动中 `.cm-table-widget.is-dragging` 把所有把手 `display:none`、只留 `:active` 的那一个，被抓的把手本体沿表格边滑动（clamp 在表首尾），源行/列留在原地带选中态。`.table-col-drag-ghost` 那条 CSS 确实存在，但全 asar 没有任何 JS 创建它，是遗留未启用样式，不作数。

Typora 不给光标格加类。鼠标进入任一 th/td 时（事件是 `#write` 上对 `th, td` 的 `mouseenter click` 委托，且守卫 `children("[mdtype]")`，所以裸 HTML 表格永远拿不到把手），body 级的 `#typora-table-row-tracker` 定位到该行左上，`#typora-table-col-tracker` 定位到该列左上。两者内部的 `.typora-table-drag-area` 是把手：12×8，`left:-6px` 或 `top:-4px`，`opacity:0`；另一维由 JS 设为行高或列宽。

拖动开始时 JS 给被拖对象加 `typora-on-moving`（出厂 `color:transparent; background:#c7c5c5; opacity:.5`）——**行拖加在 `<tr>` 上，列拖加在该列每个单元格上**，这一点是两套描边选择器得以互不相犯的依据。随后它把同一段标记**重新 parse**（不是 clone）进 `.typora-table-data-area` 当幽灵；行路径先加类后取 `outerHTML`，列路径相反，所以行幽灵带 `typora-on-moving` 而列幽灵不带。拖动中 `mousemove` 每帧把指针坐标直接写进 tracker 的 `top`（行）/ `left`（列），无 clamp，所以**把手本身已经是 1:1 跟随指针的药丸**，与原版同构。落点标记 `#typora-table-row-insert-marker` / `#typora-table-col-insert-marker` 被 JS 拉到整表宽或高，内含两枚 `fa-caret`。Typora 没有加行、加列按钮的 DOM。

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
| 把手 | 悬停显形：14px 贴外缘，faint 色，5px 圆角，按下 accent。grip **两套方向**：行 2 列 ×3 行，列 3 列 ×2 行 |
| 拖动态 | **藏掉幽灵**（`.typora-table-data-area{display:none}`），只留跟指针滑的药丸；源行/列原位取 Obsidian 选中语汇：accent 10% 底 + 2px accent 外沿描边 + 外沿 4px 圆角，文字 muted（Obsidian `--text-muted`，本主题落 `--ui-muted-color`）；落点 4px accent 线、2px 圆角，隐藏三角 |
| 工具条 | 贴上缘横排，无容器，宽随表；图标 16px muted（同上，`--ui-muted-color`）；hover 6.7% 圆底 5px；当前对齐 accent 图标加 accent 15% 底。上抬 16px 让开列把手带（甲案：无条件上移，不做 `:has()` 门控） |
| More 按钮 | macOS 恢复出厂隐藏（主题此前无意把它复活）；Windows / Linux 不动 |
| 弹层 | 面板 `--menu-bg-color`、1px 边、7px 圆角、`--shadow-sm`；网格三态：空透明，当前中性实底，新选 accent 15% 加 accent 边，表头行同态各加深一档；输入框走 Obsidian 语法，焦点灰 `--ui-border-focus-color`；"确定"走 mod-cta。收紧内距压低总高，网格横向填满面板 |
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
/* 空格兜底：只命中裸空单元格 */
#write td:not(.md-reset):empty::after,
#write th:not(.md-reset):empty::after { content: ""; display: inline-block; }
```

- 选择器用 `table-figure`。编辑器里是 `md-table-fig table-figure`，导出里只有 `table-figure`，两态都命中。
- `6ch` 落地前在 Obsidian 实机量一次空 td 的 `offsetWidth`，以实测为准。两边都是 border-box，但字形不同。
- 现有 `#write table:not(.md-reset){margin:20px auto}` 的外距**保留**：编辑器与导出的表格都包在 `figure.table-figure` 里，归零交给上面那条 figure 作用域的规则，间距统一由 figure 承担；泛规则的 `20px auto` 留给没有 figure 的表格 —— 原始 HTML 块会把裸 `<table>` 直接落进 `#write`，那种表格仍要靠它居中和留白。`width:auto`、六值、阴影、守卫不动。
- **空行不是 Typora 表的问题，两端都不是。** 编辑器里每个单元格都有 `span.td-span`，出厂给它 `display:inline-block; min-height:10px` 和 `:empty:after{content:" "}`，全空行与内容行等高（实测 27.50px）。导出侧虽然确实剔掉了 `.td-span`，但序列化器把空格写成 `<td>&nbsp;</td>`（`main.js` byte 378283 `case o.table_cell: return _(e,n) || "&nbsp;"`，HTML 与 PDF 同一分支），那个 nbsp 自己就撑出行盒 —— 实测有无兜底规则都是 27.50px。**所以这条规则在导出里从来不会命中，也不是导出表格整齐的原因。**
- 真正会塌成 8px 薄条的只有一种形状：**文档里手写或从别处粘贴进来的 HTML 表格**（实测 8.00 → 27.50）。`:empty` 保证只命中它；伪元素落在 `<td>` 上而不是 `contenteditable` 的 span 里，够不着光标，也不与出厂 `:empty:after` 重复。空列无需处理，`min-width:6ch` 已兜底。

### 5.2 把手与拖动态

```css
/* 把手：只改 CSS 这一维，JS 设的另一维不动 */
#typora-table-row-tracker .typora-table-drag-area { width: 14px; left: -14px; border-radius: 5px 0 0 5px; }
#typora-table-col-tracker .typora-table-drag-area { height: 14px; top: -14px; border-radius: 5px 5px 0 0; }
.typora-table-drag-area { opacity: 0; background: transparent; cursor: grab; }
.typora-table-drag-area:hover,
.typora-table-drag-area:active { opacity: 1; }   /* :active 必须一起给，见下 */
.typora-table-drag-area::before {
  content: ""; position: absolute; inset: 0; margin: auto;
  background: radial-gradient(circle, var(--ui-faint-color) 1px, transparent 1.5px) 0 0 / 4px 4px;
}
/* 点阵两套方向，各自都是整数个瓦片 */
#typora-table-row-tracker .typora-table-drag-area::before { width: 8px; height: 12px; }                        /* 2x3 个 4px 瓦片 */
#typora-table-col-tracker .typora-table-drag-area::before { width: 15px; height: 8px; background-size: 5px 4px; }  /* 3x2 个 5x4 瓦片 */
.typora-table-drag-area:active { background: var(--interactive-accent); box-shadow: 0 0 0 2px var(--interactive-accent); cursor: grabbing; }
.typora-table-drag-area:active::before { background-image: radial-gradient(circle, #fff 1px, transparent 1.5px); }
#typora-table-row-tracker, #typora-table-col-tracker { cursor: auto; }   /* 压出厂 ns-resize / ew-resize */

/* 幽灵藏除：必须 display:none */
.typora-table-data-area { display: none; }

/* 源行/列：行拖类在 <tr> 上，列拖类在每个单元格上，两套选择器互斥 */
#write tr.typora-on-moving > td, #write tr.typora-on-moving > th,
#write td.typora-on-moving,      #write th.typora-on-moving
  { position: relative; color: var(--ui-muted-color); opacity: 1; }
#write tr.typora-on-moving > td, #write td.typora-on-moving { background-color: transparent; }   /* 只清 td：th 自己的 accent 底已压过出厂灰 */
/* 描边与淡底都画在 ::before 上（::after 留给 §5.1 的空格兜底） */
#write tr.typora-on-moving > td::before, #write tr.typora-on-moving > th::before,
#write td.typora-on-moving::before,      #write th.typora-on-moving::before
  { content: ""; position: absolute; inset: 0; background: var(--table-drag-src-bg);
    border: 0 solid var(--interactive-accent); pointer-events: none; }
/* 行拖：每格上下边，首末格补左右边与圆角（圆角写长手，单列表两侧都圆） */
#write tr.typora-on-moving > td::before, #write tr.typora-on-moving > th::before { border-top-width: 2px; border-bottom-width: 2px; }
#write tr.typora-on-moving > :first-child::before { border-left-width: 2px; border-top-left-radius: 4px; border-bottom-left-radius: 4px; }
#write tr.typora-on-moving > :last-child::before  { border-right-width: 2px; border-top-right-radius: 4px; border-bottom-right-radius: 4px; }
/* 列拖：同三条转 90° */
#write td.typora-on-moving::before, #write th.typora-on-moving::before { border-left-width: 2px; border-right-width: 2px; }
#write thead th.typora-on-moving::before, #write thead td.typora-on-moving::before { border-top-width: 2px; border-top-left-radius: 4px; border-top-right-radius: 4px; }
#write tbody tr:last-child > td.typora-on-moving::before,
#write tbody tr:last-child > th.typora-on-moving::before { border-bottom-width: 2px; border-bottom-left-radius: 4px; border-bottom-right-radius: 4px; }

/* 落点：JS 已把 marker 拉到整表宽或高 */
.typora-table-insert-marker .fa { display: none; }
#typora-table-row-insert-marker::before,
#typora-table-col-insert-marker::before { content: ""; position: absolute; background: var(--interactive-accent); border-radius: 2px; }
#typora-table-row-insert-marker::before { left: 0; right: 0; top: -2px; height: 4px; }
#typora-table-col-insert-marker::before { top: 0; bottom: 0; left: -2px; width: 4px; }
```

- `--table-drag-src-bg` 改回**半透明** accent 10%（亮 `hsla(207,77%,54%,.1)` / 暗 `hsla(208,64%,49%,.1)`），亮暗各一，记入 color-mapping。它现在画在覆盖层上而不是当单元格底色，所以斑马纹与表头自己的 accent 底必须透出来——这正是原版 `is-selected` 覆盖层的做法；预混不透明版本会把它们盖死。
- 描边不能用真 border：表格 `border-collapse: collapse`，拖动中突然出现的边会把整张网格重排。改用 `::before` 绝对定位覆盖单元格 padding 盒。
- **原版选中层的 `mix-blend-mode`（亮 `darken` / 暗 `lighten`）没有移植**，这里就是普通 alpha 叠加。后果是表头格叠了两层蓝：自身 accent 10% 洗底 + 覆盖层 accent 10%，实测叠出约 19% accent，比正文格明显深一档。观感可接受，属有意简化 —— `mix-blend-mode` 会让覆盖层与斑马纹、表头底色三者互算，在本主题的不透明底色体系里收益不确定，不值得为它引入一个新的混合上下文。记在这里，免得下次被当成 bug 重查一遍。
- 幽灵必须 `display:none`。列路径用 jQuery `.offset()` setter 往那个 div 写绝对页面坐标，任何仍占布局的藏法（`visibility` / `opacity` / `height:0`）都会把 tracker 的框撑到文档另一头，把手跟着跑掉。藏掉之后 tracker 保持空闲时的零尺寸盒，把手位置不变；落点阈值与 marker 尺寸全取自源表格，没有任何代码回读这个 div。
- `:active` 必须和 `:hover` 一起给 `opacity: 1`。指针一旦偏离拖拽轴就离开把手（另一维只有 14px），而指针捕获期间掉的是 `:hover` 不是 `:active`——只挂 `:hover` 时药丸会在拖动中整个消失，只剩一块 accent 色块。
- 落点线的负偏移就是原版的 half-width，所以 4px 线正好骑在 JS 瞄准的那条边上，不会偏 1px。

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
  transform: translateY(-16px); /* 内联 margin-top:-H 保留，它把条顶到表格上方；再抬 16px 让开列把手带 */
  background: transparent; border: 0;
  display: flex; align-items: center; gap: 2px;
}
.ty-table-edit .right-th-button { float: none; margin-left: auto; }
/* macOS 恢复出厂隐藏；连同空壳 span 一起收掉，垃圾桶才真贴右缘 */
.html-for-mac .ty-table-edit .md-table-more,
.html-for-mac .ty-table-edit .right-th-button ~ .right-th-button { display: none; }
#write .ty-table-edit .btn-group > .btn { border-radius: 5px; }   /* (1,3,0) 拆掉 Bootstrap 把三个对齐钮焊成一颗药丸的圆角规则 (0,4,0)/(0,5,0) */
.ty-table-edit .btn-group .btn + .btn { margin-left: 2px; }       /* 与条上的 flex gap 同值 */
.ty-table-edit button.btn { display: flex; align-items: center; justify-content: center; padding: 4px 6px; border: 0; border-radius: 5px; background: transparent; box-shadow: none; color: var(--ui-muted-color); line-height: 1; }   /* flex 三条让 16px 图标墨迹在按钮里居中 */
.ty-table-edit .ty-icon { font-size: 16px; line-height: 1; }
.ty-table-edit button:hover { background: var(--item-hover-bg-color); }
.ty-table-edit button.active { color: var(--primary-color); background: var(--suggest-active-bg); box-shadow: none; }
.ty-table-edit button:focus { outline: 0; }
/* 弹层对齐网格按钮左缘。宽度那一半见 5.4，两条写在同一个选择器上，合成一条规则 */
.md-resize-table-th .popover { width: 144px; margin-left: 5px !important; }   /* 弹层的包含块是条的内距盒，其左缘在表格左缘外 5px；5px 抵掉条的左内距。main.js 把 margin-left:-10px 写成内联样式，只有 !important 够得着 */
```

- 按钮 24px 高。**上抬 16px 而不是 2px**：列把手占着表格正上方 14px 的带子，而它画在工具条之上 —— tracker 是 `#write` 的**兄弟**且带 `z-index:99`，工具条是 `#write` 内一个 `z-index:auto` 的定位元素，二者在根层叠上下文里比较，99 直接胜出；`opacity:0` 仍可命中。2px 时两者重叠 12px，实测 `elementFromPoint` 打在最前面几个按钮上返回的是 `.typora-table-drag-area` —— 点下去开始拖列（压住几个取决于首列宽度）。16px 后条底 110、把手顶 112，留 2px 余量，五个按钮全部可点。
  - **勘误**：此前把机制写成 `#write{transform:translateZ(0)}` 造出层叠上下文，那条声明只在 `TypeMark/style/window.css`，而 macOS 的 `index.html` **不 link 它**（清单止于 `base.css` → `base-control.css` → `mac.css` → `codemirror.css` → 主题；`mac.css` 里那条 `translateZ(0)` 挂的是 `.html-for-mac video`）。macOS 上 `#write` 的 `transform` 实测为 `none`，不是层叠上下文。结论不依赖它：两种外壳下（挂与不挂 `window.css`）读数完全一致。注意 `content{overflow-y:auto}` 来自 `base-control.css`，所以下面第 4 条的裁剪结论不受此勘误影响。
- 上抬必须用 `transform`：`resizeTableEdit()` 每次布局都重写内联 `margin-top`，用外距会被盖掉；`translateY` 也不污染它量的自身高度。
- **代价：条顶越过前一块的盒底从 6px 变成 20px**（条高 24 + translate 16 − figure 上外距 20）。图标墨迹在条内居中、顶边退 4px，所以墨迹落在 `[前块盒底 − 16, 前块盒底]`。实测（无头 Chrome，16px/24px 行盒）图标墨迹 90–106 与前一块**最后一行的文字墨迹** 84–104 纵向重叠 14px；本例里那一行的横向范围没伸到表格底下所以没撞上，但只要前一块最后一行铺满正文宽，图标就会压在字上。工具条只在表格入焦时出现，属于短暂叠放，观感留待实机确认。
- 另外两条路已排除：`:has()` 按需上移（行拖会中途隐藏列 tracker，条在 mousedown 瞬间掉 14px，一次拖拽两次跳动）、把手挪进表格上缘内侧（把手就不在表外了，与原版观感冲突）。
- 条的包含块是 `#write`（出厂的），不是 figure。figure 是滚动容器（出厂 `figure{overflow-x:auto}`，单轴 visible 会算成 auto），一旦让它当包含块，悬在它内容盒上方一整条高度的工具条就落进裁切区里没了；让它不定位，条的包含块是 figure 的祖先，裁切够不着它 —— 宽表照旧在 figure 内滚动，条完整，垃圾桶落在 figure 可见的右缘。
- **More 按钮 macOS 隐藏。** 出厂两道锁（`showAlignCol()` 里 `File.isMac` 不 `.show()`，base-control 的 `.html-for-mac .md-table-more{display:none}` (0,2,0)），但主题的 `.ty-table-edit button.btn{display:flex}` 是 (0,2,1) 且载入更晚，把它复活了；hover 还会展开 “More Actions” 文案，整条宽 36px。用 (0,3,0) 重画这道锁即可，不需要 `!important`。空壳 `span` 一起收掉：只藏按钮会在条尾留一个零宽 flex 项，它前面那 2px gap 把垃圾桶顶离表格右缘 2px（实测 2.00 → 0.00）。Windows / Linux 不受影响，那里的按钮是真的。
- Windows 的 `.md-table-more` 带文字，随 flex 排在垃圾桶旁。验收放在 Windows VM 尾项。

### 5.4 选格弹层

```css
.md-table-resize-popover { background: var(--menu-bg-color); border: 1px solid var(--ui-border-color); border-radius: 7px; box-shadow: var(--shadow-sm); }
table.md-grid-board { width: 100%; table-layout: fixed; margin: 4px auto; }   /* 压出厂 margin:10px auto；格子由表分宽 */
.md-grid-board a { width: auto; border: 1px solid var(--ui-border-color); border-radius: 2px; background: transparent; opacity: 1; transition: none; }
.md-grid-board a:hover { opacity: 1; }                                   /* (0,2,1) 压主题 a:hover 的 0.8 */
.md-grid-board tr[row='1'] { background: transparent; }                  /* 去掉整行 #dcdcdc */
.md-grid-board .md-grid-ext { background: var(--grid-current-bg); }      /* 文字色约 25% 预混 */
.md-grid-board tr[row='1'] .md-grid-ext { background: var(--grid-current-bg-strong); }   /* 约 40% */
.md-grid-board a.md-active, .md-grid-board a:hover { background: var(--suggest-active-bg); border-color: var(--primary-color); }
.md-grid-board tr[row='1'] a.md-active, .md-grid-board tr[row='1'] a:hover { background: var(--grid-select-bg-strong); }   /* accent 约 30% */
.md-resize-table-th .popover { width: 144px; }    /* 压出厂 134px，见下；与 5.3 的 margin-left 同选择器，落地时合成一条规则 */
.md-grid-board-wrap { width: auto; padding: 6px 8px; }   /* 压出厂 100px 与 .code-tooltip-content 的 1ch */
/* 出厂把这行排成受 text-align 牵引的 inline-block，再靠按钮上的 1ch 外距分隔，
   "确定"一现身就顶出面板右缘。改成居中 flex 行，间距全交给一个 4px gap；
   Bootstrap .popover-title 继承来的 14px 左右内距去掉，让 wrap 自己的内距成为
   这一行唯一的横向内缩 —— 面板宽度正是按这个量出来的。 */
.md-grid-board-wrap .popover-title { border-top: 1px solid var(--ui-border-color); color: var(--ui-muted-color); display: flex; align-items: center; justify-content: center; gap: 4px; padding: 6px 0; }
.md-grid-board-wrap input { border: 1px solid var(--ui-border-color); border-radius: 7px; background: var(--bg-color); height: 22px; width: 4ch; padding: 0 4px; color: var(--text-color); }
.md-grid-board-wrap input:focus { border-color: var(--ui-border-focus-color); }   /* (0,2,1) 压出厂 input:focus */
#md-resize-grid { background: var(--interactive-accent); color: #fff; border: 0; border-radius: 7px; height: 22px; margin: 0; padding: 0 8px; font-size: 12px; }
```

- 暗色覆盖：三个网格 token 与 `--table-drag-src-bg` 各给暗值。边框不必单列 —— 亮色那条读的是 `--ui-border-color`，暗色 `:root` 已把它别名到 `--dark-border-color`。
- 面板**定宽**，不随内容收缩："确定"随输入框入焦显隐，宽度会跳的面板比略宽的面板更糟。所以按最宽态量：确定可见、两格都填两位数。max-content 克隆实测（亮暗一致，Inter 14px，1ch = 8.67px）：标题行内容 121.72 + wrap 左右各 1ch 17.34 + 面板边框 2 + 面板内距 2 = 143.03 → **144px**。出厂 134px 挂在 `.md-resize-table-th .popover` (0,2,0)，覆盖必须同选择器、靠加载顺序取胜。
- **那次测量差了一点点。** 等 `document.fonts.ready`（Inter 真就位）后重测：最宽态标题行要 **123.56px**，而 1ch 内距只留 122.34px —— 两个输入框各被 flex 压掉 0.61px（渲染 34.72 而非声明的 4ch = 35.33），肉眼看不出但确实没排下。wrap 横向内距收到 8px 后行宽 124px，字段回到声明宽度，余量 **0.44px**。面板宽度 144px 不动。
- **手输上限是 40 列 / 99 行**，不是 20 / 99。main.js 模块顶部 `var d = 99, u = 40`，列走 `Math.min(u, v)`；标记里的 `max="20"` 写在 `type=text` 上，浏览器完全忽略。两者都是两位数，所以上面的宽度测量不受影响 —— 这条只更正记述。
- 输入框 `4ch` 而非出厂 `3ch`：左右各 4px 内距吃掉内容盒后，两位数会被切掉 3px。
- **高度收紧。** 出厂给一张 10 行网格套的是提示气泡的排场：wrap 四周 1ch（8.8px）、网格上下各 10px 外距、标题行 8px 内距，总高 232.63px。收到 6px/8px、4px、6px 后是 **211px**（−21.6），再加工具条上抬带来的 14px，面板底边整体上移 35.6px。这是能对"底部被裁"做的全部：main.js 把 `top:20px` 写死进内联样式且没有任何翻转逻辑，越界只能靠压低缓解。
- **网格横向填满。** 原来 92px 网格摆在 122px 内容盒里，30px 是死边距，一小块网格漂在宽面板里。`width:100%` + `table-layout:fixed` 把这块空间交给格子（13×13 → 18.33×13），面板读成一整块。格高保留出厂 13px：表格的列本来就比行宽，横向格子在这里读得通；若要保持正方形填满宽度，面板会**高**出 50px，与压低总高正相反。
- 出厂行为不碰："确定"默认 `display:none`，输入框入焦时 `.show()`，悬停网格时 `.hide()`。两个输入框向"x"对齐的出厂规则保留。网格写死 6 列 × 10 行（模板逐个手写），不可变。

### 5.5 模态

```css
.modal-content { border-radius: 24px; padding: 16px; border: 1px solid var(--ui-border-color); box-shadow: var(--shadow-md); }
.modal-header, .modal-footer { border: 0; }
/* 内距全部归零重排：`.modal-content` 的 16px 是唯一的框内内缩，出厂 bootstrap 给
   header / body / footer 各 15px、给相邻按钮 5px，不清掉会叠在 16px 上。 */
.modal-header { padding: 0 0 12px; }
.modal-body { padding: 0; }
.modal-footer { padding: 16px 0 0; }
.modal-footer .btn + .btn { margin-left: 8px; }
.modal-title { font-size: 20px; font-weight: 600; }
/* 裸选择器那条管关闭态：bootstrap 关对话框时先摘 .in 再淡出，那段时间只有它命中，
   缺了就会回落到 window.css 的不透明 #fff（Windows / Linux）或 bootstrap 的 #000
   （macOS）闪一下。opacity:1 只能待在 .in 上：写到裸选择器会输给出厂
   .modal-backdrop.in{opacity:.5}，0.4 再折一半成 0.2。mac.css 自带一条 opacity:1，
   所以 macOS 上它是空操作，真正受益的是不加载 mac.css 的 Windows / Linux。 */
.modal-backdrop { background: rgba(220,220,220,.4); }
.modal-backdrop.in { background: rgba(220,220,220,.4); opacity: 1; backdrop-filter: none; -webkit-backdrop-filter: none; }
/* 暗色：.modal-content 底 --dark-panel-bg，边 --dark-border-color（阴影读亮色那条的 --shadow-md，暗 :root 已改值，不必重写）；遮罩两条都用 rgba(10,10,10,.4) */

#table-insert-dialog .input-group { display: flex; align-items: center; }
#table-insert-dialog .input-group-addon { background: transparent; border: 0; color: var(--ui-muted-color); padding: 0 8px 0 0; }
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
   - 工具条：条宽等于表宽；条底距表顶 16px 且不与列把手带重叠，五个按钮 `elementFromPoint` 全部可命中；按钮 24px 高；三态色。两行小表与满宽表各测一次。
   - 弹层：六态（空、当前、新选，各乘正文行、表头行）逐格读 computed；输入框入焦色；"确定"按钮尺寸；总高与网格宽；首末格与"确定"的命中测试。
   - 把手与拖动态：手工构造静态 DOM，即 tracker 显形、源行/列上描边、落点线，量位置与色；grip 两套点阵数点。
   - 模态：用 index.html 的静态 DOM 量圆角、内距、标题、按钮、输入框。
   - 输出 Obsidian 截图与 Typora 的并排合成图。
2. 三路同步后用户实机验收，亮暗各一：表格入焦、hover、切换对齐、弹层从悬停到输入到确定、拖一次行与一次列、三个对话框（插入表格、删除文件确认、图片建文件夹确认）。
3. 导出 HTML 与 PDF，抽查表格页：居中、20px、无控件残留。**空行一项无需再验** —— 导出序列化器已把空格换成 `&nbsp;`，兜底规则在导出里根本不命中（见 §5.1）。完整四路并入发布前门。
4. Windows VM 尾项追加：工具条"更多"按钮、三个模态的遮罩、把手。

> 落地记录：第 1 条的 WebKit 离屏 harness 在一次重启中随 `/private/tmp` 一起丢了。复审与三轮修复因此改用无头 Chrome 量 computed style 与几何，按同一套加载顺序挂 `bootstrap.css` / `base.css` / `base-control.css` / `mac.css` 或 `window.css` 再挂主题；还补挂了 `style/typora-icon/style.css`，图标是真字形，工具条的宽度读数才作数（此前无图标字体的读数偏窄）。文字度量类结论（工具条压前块那 14px、面板标题行的余量）都是 **Chrome 量测，WKWebView 待实机**。
>
> 第三轮（拖拽专项）在 fixture 里补了四样：`.typora-on-moving` 的两种落类形态（`<tr>` 与逐格）与它们的 `::before` 逐边读数；把手的 `:hover` / `:active` 用真鼠标事件驱动（元素级截图会滚动重置伪类，必须整页截图再按坐标裁）；grip 点阵用截图连通域分析数点、量点距与边距，确认没有半点被裁；裸 HTML 表与导出形态表的空行高度。测量脚本一律等 `document.fonts.ready` 再跑 —— 不等的话 Inter 未就位，`ch` 与表宽读数会漂十几个像素。

## 7. 边界情况

- 加行、加列按钮：Typora 无 DOM，造不出。记入 `TODO.md` 边界。
- 把手显形要先让鼠标进入单元格，这是 Typora 的触发条件；Obsidian 也是悬停才见。
- 弹层悬在表格左上角之上，与出厂相同；菜单覆盖内容。
- 两列 6ch 的小表比工具条内容窄时，条按 `min-width: max-content` 向右溢出，不收缩按钮。溢出量实测（无头 Chrome，真图标字体，`#write` 内容盒 660px）：两列 6ch 的表宽 126.66px；工具条内容盒的下限，macOS 五个图标钮 148px，溢出 21.34px；Windows 多一个"更多"钮，标签默认 `display:none`，内容盒 175.33px，溢出 48.67px，指针悬停或键盘入焦时出厂把标签放出来，内容盒 250.64px，溢出 123.98px（标签文案随语言变，宽度随之浮动）。设计维持：按钮不收缩，宁可条比表宽。
- 列把手宽等于列宽，grip 点阵居中；点阵是 15×8，列宽小于 15px 才会容不下它。6ch 下限（实测 56.78px）使这种情况不会发生。

以下十一条是本波逐条核实过的边界 —— 多数是 CSS 够不着的 Typora 行为，末尾三条是本主题自己选的取舍。不必再查：

1. **把手必须先把指针放进单元格才现，且不随离开消失。** 事件是 `#write` 上对 `th, td` 的 `mouseenter click` 委托，没有任何表格外围的邻近触发区；显示后只有 `deleteTable()` / 拖拽结束 / `unfocusAll()` 会藏它。所以把手会长期停在表格上下缘 —— 工具条 16px 上抬正是为此。守卫 `children("[mdtype]")` 还意味着裸 HTML 表格永远没有把手。
2. **拖动中没有整行 / 整列 hover 高亮。** `mousemove` 只算落点索引并挪 marker，从不给目标行列加类或写属性。非拖拽态的整行 hover 是 `#write tbody tr:hover`（已有）；整列 hover 任何情况下 CSS 都做不了（没有列 hover 选择器，Typora 生成的表也没有 `<colgroup>`）。
3. **把手 hover 不联动点亮所在行/列。** 原版的联动是 DOM 归属的副产物 —— 它的把手是单元格的子元素，`:hover` 沿祖先链传播。Typora 的把手是 `content` 的直接子元素，不在表格里，传不过去。
4. **弹层贴近窗口底部不会翻转。** main.js 把 `top:20px` 写死进内联样式，且没有任何边界回避逻辑（对比 `showExtMenu` 是有 clamp 的）。裁它的是 `content` 的 `overflow-y:auto`。只能靠 §5.4 的压低缓解。
5. **拖后描边保持不到失焦。** `mouseup` 的 `D()` 立刻摘掉 `.typora-on-moving`，随后 `moveTableRow/Col` 用 `replaceWith(toHTML())` 整表重建，新 DOM 上没有任何状态类或属性；`buildUndo` 在此处返回 `null`，拖完表里连光标都没有，`:focus-within` 也用不上。原版那种"拖完保留选中直到失焦"在 Typora 里没有可挂载点。
6. **`grabbing` 光标只在主轴上保得住。** 光标由指针下方的元素解析，不看 `:active`。把手沿拖拽轴 1:1 跟随，主轴永不脱手；跨轴一旦移出把手的另一维（14px），光标立刻掉回 `#write` 的 `text`。要修得在 `body` 上挂拖拽态 class，那是 JS。药丸本身不会跟着消失 —— `:active` 已一并给了 `opacity: 1`。
7. **搜索面板 / 通知条开着时行拖的药丸会垂直错位 20 / 36px。**（备案）`m = $("content").offset().top` 只在模块初始化的 `setTimeout(…,200)` 里取一次；`window.css` 的 `.on-search-panel-open content{top:48px}` 与 `.ty-show-notification content{top:64px}` 会改 `content` 顶边而 `m` 不刷新。纯 JS 缺陷，CSS 无解。
8. **列拖过程中工具条会整个消失。** 移动列落点线那一步先执行 `r.find(".ty-table-edit").remove()`，拖完由 `showTableEdit` 重建。出厂行为。
9. 列拖的描边靠 `thead` 收上沿、`tbody tr:last-child` 收下沿。表体为空的退化表格（只有表头行）拿不到下沿那条 2px —— 需要 `:has()` 才能补，为一个退化形状不值得，记为已知缺口。
10. **工具条上抬 16px 后，打开的弹层顶部约 10px 落在列把手带下面。** 弹层顶 116、把手带 112–126，横向重叠第一列宽度那一段。把手 `opacity:0` 不可见但可命中，所以那 10px 里点下去开始拖列而不是命中面板。弹层自带 Bootstrap 的 `z-index:1060`，之所以压不过 `z-index:99` 的把手，是因为**工具条自己的 `transform: translateY(-16px)` 造出了一个层叠上下文**，把弹层封在里面 —— 反事实实验证实：去掉工具条那条 transform，同一点就命中 `.md-grid-board-wrap` 而不是把手。也就是说这条边界与上抬是同一件事的两面；日后若改掉那个 transform，这条边界会自行消失（弹层反而变可点），记述需同步。
11. **空格兜底不认只含空白的单元格。** `:empty` 要求元素连文本节点都没有，所以手写 HTML 表里换行缩进出来的 `<td> </td>` / `<td>\n</td>` 仍塌成 8.00px（实测）。手写表格带缩进是常态，这个形状不算罕见。选 `:empty` 是决策定的，换成 `:blank` 之类会同时把带空白的 Typora 单元格也卷进来，得不偿失 —— 记为选择器自身带来的已知取舍，不是实现偏离。上抬之前弹层从 130 起，整个在把手带之下，没有这个区间 —— 属新增行为。这 10px 只是面板的内距，没有任何控件：网格首行首格顶边在 130，实测 `elementFromPoint` 命中 `<a>`。因此收紧内距时留了下限：面板边框 1 + 面板内距 1 + wrap 上内距 6 + 网格上外距 4 + `border-spacing` 2 = 14px，再压就要让首行落进把手带。

## 8. 涉及文件清单

- `blue-topaz.css`：第 12 节 Table（figure、最小宽、空格兜底）；第 13 节 Table edit UI（工具条、More 隐藏、弹层、把手、幽灵藏除、拖动态、落点线）；模态节（`.modal-content` 等）；`.btn-*` 限定在 `.modal` 内。
- `blue-topaz-dark.css`：对应节的暗值；打印块守卫。
- `dev/color-mapping.md`：`--grid-current-bg`、`--grid-current-bg-strong`、`--grid-select-bg-strong`、`--table-drag-src-bg`。
- `TODO.md`：光标格标记推迟项、不搬清单、边界、导出四路与 Windows 尾项追加。
- 提交按面拆分：本体、把手与拖动、工具条、弹层、模态、修复。Conventional Commits，带 body。
