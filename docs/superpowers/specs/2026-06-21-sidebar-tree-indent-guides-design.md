# 侧边栏树缩进线 + 文件树去图标 — 设计文档

- 日期：2026-06-21
- 状态：已确认，待转实现计划
- 范围文件：`blue-topaz.css`、`blue-topaz-dark.css`、`dev/color-mapping.md`

## 1. 背景与目标

为侧边栏的**大纲树（OUTLINE）**和**文件树（FILES）**添加层级缩进线（indent guide），让嵌套层级一眼可辨，观感对齐正文无序/有序列表已有的缩进线，并忠于 Obsidian Blue Topaz 原版的侧边栏树风格。

同期顺带移除文件树的文件/文件夹图标，使文件树与大纲（本就无图标）风格统一、更贴近 Obsidian 默认。

此功能曾因实现困难长期搁置，现于项目上线后开发。

## 2. 调研结论（Obsidian Blue Topaz 原版）

对照用户本地 vault 的 `themes/Blue Topaz/theme.css`（基于 v2025052001 同源）：

- **侧边栏树缩进线的实际范式**（大纲，`theme.css:15276`）：
  ```css
  .workspace-leaf-content[data-type=outline] .tree-item-children {
    margin-left: 14px;
    border-left: 1px solid #94949433;            /* 常驻淡中灰线 ≈ rgba(148,148,148,0.2) */
    transition: all 400ms ease-in-out;
  }
  .workspace-leaf-content[data-type=outline] .tree-item-children:hover {
    border-left-color: var(--theme-color-translucent-04);   /* 悬停变主题色半透明 */
  }
  ```
  即：在「子节点容器」上加 `border-left` 画竖线，`margin-left` 控缩进，只画嵌套层级，悬停变主题色，400ms 过渡。

  > **调研严谨性说明**：上面这套常驻 `border-left` 缩进线，在原版**仅于大纲（app 内）直接确证**。文件树 app 内未找到同款常驻线规则——只有 Publish 站点的注释版 `.nav-view-outer` 思路一致；Obsidian app 内文件树的缩进参考线主要由核心 `app.css` 的 indentation guides 承担（不在主题 CSS 内）。本移植据此把**大纲这套成熟范式统一套用到两棵树**，正契合「两树都要、风格统一」的要求。
- 另有一套 `connected-indent`（`theme.css:13348+`）用极复杂的 `:has()` 悬停链点亮整条祖先链、彩色、3px、粉红系——但它主要作用于**正文编辑器**列表，不是侧边栏，移植成本与必要性都不成立，**不采用**。
- 结论：侧边栏树采用前述简洁的「子容器 `border-left`」范式。

## 3. 决策记录（均经用户确认）

| 决策点 | 结论 |
|---|---|
| 缩进线画法 | 子节点容器 `border-left`（Obsidian 原生做法）。否决 `::before` 绝对定位（正文列表用的那套，侧栏树无谓复杂）与 JS 注入（本主题纯 CSS） |
| 大纲（OUTLINE）悬停 | 平时淡灰中性常驻；悬停某分支时其**整条祖先链**竖线一起渐变为主题蓝（400ms）。祖先链高亮是嵌套 `:hover` 的自然结果，正是 Obsidian 效果 |
| 文件树（FILES）悬停 | 平时淡灰中性**常驻**；**悬停不变色**（静态）。文件树本就有行背景卡片承担悬停反馈，缩进线再变色会过花 |
| 文件树图标 | **移除全部**（文件 + 文件夹）。纯文字 + 展开箭头，与大纲风格统一、最贴近 Obsidian。代价：失去现有蓝文件图标 / active 图标变蓝 / 悬停橙红 `#eb7c46`；这些非 Obsidian 原版元素 |
| 不破坏现有背景 | **硬约束**。只新增 `border-left` 与 `display:none`，绝不改动任何现有 hover/active 背景规则；加线前后背景卡片视觉零变化，列为验证项 |
| 改动范围 | **最小化、可追溯**。只为「加缩进线 + 去图标」做必需改动；无关优化一律不做，记入 `TODO.md` 留后续 |

