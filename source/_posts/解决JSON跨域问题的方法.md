---
title: 解决JSON跨域问题的方法
date: 2018-2-15 21:31:44
tags: [java]
---

## 1.使用JSONP 解决跨域


先在java中添加切面
``` java
@ControllerAdvice
public class JsonAdvice extends AbstractJsonpResponseBodyAdvice{
    public JsonAdvice(){
        super("callback");
    }
}
```
```javascript
$.ajax({
    url: base+"/get",
    dataType : "jsonp",
    success: function(json){
        result = json
    }
})
```

这样后 js发出的get请求 类型为 script
url为：http://www.xxx.com/get?callback=6465416531316

### 2.JSONP的弊端
- 服务器需要改动代码（如果是自己的服务器无所属，如果是别人的接口就会麻烦）
- 只支持GET方法
- 发送的不是XHR请求， XHR请求是异步的 还有很多好的特性

## 不使用JSONP 通过服务器添加Filter解决跨域
