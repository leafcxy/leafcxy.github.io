---
title: JavaScript自定义事件
date: 2023-06-15 15:02:14
tags:
---

## JavaScript 自定义事件 Demo

<!-- more -->

```html
<!DOCTYPE html>
<html>
<head>
	<title>JavaScript 自定义事件 Demo</title>
</head>
<body>
	<button id="myButton">点击我</button>

	<script>
		// 创建自定义事件
		var myEvent = new Event("myEvent");

		// 获取按钮元素
		var button = document.getElementById("myButton");

		// 给按钮添加自定义事件处理程序
		button.addEventListener("myEvent", function() {
			alert("自定义事件被触发了！");
		});

		// 触发自定义事件
		button.dispatchEvent(myEvent);
	</script>
</body>
</html>
```

