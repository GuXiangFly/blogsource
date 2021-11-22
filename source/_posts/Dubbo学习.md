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
  