## 4. 范围与非目标

**做：**
- 大纲树缩进线（常驻淡灰 + 悬停祖先链变蓝）。
- 文件树缩进线（常驻淡灰，静态不变色）。
- 移除文件树全部图标，并清理随之失效的图标配色规则。
- 为上述新增颜色 token，并同步 `dev/color-mapping.md`。

**不做（非目标）：**
- 不动正文列表缩进线（`#write li>ul::before`，scope 边界）。
- 不做任何与本任务无关的「顺手优化」（行高、间距、字号、现有 hover 色等）；发现的可优化项记入 `TODO.md`。
- 不影响导出/打印——侧边栏不进导出 DOM，本功能为纯屏幕 UI，无需 PDF/HTML 四路验证。
- 无法提供开关：Typora 无 Style Settings 面板，主题写死、对所有用户生效。

## 5. 详细设计

> 本节引用的行号为撰写时（master `155897d`）的快照，仅辅助定位；行号会随重构漂移，**以选择器为准**（与 `dev/color-mapping.md` 的惯例一致）。

### 5.1 大纲缩进线（OUTLINE）

DOM 结构（实测核实）：`#outline-content` 直接包含顶层 `<li class="outline-item-wrapper outline-h1">`，其下嵌套 `<ul class="outline-children">`；每个 `.outline-item-wrapper` 内有兄弟关系的 `<div class="outline-item">`（行）+ `<ul class="outline-children">`（子容器）。

- 画线：
  ```css
  .outline-children {
    border-left: 1px solid var(--indent-guide-color);
    transition: border-color 0.4s ease;
  }
  .outline-children:hover {
    border-left-color: var(--indent-guide-active-color);
  }
  ```
- **根层级天然无线**：顶层 H1 不被任何 `.outline-children` 包裹，故所有 `.outline-children` 都是嵌套层级，根部无竖线。
- **祖先链高亮**：`:hover` 含后代，悬停深层标题时其各级祖先 `.outline-children` 同时进入 `:hover`，整条祖先链一起变蓝（预期效果）。
- **副作用预期**：最外层 `.outline-children` 几乎包含所有标题，故悬停大纲内任意标题时它都会 `:hover`——即**最外层主竖线在悬停态下倾向常亮**。这是 Obsidian 同款行为；若实测觉得过醒目，可在实现阶段微调 active 色 alpha 或按层级收敛，不属本次必改项。
- 不改现有 margin/padding；竖线落在子容器左缘。竖线对齐父标题展开箭头中心的精确偏移 → **实现时在真实 Typora 实测**。

不冲突性：行背景来自 `.outline-item:hover`（1357 行）与 `.outline-item-active`（1412 行，`background: var(--item-hover-bg-color)`），画在 `.outline-item` 上；竖线画在其兄弟 `.outline-children` 上，二者不同元素，分层共存。

### 5.2 文件树缩进线（FILES）

- 画线（复用现有选择器，仅加 `border-left`）：
  ```css
  .file-tree-node:not(.file-node-root) > .file-node-children {
    /* 现有：margin-left: 10px（1302 行） */
    border-left: 1px solid var(--indent-guide-color);
  }
  ```
- `:not(.file-node-root)` 保证根容器无竖线；**无 `:hover` 变色规则**（静态）。
- 竖线对齐父文件夹展开箭头中心 → 实测。

不冲突性：文件树 hover/active 背景画在绝对定位的 `.file-node-background`（`left:8px; right:8px`，统一卡片宽度，1147/1195 行）；竖线画在 `.file-node-children` 边框上，互不干扰。

### 5.3 移除文件树图标

