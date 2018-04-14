---
title: WebSocket   SpringBoot使用步骤
date: 2017-6-24 21:09:04
tags: [SpringBoot,WebSocket]

---

## 一： 加入依赖
``` xml
	<dependency>
			<groupId>org.springframework.boot</groupId>
			<artifactId>spring-boot-starter-websocket</artifactId>
	</dependency>
```

## 二： 配置  ServerEndpointExporter  暴露Endpoint
``` java
@Component
public class WebSocketConfig {

    @Bean
    public ServerEndpointExporter serverEndpointExporter(){
        return new ServerEndpointExporter();
    }
}

```

##  三：编写 动作
``` java
/**
 * WebSocketEndPoint
 *
 * @author guxiang
 * @date 2017/11/19
 */
@Component
@Slf4j
@ServerEndpoint("/webSocket")
public class WebSocketConnect {

    private Session session;

    private static CopyOnWriteArraySet<WebSocketConnect> webSocketSet = new CopyOnWriteArraySet<>();


    @OnOpen
    public void onOpen(Session session){
        this.session=session;
        webSocketSet.add(this);
    }

    @OnClose
    public void onClose(Session session){
        webSocketSet.remove(this);
    }

    @OnMessage
    public void onMessage(String message) {
        log.info("【websocket消息】收到客户端发来的消息:{}", message);
    }

    public void sendMessage(String message) {
        for (WebSocketConnect webSocketConnect: webSocketSet) {
            log.info("【websocket消息】广播消息, message={}", message);
            try {
                webSocketConnect.session.getBasicRemote().sendText(message);
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }
}

```
## 四： 在前端界面编写连接
``` javascript
<script src="https://cdn.bootcss.com/jquery/1.12.4/jquery.min.js"></script>
<script src="https://cdn.bootcss.com/bootstrap/3.3.5/js/bootstrap.min.js"></script>

<script>
    var websocket = null;
    if('WebSocket' in window) {
        websocket = new WebSocket(encodeURI('ws://localhost:8080/sell/webSocket'));
    }else {
        alert('该浏览器不支持websocket!');
    }

    websocket.onopen = function (event) {
        console.log('建立连接');
    };

    websocket.onclose = function (event) {
        console.log('连接关闭');
    };

    websocket.onmessage= function (event) {
        console.log('收到消息:' + event.data)
        $('#myModal').modal('show');
        document.getElementById('notice').play();
    };
    websocket.onerror = function () {
        alert('websocket通信发生错误！');
    };
    window.onbeforeunload = function () {
        websocket.close();
    };

</script>
```

## 五：发送消息的实例

![image.png](http://upload-images.jianshu.io/upload_images/6406935-72a6013e3c4fea33.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

