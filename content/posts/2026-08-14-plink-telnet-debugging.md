+++
title = 'plink.exe 命令行工具：telnet 连接设备调试与数据采集'
date = '2026-08-14T14:20:00+08:00'
slug = 'plink-telnet-debugging'
draft = false
tags = ['plink', 'putty', 'telnet', '命令行', '调试', '数据采集']
+++

## 引言

最近需要连接一台带网络接口的设备（带电池管理系统的工业设备），通过 telnet 协议读取它的实时测量数据。图形界面的 PuTTY 虽然能连上，但只能手动交互，没法自动采集、落盘、二次处理。于是找到了 PuTTY 套件里那个不起眼的命令行工具——`plink.exe`。

## plink.exe 是什么

plink.exe（PuTTY Link）是 PuTTY 套件中的命令行连接工具，和图形界面 PuTTY 共用同一套协议实现，支持 **SSH、telnet、rlogin、raw** 等多种协议。它是脚本化、自动化运维的利器——凡是 PuTTY 能干的事，都能用一条命令搞定，而且输出可以直接重定向到文件。

<!-- more -->

## 为什么用 plink 而非 PuTTY 图形界面

- **自动化**：可以写进批处理、计划任务，无人值守运行
- **输出可重定向**：结果直接 `> result.txt` 落盘，便于后续解析
- **无交互**：配合 `-batch` 参数完全跳过人工确认
- **脚本友好**：支持管道传命令、`-m` 文件批量命令

## 安装与获取

plink.exe 不需要安装，从 PuTTY 官网下载 `putty.zip` 解压即可。单个 exe 文件，放到 `PATH` 里就能在命令行直接调用。

## telnet 连接基础

最简单的连接方式，`-telnet` 指定协议，后面跟设备地址：

```sh
plink.exe -telnet 192.168.1.100
```

指定端口用 `-P`：

```sh
plink.exe -telnet -P 23 192.168.1.100
```

## 实战：连接设备采集数据

### 场景

设备提供一个 telnet 调试接口，发送 `measure print internal 1000` 命令后，设备会每 1000ms 打印一行内部 ADC 测量数据，形如：

```
Timestamp ADC_UDC_INT ADC_UBAT_EXT ADC_SENSE_12V ADC_RLYMON ADC_TEMP_HALL_SENSOR ADC_UBAT_INT ADC_UDC_EXT ADC_UPE
16783     98.51       100.03       12.48         1.08       25.88                99.66        755.49      45.38
```

每行包含时间戳和 8 个通道的电压、温度采样值，非常适合做长时间的数据采集。

### 管道传命令

最简单的方式，把命令通过管道喂给 plink，输出重定向到文件：

```sh
echo "measure print internal 1000" | plink.exe -telnet "fe80::cc26:c45b:8db6:afcf%19" > result.txt
```

### 批量命令 -m

命令较多时，写进文件用 `-m` 读取，一行一条命令：

```
:: commands.txt
measure print internal 1000
```

```sh
plink.exe -telnet "fe80::cc26:c45b:8db6:afcf%19" -m commands.txt > result.txt
```

### 非交互模式 -batch

脚本化**必须**加 `-batch`，禁用所有交互式提示（否则 SSH 会卡在“是否信任主机密钥”这类确认上）：

```sh
plink.exe -batch -telnet "fe80::cc26:c45b:8db6:afcf%19" -m commands.txt > result.txt
```

## 输出处理：清理 ANSI 转义码

telnet 设备的输出往往带大量控制字符：ANSI 颜色码（`\x1b[1;32m`）、光标移动码（`\x1b[5D`、`\x1b[J`），以及 telnet 协议的协商字节（`\xff` 开头）。

原始输出用 `cat -v` 才能看到这些隐藏字符：

```
^[[1;32mPENG>^[[m^[[5D^[[J16783  98.51  100.03  12.48 ...
```

### 方案一：perl 正则

```sh
plink.exe -batch -telnet "host" -m commands.txt 2>&1 | perl -pe 's/\xff[\xfb\xfc\xfd\xfe].//g; s/\xff\xfa.*?\xff\xf0//g; s/\xff\xff/\xff/g; s/\x1b\[[0-9;]*[A-Za-z]//g' > clean.txt
```

这段正则同时处理了三类垃圾字符：telnet 协商字节、子协商序列、ANSI 颜色/光标码。

### 方案二：VBScript（cscript）

Windows 下没有 perl 时，可以用 VBScript。写一个 `strip_ansi.vbs`：

```vbscript
Set re = New RegExp
re.Global = True
re.Pattern = Chr(27) & "\[[0-9;]*[A-Za-z]"
Set f = CreateObject("Scripting.FileSystemObject")
text = f.OpenTextFile(WScript.Arguments(0)).ReadAll
text = re.Replace(text, "")
f.CreateTextFile(WScript.Arguments(1), True).Write text
```

调用时传入输入文件和输出文件：

```bat
cscript //nologo strip_ansi.vbs raw.txt clean.txt
```

## 踩坑记录

### 坑 1：echo. 的点号陷阱

Windows cmd 里 `echo.` 常被当成“输出一个空行”的惯用法，于是有人写出：

```bat
(echo measure print internal 1000&echo.) | plink.exe -batch -telnet host > raw.txt
```

结果设备报错 `.: command not found`——因为 `echo.` 在某些环境下会真的输出一个点号 `.`，这个孤零零的 `.` 被当成命令发给了设备。

正确的空行写法应该用 `echo(` 或 `echo:`，避免产生点号：

```bat
(echo measure print internal 1000&echo() | plink.exe -batch -telnet host > raw.txt
```

### 坑 2：telnet 协商字节污染数据

telnet 连接建立时会有一串 `\xff` 开头的协商字节，直接写进文件会污染数据。清理时除了 ANSI 颜色码，务必把这些 `\xff` 序列一并处理掉，否则正则匹配会漏。

## 总结

plink.exe 是 PuTTY 套件里被低估的命令行工具。对于需要脚本化连接设备、采集数据、自动化调试的场景，它比图形界面方便得多。核心用法就三个参数：

- `-telnet`：指定协议
- `-m`：批量命令文件
- `-batch`：非交互模式

再加上对输出的 ANSI/telnet 控制字符清理，就能搭起一套轻量的设备数据采集流程，几十行代码都不用写。
