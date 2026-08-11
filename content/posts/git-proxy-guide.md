+++
date = '2026-08-11T10:00:00+08:00'
draft = false
title = 'Git 代理配置完全指南'
tags = ['git', 'proxy', 'network']
+++

这篇文章梳理 Git 中所有代理配置方式，从简单的 `git config` 到 SSH 协议的 SOCKS5 隧道，一份指南全搞定。

<!-- more -->

## 为什么需要代理

访问 GitHub、GitLab 等平台时，有时会遇到 `git clone` 速度极慢甚至超时的情况。尤其是在国内网络环境下，给 Git 配置代理几乎是必备技能。

{{< mermaid >}}
flowchart LR
    A[你的电脑] --> B{需要代理？}
    B -->|直连通畅| C[直接连接 Git 服务器]
    B -->|速度慢/超时| D[代理服务器]
    D --> E[Git 服务器<br/>github.com<br/>gitlab.com]
    C --> E
{{< /mermaid >}}

## 配置方式总览

Git 提供多种配置代理的途径，优先级从高到低：

| 配置方式 | 持久性 | 作用范围 |
|----------|--------|----------|
| `-c` 命令行参数 | 单次命令 | 单仓库 |
| `git config --local` | 写入 `.git/config` | 单个仓库 |
| `git config --global` | 写入 `~/.gitconfig` | 当前用户 |
| 环境变量 | Shell 会话级 | 当前终端 |

{{< mermaid >}}
graph TD
    A[Git 发起网络请求] --> B{有 -c 参数？}
    B -->|是| F[使用 -c 指定的代理]
    B -->|否| C{有 local 配置？}
    C -->|是| G[使用 local 代理]
    C -->|否| D{有 global 配置？}
    D -->|是| H[使用 global 代理]
    D -->|否| E{有环境变量？}
    E -->|是| I[使用环境变量代理]
    E -->|否| J[直连]
{{< /mermaid >}}

## 一、HTTP/HTTPS 代理

这是最常用的方式，适用于 `https://` 协议的仓库。

### 1.1 配置命令

```bash
# 全局设置
git config --global http.proxy  http://127.0.0.1:7890
git config --global https.proxy http://127.0.0.1:7890

# 仅对当前仓库设置
git config --local http.proxy  http://127.0.0.1:7890

# 查看当前配置
git config --global --get http.proxy

# 取消代理
git config --global --unset http.proxy
git config --global --unset https.proxy
```

### 1.2 带认证的代理

```bash
# 用户名密码认证
git config --global http.proxy http://user:pass@127.0.0.1:7890

# 特殊字符需要 URL 编码，@ → %40，: → %3A
git config --global http.proxy http://user:p%40ss@127.0.0.1:7890
```

### 1.3 针对特定域名

只想给 GitHub 走代理，公司内网 GitLab 直连？按域名精准控制：

```bash
# 仅对 github.com 配置代理
git config --global http.https://github.com.proxy http://127.0.0.1:7890

# 取消特定域名的代理
git config --global --unset http.https://github.com.proxy
```

{{< mermaid >}}
flowchart LR
    subgraph 全局模式
        GA[所有 HTTPS 请求] -->|http.proxy| P1[代理 127.0.0.1:7890]
    end
    subgraph 按域名模式
        GH[github.com] -->|http.https://github.com.proxy| P2[代理 127.0.0.1:7890]
        GL[gitlab.company.com] --> D[直连]
    end
{{< /mermaid >}}

## 二、SOCKS5 代理

Clash、V2Ray 等工具通常提供 SOCKS5 端口，比 HTTP 代理更通用。

```bash
# SOCKS5 代理（7891 是 Clash 默认 SOCKS5 端口）
git config --global http.proxy  socks5://127.0.0.1:7891
git config --global https.proxy socks5://127.0.0.1:7891

# 如果 DNS 也需要走代理（防止 DNS 污染）
git config --global http.proxy  socks5h://127.0.0.1:7891
#                                    ↑ socks5h = 代理服务器解析 DNS
```

> `socks5://` 与 `socks5h://` 的区别：`socks5h` 让代理服务器解析域名，避免本地 DNS 污染。

## 三、SSH 协议的代理

大多数开发者使用 SSH 协议 clone（`git@github.com:user/repo.git`）。SSH 不走 HTTP 代理，需要特殊配置。

### 3.1 使用 `core.gitProxy`（Git 2.44+）

```bash
# 使用 socat（需预先安装）
git config --global core.gitProxy 'socat - SOCKS5:127.0.0.1:%h:%p'

# 使用 connect（Windows Git 自带）
git config --global core.gitProxy 'connect -S 127.0.0.1:7891 %h %p'

# 使用 netcat
git config --global core.gitProxy 'nc -X 5 -x 127.0.0.1:7891 %h %p'
```

### 3.2 传统方式：配置 `~/.ssh/config`

```ssh-config
# ~/.ssh/config
Host github.com
    HostName github.com
    User git
    Port 22
    # macOS/Linux
    ProxyCommand nc -X 5 -x 127.0.0.1:7891 %h %p
    # Windows (Git Bash 自带 connect)
    # ProxyCommand connect -S 127.0.0.1:7891 %h %p
```

