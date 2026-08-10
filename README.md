# LeafCxy's Blog

基于 [Hugo](https://gohugo.io/) + [PaperMod](https://github.com/adityatelange/hugo-PaperMod) 的个人博客，部署于 [GitHub Pages](https://leafcxy.github.io/)。

## 本地开发

```bash
# 克隆仓库（含主题子模块）
git clone --recurse-submodules https://github.com/leafcxy/leafcxy.github.io.git

# 启动开发服务器
hugo server -D

# 构建
hugo
```

## 创建文章

```bash
hugo new content posts/文章名.md
```

## 目录结构

```
├── hugo.toml              # 站点配置
├── archetypes/            # 文章模板
├── assets/                # SCSS/CSS/JS 覆盖
├── content/               # 文章内容
├── layouts/               # 自定义布局（覆盖主题）
├── static/                # 静态文件
└── themes/PaperMod/       # 主题（git submodule）
```

## 部署

推送 `main` 分支后，GitHub Actions 自动构建并部署到 GitHub Pages。
