+++
title = 'Go 1.25 在 Windows 编译的程序无法在你的电脑上运行？原因竟然是这个！'
date = '2026-08-27T18:30:00+08:00'
slug = 'go-1-25-windows-dwarf5-cannot-run'
draft = false
tags = ['Go', 'Windows', 'DWARF', '编译', '踩坑']
+++

> 原文来自知乎专栏：[zhuyasen - Go有引力](https://zhuanlan.zhihu.com/p/1961514850497836260)

升级到 Go 1.25 之后，在 Windows 上编译出来的 `.exe` 双击却提示 **「此应用无法在你的电脑上运行」**？明明 Go 1.24 还好好的，到底发生了什么？答案就藏在一个叫 **DWARF v5** 的调试信息格式里。

---

## 根本原因

从 **Go 1.25** 开始，官方默认启用了 `dwarf5` 实验性功能，编译生成可执行文件时会使用 **DWARF v5 调试信息格式**。

这本身是为了优化调试体验（更紧凑的结构、支持更多元数据），但 Windows PE 格式对 DWARF 的支持非常有限。在 **部分 Windows 版本**（尤其是启用了 SmartScreen / Core Isolation 的 Windows 11 环境）中，系统加载器或安全组件会**直接拒绝**包含 DWARF v5 section 的 EXE 文件，导致上述错误。

---

## DWARF 是什么？

DWARF 是一种标准的**调试信息格式**，用于在二进制文件中存储：

- 源代码行号
- 变量名和类型
- 函数符号
- 栈帧和调试符号表

Go 在编译时把这些信息写入 `.debug_*` 段（sections）里，**运行时并不读取这些调试段**——它们纯粹是给调试器（GDB / Delve）使用的。

---

## DWARF v4 vs v5 对比

| 对比项 | DWARF v4 | DWARF v5 |
|--------|----------|----------|
| 引入时间 | Go ≤ 1.24 默认 | Go ≥ 1.25 默认 |
| 文件体积 | 略大 | 更紧凑（结构优化） |
| 调试信息格式 | 较旧，兼容性好 | 新格式，支持更多元数据 |
| 调试器支持 | GDB / Delve 都支持 | 需新版 GDB / Delve |
| 对运行性能影响 | 无 | 无 |
| Windows 兼容性 | ✅ 稳定 | ❌ 可能导致「此应用无法在你的电脑上运行」 |

DWARF v5 改善的是**调试体验**，而非运行性能。遗憾的是，某些 Windows 安全机制对新格式不买账。

---

## 解决方法

### 临时方案（当次构建）

```bash
set GOEXPERIMENT=nodwarf5
go build .
```

### 永久方案（推荐）

```bash
go env -w GOEXPERIMENT=nodwarf5
```

这会告诉 Go：**不要使用 DWARF v5，回退到 DWARF v4 调试信息格式**。

设置后，编译产物恢复兼容性，`.exe` 可以在 Windows 上正常加载执行。

---

## 三种情况对比

| 项目 | Go 1.24.x | Go 1.25.x（默认） | Go 1.25.x + nodwarf5 |
|------|-----------|-------------------|----------------------|
| 调试信息格式 | DWARF v4 | DWARF v5 | DWARF v4 |
| Windows 构建兼容性 | ✅ 稳定 | ❌ 可能报错 | ✅ 稳定 |
| 链接方式 | 内部链接器 | 外部链接器 | 外部或内部均可 |
| 推荐用途 | 全面兼容 | 实验性 | 推荐作为默认设置 |

---

## Go 1.25.x 其他实验性功能

Go 1.25 同期还引入了几个值得关注的 `GOEXPERIMENT` 选项：

| 功能 | 说明 |
|------|------|
| `greenteagc` | 新的垃圾回收器，旨在降低高并发、小对象频繁分配服务中的 GC 开销 |
| `jsonv2` | `encoding/json` 包的新实现，提供更快的解码速度 |
| `nodwarf5` | 禁用 DWARF v5 调试信息，回退到 v4，解决 Windows 兼容性问题 |

可以同时启用多个：

```bash
GOEXPERIMENT=greenteagc,jsonv2 go build .
```

---

## 小结

- Go 1.25 默认启用 DWARF v5，导致部分 Windows 环境无法运行编译产物。
- 影响范围：启用了 SmartScreen / Core Isolation 的 Windows 11，以及部分使用外部链接器的场景。
- **一行命令搞定**：`go env -w GOEXPERIMENT=nodwarf5`
- 这是调试信息格式的兼容性问题，与运行性能无关，设置 `nodwarf5` 没有性能损失。

> 如果你的团队有 Windows 发布需求，建议在 CI/CD 流程中统一加上此环境变量，避免发布后出现兼容性问题。
