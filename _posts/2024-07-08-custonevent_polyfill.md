---
title: 如何在ES5环境中使用CustomEvent polyfill来触发自定义事件
date: 2024-07-08 06:08:55
tags: [Blogs, Jekyll, default_tags]
---

下面是一个完整的示例，展示了如何在ES5环境中使用CustomEvent polyfill来触发自定义事件：

<!-- more -->

<!-- more -->

```html
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Custom Event Example in ES5</title>
</head>
<body>

<button id="myButton">Click me!</button>

<script>
  if (!window.CustomEvent) {
    (function() {
      function CustomEvent(event, params) {
        params = params || { bubbles: false, cancelable: false, detail: undefined };
        var evt = document.createEvent('CustomEvent');
        evt.initCustomEvent(event, params.bubbles, params.cancelable, params.detail);
        return evt;
      }

      CustomEvent.prototype = window.Event.prototype;

      window.CustomEvent = CustomEvent;
    })();
  }

  var button = document.getElementById('myButton');

  // 创建并分发事件
  button.addEventListener('click', function() {
    var myEvent = new CustomEvent('myCustomEvent', {
      detail: { message: 'Hello from the custom event!' },
      bubbles: true,
      cancelable: true
    });
    button.dispatchEvent(myEvent);
  });

  // 注册事件监听器
  button.addEventListener('myCustomEvent', function(event) {
    console.log('Custom event received');
    console.log('Detail data:', event.detail);
  });
</script>

</body>
</html>
```

在这个示例中，当用户点击按钮时，会触发myCustomEvent事件，控制台将输出事件的详细信息。这种方法确保了在ES5环境下的广泛兼容性。


