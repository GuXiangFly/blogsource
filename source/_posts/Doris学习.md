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
| agg_type                    | 聚合类型，如果不指定，则该列为 key 列。否则，该列为 value 列 | SUM、MAX、MIN、REPLACE                                       |



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

#### AGGREGATE KEY

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

