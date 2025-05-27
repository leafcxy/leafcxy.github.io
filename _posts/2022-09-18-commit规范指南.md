---
title: commit规范指南
date: 2022-09-18 09:52:32
tags:
---

## Commit Message格式

```xml
<type>(<scope>): <subject>
<BLANK LINE>
<body>
<BLANK LINE>
<footer>
```

<!-- more -->

### type(必填)

`type`用于说明 commit 的类别

feat：新增功能  
fix：bug 修复  
docs：文档更新  
style：不影响程序逻辑的代码修改(修改空白字符，格式缩进，补全缺失的分号等，没有改变代码逻辑)  
refactor：重构代码(既没有新增功能，也没有修复 bug)  
perf：性能, 体验优化  
test：新增测试用例或是更新现有测试  
build：主要目的是修改项目构建系统(例如 glup，webpack，rollup 的配置等)的提交  
ci：主要目的是修改项目继续集成流程(例如 Travis，Jenkins，GitLab CI，Circle等)的提交  
chore：不属于以上类型的其他类，比如构建流程, 依赖管理  
revert：回滚某个更早之前的提交  

### scope(可选)

`scope`用于说明 commit 影响的范围，比如数据层、控制层、视图层等等，视项目不同而不同

### subject(必填)

`subject`是 commit 目的的简短描述

### body(可选)

`body`部分是对本次 commit 的详细描述，可以分成多行

### footer(可选)

1. 不兼容变动: 以`BREAKING CHANGE`开头，后面是对变动的描述、以及变动理由和迁移方法
2. 关闭issue: `Closes #123, #245, #992`

### Revert(特殊)

如果当前 commit 用于撤销以前的 commit，则必须以 `revert:` 开头，后面跟着被撤销 Commit 的 Header

```js
revert: feat(pencil): add 'graphiteWidth' option

This reverts commit 667ecc1654a317a13331b17617d973392f415f02.
```
