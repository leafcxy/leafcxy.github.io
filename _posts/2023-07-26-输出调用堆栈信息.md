---
title: 输出调用堆栈信息
date: 2023-07-26 11:30:10
tags:
---

命名空间：System.Diagnostics

<!-- more -->

得到相关信息：

StackTrace st = new StackTrace(new StackFrame(true));
StackFrame sf = st.GetFrame(0);
Console.WriteLine(" File: {0}", sf.GetFileName());//文件名
Console.WriteLine(" Method: {0}", sf.GetMethod().Name);//函数名
Console.WriteLine(" Line Number: {0}", sf.GetFileLineNumber());//文件行号
Console.WriteLine(" Column Number: {0}", sf.GetFileColumnNumber());


写日志，便于调试，查找问题

StackTrace st = new StackTrace(new StackFrame(true));只能获取本次的堆栈信息，可以改用下面的方法获取程序的调用堆栈信息。
StackTrace st = new StackTrace(true); 就可以获取程序的整个堆栈调用关系的列表信息。
使用st.ToString()可以直接获取堆栈列表，是不是很方便啊。

