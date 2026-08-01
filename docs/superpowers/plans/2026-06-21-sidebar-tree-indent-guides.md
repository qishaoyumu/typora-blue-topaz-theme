# 侧边栏树缩进线 + 文件树去图标 实现计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 为 Typora Blue Topaz 主题的侧边栏大纲树与文件树添加层级缩进线，并移除文件树图标，对齐 Obsidian Blue Topaz 原版风格。

**Architecture:** 在子节点容器（大纲 `.outline-children` / 文件树 `.file-node-children`）上加 `border-left` 画竖线，`margin-left` 控缩进；大纲悬停时整条祖先链变主题蓝，文件树保持静态。颜色走两个新 `:root` token，dark 只覆盖 token 值、选择器经 `@import` 继承。文件树图标改 `display:none` 并清理失效配色规则。

**Tech Stack:** 纯 CSS（无构建工具、无包管理器）。`blue-topaz.css`（亮色全量）+ `blue-topaz-dark.css`（`@import` 亮色后仅覆盖差异）。

## 验证方式（全局适用）

本项目**无自动化测试**。每个 task 的验证分两层：

- **结构自检（agent 可执行）**：用 `grep` 确认选择器、token、值已按计划写入正确位置。命令与预期输出在各 step 给出。
- **视觉验收（必须人工在真实 Typora 执行）**：Typora 侧边栏不在导出 DOM 内，无法用 headless 工具复现，只能由**用户在真实 Typora 截图**对照 checklist。改 CSS 后 Typora 不热重载，需**切换主题再切回，或 `Cmd+Q` 重启** Typora 刷新（主题目录已 symlink 到本仓库）。每个 task 的视觉验收是**人工检查点**，通过后方可进入下一 task。

## Global Constraints

逐条来自 spec，每个 task 隐含适用：

- **不破坏现有背景（硬约束）**：只新增 `border-left` 与 `display:none`，绝不改动任何现有 hover/active 背景规则；对比实现前后，背景卡片外观必须不变。
- **最小化、可追溯改动**：只为「加缩进线 + 去图标」做必需改动；无关优化一律不做，发现的记入 `TODO.md`。
- **双主题**：亮色规则写在 `blue-topaz.css`；`blue-topaz-dark.css` 仅在 `:root` 覆盖 token 值，不重复任何选择器。
- **不影响导出/打印**：纯屏幕 UI，无需 PDF/HTML 验证。
- **无开关**：Typora 无 Style Settings 面板，主题写死、对所有用户生效。
- **行号基准**：本计划行号为 master `155897d` 快照，仅辅助定位，**以选择器为准**。
- **分支**：在 `feat/sidebar-indent-guides` 上提交。

---

## 文件结构

| 文件 | 职责 | 本计划改动 |
|---|---|---|
| `blue-topaz.css` | 亮色全量样式 | 新增 2 个 token；大纲 `.outline-children` 画线+悬停；文件树 `.file-node-children` 画线；图标规则改 `display:none` 并清理 |
| `blue-topaz-dark.css` | 暗色覆盖（`@import` 亮色后只覆盖差异） | `:root` 新增 2 个 token 的 dark 值 |
| `dev/color-mapping.md` | Obsidian→Typora 配色映射文档 | 记录 2 个新 token；删除失效的图标配色记录（`#eb7c46`） |

---

## Task 1: 颜色 token + 大纲缩进线

定义两个 token（亮/暗），并让大纲成为它们的首个消费者。token 折叠进本 task（首个使用者）。

**Files:**
- Modify: `blue-topaz.css:73-77`（`:root` sidebar token 簇，新增 2 token）
- Modify: `blue-topaz.css:1370-1373`（`.outline-content` 规则后，新增 `.outline-children`）
- Modify: `blue-topaz-dark.css:86`（`:root`，新增 2 个 dark token）
- Modify: `dev/color-mapping.md`（Sidebar 节记录新 token）

**Interfaces:**
- Produces: CSS 变量 `--indent-guide-color`（静态线色）、`--indent-guide-active-color`（大纲悬停色）。Task 2 复用 `--indent-guide-color`。

- [ ] **Step 1: 写下视觉验收标准（相当于「写测试」）**

本 task 完成后，在真实 Typora 截图须满足：
1. 大纲嵌套层级出现淡灰竖线；顶层 H1 左侧**无**竖线。
2. 悬停某标题 → 该标题到根的**整条祖先链**竖线渐变为主题蓝（约 400ms），移开恢复淡灰。（**预期副作用**：最外层 `.outline-children` 几乎含所有标题，故悬停任意项时最外层主竖线倾向常亮——Obsidian 同款行为、非 bug，见 spec §5.1。）
3. 亮、暗主题各验一遍，线在两种侧栏背景上都「淡而可见、不抢背景」。
4. 对比实现前后，大纲 hover/active 的**行背景卡片外观不变**（背景照常出现，不因加线而变形/变色）。