- 隐藏：`.file-node-icon { display: none; }`
- 清理随之失效的规则（删除或合并，避免留死代码）：
  - `.file-node-icon`（颜色 / opacity / margin，1211 行）
  - `.file-tree-node[data-is-directory="true"] > .file-node-content .file-node-icon`（文件夹图标中性色，1219 行）
  - `.file-library-node.active .file-node-icon`（active 蓝，1199 行）
  - `.file-library-node.active > .file-node-content:hover .file-node-icon`（悬停橙红 `#eb7c46`，1207 行）
- **对齐补偿**：去图标后文字左移，由现有 `.file-node-open-state { width:20px }`（1246 行）箭头位占位保证不错位（文件 / 空文件夹的箭头位是占位的，箭头本身 `display:none` 但容器在）；若实测有偏差，微调 `.file-node-content` 的 padding —— 此为「去图标」必需收尾，非独立优化。
- **文件夹/文件区分**：保留文件夹 `font-weight:600`（1232 行）；active 文件改为只靠背景卡片标识（`.file-library-node.active > .file-node-background`，1195 行，与 Obsidian 一致）。

### 5.4 新增颜色 token

在 `blue-topaz.css` 的 `:root` 新增，在 `blue-topaz-dark.css` 的 `:root` 覆盖 dark 值。下表初值仅作方向参考，最终在真实侧栏背景上实测后定稿（须淡而可见、不抢背景）。

| Token | light 初值 | dark 初值 | 用途 |
|---|---|---|---|
| `--indent-guide-color` | `rgba(148, 148, 148, 0.2)`（对齐 Obsidian `#94949433`） | `rgba(255, 255, 255, 0.1)`（在 `#151515` 上淡而可见） | 静态淡灰竖线（两树共用） |
| `--indent-guide-active-color` | `hsla(207, 77%, 54%, 0.4)`（主题色 0.4，对齐 translucent-04） | `hsla(208, 72%, 58%, 0.4)`（dark sidebar 蓝 0.4） | 大纲悬停蓝 |

> 侧栏背景非白（dark 为 `#151515`），故**不能**复用正文列表的 `rgba(0,0,0,0.1)`，必须 light/dark 分别定义。
>
> 同步更新 `dev/color-mapping.md`：在「Sidebar & File Tree」节记录两个新 token；删除已失效的图标配色记录（蓝文件图标、`#eb7c46` 橙红 hover、文件图标 active 蓝）。

### 5.5 暗色覆盖策略

`blue-topaz-dark.css` 经 `@import` 继承全部选择器规则（画线、悬停、去图标），**只在 dark `:root` 覆盖两个 token 的值**，不重复任何选择器——符合「dark 只覆盖差异」。

## 6. 验证计划

纯屏幕 UI，截图逐项对比（亮 + 暗各一遍；改后切主题或 `Cmd+Q` 重启 Typora 刷新，symlink 不热重载）：

1. 大纲：静态淡灰竖线、嵌套层级正确、**根无线**。
2. 大纲：悬停某分支 → 整条祖先链变蓝、400ms 过渡；**对比实现前后，hover/active 背景卡片外观不变**（背景照常出现，只是不因加线而改变形态/颜色）。
3. 文件树：静态淡灰竖线、嵌套缩进、根无线、**悬停不变色**。
4. 文件树：图标已移除、文字对齐正常、文件夹加粗可辨、active 背景标识、空文件夹辨识可接受。
5. 竖线与父节点展开箭头对齐美观。

## 7. 边界情况

- 空文件夹（无展开箭头、无图标）：仅靠加粗与文件区分（已知可接受，Obsidian 同）。
- 深层嵌套：多条竖线并存，层级清晰。
- 无子项节点：无 `.outline-children` / `.file-node-children`，自然无线。

## 8. 涉及文件清单

- `blue-topaz.css`：新增两个 token；大纲 `.outline-children` 画线 + 悬停；文件树 `.file-node-children` 画线；`.file-node-icon` 隐藏并清理图标规则；（必要时）`.file-node-content` padding 对齐微调。
- `blue-topaz-dark.css`：`:root` 覆盖两个 token 的 dark 值。
- `dev/color-mapping.md`：记录新 token，删除失效图标配色记录。
