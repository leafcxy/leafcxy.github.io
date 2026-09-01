+++
title = 'git filter-repo：彻底清理 Git 仓库历史（大文件 / 敏感信息）'
date = '2026-09-01T10:00:00+08:00'
slug = 'git-filter-repo-clean-history'
draft = false
tags = ['git', 'filter-repo', '教程', '安全']
+++

仓库用了几年之后，`.git` 目录常常比源码本身还大——曾经提交过的大文件、误传的密钥、不小心提交的 `node_modules`，都永久留在了历史里。它们不会因为你后来删掉文件而消失，只要别人 `git clone` 一下，这些包袱就会被整个拖下来。本文介绍 **git filter-repo**，Git 官方推荐的历史重写工具，用来把这些垃圾彻底清出仓库历史。

<!-- more -->

## 为什么需要重写历史

很多人以为「删掉文件再提交」就完事了，其实不是。Git 的历史是不可变的追加结构，每一个 commit 都指向上一个 commit。你删除一个大文件，只是在**新的** commit 里移除了它；而**旧的** commit 仍然引用着那个 blob，它依旧躺在 `.git/objects` 里。

这意味着：

- `.git` 目录体积不会变小，`git clone` 依然要把整个历史（含那些大文件）拖下来；
- 误提交的密钥 / 密码 / 内网地址，即使后来删了，别人翻一下历史 `git log -p` 就能翻出来；
- 想彻底抹掉，只能**重写历史**——重新生成一批 commit，把不该存在的内容从所有版本里剔除。

历史上做这件事的标准工具是 `git filter-branch`，但它又慢又容易出错，Git 官方文档现在直接建议改用 **git filter-repo**（由 GitHub 前工程师 Elijah Newren 编写）。相比 filter-branch，filter-repo 快几个数量级，且内置了大量安全校验，防止误操作。

## 安装

`git filter-repo` 是一个 Python 脚本，安装 Python 后通过 pip 安装：

```bash
pip install git-filter-repo
```

验证是否装好：

```bash
git filter-repo --version
```