- [ ] **Step 2: 确认 baseline（相当于「跑测试看它失败」）**

Run: `grep -n 'outline-children\|indent-guide' blue-topaz.css`
Expected: 无输出（`.outline-children` 尚无规则、token 尚未定义）。
并在 Typora 打开 `test/test-document.md`，确认大纲当前**无缩进线**。

- [ ] **Step 3: 新增 light token**

在 `blue-topaz.css` 的 `:root` 内，把 sidebar token 簇这段：

```css
    --file-text-color: #272727;

    --sequence-theme: simple;
```

改为：

```css
    --file-text-color: #272727;

    /* Sidebar tree indent guides */
    --indent-guide-color: rgba(148, 148, 148, 0.2);
    --indent-guide-active-color: hsla(207, 77%, 54%, 0.4);

    --sequence-theme: simple;
```

- [ ] **Step 4: 新增 dark token**

在 `blue-topaz-dark.css` 的 `:root` 内，把：

```css
    --file-text-color: #b3b3b3;

    --sequence-theme: simple;
```

改为：

```css
    --file-text-color: #b3b3b3;

    /* Sidebar tree indent guides */
    --indent-guide-color: rgba(255, 255, 255, 0.1);
    --indent-guide-active-color: hsla(208, 72%, 58%, 0.4);

    --sequence-theme: simple;
```

- [ ] **Step 5: 新增大纲画线规则**

在 `blue-topaz.css` 中，把 `.outline-content` 规则：

```css
.outline-content {
    padding-left: 8px;
    padding-right: 8px;
}
```

改为（在其后追加 `.outline-children` 两条规则）：

```css
.outline-content {
    padding-left: 8px;
    padding-right: 8px;
}

/* Indent guides: a 1px line on every nested children container.
   Top-level H1 is not wrapped in .outline-children, so the root has no
   line. :hover includes descendants, so hovering a deep heading lights
   its whole ancestor chain (matches Obsidian). Only border-color is
   added here; no existing hover/active background rule is touched. */
.outline-children {
    border-left: 1px solid var(--indent-guide-color);
    transition: border-color 0.4s ease;
}

.outline-children:hover {
    border-left-color: var(--indent-guide-active-color);
}
```

- [ ] **Step 6: 更新 color-mapping.md（记录新 token）**

在 `dev/color-mapping.md` 的 `### Sidebar & File Tree (Light)` 表格内追加两行：

```markdown
| `--indent-guide-color` | `rgba(148, 148, 148, 0.2)` | Sidebar tree indent guide line (outline + file tree); aligned with Obsidian's `#94949433` |
| `--indent-guide-active-color` | `hsla(207, 77%, 54%, 0.4)` | Outline indent guide on hover (ancestor-chain highlight); aligned with Obsidian `--theme-color-translucent-04` |
```

在 `### Sidebar & File Tree (Dark)` 表格内追加两行：

