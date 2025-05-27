---
title: httpserver
date: 2023-06-18 11:29:39
tags:
---

<!-- more -->

```csharp
static void Main(string[] args)
{
    TcpListener listener = new TcpListener(IPAddress.Any, 8080);
    listener.Start();
    Console.WriteLine("Server started on port 8080");

    while (true)
    {
        TcpClient client = listener.AcceptTcpClient();
        Console.WriteLine("Client connected");

        StreamReader reader = new StreamReader(client.GetStream());
        string request = reader.ReadLine();
        Console.WriteLine(request);

        StreamWriter writer = new StreamWriter(client.GetStream());
        writer.Write("HTTP/1.1 200 OK\r\n");
        writer.Write("Content-Type: text/html\r\n");
        writer.Write("\r\n");
        writer.Write("<html><body><h1>Hello World!</h1></body></html>");
        writer.Flush();

        client.Close();
        Console.WriteLine("Client disconnected");
    }
}
```
