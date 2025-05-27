---
title: FileSystemWatcher
date: 2023-06-15 15:21:06
tags:
---

<!-- more -->

```csharp
using System;
using System.IO;

class Program
{
    static void Main(string[] args)
    {
        // 创建一个新的FileSystemWatcher对象
        FileSystemWatcher watcher = new FileSystemWatcher();

        // 设置要监视的目录路径
        watcher.Path = @"C:\MyFolder";

        // 设置要监视的文件和文件夹更改类型
        watcher.NotifyFilter = NotifyFilters.LastWrite
                             | NotifyFilters.FileName
                             | NotifyFilters.DirectoryName;

        // 只监视文本文件类型
        watcher.Filter = "*.txt";

        // 添加事件处理程序
        watcher.Changed += new FileSystemEventHandler(OnChanged);
        watcher.Created += new FileSystemEventHandler(OnCreated);
        watcher.Deleted += new FileSystemEventHandler(OnDeleted);
        watcher.Renamed += new RenamedEventHandler(OnRenamed);

        // 开始监视
        watcher.EnableRaisingEvents = true;

        // 等待用户输入
        Console.WriteLine("Press 'q' to quit the sample.");
        while (Console.Read() != 'q') ;
    }

    // 文件或文件夹更改事件处理程序
    private static void OnChanged(object source, FileSystemEventArgs e)
    {
        Console.WriteLine($"File {e.FullPath} has been changed.");
    }

    // 文件或文件夹创建事件处理程序
    private static void OnCreated(object source, FileSystemEventArgs e)
    {
        Console.WriteLine($"File {e.FullPath} has been created.");
    }

    // 文件或文件夹删除事件处理程序
    private static void OnDeleted(object source, FileSystemEventArgs e)
    {
        Console.WriteLine($"File {e.FullPath} has been deleted.");
    }

    // 文件或文件夹重命名事件处理程序
    private static void OnRenamed(object source, RenamedEventArgs e)
    {
        Console.WriteLine($"File {e.OldFullPath} has been renamed to {e.FullPath}");
    }
}
```
