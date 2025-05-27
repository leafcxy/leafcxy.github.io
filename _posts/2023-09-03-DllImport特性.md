---
title: DllImport特性
date: 2023-09-03 14:36:56
tags:
---

在C#中，DllImport是一种特性，它被用于指定在本地代码中调用的DLL（动态链接库）的入口点。DllImport特性通常被应用于C#中的托管代码中，以便调用由C、C++或者其他非托管语言编写的DLL。

<!-- more -->

使用DllImport特性，你可以在C#中调用DLL中的函数，而不需要了解该DLL的内部实现细节。这使得C#能够与各种不同的外部库进行交互，并扩展了C#的功能。

DllImport特性的语法如下：

```csharp
[DllImport("dllname.dll", CallingConvention = CallingConvention.Cdecl)]  
public static extern returnType functionName(parameterList);
```

其中：

- "dllname.dll" 是包含目标函数的DLL的名称。
- CallingConvention.Cdecl 是调用约定，指定了函数如何传递参数和返回值。
- returnType 是函数的返回类型。
- functionName 是要调用的函数的名称。
- parameterList 是函数的参数列表。

需要注意的是，DllImport特性只能用于托管代码，即由公共语言运行时（CLR）管理的代码。对于非托管代码，如直接调用操作系统API或硬件接口等，需要使用P/Invoke（平台调用服务）来实现。
