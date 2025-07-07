---
title: 特性和反射
date: 2023-07-26 16:35:21
tags:
---

以下是一个示例，展示了如何定义和使用特性，并使用反射来获取特性信息：

<!-- more -->

```csharp
using System;
using System.Reflection;

// 自定义特性类
[AttributeUsage(AttributeTargets.Class | AttributeTargets.Method, AllowMultiple = true)]
class MyCustomAttribute : Attribute
{
    public string Description { get; }

    public MyCustomAttribute(string description)
    {
        Description = description;
    }
}

// 带有特性的类
[MyCustom("This is a class attribute")]
class MyClass
{
    [MyCustom("This is a method attribute")]
    public void MyMethod()
    {
        Console.WriteLine("Hello from MyMethod");
    }
}

class Program
{
    static void Main()
    {
        // 使用反射获取类的特性
        Type classType = typeof(MyClass);
        MyCustomAttribute[] classAttributes = (MyCustomAttribute[])classType.GetCustomAttributes(typeof(MyCustomAttribute), true);
        foreach (MyCustomAttribute attribute in classAttributes)
        {
            Console.WriteLine("Class Attribute: " + attribute.Description);
        }

        // 使用反射获取方法的特性
        MethodInfo methodInfo = classType.GetMethod("MyMethod");
        MyCustomAttribute[] methodAttributes = (MyCustomAttribute[])methodInfo.GetCustomAttributes(typeof(MyCustomAttribute), true);
        foreach (MyCustomAttribute attribute in methodAttributes)
        {
            Console.WriteLine("Method Attribute: " + attribute.Description);
        }

        // 等待用户输入，防止控制台窗口关闭
        Console.ReadLine();
    }
}
```

在这个示例中，我们首先定义了一个自定义特性类 `MyCustomAttribute`，它继承自 `Attribute`。然后，我们在 `MyClass` 类和 `MyMethod` 方法上应用了 `MyCustomAttribute` 特性，并传入了相应的描述信息。

在 `Main` 方法中，我们使用反射获取了 `MyClass` 类和 `MyMethod` 方法的特性信息。通过调用 `GetCustomAttributes` 方法并指定特性类型，我们可以获取到应用在类和方法上的特性对象数组。然后，我们遍历特性数组，并打印出特性的描述信息。

请注意，特性和反射是 C# 中强大的功能，可以用于实现各种元编程和自定义行为。在实际应用中，您可以根据需要定义和使用不同的特性，并使用反射来获取特性信息并进行相应的处理。
