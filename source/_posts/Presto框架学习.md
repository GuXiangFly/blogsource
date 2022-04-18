---
title: Presto学习
date: 2017-10-5 23:00:04
tags: [大数据]
---



Presto  是一个开源的分布式SQL查询引擎，数据量支持GB 到 PB字节，主要用来处理 秒级查询的场景





#### Presto的概念图

![image-20200713165501201](http://guxiangflyimagebucket.oss-cn-beijing.aliyuncs.com/img/image-20200713165501201.png)

- Presto 本身是不存储数据的，它通过 Hive 的 Metastore来对接Hive。

- Presto 本身可以对接不同的数据源如 Hive，redis，Kafka ， 一个Catalog可以对接一个数据源，Presto可以配置多个catalog。

- Presto 的一个scheme类似是一个Mysql中的DB， DB中有多个表。





