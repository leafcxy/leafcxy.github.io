---
title: SerialPort串口编程
date: 2023-09-18 11:28:54
tags: [Blogs, Jekyll, default_tags]
---

从Microsoft .Net 2.0版本以后，就默认提供了System.IO.Ports.SerialPort类，用户可以非常简单地编写少量代码就完成串口的信息收发程序。

<!-- more -->

## 串口端口号搜索

```csharp
string[] portList = System.IO.Ports.SerialPort.GetPortNames();
for (int i = 0; i < portList.Length; i++)
{
    string name = portList[i];
    comboBox.Items.Add(name);
}
```

## 串口属性参数设置

```csharp
SerialPort mySerialPort = new SerialPort("COM2");//端口
mySerialPort.BaudRate = 9600;//波特率
mySerialPort.Parity = Parity.None;//校验位
mySerialPort.StopBits = StopBits.One;//停止位
mySerialPort.DataBits = 8;//数据位
mySerialPort.Handshake = Handshake.Non;
mySerialPort.ReadTimeout = 1500;
mySerialPort.DtrEnable = true;//启用数据终端就绪信息
mySerialPort.Encoding = Encoding.UTF8;
mySerialPort.ReceivedBytesThreshold = 1;//DataReceived触发前内部输入缓冲器的字节数
mySerialPort.DataReceived += new SerialDataReceivedEvenHandler(DataReceive_Method);

mySerialPort.Open();
```
## 串口发送信息

```csharp
// Write a string
port.Write("Hello World");

// Write a set of bytes
port.Write(new byte[] { 0x0A, 0xE2, 0xFF }, 0, 3);

// Close the port
port.Close();
```

## 串口接收信息

```csharp
string serialReadString;
private void port_DataReceived(object sender, SerialDataReceivedEventArgs e)
{
    serialReadString = port.ReadExisting());
    this.txt1.Invoke( new MethodInvoker(delegate { this.txt1.AppendText(serialReadString); }));
}
```
## 循环接收数据

```csharp
void com_DataReceived(object sender, SerialDataReceivedEventArgs e)
{
    // Use either the binary OR the string technique (but not both)
    // Buffer and process binary data
    while (com.BytesToRead > 0)
        bBuffer.Add((byte)com.ReadByte());
    ProcessBuffer(bBuffer);

    // Buffer string data
    sBuffer += com.ReadExisting();
    ProcessBuffer(sBuffer);
}

private void ProcessBuffer(string sBuffer)
{
    // Look in the string for useful information
    // then remove the useful data from the buffer
}

private void ProcessBuffer(List<byte> bBuffer)
{
    // Look in the byte array for useful information
    // then remove the useful data from the buffer
}
```