> 如果你不方便用 pip，也可以直接从 [官方仓库](https://github.com/newren/git-filter-repo) 下载那个单文件脚本 `git-filter-repo`，放到 `PATH` 里的某个目录即可（它就是一个独立的 Python 脚本，无第三方依赖）。

## 核心工作流程

filter-repo 有一个硬性约束：**它只应该在「全新克隆」（fresh clone）出来的仓库上运行**，并且运行后会主动移除 `origin` 远程，防止你不小心把改写后的历史直接推回原仓库。标准的操作流程如下：

```bash
# 1. 克隆一个镜像仓库（bare 镜像，包含所有 ref）
git clone --mirror https://github.com/user/repo.git

# 2. 进入镜像仓库目录
cd repo.git

# 3. 执行清理操作（后面详述各种场景）
git filter-repo --strip-blobs-bigger-than 10M

# 4. 检查结果，确认无误后强推回远端
git push --force origin
```

这里有几个关键点需要先说明：

1. **备份优先**：重写历史不可逆。`git clone --mirror` 出来的那个目录本身就是一份完整备份，动手前先把这份镜像留好，出问题随时能从头再来。
2. **fresh clone 很重要**：不要在你自己平时工作的、带本地分支和 stash 的仓库上直接跑。filter-repo 会检查仓库状态，如果检测到不是 fresh clone 会拒绝执行。这不是刁难你，而是保护你。
3. **commit 的 hash 全部改变**：历史重写后，所有 commit 的 SHA 都会变（因为内容变了）。所有协作者必须**重新克隆**仓库，不能再基于旧历史继续推送。

## 常见场景

### 1. 分析仓库：先搞清楚垃圾在哪

在动手之前，先用 `--analyze` 生成一份仓库体检报告，看看历史里到底什么占地方、什么文件反复被改：

```bash
git filter-repo --analyze
```

这个命令**不会修改任何历史**，只会在仓库目录下生成 `.git/filter-repo/analysis/` 目录，里面有一堆报告文件：

```text
.git/filter-repo/analysis/
├── README                       # 报告使用说明
├── blob-shas-and-paths.txt      # 每个 blob 及其出现的路径
├── path-all-sizes.txt           # 各路径在当前版本中的大小
├── path-deleted-sizes.txt       # 各路径「已被删除内容」的累计大小
├── directory-all-sizes.txt      # 各目录的总体大小
├── deletions.txt                # 被删除的文件清单
└── commits-by-deleted-size.txt  # 按删除体积排序的 commit
```

其中 `path-deleted-sizes.txt` 和 `commits-by-deleted-size.txt` 最能反映问题——前者告诉你哪些路径历史上堆积了大量被删内容，后者直接指出是哪几次提交塞进了大文件。看完报告再决定清理策略，比盲目 `--strip-blobs-bigger-than` 靠谱得多。

### 2. 删除大文件

最常用的场景：历史里某个版本引入过超大文件（安装包、数据库 dump、视频、`*.zip` 等）。按大小一刀切：

```bash
git filter-repo --strip-blobs-bigger-than 10M
```

这会把**所有历史版本中**体积超过 10M 的 blob 全部删除（用占位内容替换）。`10M` 支持 `K`/`M`/`G` 等单位。

### 3. 删除指定路径 / 文件

只想删掉某个文件或目录，可以用 `--path` 配合 `--invert-paths`（`--invert-paths` 表示「排除」列出的路径）：

```bash
# 从所有历史中删除这个文件
git filter-repo --path filename.txt --invert-paths

# 删除整个目录（注意：路径是相对仓库根的）
git filter-repo --path node_modules/ --invert-paths

# 也可以用 glob 模式
git filter-repo --path '*.zip' --path '*.tar.gz' --invert-paths
```

反过来，`--path` 不带 `--invert-paths` 时表示「**只保留**这些路径」。这个能力可以做一件很有用的事——**把子目录拆分成独立的仓库**：

```bash
# 只保留 lib/ 目录，且把它变成新仓库的根目录
git filter-repo --path lib/
```

执行后，原来的 `lib/foo.c` 会变成新仓库根下的 `foo.c`，一个 monorepo 就能拆成若干个独立仓库。

### 4. 替换敏感信息

密钥、密码、内网 IP 这类文本，光删文件不够，还得把历史里**所有出现过这些字符串的地方**都替换掉。使用 `--replace-text`，规则写在一个文本文件里，格式为 `原文==>替换后`：

```text
# replacements.txt
password123==>***REMOVED***
10.0.0.100==>***REMOVED***
```

然后执行：

```bash
git filter-repo --replace-text replacements.txt
```

规则文件支持三种匹配模式：

| 前缀 | 匹配对象 | 示例 | 含义 |
| :--- | :--- | :--- | :--- |
| （无前缀） | blob 内容（字面量） | `password123==>***REMOVED***` | 精确替换字符串 |
| `regex:` | blob 内容（正则） | `regex:password\w+==>***REMOVED***` | 正则替换，支持 `\1` 反向引用 |
| `glob:` | 文件路径（glob） | `glob:*.pem==>***REMOVED***` | 匹配到的文件，整个内容替换 |

最后一行 `glob:` 特别有用——像 `*.pem`、`*.key`、`id_rsa` 这类私钥文件，你不必知道它们内容是什么，直接按文件名把所有版本里的内容抹掉即可。

> 提示：`--replace-text` 默认还会把 `replacements.txt` 里写到的「原字符串」本身（比如 `password123`）也列入清理目标，避免规则文件泄密。这属于 filter-repo 内置的安全细节。

### 5. 重写作者 / 邮箱信息

如果历史里混入了错误的作者名、公司邮箱或个人邮箱，用 `--mailmap` 批量纠正。`.mailmap` 是 Git 原生支持的作者映射格式：

```text
# .mailmap
正确名字 <correct@example.com> 旧名字 <old@example.com>
正确名字 <correct@example.com> <other@example.com>
```

```bash
git filter-repo --mailmap .mailmap
```

这比挨个 `--commit-callback` 改省事得多，尤其适合「换公司了，想把历史里的工作邮箱统一换掉」这类需求。

## 注意事项

清理完成后，还有几件事必须做对，否则前面的功夫会白费甚至帮倒忙：

1. **确认无误再强推**：改写只发生在本地镜像里。推回远端必须 `git push --force`（force 是必然的，因为历史变了），但请先 `git log`、`git count-objects -vH` 检查一下结果是否符合预期。
2. **通知所有协作者重新克隆**：这是重写历史最大的「代价」。所有同事都要删掉旧仓库，重新 `git clone`。任何基于旧历史的分支、未推送的本地提交，都无法再合入——必须在动手前跟团队同步好。
3. **留好备份与回滚路径**：`git clone --mirror` 的目录本身就是备份；如果推上去之后发现问题，也可以用备份里的旧 ref 强推回去（当然，前提是还没人基于新历史继续提交）。
4. **remote 被移除是特性**：filter-repo 跑完会把 `origin` 删掉。这是防止你在 fresh clone 上误 `push`。需要推送时自己 `git remote add origin <url>` 再加回来。

## 总结

`git filter-repo` 是当前清理 Git 历史的事实标准工具，比 `filter-branch` 快得多、安全得多。它的使用套路可以概括为「**分析 → 改写 → 强推 → 通知重克隆**」：

- `--analyze` 先摸清仓库「病灶」；
- `--strip-blobs-bigger-than` 删大文件、`--path`/`--invert-paths` 删指定路径、`--replace-text` 抹敏感内容、`--mailmap` 改作者；
- 一切在 fresh clone 的镜像上做，`--force` 推送前务必检查；
- 历史重写后 commit hash 全变，**所有协作者重新克隆**是绕不开的一步。

重写历史是一把「伤筋动骨」的手术刀——它能彻底抹掉那些不该存在的内容，但也切断了所有人手里的历史连续性。所以它更适合在「仓库还小、协作者还少」的时候尽早做；等到几十个人都基于旧历史各自开发时再动手，成本就会高得多。**与其事后清理，不如一开始就用 `.gitignore` 和 pre-commit 钩子把大文件、密钥挡在门外。**