```markdown
| `--indent-guide-color` | `rgba(255, 255, 255, 0.1)` | Sidebar tree indent guide line; light/white tint so it stays visible on `#151515` |
| `--indent-guide-active-color` | `hsla(208, 72%, 58%, 0.4)` | Outline indent guide on hover (dark sidebar blue at 0.4) |
```

- [ ] **Step 7: 结构自检（agent 执行）**

Run: `grep -nE 'indent-guide-color|indent-guide-active-color' blue-topaz.css blue-topaz-dark.css && echo '---' && grep -n -A4 '^\.outline-children' blue-topaz.css`
Expected:
- `blue-topaz.css` 与 `blue-topaz-dark.css` 各 2 处 token 定义（值分别为 light `rgba(148,148,148,0.2)`/`hsla(207,77%,54%,0.4)`，dark `rgba(255,255,255,0.1)`/`hsla(208,72%,58%,0.4)`）；
- `.outline-children` 含 `border-left: 1px solid var(--indent-guide-color)` 与 `transition`，`.outline-children:hover` 含 `border-left-color: var(--indent-guide-active-color)`。

- [ ] **Step 8: 视觉验收（人工，在真实 Typora）**

切主题或重启 Typora 刷新后，对照 Step 1 的 4 条逐一截图确认（亮+暗）。任一条不达标即记录现象、回到 Step 3–5 调整（如线太淡/太显，微调 token alpha）。

- [ ] **Step 9: Commit**

```bash
git add blue-topaz.css blue-topaz-dark.css dev/color-mapping.md
git commit -m "feat: add outline tree indent guides with hover highlight" \
-m "Define --indent-guide-color / --indent-guide-active-color (light + dark) and draw a 1px border-left on every .outline-children; hovering a heading lights its ancestor chain to theme blue. Existing hover/active backgrounds untouched. Records the two tokens in dev/color-mapping.md." \
-m "Claude-Session: https://claude.ai/code/session_01TApWQQVuMbxMaDsGHdfyjo"
```

---

## Task 2: 文件树缩进线（静态）

复用 Task 1 的 `--indent-guide-color`，在文件树子容器加同款竖线，但**无悬停变色**。

**Files:**
- Modify: `blue-topaz.css:1302-1304`（`.file-tree-node:not(.file-node-root) > .file-node-children` 现有 `margin-left` 规则，加 `border-left`）

**Interfaces:**
- Consumes: `--indent-guide-color`（Task 1 定义）。

- [ ] **Step 1: 写下视觉验收标准**

完成后在真实 Typora 截图须满足：
1. 文件树嵌套层级出现淡灰竖线；最外层（根目录直接子项）左侧**无**竖线。
2. 悬停文件/文件夹时，缩进线**不变色**（保持淡灰）；行背景卡片照常高亮，外观与实现前一致。
3. 亮、暗主题各验一遍。

- [ ] **Step 2: 确认 baseline**

Run: `grep -n -A3 'file-node-root) > .file-node-children' blue-topaz.css`
Expected: 现有规则只有 `margin-left: 10px;`，无 `border-left`。

- [ ] **Step 3: 加 border-left**

在 `blue-topaz.css` 中，把：

```css
.file-tree-node:not(.file-node-root) > .file-node-children {
    margin-left: 10px;
}
```

改为：

```css
.file-tree-node:not(.file-node-root) > .file-node-children {
    margin-left: 10px;
    border-left: 1px solid var(--indent-guide-color);
}
```

- [ ] **Step 4: 结构自检（agent 执行）**

Run: `grep -n -A3 'file-node-root) > .file-node-children' blue-topaz.css`
Expected: 规则体含 `margin-left: 10px;` 与 `border-left: 1px solid var(--indent-guide-color);`，且无 `:hover` 变色规则跟随。

- [ ] **Step 5: 视觉验收（人工，在真实 Typora）**

切主题或重启刷新后，对照 Step 1 三条截图确认（亮+暗）。重点确认竖线与父文件夹展开箭头对齐美观；若偏移，可在本 task 内微调（如调整 `margin-left` 或加 `padding-left` 配合 `border-left`，但不得改动背景规则）。

- [ ] **Step 6: Commit**

```bash
git add blue-topaz.css
git commit -m "feat: add static indent guides to the file tree" \
-m "Add a 1px border-left (var(--indent-guide-color)) to nested .file-node-children, reusing the outline guide color. No hover color change, matching the agreed static behavior; root container excluded via :not(.file-node-root)." \
-m "Claude-Session: https://claude.ai/code/session_01TApWQQVuMbxMaDsGHdfyjo"
```

---

## Task 3: 移除文件树图标 + 清理

把图标改为 `display:none`，删除随之失效的 4 条图标配色规则，并清理 color-mapping 中的图标配色记录。

**Files:**
- Modify: `blue-topaz.css:1199-1221`（4 条图标规则 → 1 条 `display:none`）
- Modify: `dev/color-mapping.md`（删除 `#eb7c46` 图标配色记录两处）

**Interfaces:**
- Consumes: 无（独立于 token）。依赖现有 `.file-node-open-state{width:20px}` 占位保证对齐、`.file-tree-node[data-is-directory="true"] .file-node-title-name-part{font-weight:600}` 保证文件夹可辨。

- [ ] **Step 1: 写下视觉验收标准**

完成后在真实 Typora 截图须满足：
1. 文件树所有文件/文件夹图标消失，仅余展开箭头 + 文字。
2. 文字左边界对齐正常、不错位（由 20px 箭头位占位保证）。
3. 文件夹靠**加粗**与文件区分；展开箭头仍在。
4. 当前打开的文件（active）仍由**背景卡片**清晰标识。
5. 空文件夹（无箭头、无图标）靠加粗可辨（接受其辨识度略弱）。
6. 亮、暗主题各验一遍。

- [ ] **Step 2: 确认 baseline**

Run: `grep -nc 'file-node-icon' blue-topaz.css`
Expected: 多处（当前有 4 条图标规则 + 选择器引用）。Typora 中确认文件树**当前显示图标**。

- [ ] **Step 3: 图标规则 → display:none**

在 `blue-topaz.css` 中，把这一整段（4 条图标相关规则及其注释）：

