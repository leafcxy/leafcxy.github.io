---
title: WaitCallback
date: 2023-06-15 13:15:42
tags:
---

`WaitCallback` 委托一般用于将方法异步执行到线程池线程上。线程池是一组可重用的线程，可以在需要时分配线程来执行工作，而不需要创建新的线程。使用线程池可以避免频繁地创建和销毁线程，从而提高应用程序的性能和可伸缩性。

<!-- more -->

通常，您可以使用 `ThreadPool.QueueUserWorkItem` 方法将方法异步执行到线程池线程上，并使用 `WaitCallback` 委托来表示要执行的方法。在这种情况下，`WaitCallback` 委托的参数是一个 `object` 类型的对象，该对象可以包含要传递给方法的数据。

例如，以下代码演示了如何使用 `WaitCallback` 委托和 `ThreadPool.QueueUserWorkItem` 方法：

```csharp
WaitCallback callback = new WaitCallback(MyMethod);
ThreadPool.QueueUserWorkItem(callback, data);

private void MyMethod(object state)
{
    // 执行一些工作
}
```

在这个例子中，`MyMethod` 方法将在线程池线程上异步执行。`data` 对象将作为 `state` 参数传递给 `MyMethod` 方法。
