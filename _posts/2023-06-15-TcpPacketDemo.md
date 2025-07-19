---
title: TcpPacketDemo
date: 2023-06-15 15:39:07
tags:
---

<!-- more -->

```csharp
using System;
using System.IO;
using System.Net;
using System.Net.Sockets;
using System.Text;

class TcpPacketDemo
{
    static byte[] buffer = new byte[1024];
    static int packetSize = 4;

    static void Main(string[] args)
    {
        TcpListener listener = new TcpListener(IPAddress.Any, 8080);
        listener.Start();
        Console.WriteLine("Server started on port 8080");

        while (true)
        {
            TcpClient client = listener.AcceptTcpClient();
            Console.WriteLine("Client connected");

            NetworkStream stream = client.GetStream();

            while (true)
            {
                int bytesRead = stream.Read(buffer, 0, packetSize);
                if (bytesRead == 0)
                {
                    Console.WriteLine("Client disconnected");
                    break;
                }

                int packetLength = BitConverter.ToInt32(buffer, 0);
                byte[] packet = new byte[packetLength];
                bytesRead = 0;
                while (bytesRead < packetLength)
                {
                    int bytesToRead = packetLength - bytesRead;
                    if (bytesToRead > buffer.Length)
                    {
                        bytesToRead = buffer.Length;
                    }

                    int n = stream.Read(buffer, 0, bytesToRead);
                    if (n == 0)
                    {
                        Console.WriteLine("Client disconnected");
                        break;
                    }

                    Array.Copy(buffer, 0, packet, bytesRead, n);
                    bytesRead += n;
                }

                Console.WriteLine("Received packet: " + Encoding.ASCII.GetString(packet));

                byte[] response = Encoding.ASCII.GetBytes("Packet received");
                byte[] responseLength = BitConverter.GetBytes(response.Length);
                stream.Write(responseLength, 0, packetSize);
                stream.Write(response, 0, response.Length);
                stream.Flush();
            }

            client.Close();
        }
    }
}
```
