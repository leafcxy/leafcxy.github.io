# LeafCxy's Blog

基于 [Hugo](https://gohugo.io/) + [PaperMod](https://github.com/adityatelange/hugo-PaperMod) 的个人博客，部署于 [GitHub Pages](https://leafcxy.github.io/)。

站点语言为中文（`zh-cn`），支持深色/浅色模式切换、全文搜索（Fuse.js）、Mermaid 图表。

## 本地开发

```bash
# 克隆仓库（含主题子模块）
git clone --recurse-submodules https://github.com/leafcxy/leafcxy.github.io.git

# 启动开发服务器（含草稿内容）
hugo server -D

# 构建
hugo
```

## 创建文章

```bash
hugo new content posts/文章名.md
```

新文章默认使用 TOML frontmatter（`+++`），且 `draft = true`。发布前需将 `draft` 改为 `false`。

## 更新 PaperMod 主题

PaperMod 作为 git 子模块管理，不直接修改 `themes/PaperMod/` 中的文件。

```bash
# 更新到上游最新版
cd themes/PaperMod
git fetch origin
git merge origin/master
cd ../..

# 或一条命令
git submodule update --remote themes/PaperMod

# 更新后提交子模块引用
git add themes/PaperMod
git commit -m "更新 PaperMod 主题子模块"
```

> 更新后建议 `hugo server -D` 验证站点正常，大版本更新可能有破坏性变更。

## 目录结构

```
├── hugo.toml              # 站点配置
├── archetypes/            # 文章模板
├── assets/                # SCSS/CSS/JS 覆盖（Hugo Pipes）
├── content/               # 文章与页面
│   ├── posts/             # 博客文章
│   ├── search.md          # 搜索页
│   └── archives.md        # 归档页
├── data/                  # Hugo 数据文件
├── i18n/                  # 国际化翻译覆盖
├── layouts/               # 自定义布局（覆盖主题）
│   ├── _partials/         # 模板片段（如 Mermaid CDN 加载）
│   └── shortcodes/        # 短代码（如 Mermaid 图表）
├── static/                # 静态文件
├── themes/PaperMod/       # 主题（git submodule）
└── .github/workflows/     # GitHub Actions 自动部署
```

## 部署

推送 `main` 分支后，GitHub Actions 自动构建并部署到 GitHub Pages。
