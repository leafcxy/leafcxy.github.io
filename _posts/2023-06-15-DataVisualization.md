---
title: DataVisualization
date: 2023-06-15 15:21:56
tags:
---

<!-- more -->

```csharp
using System;
using System.Drawing;
using System.Windows.Forms;
using System.Windows.Forms.DataVisualization.Charting;

namespace ChartDemo
{
    public partial class Form1 : Form
    {
        public Form1()
        {
            InitializeComponent();

            // 创建 Chart 控件并设置属性
            Chart chart = new Chart();
            chart.Parent = this;
            chart.Dock = DockStyle.Fill;

            // 创建一个 Series 对象并添加数据
            Series series = new Series();
            series.Name = "MySeries";
            series.ChartType = SeriesChartType.Line;
            series.Points.AddXY(1, 10);
            series.Points.AddXY(2, 20);
            series.Points.AddXY(3, 30);
            series.Points.AddXY(4, 40);
            series.Points.AddXY(5, 50);

            // 将 Series 对象添加到 Chart 控件中
            chart.Series.Add(series);

            // 设置 Chart 控件的标题和坐标轴标签
            chart.Titles.Add("My Chart");
            chart.ChartAreas[0].AxisX.Title = "X Axis";
            chart.ChartAreas[0].AxisY.Title = "Y Axis";
        }
    }
}
```
