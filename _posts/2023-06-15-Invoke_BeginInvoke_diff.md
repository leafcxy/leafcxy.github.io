---
title: Invoke与BeginInvoke的不同
date: 2023-06-15 11:39:12
tags:
- C#
- winform
---

<!-- more -->

不同点：
Invoke是同步更新，会阻塞所在工作者线程，BeginInvoke是异步更新，不会阻塞当前线程。
Invoke调用后将指定代码立即插入主线程中执行，而BeginInvoke调用后，发送消息给UI线程，
相当于向Dispatcher队列中添加工作项，待之前UI更新任务完成后，再执行BeginInvoke中的内容。
在使用场景上，Invoke方法会拖延线程直到执行完指定代码，如果需要暂停异步操作，直到用户提供反馈信息，可使用Invoke，
比如指定代码弹出YES/NO对话框，需要根据用户反馈以进一步执行操作的场景。
相同点：两者虽然一个为同步，一个为异步，实际是运行在同一线程，即UI主线程。
