---
title: csharp互操作
date: 2023-11-28 16:19:04
tags: [Blogs, Jekyll, default_tags]
---

## Platform Invoke(P/Invoke)，即平台调用,主要用于调用C库函数和Windows API

<!-- more -->


```csharp
using System;

// 使用平台调用技术进行互操作性之前，首先需要添加这个命名空间
using System.Runtime.InteropServices;

namespace 平台调用Demo
{
    class Program
    {
        // 在托管代码中对非托管函数进行声明，并且附加平台调用所需要属性
        // 在默认情况下，CharSet为CharSet.Ansi
        // 指定调用哪个版本的方法有两种——通过DllImport属性的CharSet字段和通过EntryPoint字段指定
        // 在托管函数中声明注意一定要加上 static 和extern 这两个关键字        [DllImport("user32.dll")]
        public static extern int MessageBox1(IntPtr hWnd, String text, String caption, uint type);

        // 在默认情况下，CharSet为CharSet.Ansi
        [DllImport("user32.dll")]
        public static extern int MessageBoxA(IntPtr hWnd, String text, String caption, uint type);

        // 在默认情况下，CharSet为CharSet.Ansi
        [DllImport("user32.dll")]
        public static extern int MessageBox(IntPtr hWnd, String text, String caption, uint type);

        // 第一种指定方式，通过CharSet字段指定
        [DllImport("user32.dll", CharSet = CharSet.Unicode)]
        public static extern int MessageBox2(IntPtr hWnd, String text, String caption, uint type);

        // 通过EntryPoint字段指定
        [DllImport("user32.dll", EntryPoint="MessageBoxA")]
        public static extern int MessageBox3(IntPtr hWnd, String text, String caption, uint type);

        [DllImport("user32.dll", EntryPoint = "MessageBoxW")]
        public static extern int MessageBox4(IntPtr hWnd, String text, String caption, uint type);
        static void Main(string[] args)
        {
            // 在托管代码中直接调用声明的托管函数
            // 使用CharSet字段指定的方式，要求在托管代码中声明的函数名必须与非托管函数名一样
            // 否则就会出现找不到入口点的运行时错误
            //MessageBox1(new IntPtr(0), "Learning Hard", "欢迎", 0);
            
            // 下面的调用都可以运行正确
            //MessageBoxA(new IntPtr(0), "Learning Hard", "欢迎", 0);
            //MessageBox(new IntPtr(0), "Learning Hard", "欢迎", 0);
            
            // 使用指定函数入口点的方式调用
            //MessageBox3(new IntPtr(0), "Learning Hard", "欢迎", 0);

            // 调用Unicode版本的会出现乱码
            MessageBox4(new IntPtr(0), "Learning Hard", "欢迎", 0);
        }
    }
}
```

## C++ Introp, 主要用于Managed C++(托管C++)中调用C++类库

第二部分主要向大家介绍了第一种互操作性技术，然后我们也可以使用C++ Interop技术来实现与非托管代码进行交互。
然而C++ Interop 方式有一个与平台调用不一样的地方，就是C++ Interop 允许托管代码和非托管代码存在于一个程序集中，甚至同一个文件中。
C++ Interop 是在源代码上直接链接和编译非托管代码来实现与非托管代码进行互操作的，而平台调用是加载编译后生成的非托管DLL并查找函数的入口地址来实现与非托管函数进行互操作的。
`C++ Interop使用托管C++来包装非托管C++代码，然后编译生成程序集，然后再托管代码中引用该程序集，从而来实现与非托管代码的互操作`。

## COM Interop, 主要用于在.NET中调用COM组件和在COM中使用.NET程序集。

在.NET中使用COM对象，主要有3种方法：

1. 使用TlbImp工具为COM组件创建一个互操作程序集来绑定早期的COM对象，这样就可以在程序中添加互操作程序集来调用COM对象
2. 通过反射来后期绑定COM对象
3. 通过P/Invoke创建COM对象或使用C++ Interop为COM对象编写包装类

```csharp
using System;
// 添加额外的命名空间
using Microsoft.Office.Interop.Word;

namespace COM互操作性
{
    class Program
    {
        static void Main(string[] args)
        {
            // 调用COM对象来创建Word文档
            CreateWordDocument();
        }

        private static void CreateWordDocument()
        {
            // 启动Word并使Word可见
            Application wordApp = new Application() { Visible = true };

            // 新建Word文档
            wordApp.Documents.Add();
            Document wordDoc = wordApp.ActiveDocument;
            Paragraph para = wordDoc.Paragraphs.Add();
            para.Range.Text = "欢迎你，进入Learning Hard博客";

            // 保存文档
            object filename = @"D:\learninghard.doc";
            wordDoc.SaveAs2(filename);

            // 关闭Word
            wordDoc.Close();
            wordApp.Application.Quit();
        }
    }
}
```

> https://www.cnblogs.com/zhili/archive/2013/01/14/NetInterop.html
