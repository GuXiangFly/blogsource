---
title: Dubbo学习
date: 2018-7-27 20:09:04
tags: [Java]

---

## RPC

RPC【Remote Procedure Call】是指远程过程调用，是一种进程间通信方式，他是一种技术的思想，而不是规范。它允许程序调用另一个地址空间（通常是共享网络的另一台机器上）的过程或函数，它允许程序调用另一个地址空间（通常是共享网络的另一台机器上）的过程或函数，编写的调用代码基本相同。

<img src="https://gitee.com/guxiangfly/blogimage/raw/master/img/image-20211122151456131.png" alt="image-20211122151456131" style="zoom:50%;" />



<img src="https://gitee.com/guxiangfly/blogimage/raw/master/img/image-20211122151535452.png" alt="image-20211122151535452" style="zoom:50%;" />





### Dubbo架构

<img src="https://gitee.com/guxiangfly/blogimage/raw/master/img/image-20211122153532450.png" alt="image-20211122153532450" style="zoom:50%;" />

- 服务提供者（Provider）：暴露服务的服务提供方，服务提供者在启动时，向注册中心注册自己提供的服务。

- 服务消费者（Consumer）: 调用远程服务的服务消费方，服务消费者在启动时，向注册中心订阅自己所需的服务，服务消费者，从提供者地址列表中，基于软负载均衡算法，选一台提供者进行调用，如果调用失败，再选另一台调用。

- 注册中心（Registry）：注册中心返回服务提供者地址列表给消费者，如果有变更，注册中心将基于长连接推送变更数据给消费者

- 监控中心（Monitor）：服务消费者和提供者，在内存中累计调用次数和调用时间，定时每分钟发送一次统计数据到监控中心







dubbo在zookeeper挂了的情况下能不能









### zookeeper的负载均衡策略

<img src="https://gitee.com/guxiangfly/blogimage/raw/master/img/image-20211222151226322.png" alt="image-20211222151226322" style="zoom:50%;" />

**Random LoadBalance**

随机，按权重设置随机概率。

在一个截面上碰撞的概率高，但调用量越大分布越均匀，而且按概率使用权重后也比较均匀，有利于动态调整提供者权重。

**RoundRobin LoadBalance**

轮循，按公约后的权重设置轮循比率。

存在慢的提供者累积请求的问题，比如：第二台机器很慢，但没挂，当请求调到第二台时就卡在那，久而久之，所有请求都卡在调到第二台上。











## 服务降级

> **当服务器压力剧增的情况下，根据实际业务情况及流量，对一些服务和页面有策略的不处理或换种简单的方式处理，从而释放服务器资源以保证核心交易正常运作或高效运作。**

其中：

-  mock=force:return+null 表示消费方对该服务的方法调用都直接返回 null 值，不发起远程调用。用来屏蔽不重要服务不可用时对调用方的影响。

- 还可以改为 mock=fail:return+null 表示消费方对该服务的方法调用在失败后，再返回 null 值，不抛异常。用来容忍不重要服务不稳定时对调用方的影响。



## 服务容错

- 在集群调用失败时，Dubbo 提供了多种容错方案，缺省为 failover 重试。

集群容错模式

> **Failover Cluster**
>
> 失败自动切换，当出现失败，重试其它服务器。通常用于读操作，但重试会带来更长延迟。可通过 retries="2" 来设置重试次数(不含第一次)。
>
> 重试次数配置如下：
>
> ```xml
> <dubbo:service retries="2" />
> 或
> <dubbo:reference retries="2" />
> 或
> <dubbo:reference>
>   <dubbo:method name="findFoo" retries="2" />
> </dubbo:reference>
> ```
>
> **Failfast Cluster**
>
> 快速失败，只发起一次调用，失败立即报错。通常用于非幂等性的写操作，比如新增记录。
>
> **Failsafe Cluster**
>
> 失败安全，出现异常时，直接忽略。通常用于写入审计日志等操作。
>
> **Failback Cluster**
>
> 失败自动恢复，后台记录失败请求，定时重发。通常用于消息通知操作。
>
> **Forking Cluster**
>
> 并行调用多个服务器，只要一个成功即返回。通常用于实时性要求较高的读操作，但需要浪费更多服务资源。可通过 forks="2" 来设置最大并行数。
>
> **Broadcast Cluster**
>
> 广播调用所有提供者，逐个调用，任意一台报错则报错 [2]。通常用于通知所有提供者更新缓存或日志等本地资源信息。
>
> **集群模式配置**
>
> 按照以下示例在服务提供方和消费方配置集群模式
>
> ```xml
> <dubbo:service cluster="failsafe" />
> 或
> <dubbo:reference cluster="failsafe" />
> ```

#### 整合hystrix进行服务容错

```
Hystrix 旨在通过控制那些访问远程系统、服务和第三方库的节点，从而对延迟和故障提供更强大的容错能力。Hystrix具备拥有回退机制和断路器功能的线程和信号隔离，请求缓存和请求打包，以及监控和配置等功能
```

```xml
       <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-netflix-hystrix</artifactId>
            <version>1.4.4.RELEASE</version>
        </dependency>
```







# Dubbo原理

## 1. RPC原理

<img src="https://gitee.com/guxiangfly/blogimage/raw/master/img/image-20211222155132753.png" alt="image-20211222155132753" style="zoom:50%;" />

```
一次完整的RPC调用流程（同步调用，异步另说）如下： 
1）服务消费方（client）调用以本地调用方式调用服务； 
2）client stub接收到调用后负责将方法、参数等组装成能够进行网络传输的消息体； 
3）client stub找到服务地址，并将消息发送到服务端； 
4）server stub收到消息后进行解码； 
5）server stub根据解码结果调用本地的服务； 
6）本地服务执行并将结果返回给server stub； 
7）server stub将返回结果打包成消息并发送至消费方； 
8）client stub接收到消息，并进行解码； 
9）服务消费方得到最终结果。
RPC框架的目标就是要2~8这些步骤都封装起来，这些细节对用户来说是透明的，不可见的。
```



<img src="https://gitee.com/guxiangfly/blogimage/raw/master/img/image-20211222160852369.png" alt="image-20211222160852369" />







### Netty 的模型

![image-20220112115234929](https://gitee.com/guxiangfly/blogimage/raw/master/img/image-20220112115234929.png)





