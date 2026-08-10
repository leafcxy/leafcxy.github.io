# CLAUDE.md

此文件为 Claude Code (claude.ai/code) 在此仓库中工作时提供指导。

## 项目概述

基于 [Hugo](https://gohugo.io/) 静态站点生成器的个人博客，使用 [PaperMod](https://github.com/adityatelange/hugo-PaperMod) 主题，部署于 GitHub Pages：`https://leafcxy.github.io/`。

## 常用命令

```bash
# 安装 Hugo（需要 extended 版本以支持 SCSS/Sass）
# Windows: choco install hugo-extended  或  winget install Hugo.Hugo.Extended

# 启动开发服务器（含草稿内容，热重载）
hugo server -D

# 构建站点（输出到 public/ 目录）
hugo

# 创建新文章
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
│   └── default.md         # 新文章的默认 frontmatter
├── assets/                # SCSS/CSS/JS 覆盖（Hugo Pipes 处理）
├── content/               # Markdown 内容（文章、页面）
├── layouts/               # 自定义布局覆盖（覆盖主题默认布局）
├── static/                # 静态文件，直接复制到输出目录
├── themes/
│   └── PaperMod/          # 主题（git 子模块）
└── public/                # 构建产物（gitignore，由 GitHub Actions 部署）
```

### 配置文件 (`hugo.toml`)

- **baseURL**: `https://leafcxy.github.io/`
- **locale**: `en-us`
- **theme**: PaperMod（从 `themes/PaperMod/` 加载）

### 内容模型

- 文章存放于 `content/posts/` 目录，使用 Markdown 文件，frontmatter 以 `+++` 包裹的 TOML 格式书写。
- 草稿文章（`draft = true`）不会出现在生产构建中，但可通过 `hugo server -D` 预览。
- `archetypes/default.md` 定义了新文章的默认 frontmatter 字段：`date`、`draft`、`title`。

### 主题：PaperMod

PaperMod 是一个快速、极简的 Hugo 主题，特性包括：
- 深色/浅色模式切换
- 内置搜索（基于 Fuse.js）
- 多语言 i18n 支持
- 如需自定义，在项目级的 `layouts/`、`assets/`、`static/` 中创建对应文件即可覆盖主题默认行为（Hugo 合并策略）。

### 部署

站点部署到 GitHub Pages。PaperMod 主题自带 GitHub Actions 工作流（`themes/PaperMod/.github/workflows/gh-pages.yml`），可作为配置自动部署的参考。
