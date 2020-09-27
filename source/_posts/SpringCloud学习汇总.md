---
title: SpringCloud学习汇总
date: 2018-01-16 06:27:29
categories:
- 技术杂谈
tags:
- Java
---



### Nacos 的学习笔记

nacos 启动代码：

```bash
sh startup.sh -m standalone     ## mac启动
```

nacos http地址：http://localhost:8848/nacos/

nacos：

![image-20200921170401839](../../../../../../Library/Application Support/typora-user-images/image-20200921170401839.png)







<img src="https://gitee.com/guxiangfly/blogimage/raw/master/img/image-20200921210204976.png" alt="image-20200921210204976" style="zoom: 33%; " />





### Alibaba Sentinel学习笔记



- sentinel流控规则
  1. 通过QPS控制

<img src="https://gitee.com/guxiangfly/blogimage/raw/master/img/image-20200922105823011.png" alt="image-20200922105823011" style="zoom:33%;" />

2. 通过线程数流控

​				一个controller的内部线程数

  		3.  流控模式-关联
          		1.  假设有支付场景。用户先下订单，然后再让进行支付。 如果支付接口QPS已经顶不住了，那么同时我们也要限制订单接口，不要让用户下订单了，因为你下了订单也无法支付。
		4.  预热（warm  up）
		5.  排队等待







- 系统规则限流

  - 将整个 java服务当成一个整体，通过各个参数进行限流

    <img src="https://gitee.com/guxiangfly/blogimage/raw/master/img/image-20200923172558458.png" alt="image-20200923172558458" style="zoom:33%;" />

