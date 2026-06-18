# Blue Topaz 主题（Typora 版）

[![License](https://img.shields.io/github/license/qishaoyumu/typora-blue-topaz-theme?style=flat-square&colorA=1e3a5f&colorB=4394e5)](LICENSE)
[![GitHub stars](https://img.shields.io/github/stars/qishaoyumu/typora-blue-topaz-theme?style=flat-square&colorA=1e3a5f&colorB=4394e5)](https://github.com/qishaoyumu/typora-blue-topaz-theme/stargazers)
[![Release](https://img.shields.io/github/v/release/qishaoyumu/typora-blue-topaz-theme?style=flat-square&colorA=1e3a5f&colorB=4394e5)](https://github.com/qishaoyumu/typora-blue-topaz-theme/releases/latest)

[English](README.md) | [在 Typora 主题画廊查看](https://theme.typora.io/theme/Obsidian-Blue-Topaz/)

将 Obsidian 的 [Blue Topaz](https://github.com/PKM-er/Blue-Topaz_Obsidian-css) 主题移植到 Typora，提供标题分级配色（浅色模式蓝色渐变，深色模式彩虹色）、代码高亮和 GFM Alert 样式。如果你在 Obsidian 里用过 Blue Topaz，这个主题把同样的观感带到 Typora。

### 深色模式

![Blue Topaz 深色主题预览](screenshots/dark.png)

### 浅色模式

![Blue Topaz 浅色主题预览](screenshots/light.png)

## 特性

- **浅色与深色模式**：两个主题入口共用一份样式源。`blue-topaz-dark.css` 通过 `@import` 加载 `blue-topaz.css`，再覆盖深色配色、代码高亮与打印样式。
- **标题分级配色**：浅色模式 h1 到 h6 蓝色渐变，深色模式彩虹色。
- **GFM Alert**：Note、Tip、Important、Warning、Caution 五种，与 GitHub 一致。
- **代码高亮**：`cm-s-inner` token 在浅色模式下基于 CodeMirror 默认配色，深色模式下采用 GitHub Dark 风格配色。
- **Mermaid**：浅色模式使用蓝色节点配色，深色模式提供深色预设，并自定义节点、连线与标签配色。
- **专注模式**：弱化非聚焦块，同时保留其标题与正文颜色。
- **打印与导出**：输出跟随所选主题，深色主题保持深底浅字，浅色主题保持浅色。
- **Typora 界面适配**：侧边栏、文件树、搜索、快速打开、偏好设置、模态框与源码模式。
- **Markdown 元素**：表格、任务列表、引用块、`details` / `summary`、定义列表、多彩高亮、上下标均有样式，并处理了 `prefers-reduced-motion`。
- **无障碍**：链接、行内代码、强调、标题、Alert 标题等高频彩色文字达到 WCAG AA 对比度。
- **中文支持**：提供 CJK 字体回退链，可选安装 LXGW WenKai；西文与代码使用内置的 Inter 与 JetBrains Mono。

## 安装

需要 Typora 1.13 或更高版本（主题使用了 `:has()` 等现代 CSS）。若主题未出现或渲染异常，请先更新 Typora。

1. 下载并解压 [**最新发布版**](https://github.com/qishaoyumu/typora-blue-topaz-theme/releases/latest)，或克隆本仓库。
2. 从 Typora 打开主题文件夹：
   - macOS：`Typora > 偏好设置 > 外观 > 打开主题文件夹`
   - Windows / Linux：`文件 > 偏好设置 > 外观 > 打开主题文件夹`
3. 将以下内容复制到主题文件夹，保持文件名和目录结构不变（深色主题通过 `@import` 加载浅色主题，两个主题的字体均从 `blue-topaz/` 加载）：
   - `blue-topaz.css`
   - `blue-topaz-dark.css`
   - 整个 `blue-topaz/` 文件夹（含 `font.css`、`.woff2` 字体和字体许可证）
4. 重启 Typora，在 **主题** 菜单中选择 **Blue Topaz** 或 **Blue Topaz Dark**。

**更新**：下载新版本，覆盖主题文件夹中的 `blue-topaz.css`、`blue-topaz-dark.css` 和整个 `blue-topaz/` 文件夹，然后重启 Typora。

**卸载**：先切换到其他主题，再删除主题文件夹中的 `blue-topaz.css`、`blue-topaz-dark.css` 和 `blue-topaz/` 文件夹，然后重启 Typora。

## 推荐字体

主题已内置 **Inter**（西文正文）和 **JetBrains Mono**（代码）。Inter 不含中文字形，中文显示建议安装 [LXGW WenKai（霞鹜文楷）](https://github.com/lxgw/LxgwWenKai)：

- macOS：`brew install --cask font-lxgw-wenkai`（或下载 TTF 安装）
- Windows：从 [GitHub Releases](https://github.com/lxgw/LxgwWenKai/releases) 下载最新 TTF 并安装
- Debian / Ubuntu：`sudo apt install fonts-lxgw-wenkai`
- 其他 Linux：安装发行版自带的对应包，或下载 TTF 后运行 `fc-cache -f`

未安装 LXGW WenKai 时，中文会回退到系统默认字体（macOS 为 PingFang SC 苹方，Windows 为 Microsoft YaHei 微软雅黑；Linux 取决于 fontconfig 配置）。

## 常见问题

- **主题没有样式，深色主题尤其明显**：`blue-topaz.css` 和 `blue-topaz/` 文件夹必须与 `blue-topaz-dark.css` 在同一个主题文件夹里。深色主题通过 `@import` 加载浅色主题，两者缺一不可。
- **主题菜单里找不到**：确认文件直接放在主题文件夹里，而不是在解压时产生的嵌套子目录中，然后完全退出并重启 Typora（macOS 用 Cmd+Q），不要只关窗口。
- **文字或排版异常**：确认 Typora 为 1.13 或更高版本。
- **导出的 HTML 字体变了**：Typora 会在导出 HTML 时移除主题内置的 `@font-face` 规则，因此在未安装 Inter 或 JetBrains Mono 的机器上，文字会回退到系统字体（文档结构和颜色不受影响）。这是 Typora 的导出行为，不是主题缺陷；PDF 导出会嵌入这些字体，正式分享时建议使用 PDF，或让接收方安装字体。

## 致谢

基于 WhyI 与 Pkmer 社区的 [Blue Topaz](https://github.com/PKM-er/Blue-Topaz_Obsidian-css) v2025052001。详见 [CREDITS.md](CREDITS.md)。

## 贡献

欢迎提交 Issue 或 PR。提交 PR 时请：

- 同步浅色与深色行为，两份 README 一并更新。
- 沿用现有 CSS 分节注释风格（`/* ========== Section ========== */`）。
- 涉及视觉改动请附 Typora 内的改动前后截图。

## 许可证

主题 CSS 采用 [MIT 许可证](LICENSE)。`blue-topaz/` 目录下的字体遵循 SIL Open Font License 1.1，详见 [CREDITS.md](CREDITS.md)。