{{< mermaid >}}
sequenceDiagram
    participant U as 你的电脑
    participant P as SOCKS5 代理<br/>127.0.0.1:7891
    participant G as github.com:22

    U->>P: SSH 连接请求
    Note over U,P: ProxyCommand nc -X 5 -x<br/>127.0.0.1:7891 github.com 22
    P->>G: 转发到目标服务器
    G-->>P: SSH 握手响应
    P-->>U: 返回 SSH 连接
    Note over U,G: Git 数据通过 SSH 隧道安全传输
{{< /mermaid >}}

## 四、环境变量方式

不想写 Git 配置？用环境变量一次性搞定：

```bash
# Linux / macOS
export http_proxy=http://127.0.0.1:7890
export https_proxy=http://127.0.0.1:7890
export all_proxy=socks5://127.0.0.1:7891     # 全部协议走 SOCKS5

# Windows PowerShell
$env:http_proxy="http://127.0.0.1:7890"
$env:https_proxy="http://127.0.0.1:7890"

# 取消
unset http_proxy https_proxy all_proxy
```

> 环境变量仅对当前终端会话有效。`no_proxy` 可排除特定域名：`export no_proxy=localhost,127.0.0.1,.local`

## 五、常见代理工具端口对照

| 工具 | HTTP 端口 | SOCKS5 端口 | 说明 |
|------|-----------|-------------|------|
| Clash Verge | 7890 | 7891 | 最流行的跨平台代理客户端 |
| V2Ray | 10809 | 10808 | 配合 v2rayN 使用 |
| SS/SSR | 1080 | — | 需配合 Privoxy 转 HTTP |
| 公司代理 | 8080 | — | 通常需要用户名密码认证 |

### Clash 完整配置示例

```bash
# Clash 默认：HTTP 7890, SOCKS 7891

# HTTPS 仓库走 HTTP 代理
git config --global http.proxy  http://127.0.0.1:7890
git config --global https.proxy http://127.0.0.1:7890

# SSH 仓库走 SOCKS5（~/.ssh/config）
# Host github.com
#     ProxyCommand nc -X 5 -x 127.0.0.1:7891 %h %p
```

## 六、快速开关代理的别名

每次都敲长命令太麻烦？给 shell 配个 alias：

```bash
# ~/.bashrc 或 ~/.zshrc

# 开启代理
alias gitproxy='git config --global http.proxy http://127.0.0.1:7890 && \
                git config --global https.proxy http://127.0.0.1:7890 && \
                echo "Git 代理已开启 ✓"'

# 关闭代理
alias gitnoproxy='git config --global --unset http.proxy && \
                  git config --global --unset https.proxy && \
                  echo "Git 代理已关闭 ✗"'

# 查看状态
alias gitproxystatus='echo "HTTP:  $(git config --global --get http.proxy)"; \
                      echo "HTTPS: $(git config --global --get https.proxy)"'
```

## 七、配置文件完整参考

一个典型的 `~/.gitconfig` 代理配置段：

```ini
[http]
    proxy = http://127.0.0.1:7890

[https]
    proxy = http://127.0.0.1:7890

# 针对 GitHub 的独立配置
[http "https://github.com"]
    proxy = socks5h://127.0.0.1:7891

[core]
    # SSH 代理（Git 2.44+）
    gitProxy = connect -S 127.0.0.1:7891 %h %p
```

## 八、故障排查

```bash
# 1. 检查全局代理配置
git config --global --get http.proxy
git config --global --get https.proxy

# 2. 检查当前仓库的 local 配置
git config --local --list | grep proxy

# 3. 测试到 GitHub 的 SSH 连接
ssh -T git@github.com

# 4. 使用 GIT_TRACE 调试网络请求（详细输出）
GIT_TRACE=1 GIT_CURL_VERBOSE=1 git clone https://github.com/user/repo.git
```

## 总结

{{< mermaid >}}
graph LR
    Q[需要 clone/push] --> R{什么协议？}
    R -->|HTTPS| S{需要范围？}
    S -->|临时| T["git -c http.proxy=... clone"]
    S -->|全局| U["git config --global http.proxy"]
    S -->|部分域名| V["http.https://xxx.com.proxy"]

    R -->|SSH| W{需要范围？}
    W -->|Git 2.44+| X["core.gitProxy"]
    W -->|通用| Y["~/.ssh/config<br/>ProxyCommand"]
{{< /mermaid >}}

| 场景 | 推荐方案 |
|------|----------|
| 临时 clone 一个仓库 | `git -c http.proxy=... clone` |
| 只用 HTTPS 协议 | `git config --global http.proxy` |
| 主要用 SSH 协议 | 配置 `~/.ssh/config` 的 ProxyCommand |
| 部分站点走代理 | 按域名配置 `http.https://xxx.com.proxy` |
| 不想改 Git 配置 | 设置 `http_proxy` 环境变量 |

选对方案，`git clone` 再也不转圈。
