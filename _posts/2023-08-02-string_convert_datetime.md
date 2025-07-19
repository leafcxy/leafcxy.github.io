---
title: 字符串未被识别为有效的datetime
date: 2023-08-02 16:28:18
tags:
---

最近需要把“20121010”转换为“2012-10-10”格式，直接用Convert.ToDateTime("20121010")，部分电脑系统会报错“未被识别的DateTime类型”。

<!-- more -->

在C#中如果将一个字符串类型的日期转换成日期类型很方便的

即使用Convert.ToDateTime("2015/01/01").ToString()或DateTime.TryParse 可完成转换，前提是字符串里的格式必须是系统可以识别的日期格式
如:
yyyy-MM-dd
yyyy/MM/dd
等等....
如果字符串中的格式是自定义的话(yyyyMMdd)，那么系统的方法就无法直接完成转换（虽然字符串的内容是日期,如20111021）
还好C#提供了强大的可自定义格式转换功能，可以完成自定义需求,不废话直接上代码


```csharp
using System;
public class DateTime_TryParseExact_Demo
{
    public static void Main()
    {
        string str = DateTime.Now.ToString("yyyyMMdd");
        string[] format = {"yyyyMMdd"};
        DateTime date;
        if (DateTime.TryParseExact(str, 
                                   format, 
                                   System.Globalization.CultureInfo.InvariantCulture,
                                   System.Globalization.DateTimeStyles.None, 
                                   out date))
        {
             Console.WriteLine("Custom DateTime Type Convert success:"+date.ToString());
        }
        else
             Console.WriteLine("Custom DateTime Type Convert error ");
    }//end Main
}//end
```

