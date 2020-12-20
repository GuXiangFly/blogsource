---
title: LSM-Tree的运用
date: 2017-11-1 13:22:54
tags: [MongoDB,java]

---


======





# LSM 树是什么

Log Structured-Merge Tree  日志合并树





## LSM 的简易模型



LSM 的简易树状结构分为两棵树  C0  和 C1



C0 比较小，全部存储于内存之中，  C1则存储于磁盘之上。

一个数据来了，我们先将数据存入C0这个内存的树上， C0大小达到阈值后，会刷写入 C1硬盘。

第一次



![image-20201214224313607](https://gitee.com/guxiangfly/blogimage/raw/master/img/image-20201214224313607.png)