```css
.file-library-node.active .file-node-icon {
    color: var(--primary-color);
    opacity: 1;
}

/* Obsidian signature: active file icon shifts to orange-red on hover.
   Use direct color (not filter: hue-rotate) to avoid GPU compositing layer
   creation which causes subpixel icon shift on hover in Typora. */
.file-library-node.active > .file-node-content:hover .file-node-icon {
    color: #eb7c46;
}

.file-node-icon {
    color: var(--primary-color);
    opacity: 0.7;
    margin-right: 6px;
}

/* Directory nodes: icon uses neutral control-text instead of theme blue,
   creating a container/content visual hierarchy with file icons. */
.file-tree-node[data-is-directory="true"] > .file-node-content .file-node-icon {
    color: var(--control-text-color);
}
```

替换为（单条隐藏规则）：

```css
/* File-tree icons removed for an Obsidian-style text-only tree: folders
   read via 600 weight + caret, the active file via its background card.
   (Dropping the icons also drops the former blue / active-blue / #eb7c46
   hover accents — see dev/color-mapping.md.) */
.file-node-icon {
    display: none;
}
```

> 注意：紧随其后的 `.file-tree-node[data-is-directory="true"] > .file-node-content { color: var(--text-color); }`（文件夹**文字**色）与 `.file-tree-node[data-is-directory="true"] .file-node-title-name-part { font-weight: 600; }`（文件夹加粗）**保留不动**——它们负责去图标后的文件夹/文件区分。

- [ ] **Step 4: 清理 color-mapping.md 的图标配色记录**

在 `dev/color-mapping.md` 删除以下两行（Light 节与 Dark 节各一行 `#eb7c46` 记录）：

Light 节待删行：
```markdown
| Hard-coded `#eb7c46` | `#eb7c46` | Active-file icon hover color (Obsidian's signature orange-red), shared between light and dark. A decorative hover accent, not body text; ~2.5:1 on the light background, kept for brand identity |
```

Dark 节待删行：
```markdown
| Hard-coded `#eb7c46` | `#eb7c46` | Active-file icon hover color, shared with light; clears WCAG AA (>4.5:1) on the dark background |
```

此外，`## Contrast / accessibility notes` 的「Intentionally left below AA」列表里还有一条 `#eb7c46` 记录（实测位于第 466–467 行），同样失效，删除整条 bullet：

```markdown
- `#eb7c46` active-file icon hover (~2.5:1 light): a decorative icon hover, not
  body text; kept for Obsidian brand identity.
```

删除后用 `grep -n 'eb7c46' dev/color-mapping.md` 复核，三处（46 / 87 / 466）应全部清空、无任何残留。

- [ ] **Step 5: 结构自检（agent 执行）**

Run: `grep -nc 'file-node-icon' blue-topaz.css && echo '--- icon rule:' && grep -n -A2 '^\.file-node-icon' blue-topaz.css && echo '--- eb7c46 residue:' && grep -rn 'eb7c46' blue-topaz.css blue-topaz-dark.css dev/color-mapping.md`
Expected:
- `.file-node-icon` 仅剩 1 条规则，规则体为 `display: none;`；
- 4 条旧图标配色规则（active 蓝、`#eb7c46` hover、基础色、文件夹中性色）已不存在；
- `eb7c46` 在三个文件中**无任何残留**。

- [ ] **Step 6: 视觉验收（人工，在真实 Typora）**

切主题或重启刷新后，对照 Step 1 六条逐一截图确认（亮+暗）。重点：去图标后文字是否对齐、文件夹是否仍一眼可辨、active 文件是否清晰、缩进线与文字关系是否干净。若文字相对箭头有轻微错位，微调 `.file-node-content` 的 `padding`（此为去图标的必需收尾，不动背景规则）。

- [ ] **Step 7: Commit**

```bash
git add blue-topaz.css dev/color-mapping.md
git commit -m "feat: remove file-tree icons for a text-only Obsidian-style tree" \
-m "Hide .file-node-icon and drop the now-dead icon color rules (theme-blue base, active blue, #eb7c46 hover, folder neutral). Folders stay distinguishable via 600 weight + caret; the active file via its background card. Alignment holds via the existing 20px caret slot. Removes the #eb7c46 icon-color records from dev/color-mapping.md." \
-m "Claude-Session: https://claude.ai/code/session_01TApWQQVuMbxMaDsGHdfyjo"
```

---

## 收尾（全部 task 完成后）

- [ ] **整体回归（人工）**：亮、暗主题各开一次 `test/test-document.md`，同时核对：大纲缩进线+悬停、文件树缩进线（静态）、文件树无图标且对齐、所有现有 hover/active 背景卡片外观未变。
- [ ] **分支状态**：确认三个提交都在 `feat/sidebar-indent-guides` 上，`git status` 干净。
- [ ] 后续合并/发布按 `CLAUDE.md` 的 Release Process（本功能为屏幕 UI，不触发资产或导出变更）。
