---
title: Druid大数据框架学习
date: 2019-11-27 13:22:54
tags: [大数据]

---



## Druid介绍

这个  Druid 是 Apache Druid  它与 Alibaba 的 Druid连接池毫无关系

> Druid 是一个 rOLAP的查询引擎
>
> 

#### ROLAP、MOLAP、HOLAP

| **名称**                     | **描述**                   | **细节数据存储位置** | **聚合后的数据存储位置** | 优化方式                 |
| ---------------------------- | -------------------------- | -------------------- | ------------------------ | ------------------------ |
| ROLAP(Relational OLAP)       | 基于关系数据库的OLAP实现   | 关系型数据库         | 关系型数据库             | 通过内存优化查询         |
| MOLAP(Multidimensional OLAP) | 基于多维数据组织的OLAP实现 | 数据立方体           | 数据立方体               | 通过预计算优化查询       |
| HOLAP(Hybrid OLAP)           | 基于混合数据组织的OLAP实现 | 关系型数据库         | 数据立方体               | 通过预计算和内存优化查询 |

Druid 相对于kylin的优势在于，既可以做实时计算，又可以做批量离线计算。而kylin无法支持实时计算



![](https://i.loli.net/2019/12/10/Y5Pt8fjrygK6Tmk.png)



## Druid的数据结构

与Druid架构相辅相成的是其基于**DataSource**与**Segment**的数据结构，它们共同成就了 Druid的高性能优势。

### DataSource结构

若与传统的关系型数据库管理系统（ RDBMS）做比较，Druid的DataSource可以理解为 RDBMS中的表（Table）。DataSource的结构包含以下几个方面。

1. 时间列（ TimeStamp）：表明每行数据的时间值，默认使用 UTC时间格式且精确到毫秒级别。这个列是数据聚合与范围查询的重要维度。

2. 维度列（Dimension）：维度来自于 OLAP的概念，用来标识数据行的各个类别信息。

3. 指标列（ Metric）：指标对应于 OLAP概念中的 Fact，是用于聚合和计算的列。这些指标列通常是一些数字，计算操作通常包括 Count、Sum和 Mean等。

![DataSource结构](https://i.loli.net/2019/12/10/TwDyRWqikPuEgAv.png)



​      无论是实时数据消费还是批量数据处理， Druid在基于DataSource结构存储数据时即可选择对任意的指标列进行聚合（ RollUp）操作。该聚合操作主要基于维度列与时间范围两方面的情况。

### Segment结构

Segment却是数据的实际物理存储格式， DataSource是一个逻辑概念。

​		Druid正是通过 Segment实现了对数据的横纵向切割（ Slice and Dice）操作。从数据按时间分布的角度来看，通过参数 segmentGranularity的设置，Druid将不同时间范围内的数据存储在不同的 Segment数据块中，这便是所谓的数据横向切割。

​		这种设计为 Druid带来一个显而易见的优点：按时间范围查询数据时，仅需要访问对应时间段内的这些 Segment数据块，而不需要进行全表数据范围查询，这使效率得到了极大的提高。

![](https://i.loli.net/2019/12/10/IzPDE1pBwhOyMdY.png)

​		通过 Segment将数据按时间范围存储，同时，在 Segment中也面向列进行数据压缩存储，这便是所谓的数据纵向切割。而且在 Segment中使用了 Bitmap等技术对数据的访问进行了优化。



### Druid的安装







#### LSM tree

Ddd





