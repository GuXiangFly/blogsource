---
title: AQS面试
date: 2018-3-27 20:09:04
tags: [JUC]

---

**ReentrantLock加锁和释放锁的底层原理**

![image-20201214023523713](http://guxiangflyimagebucket.oss-cn-beijing.aliyuncs.com/img/image-20201214023523713.png)



AQS 主要是用来实现 锁的，类似 reentrantLock 就是内部使用的AQS



AQS 内部主要有三块东西

-  state 变量：   atomicInteger
  - state = 0 代表没被加锁  
  - state = 1 代表被加锁了，加锁后会将加锁的线程对象记录为加锁线程
  - 线程使用 CAS 来尝试修改state 的值
- 加锁线程
  - 记录占有该锁的线程

- CLH 等待队列（内部是一个双向链表）
  - 如果有新线程，类似线程2 如果来竞争锁，如果通过CAS竞争到了state 那么直接占有锁，如果竞争不到，就放到 CLH 队列中进行等待。

