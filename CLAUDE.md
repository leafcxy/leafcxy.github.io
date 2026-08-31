# CLAUDE.md

此文件为 Claude Code (claude.ai/code) 在此仓库中工作时提供指导。

## 项目概述

基于 [Hugo](https://gohugo.io/) 静态站点生成器的个人博客，使用 [PaperMod](https://github.com/adityatelange/hugo-PaperMod) 主题，部署于 GitHub Pages：`https://leafcxy.github.io/`。

- **站点语言**：中文（`zh-cn` / `defaultContentLanguage = 'zh'`）
- **内容**：文章存放于 `content/posts/`，另有搜索页 `content/search.md` 和归档页 `content/archives.md`
- **自定义功能**：Mermaid 图表支持、KaTeX 数学公式支持（行内 `$..$` 与块级 `$$..$$`）

## 常用命令

```bash
# 安装 Hugo（需要 extended 版本以支持 SCSS/Sass）
# Windows: choco install hugo-extended  或  winget install Hugo.Hugo.Extended

# 启动开发服务器（含草稿内容，热重载）
hugo server -D

# 构建站点（输出到 public/ 目录）
hugo

# 创建新文章（使用 TOML frontmatter）
hugo new content posts/文章文件名.md

# 更新 PaperMod 主题子模块
git submodule update --init --recursive
git submodule update --remote themes/PaperMod
```

## 项目架构

```
leafcxy.github.io/
├── hugo.toml              # Hugo 站点配置
├── archetypes/            # 内容模板（hugo new 使用）
│   └── default.md         # 新文章的默认 frontmatter（TOML 格式，draft=true）
├── assets/                # SCSS/CSS/JS 覆盖（Hugo Pipes 处理）
├── content/               # Markdown 内容
│   ├── posts/             # 博客文章
│   ├── search.md          # 搜索页面（layout: search）
│   └── archives.md        # 归档页面（layout: archives）
├── data/                  # Hugo 数据文件（JSON/YAML/TOML）
├── i18n/                  # 国际化翻译覆盖（主题提供 47 种语言）
├── layouts/               # 自定义布局覆盖
│   ├── _default/_markup/
│   │   └── render-codeblock-mermaid.html  # 渲染 ```mermaid 代码块
│   ├── _partials/
│   │   └── extend_head.html   # 条件加载 Mermaid.js CDN
│   └── shortcodes/
│       └── mermaid.html       # {{< mermaid >}} 短代码（已废弃，改用代码块语法）
├── static/                # 静态文件，直接复制到输出目录
├── themes/
│   └── PaperMod/          # 主题（git 子模块）
├── .github/
│   └── workflows/
│       └── deploy.yml     # GitHub Actions 自动部署
└── public/                # 构建产物（gitignore，由 GitHub Actions 部署）
```

### 配置文件 (`hugo.toml`)

- **baseURL**: `https://leafcxy.github.io/`
- **locale**: `zh-cn`，默认内容语言 `zh`
- **theme**: PaperMod（从 `themes/PaperMod/` 加载）
- **导航菜单**: 文章、归档、标签、搜索（权重 10~40）
- **输出格式**: HTML + RSS + JSON（JSON 供搜索索引使用）
- **永久链接**: `[permalinks] posts = '/posts/:year/:month/:slug/'`，文章 URL 为 `/posts/年/月/slug/`

### 内容模型

- 文章存放于 `content/posts/` 目录，使用 Markdown 文件，frontmatter 以 `+++` 包裹的 **TOML** 格式书写。
- 草稿文章（`draft = true`）不会出现在生产构建中，但可通过 `hugo server -D` 预览。
- `archetypes/default.md` 定义了新文章的默认 frontmatter 字段：`date`、`draft`、`slug`、`title`（`slug` 由文件名去日期自动生成）。

### 文章命名规范

文章采用 `YYYY-MM-DD-标题.md` 命名（标题小写，空格用短横线 `-` 代替），例如 `2026-08-14-hugo-papermod-mermaid.md`。Hugo 会从文件名解析日期；URL 的 slug 需在 frontmatter 显式写 `slug` 字段（见下），否则 Hugo 会用 `title` 生成，可能产生中文粘连或特殊字符（如 `#`）进入 URL。

**命名硬性规则：**
1. 全部小写（中文可保留）；空格用 `-` 代替，**禁止下划线 `_`**
2. 不用特殊符号（`# & * ? / \ : "` 等），问号、括号尽量少用
3. 文件名控制在 60 字符以内
4. 不要用大写——Windows 不敏感，但 GitHub Pages（Linux）大小写敏感，会导致图片/资源 404
5. **发布后不要改文件名**（旧 URL 会 404）；要改标题只改 frontmatter 的 `title`

**frontmatter 约定（TOML）：**
```toml
+++
title = '文章标题'
date = '2026-08-14T10:00:00+08:00'  # 不写也会从文件名解析日期，建议显式写
slug = 'hugo-papermod-mermaid'        # 必须显式写（= 文件名去日期），否则 Hugo 用 title 生成 slug
draft = false
tags = ['hugo', 'papermod']
+++
```

**带图片/附件的文章（Page Bundle）：** 有截图、Mermaid 导出 SVG、本地图片时，用文件夹模式（不要塞进 `static/`）：
```
content/posts/2026-08-14-hugo-mermaid-demo/
├── index.md          # 文章正文
├── diagram.svg
└── screenshot.png
```
文章内引用图片直接写 `![图](diagram.svg)`，无需 `/static` 前缀，整文件夹可整体迁移，兼容 Obsidian。

**URL / permalinks：**
- 项目已配置 `permalinks`（见 `hugo.toml`），文章 URL 为 `/posts/年/月/slug/`
- `:slug` 取自 frontmatter 的 `slug` 字段；**未写 `slug` 时 Hugo 用 `title` 的 urlize 生成**，可能中文粘连、`#` 等特殊字符进入 URL——所以必须显式写 `slug`
- 希望 URL 全英文：`slug` 写英文，frontmatter `title` 写中文用于页面展示

**新建文章：**
```bash
# 普通文章（带日期）
hugo new content posts/2026-08-14-hugo-papermod-mermaid.md
# Page Bundle（文件夹模式）
hugo new content posts/2026-08-14-hugo-mermaid-bundle/index.md
```

**命名速查：**
- 对外发布文章：`content/posts/YYYY-MM-DD-短标题.md`（空格换 `-`、小写、frontmatter 显式写 `date`）
- 带图片/资源的文章：Page Bundle 文件夹模式
- 内部知识库笔记（`content/notes/`）：不带日期，纯标题文件名

### 主题：PaperMod

PaperMod 是一个快速、极简的 Hugo 主题，特性包括：
- 深色/浅色模式切换
- 内置搜索（基于 Fuse.js）
- 多语言 i18n 支持（47 种语言）
- 如需自定义，在项目级的 `layouts/`、`assets/`、`static/` 中创建对应文件即可覆盖主题默认行为（Hugo 合并策略）。

### 自定义布局

- **Mermaid 图表代码块**：直接在 Markdown 中使用 `mermaid` 原生代码块（三反引号 + `mermaid` 语言标识），Hugo 通过 `layouts/_default/_markup/render-codeblock-mermaid.html` 渲染为 `<div class="mermaid">`，无需 shortcode：

      ```mermaid
      graph TD
          A[开始] --> B[结束]
      ```

- **条件加载 Mermaid CDN**：`layouts/_partials/extend_head.html`，仅在含 Mermaid 图表的页面加载 `mermaid@11` 库
- **数学公式支持（KaTeX）**：`hugo.toml` 中配置了 Goldmark Passthrough 扩展（支持行内 `$ ... $` / `\( ... \)` 与块级 `$$ ... $$` / `\[ ... \]`），并通过 `layouts/_partials/extend_head.html` 自动加载 KaTeX CDN 进行客户端公式渲染。

### 部署

站点通过 `.github/workflows/deploy.yml` 部署到 GitHub Pages：
- 触发条件：推送 `main` 分支或手动 `workflow_dispatch`
- 使用 Hugo extended 版本，执行 `hugo --minify --gc`
- 构建产物上传为 Pages artifact，由 `actions/deploy-pages@v4` 部署

PaperMod 主题也包含参考工作流 `themes/PaperMod/.github/workflows/gh-pages.yml`，可作为配置自动部署的参考。
