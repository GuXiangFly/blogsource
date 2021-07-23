---
title: Doris学习
date: 2017-1-10 13:22:54
tags: [java]


---



# Doris学习



## Doris 字段类型

| TINYINT                     | 1字节                                                        | 范围：-2^7 + 1 ~ 2^7 - 1                                     |
| --------------------------- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| SMALLINT                    | 2字节                                                        | 范围：-2^15 + 1 ~ 2^15 - 1                                   |
| BIGINT                      | 8字节                                                        | 范围：-2^63 + 1 ~ 2^63 - 1                                   |
| LARGEINT                    | 16字节                                                       | 范围：-2^127 + 1 ~ 2^127 - 1                                 |
| FLOAT                       | 4字节                                                        | 支持科学计数法                                               |
| DOUBLE                      | 12字节                                                       | 支持科学计数法                                               |
| DECIMAL[(precision, scale)] | 16字节                                                       | 保证精度的小数类型。默认是 DECIMAL(10, 0)precision: 1 ~ 27scale: 0 ~ 9其中整数部分为 1 ~ 18不支持科学计数法 |
| DATE                        | 3字节                                                        | 范围：0000-01-01 ~ 9999-12-31                                |
| DATETIME                    | 8字节                                                        | 范围：0000-01-01 00:00:00 ~ 9999-12-31 23:59:59              |
| CHAR[(length)]              |                                                              | 定长字符串。长度范围：1 ~ 255。默认为1                       |
| VARCHAR[(length)]           |                                                              | 变长字符串。长度范围：1 ~ 65533                              |
| HLL                         | 1~16385个字节                                                | hll列类型，不需要指定长度和默认值、长度根据数据的聚合程度系统内控制，并且HLL列只能通过配套的hll_union_agg、Hll_cardinality、hll_hash进行查询或使用 |
| BITMAP                      |                                                              | bitmap列类型，不需要指定长度和默认值。表示整型的集合，元素最大支持到2^64 - 1 |
| agg_type                    | 聚合类型，如果不指定，则该列为 key 列。否则，该列为 value 列 | SUM、MAX、MIN、REPLACE和HLL_UNION(仅用于HLL列，为HLL独有的聚合方式)5种 |



## Doris的分区维度

Doris支持单分区和复合分区两种建表方式。

在复合分区中：

第一级称为Partition,即分区。用户指定某一维度列做为分区列（当前只支持整型和时间类型的列），并指定每个分区的取值范围。

第二级称为Distribution,即分桶。用户可以指定一个或多个维度列以及桶数进行HASH分布。

 

以下场景推荐使用复合分区

1. 有时间维或类似带有有序值的维度，可以以这类维度列作为分区列。分区粒度可以根据导入频次、分区数据量等进行评估。

2. 历史数据删除需求：如有删除历史数据的需求（比如仅保留最近N天的数据）。使用复合分区，可以通过删除历史分区来达到目的。也可以通过在指定分区内发送DELETE于禁进行删除。

3. 解决数据倾斜的问题：每个分区可以单独指定分桶数量。如按天分区，当每天的数据量差异很大的时，可以通过指定分区的分桶数，合理规划不同分区的数据，分桶列建议选择区分度大的列。

 

用户也可以不是用复合分区，仅使用单分区。则数据只做HASH分布。

### Doris创建单分区

```sql
CREATE TABLE student
(
id INT,
name VARCHAR(50),
age INT,
count  BIGINT SUM DEFAULT '0'
)
AGGREGATE KEY (id,name,age)
DISTRIBUTED BY HASH(id) buckets 10
PROPERTIES("replication_num" = "1");
```



### Doris 创建复合分区

```sql
CREATE TABLE student2
(
dt DATE,
id INT,
name VARCHAR(50),
age INT,
count  BIGINT SUM DEFAULT '0'
)
AGGREGATE KEY (dt,id,name,age)
PARTITION BY RANGE(dt)
(
  PARTITION p202007 VALUES LESS THAN ('2020-08-01'),
  PARTITION p202008 VALUES LESS THAN ('2020-09-01'),
  PARTITION p202009 VALUES LESS THAN ('2020-10-01')
)
DISTRIBUTED BY HASH(id) buckets 10
PROPERTIES("replication_num" = "1");
```

