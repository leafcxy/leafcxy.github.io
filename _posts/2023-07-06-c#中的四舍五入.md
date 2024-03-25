---
title: c#中的四舍五入
date: 2023-07-06 13:32:04
tags:
---

- C#默认四舍五入
  - Math.Round(45.367,2) //Returns 45.37
  - Math.Round(45.365,2) //Returns 45.36
- C#中的Round()不是我们中国人理解的四舍五入，是老外的四舍五入，是符合IEEE标准的四舍五入，具体是四舍六入，下面的才是符合中国人理解的四舍五入。
  - Math.Round(45.367,2,MidpointRounding.AwayFromZero); //Returns 45.37
  - Math.Round(45.365,2,MidpointRounding.AwayFromZero); //Returns 45.37
