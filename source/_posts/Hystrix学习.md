---
title: hystrix学习
date: 2017-7-27 20:09:04
tags: [IDEA,工具使用]
---





### 灾难性雪崩

![image-20211117172926956](https://gitee.com/guxiangfly/blogimage/raw/master/img/image-20211117172926956.png)



### 请求合并

> Hystrix为了降低访问服务的频率，支持将一个请求与返回结果做缓存处理。如果再次请求的URL没有变化，那么Hystrix不会请求服务，而是直接从缓存中将结果返回。这样可以大大降低访问服务的压力。
>
> Hystrix自带缓存。有两个缺点：
>
> 1.  是一个本地缓存。在集群情况下缓存是不能同步的。
>
> 2. 不支持第三方缓存容器。Redis，memcached不支持的。



关键就是一个@HystrixCollapser注解

![](https://gitee.com/guxiangfly/blogimage/raw/master/img/wpsFE74.tmp.jpg)



### 三、隔离

- 通过线程池隔离
  - 
- 通过信号量隔离





### 四、降级

- 降级是请求超时时，资源不足的时进行降级处理，
- 不发生真实的服务client-》server的请求而是快速 fallback，返回一个托底数据
- 解决服务雪崩响应，都是**避免 application client  请求 application service** 时，出现服务调用错误或网络问题。 **一般在 application client 中处理**
- @EnableCircuitBreaker ，这个注解用于开启hystrix熔断器，让 hystrix注解生效。
- 

### 五、熔断

> 当一定时间内，异常请求比例（请求超时、网络故障、服务异常等）达到阀值时，启动熔断器，熔断器一旦启动，则会停止调用具体服务逻辑，通过fallback快速返回托底数据，保证服务链的完整。
>
> 熔断有自动恢复机制，如：当熔断器启动后，每隔5秒，尝试将新的请求发送给Application Service，如果服务可正常执行并返回结果，则关闭熔断器，服务恢复。如果仍旧调用失败，则继续返回托底数据，熔断器持续开启状态。

![image-20211117171848573](https://gitee.com/guxiangfly/blogimage/raw/master/img/image-20211117171848573.png)

![image-20211117171647440](https://gitee.com/guxiangfly/blogimage/raw/master/img/image-20211117171647440.png)







### 隔离详解

![img](https://gitee.com/guxiangfly/blogimage/raw/master/img/wps9C0F.tmp.jpg)

即使某个线程池都被占用，也不影响其他线程。

![img](https://gitee.com/guxiangfly/blogimage/raw/master/img/wps1C5C.tmp.jpg)



线程池隔离的演示代码

```java
@HystrixCommand(groupKey = "jqk",commandKey = "abc",threadPoolKey = "jqk",threadPoolProperties = {
        @HystrixProperty(name="coreSize",value="8"),
        @HystrixProperty(name="maxQueueSize",value="5"),
        @HystrixProperty(name="keepAliveTimeMinutes",value="2"),
        @HystrixProperty(name="queueSizeRejectionThreshold",value="5")
})
@Override
public String thread() {
    System.out.println(Thread.currentThread().getName());
    return "thread1";
}

@Override
public String thread2() {
    System.out.println(Thread.currentThread().getName());
    return "thread2";
}
```

![img](https://gitee.com/guxiangfly/blogimage/raw/master/img/wps8F55.tmp.jpg)







### 信号量隔离

> java.util.concurrent.Semaphore用来控制可同时并发的线程数。通过构造方法指定内部虚拟许可的数量。每次线程执行操作时先通过acquire方法获得许可，执行完毕再通过release方法释放许可。如果无可用许可，那么acquire方法将一直阻塞，直到其它线程释放许可。
> 如果采用信号量隔离技术，每接收一个请求，都是服务自身线程去直接调用依赖服务，信号量就相当于一道关卡，每个线程通过关卡后，信号量数量减1，当为0时不再允许线程通过，而是直接执行fallback逻辑并返回，说白了**仅仅做了一个限流**。



![img](https://gitee.com/guxiangfly/blogimage/raw/master/img/wps5E62.tmp.jpg)



### 线程池隔离和信号量隔离

![img](https://gitee.com/guxiangfly/blogimage/raw/master/img/wps552.tmp.jpg)





###  Hystrix-dashboard

Hystrix-dashboard能够让Actuator从json转换为界面。

在包含Hystrix的项目中（DemoFallback）进行操作

![img](https://gitee.com/guxiangfly/blogimage/raw/master/img/wps6F25.tmp.jpg)

![img](https://gitee.com/guxiangfly/blogimage/raw/master/img/wps9403.tmp.jpg)