创建student2表，使用dt字段作为分区列，并且创建3个分区发，分别是:

P202007 范围值是是小于2020-08-01的数据

P202008 范围值是2020-08-01到2020-08-31的数据

P202009 范围值是2020-09-01到2020-09-30的数据







## Doris 的三种数据模型

#### 1.AGGREGATE KEY

AGGREGATE KEY相同时，新旧记录将会进行聚合操作，目前支持SUM,MIN,MAX,REPLACE。

AGGREGATE KEY模型可以提前聚合数据，适合报表和多维度业务。

建表sql

```SQL
CREATE TABLE site_visit
(
    siteid      INT,
    city        SMALLINT,
    username    VARCHAR(32),
    pv BIGINT   SUM DEFAULT '0'
)
AGGREGATE KEY(siteid, city, username)
DISTRIBUTED BY HASH(siteid) BUCKETS 10;
```

插入两天数据

```
mysql> insert into site_visit values(1,1,'name1',10);
mysql> insert into site_visit values(1,1,'name1',20);
```

结果

<img src="https://gitee.com/guxiangfly/blogimage/raw/master/img/image-20210104172415851.png" alt="image-20210104172415851" style="zoom:50%;" />

#### 2.UNIQUE KEY

UNIQUE KEY相同时，新记录覆盖旧记录。目前UNIQUE KEY和AGGREGATE KEY的REPLACE聚合方法一致。适用于有更新需求的业务。

```sql
CREATE TABLE sales_order
(
    orderid     BIGINT,
    status      TINYINT,
    username    VARCHAR(32),
    amount      BIGINT DEFAULT '0'
)
UNIQUE KEY(orderid)
DISTRIBUTED BY HASH(orderid) BUCKETS 10;
```

```
mysql> insert into sales_order values(1,1,'name1',100);
mysql> insert into sales_order values(1,1,'name1',200);
```

新数据



#### 3.DUPLICATE KEY

只指定排序列，相同的行并不会合并。适用于数据无需提前聚合的分析业务。

```sql
CREATE TABLE session_data
(
    visitorid   SMALLINT,
    sessionid   BIGINT,
    city        CHAR(20),
    ip          varchar(32)
)
DUPLICATE KEY(visitorid, sessionid)
DISTRIBUTED BY HASH(sessionid, visitorid) BUCKETS 10;
```

插入数据

```sql
mysql> insert into session_data values(1,1,'shanghai','www.111.com');
mysql> insert into session_data values(1,1,'shanghai','www.111.com');
mysql> insert into session_data values(3,2,'shanghai','www.111.com');
mysql> insert into session_data values(2,2,'shanghai','www.111.com');
mysql> insert into session_data values(2,1,'shanghai','www.111.com');
```

查询结果

<img src="https://gitee.com/guxiangfly/blogimage/raw/master/img/image-20210105105715291.png" alt="image-20210105105715291" style="zoom:50%;" />



## Rollup 索引

Rollup可以理解为表的一个物化索引结构。Rollup可以调整列的顺序以增加前缀索引的命中率，也可以减少key列以增加数据的聚合度。

（1）以session_data为例添加Rollup

<img src="https://gitee.com/guxiangfly/blogimage/raw/master/img/wpsk5bdC7.jpg" alt="img" style="zoom: 50%;" /> 

（2）比如我经常需要看某个城市的ip数，那么可以建立一个只有ip和city的rollup

```sql
mysql> alter table session_data add rollup rollup_city_ip(city,ip);
```

（3）创建完毕后，再次查看表结构

<img src="https://gitee.com/guxiangfly/blogimage/raw/master/img/wpsQrLRZT.jpg" alt="img" style="zoom:50%;" /> 

（4）然后可以通过explain查看执行计划，是否使用到了rollup

```
select ip from session_data where city = 'shanghai'
```



<img src="https://gitee.com/guxiangfly/blogimage/raw/master/img/wpshdPMR1.jpg" alt="img" style="zoom: 33%;" />





