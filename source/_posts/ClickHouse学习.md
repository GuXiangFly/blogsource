---


title: ClickHouse学习
date: 2017-10-27 20:09:04
tags: [ClickHouse]

---

### clickhouse环境设置

```
在 hadoop102 的 /etc/security/limits.conf 与  vim /etc/security/limits.d/20-nproc.conf
文件的末尾加入以下内容
[atguigu@hadoop102 ~]$ sudo vim /etc/security/limits.conf
* soft nofile 65536
* hard nofile 65536
* soft nproc 131072
* hard nproc 131072

有时候 /etc/security/limits.conf 这个文件 /etc/security/limits.d/20-nproc.conf 会被这个文件所覆盖
所以两个都需要配置
```
nofile 是 number of file  ： 表示最大文件数
nproc  是 number  process  ：表示最大进程数
由于clickhouse需要存储巨大的文件，并且需要为了最大程度发挥硬件性能，并计算需要配置最大进程数


由于使用 rpm安装目录情况
```
bin/    -----> /usr/bin/
conf/    -----> /etc/clickhouse-server/
lib/    -----> /var/lib/clickhouse
log/    -----> /var/log/clickhouse
```







clickhouse 会记录行数

![image-20220427201946190](http://guxiangflyimagebucket.oss-cn-beijing.aliyuncs.com/img/image-20220427201946190.png)

- 





# 第3章 数据类型

## 3.1 整型

![image-20210819230206354](http://guxiangflyimagebucket.oss-cn-beijing.aliyuncs.com/img/image-20210819230206354.png)

Uint32 - [0:4294967295]

Uint64 - [0:18446744073709551615]



## 3.2 浮点型
Float32 - float    4字节
Float64 - double   8字节

建议尽可能以整数形式存储数据。例如，将固定精度的数字转换卫整数值，如时间用毫秒为单位表示，因为浮点型进行计算时可能引起四舍五入的误差。

![image-20210823155348676](images/image-20210823155348676.png)

使用场景：一般数据值比较小，不涉及大量的统计计算，精度要求不高的时候。比如保存商品的重量。



## 3.3 布尔型
没有单独的类型来存储布尔值。可以使用UInt8类型，取值限制为 0 或者 1

## 3.4 Decimal型

有符号的浮点数，可在加、减和乘法运算过程中保持精度。对于除法，最低有效数字会 被丢弃（不舍入）

有三种声明：

![image-20210823155856312](http://guxiangflyimagebucket.oss-cn-beijing.aliyuncs.com/img/image-20210823155856312.png)

													s 标识小数位

使用场景： 一般金额字段、汇率、利率等字段为了保证小数点精度，都使用Decimal进行存储



## 3.5 字符串

![image-20210823160156835](http://guxiangflyimagebucket.oss-cn-beijing.aliyuncs.com/img/image-20210823160156835.png)



![image-20210823160232281](http://guxiangflyimagebucket.oss-cn-beijing.aliyuncs.com/img/image-20210823160232281.png)



## 3.6 枚举类型

![image-20210823160254410](http://guxiangflyimagebucket.oss-cn-beijing.aliyuncs.com/img/image-20210823160254410.png)

![image-20210823160616667](http://guxiangflyimagebucket.oss-cn-beijing.aliyuncs.com/img/image-20210823160616667.png)

![image-20210823160725529](http://guxiangflyimagebucket.oss-cn-beijing.aliyuncs.com/img/image-20210823160725529.png)

![image-20210823160749427](http://guxiangflyimagebucket.oss-cn-beijing.aliyuncs.com/img/image-20210823160749427.png)

## 3.7 时间类型

![image-20210823160813395](http://guxiangflyimagebucket.oss-cn-beijing.aliyuncs.com/img/image-20210823160813395.png)

							还有很多数据结构，可以参考官方文档：https://clickhouse.yandex/docs/zh/data_types/



## 3.8 数组

Array(T): 由 T 类型元素组成的数组。

T 可以视任意类型，包含数组类型。但不推荐使用多维数组，Clickhouse 对多维数组的支持有限。例如：不能在 MergeTree 表中存储多维数组。

Creating an Array

You can use a function to create an array:

```shell
array(T)
```

You can also use square brackets.

```shell
[]
```

example of creating an array:

```shell
SELECT array(1, 2) AS x, toTypeName(x)

┌─x─────┬─toTypeName(array(1, 2))─┐
│ [1,2] │ Array(UInt8)            │
└───────┴─────────────────────────┘
```

```shell
SELECT [1, 2] AS x, toTypeName(x)
┌─x─────┬─toTypeName([1, 2])─┐
│ [1,2] │ Array(UInt8)       │
└───────┴────────────────────┘
```





# 第4章 表引擎

## 4.1 表引擎的使用

表引擎是ClickHouse的一大特色。可以说，表引擎决定了如何存储表的数据。包括：

* 数据的存储方式和位置，写到哪里以及从哪里读取数据。
* 支持哪些查询以及如何支持
* 并发数据访问
* 索引的使用（如果存在）
* 是否可以执行多线程请求
* 数据复制参数

表引擎的使用方式就是必须显式在创建表时定义该表使用的引擎，以及引擎使用的相关参数。

**特别注意：引擎的名称大小写敏感， 大驼峰命名格式**



## 4.2 TinyLog

以列文件的形式保存在磁盘上，不支持索引，没有并发控制，一般保存少量数据的小表。

生产环境上作用有限。可以用于平时练习测试用。

如：

```shell
create table t_tinylog(id String, name String) engine=TinyLog;
```





## 4.3 Memory

内存引擎，数据以未压缩的原始形式直接保存在内存当中，服务器重启数据就会丢失。读写操作不会相互阻塞，不支持索引。简单查询下有非常非常高的性能表现（超过 10G/s）。

一般用到它的地方不多，除了用来测试，就是在需要非常高的性能，同时数据量又不太大（上限大概 1 亿行）的场景。



## 4.4 MergeTree （合并树）

ClickHouse 中最强大的表引擎当属 MergeTree(合并树)引擎以及该系列（*MergeTree）中的其他引擎，**支持索引和分区**，地位可以相当于 innodb 之于 MySQL。而且基于MergeTree, 还衍生出了很多小弟，也是非常有特色的引擎。

建表语句

```sql
-- 创建 t_order_mt 表
create table t_order_mt(
	id UInt32,
    sku_id String,
    total_amount Decimal(16,2),
    create_time Datetime
)engine = MergeTree
partition by toYYYYMMDD(create_time)
primary key(id)
order by (id, sku_id);;


-- 创建 t_order_tt 表
create table t_order_tt(
	id UInt32,
    sku_id String,
    total_amount Decimal(16,2),
    create_time Datetime
)engine = MergeTree
partition by toYYYYMMDD(create_time)
primary key(id)
order by (id, sku_id);;

-- 创建 m_order_mm 表
create table m_order_mm(
	id UInt32,
    sku_id String,
    total_amount Decimal(16,2),
    create_time Datetime
)engine = MergeTree
partition by toYYYYMMDD(create_time)
primary key(id)
order by (id, sku_id);;

-- 创建 n_order_nn 表
create table n_order_nn(
	id UInt32,
    sku_id String,
    total_amount Decimal(16,2),
    create_time Datetime
)engine = MergeTree
partition by toYYYYMMDD(create_time)
primary key(id)
order by (id, sku_id);;
```

插入数据

```sql
-- 为 t_order_tt 插入数据
insert into t_order_tt values
(101, 'sku_001', 1000.00, '2020-06-01 12:00:00'),
(102, 'sku_002', 2000.00, '2020-06-01 11:00:00'),
(102, 'sku_004', 2500.00, '2020-06-01 12:00:00'),
(102,'sku_002', 2000.00, '2020-06-01 13:00:00'),
(102, 'sku_002', 12000.00, '2020-06-01 13:00:00'),
(102, 'sku_002', 600.00, '2020-06-02 12:00:00');;

-- 为 m_order_mm 插入数据
insert into m_order_mm values
(101, 'sku_001', 1000.00, '2020-06-01 12:00:00'),
(102, 'sku_002', 2000.00, '2020-06-01 11:00:00'),
(102, 'sku_004', 2500.00, '2020-06-01 12:00:00'),
(102,'sku_002', 2000.00, '2020-06-01 13:00:00'),
(102, 'sku_002', 12000.00, '2020-06-01 13:00:00'),
(102, 'sku_002', 600.00, '2020-06-02 12:00:00');;

-- 为 n_order_nn  插入数据
insert into n_order_nn values
(101, 'sku_001', 1000.00, '2020-06-01 12:00:00'),
(102, 'sku_002', 2000.00, '2020-06-01 11:00:00'),
(102, 'sku_004', 2500.00, '2020-06-01 12:00:00'),
(102,'sku_002', 2000.00, '2020-06-01 13:00:00'),
(102, 'sku_002', 12000.00, '2020-06-01 13:00:00'),
(102, 'sku_002', 600.00, '2020-06-02 12:00:00');;
```

![image-20210824163350947](images/image-20210824163350947.png)



MergeTree 其实还有很多参数（绝大多数用默认值即可），但是三个参数是更加重要的，也涉及了关于MergeTree的很多概念。

### 4.4.1 partition by 分区（可选）

- 作用

  - 学过hive的同学应该不陌生，分区的目的主要是降低扫描的范围，优化查询速度

- 如果不慎

  - 只会使用一个分区

- 分区目录

  - MergeTree 是以列文件+索引文件+表定义文件组成的，但是如果设定了分区那么这些文件就会保存到不同的分区目录中。

- 并行

  - 分区后，面对涉及跨分区的查询设计，ClickHouse 会以分区为单位并行处理。

- 数据写入与分区合并

  - 任何一个批次的数据写入都会产生一个临时分区，不会纳入任何一个已有的分区。写入后的某个时刻（大概10-15分钟后），ClickHouse 会自动执行合并操作（等不及也可以手动通过 optimize 执行），把临时分区的数据，合并到已有分区中。

    ```shell
    optimize table xxxx final;
    ```







![image-20210823172831617](images/image-20210823172831617.png)



20200601_1_1_0 的解释：

```shell
PartitionId_MinBlockNum_MaxBlockNum_Level
分区值_最小分区块编号_最大分区块编号_合并层级
=》 PartitionId
	数据分区ID生成规则
	数据分区规则由分区ID决定，分区ID由PARTITION BY 分区键决定。根据分区键字段类型，ID生成规则可分为：
		未定义分区键
			没有定义 PARTITION BY， 默认生成一个目录名为all的数据分区，所有数据均存放在all目录下。
	    整型分区键
	    	分区键为整形，那么直接用该整型值的字符串形式做为分区ID
	    日期类分区键
	    	分区键位日期类型，或者可以转化成日期类型。
	    其他类型分区键
	    	String、Float类型等，通过128位的Hash算法取其Hash值作为分区ID。
=》 MinBlockNum
	最小分区块编号，自增类型，从1开始向上递增。每产生一个新的目录分区就向上递增一个数字。
	
=》 MaxBlockNum
	最大分区块编号，新创建的分区MinBlockNum等于MaxBlockNum的编号。
=》 Level
	合并的层级，被合并的次数。合并次数越多，层级值越大。
	
bin文件： 数据文件
mrk文件：标记文件
		标记文件在 idx 索引文件 和 bin 数据文件，之间起到了桥梁作用。
		以mrk2 结尾的文件，表示该表启用了自适应索引间隔。
primary.idx文件： 主键索引文件，用于加快查询效率。
minmax_create_time.idx: 分区键的最大最小值
checksums.txt： 校验文件，用于校验各个文件的正确性。存放各个文件的size以及hash值。
```



- 数据写入与分区合并

  - 任何一个批次的数据写入都会产生一个临时分区，不会纳入任何一个已有的分区。写入后的某个时刻（大概10-15分钟后），ClickHouse 会自动执行合并操作（等不及也可以手动通过 optimize 执行），把临时分区的数据，合并到已有分区中。

    ```shell
    optimize table xxxx final;
    ```

例如：再次执行上面的插入操作

```shell
insert into t_order_mt values
(101, 'sku_001', 1000.00, '2020-06-01 12:00:00'),
(102, 'sku_002', 2000.00, '2020-06-01 11:00:00'),
(102, 'sku_004', 2500.00, '2020-06-01 12:00:00'),
(102,'sku_002', 2000.00, '2020-06-01 13:00:00'),
(102, 'sku_002', 12000.00, '2020-06-01 13:00:00'),
(102, 'sku_002', 600.00, '2020-06-02 12:00:00');;
```

![image-20210823182515668](images/image-20210823182515668.png)

![image-20210823182931269](images/image-20210823182931269.png)



下 面我们通过手动执行 optimize ，把临时分区的数据，和已有分区的数据进行合并

```shell
optimize tabel t_order_mt final;
```

![image-20210823183327601](images/image-20210823183327601.png)



![image-20210823223750619](images/image-20210823223750619.png)



强制提前合并指定分区的数据

```shell
# 语法
optimize tabel t_order_mt partition "20200601" final;
```

```sql
node02 :) 
node02 :) insert into t_order_mt values　(101, 'sku_001', 1000.00, '2020-06-01 12:00:00'),　(102, 'sku_002', 2000.00, '2020-06-01 11:00:00'),　(102, 'sku_004', 2500.00, '2020-06-01 12:00:00'),　(102,'sku_002', 2000.00, '2020-06-01 13:00:00'),　(102, 'sku_002', 12000.00, '2020-06-01 13:00:00'),　(102, 'sku_002', 600.00, '2020-06-02 12:00:00');;

INSERT INTO t_order_mt VALUES

Query id: 57f9e0a4-92c5-4bab-b7ee-4926b071b2a2

Connecting to database default at localhost:9000 as user default.
Connected to ClickHouse server version 21.8.4 revision 54449.

Ok.

6 rows in set. Elapsed: 0.007 sec. 

node02 :) select * from t_order_mt;

SELECT *
FROM t_order_mt

Query id: 84251788-6d0a-4d9f-8f72-9268c22cc072

┌──id─┬─sku_id──┬─total_amount─┬─────────create_time─┐
│ 102 │ sku_002 │       600.00 │ 2020-06-02 12:00:00 │
│ 102 │ sku_002 │       600.00 │ 2020-06-02 12:00:00 │
└─────┴─────────┴──────────────┴─────────────────────┘
┌──id─┬─sku_id──┬─total_amount─┬─────────create_time─┐
│ 102 │ sku_002 │       600.00 │ 2020-06-02 12:00:00 │
└─────┴─────────┴──────────────┴─────────────────────┘
┌──id─┬─sku_id──┬─total_amount─┬─────────create_time─┐
│ 101 │ sku_001 │      1000.00 │ 2020-06-01 12:00:00 │
│ 101 │ sku_001 │      1000.00 │ 2020-06-01 12:00:00 │
│ 102 │ sku_002 │      2000.00 │ 2020-06-01 11:00:00 │
│ 102 │ sku_002 │      2000.00 │ 2020-06-01 13:00:00 │
│ 102 │ sku_002 │     12000.00 │ 2020-06-01 13:00:00 │
│ 102 │ sku_002 │      2000.00 │ 2020-06-01 11:00:00 │
│ 102 │ sku_002 │      2000.00 │ 2020-06-01 13:00:00 │
│ 102 │ sku_002 │     12000.00 │ 2020-06-01 13:00:00 │
│ 102 │ sku_004 │      2500.00 │ 2020-06-01 12:00:00 │
│ 102 │ sku_004 │      2500.00 │ 2020-06-01 12:00:00 │
└─────┴─────────┴──────────────┴─────────────────────┘
┌──id─┬─sku_id──┬─total_amount─┬─────────create_time─┐
│ 101 │ sku_001 │      1000.00 │ 2020-06-01 12:00:00 │
│ 102 │ sku_002 │      2000.00 │ 2020-06-01 11:00:00 │
│ 102 │ sku_002 │      2000.00 │ 2020-06-01 13:00:00 │
│ 102 │ sku_002 │     12000.00 │ 2020-06-01 13:00:00 │
│ 102 │ sku_004 │      2500.00 │ 2020-06-01 12:00:00 │
└─────┴─────────┴──────────────┴─────────────────────┘

18 rows in set. Elapsed: 0.011 sec. 

-- 错误示范

node02 :) optimize tabel t_order_mt partition "20200601" final;

Syntax error: failed at position 10 ('tabel'):

optimize tabel t_order_mt partition "20200601" final;

Expected TABLE

node02 :) optimize table t_order_mt partition "20200601" final;

Syntax error: failed at position 48 ('final'):

optimize table t_order_mt partition "20200601" final;

Expected one of: DoubleColon, LIKE, GLOBAL NOT IN, DIV, IS, UUID, OR, QuestionMark, BETWEEN, NOT LIKE, MOD, AND, Comma, IN, ILIKE, Dot, NOT ILIKE, NOT, Arrow, token, NOT IN, GLOBAL IN

node02 :) select * from t_order_mt;

SELECT *
FROM t_order_mt

Query id: c66054c1-7e81-4cfe-8a94-0eead4abfbde

┌──id─┬─sku_id──┬─total_amount─┬─────────create_time─┐
│ 102 │ sku_002 │       600.00 │ 2020-06-02 12:00:00 │
│ 102 │ sku_002 │       600.00 │ 2020-06-02 12:00:00 │
└─────┴─────────┴──────────────┴─────────────────────┘
┌──id─┬─sku_id──┬─total_amount─┬─────────create_time─┐
│ 102 │ sku_002 │       600.00 │ 2020-06-02 12:00:00 │
└─────┴─────────┴──────────────┴─────────────────────┘
┌──id─┬─sku_id──┬─total_amount─┬─────────create_time─┐
│ 101 │ sku_001 │      1000.00 │ 2020-06-01 12:00:00 │
│ 101 │ sku_001 │      1000.00 │ 2020-06-01 12:00:00 │
│ 102 │ sku_002 │      2000.00 │ 2020-06-01 11:00:00 │
│ 102 │ sku_002 │      2000.00 │ 2020-06-01 13:00:00 │
│ 102 │ sku_002 │     12000.00 │ 2020-06-01 13:00:00 │
│ 102 │ sku_002 │      2000.00 │ 2020-06-01 11:00:00 │
│ 102 │ sku_002 │      2000.00 │ 2020-06-01 13:00:00 │
│ 102 │ sku_002 │     12000.00 │ 2020-06-01 13:00:00 │
│ 102 │ sku_004 │      2500.00 │ 2020-06-01 12:00:00 │
│ 102 │ sku_004 │      2500.00 │ 2020-06-01 12:00:00 │
└─────┴─────────┴──────────────┴─────────────────────┘
┌──id─┬─sku_id──┬─total_amount─┬─────────create_time─┐
│ 101 │ sku_001 │      1000.00 │ 2020-06-01 12:00:00 │
│ 102 │ sku_002 │      2000.00 │ 2020-06-01 11:00:00 │
│ 102 │ sku_002 │      2000.00 │ 2020-06-01 13:00:00 │
│ 102 │ sku_002 │     12000.00 │ 2020-06-01 13:00:00 │
│ 102 │ sku_004 │      2500.00 │ 2020-06-01 12:00:00 │
└─────┴─────────┴──────────────┴─────────────────────┘

18 rows in set. Elapsed: 0.009 sec. 

node02 :) optimize table t_order_mt partition id "20200601" final;

Syntax error: failed at position 40 ('"20200601"'):

optimize table t_order_mt partition id "20200601" final;

Expected string literal

-- 正确示范

node02 :) optimize table t_order_mt partition id '20200601' final;

OPTIMIZE TABLE t_order_mt PARTITION ID '20200601' FINAL

Query id: bc831135-eefc-4bee-bcb1-3494c69a3a8e

Ok.

0 rows in set. Elapsed: 0.004 sec. 

node02 :) select * from t_order_mt;

SELECT *
FROM t_order_mt

Query id: 4696552c-88f5-472d-abfc-df356fea37d0

┌──id─┬─sku_id──┬─total_amount─┬─────────create_time─┐
│ 102 │ sku_002 │       600.00 │ 2020-06-02 12:00:00 │
│ 102 │ sku_002 │       600.00 │ 2020-06-02 12:00:00 │
└─────┴─────────┴──────────────┴─────────────────────┘
┌──id─┬─sku_id──┬─total_amount─┬─────────create_time─┐
│ 102 │ sku_002 │       600.00 │ 2020-06-02 12:00:00 │
└─────┴─────────┴──────────────┴─────────────────────┘
┌──id─┬─sku_id──┬─total_amount─┬─────────create_time─┐
│ 101 │ sku_001 │      1000.00 │ 2020-06-01 12:00:00 │
│ 101 │ sku_001 │      1000.00 │ 2020-06-01 12:00:00 │
│ 101 │ sku_001 │      1000.00 │ 2020-06-01 12:00:00 │
│ 102 │ sku_002 │      2000.00 │ 2020-06-01 11:00:00 │
│ 102 │ sku_002 │      2000.00 │ 2020-06-01 13:00:00 │
│ 102 │ sku_002 │     12000.00 │ 2020-06-01 13:00:00 │
│ 102 │ sku_002 │      2000.00 │ 2020-06-01 11:00:00 │
│ 102 │ sku_002 │      2000.00 │ 2020-06-01 13:00:00 │
│ 102 │ sku_002 │     12000.00 │ 2020-06-01 13:00:00 │
│ 102 │ sku_002 │      2000.00 │ 2020-06-01 11:00:00 │
│ 102 │ sku_002 │      2000.00 │ 2020-06-01 13:00:00 │
│ 102 │ sku_002 │     12000.00 │ 2020-06-01 13:00:00 │
│ 102 │ sku_004 │      2500.00 │ 2020-06-01 12:00:00 │
│ 102 │ sku_004 │      2500.00 │ 2020-06-01 12:00:00 │
│ 102 │ sku_004 │      2500.00 │ 2020-06-01 12:00:00 │
└─────┴─────────┴──────────────┴─────────────────────┘

18 rows in set. Elapsed: 0.006 sec. 

node02 :) 

-- 与之相对应的目录

root@node02:/var/lib/clickhouse/data/default/t_order_mt# ll
total 32
drwxr-x--- 7 clickhouse clickhouse 4096 Aug 23 14:34 ./
drwxr-x--- 3 clickhouse clickhouse 4096 Aug 23 09:00 ../
drwxr-x--- 2 clickhouse clickhouse 4096 Aug 23 10:31 20200601_1_3_1/
drwxr-x--- 2 clickhouse clickhouse 4096 Aug 23 14:34 20200601_5_5_0/
drwxr-x--- 2 clickhouse clickhouse 4096 Aug 23 10:31 20200602_2_4_1/
drwxr-x--- 2 clickhouse clickhouse 4096 Aug 23 14:34 20200602_6_6_0/
drwxr-x--- 2 clickhouse clickhouse 4096 Aug 23 09:00 detached/
-rw-r----- 1 clickhouse clickhouse    1 Aug 23 09:00 format_version.txt
root@node02:/var/lib/clickhouse/data/default/t_order_mt# ll
total 36
drwxr-x--- 8 clickhouse clickhouse 4096 Aug 23 14:43 ./
drwxr-x--- 3 clickhouse clickhouse 4096 Aug 23 09:00 ../
drwxr-x--- 2 clickhouse clickhouse 4096 Aug 23 10:31 20200601_1_3_1/
drwxr-x--- 2 clickhouse clickhouse 4096 Aug 23 14:43 20200601_1_5_2/
drwxr-x--- 2 clickhouse clickhouse 4096 Aug 23 14:34 20200601_5_5_0/
drwxr-x--- 2 clickhouse clickhouse 4096 Aug 23 10:31 20200602_2_4_1/
drwxr-x--- 2 clickhouse clickhouse 4096 Aug 23 14:34 20200602_6_6_0/
drwxr-x--- 2 clickhouse clickhouse 4096 Aug 23 09:00 detached/
-rw-r----- 1 clickhouse clickhouse    1 Aug 23 09:00 format_version.txt
root@node02:/var/lib/clickhouse/data/default/t_order_mt# 
```

### 4.4.2 primary key 主键（可选）

ClickHouse 中的主键，和其他数据库不太一样，它只提供了数据的一级索引，但是却不是唯一约束。这就意味着是可以存在相同primary key的数据的。

主键的设定主要依据是查询语句中的 where 条件

根据条件通过对主键进行某种二分查找，能够定位到对应的 index granularity,避免了全表扫描。

index granularity：直接翻译的话就是索引粒度，指在稀疏索引中两个相邻索引对应数据的间隔。Clickhouse 中的MergeTree 默认是8192。官方不建议修改这个值，除非该列存在大量重复值，比如在一个分区中几万行才有一个不同数据。

稀疏索引：

![image-20210823230528147](images/image-20210823230528147.png)

	稀疏索引的好处就是可以用很少的索引数据，定位更多的数据，代价就是只能定位到索引粒度的第一行，然后再进行扫描。

### 4.4.3 order by （必选）

order by 设定了**分区内**的数据按照哪些字段顺序进行有序保存。

order by是MergeTree 中唯一一个必填项，甚至比primary key 还重要，因为当用户不设置主键的情况，很多处理会依照order by 的字段进行处理（比如后面会讲的去重和汇总）

要求： 主键必须是order by 字段的前缀字段。

比如order by字段是（id, sku_id） 那么主键必须是id 或者(id, sku_id)

![image-20210824082331758](images/image-20210824082331758.png)



### 4.4.4 二级索引

目前在 ClickHouse 的官网上二级索引的功能在 v20.1.2.4 之前是被标注为实验性的，在这个版本之后默认是开启的。

	(1) 老版本使用二级索引前需要增加设置
	
		 是否允许使用实验性的二级索引（v20.1.2.4开始，这个参数已被删除，默认开启）

```shell
set allow_experimental_data_skipping_indices=1
```

	(2)创建测试表

```sql
create table t_order_mt2(
	id UInt32,
    sku_id String,
    total_amount Decimal(16,2),
    create_time Datetime,
    INDEX a total_amount TYPE minmal> GRANULARITY 5
)engine=MergeTree
partition by toYYYYMMDD(create_time)
primary key(id)
order by(id, sku_id);
```

其中 **GRANULARITY N** 是设定二级索引对于一级索引粒度的粒度



### 4.4.5 数据TTL

TTL 即 Time To Live, MergeTree 提供了可以管理数据**表**或**列**的生命周期的功能。

* 列级别 TTL

  创建测试表

  ```sql
  create table t_order_mt3(
  	id UInt32,
      sku_id String,
      total_amount Decimal(16,2) TTL create_time+interval 50 SECOND,
      create_time Datetime
  )engine = MergeTree
  partition by toYYYYMMDD(create_time)
  primary key(id)
  order by (id, sku_id);
  ```

  插入数据（注意：根据实际时间改变）

  ```sql
  insert into t_order_mt3 values
  (108, 'sku_001', 1000.00, '2021-08-24 10:33:50'),
  (109, 'sku_002', 2000.00, '2021-08-24 10:33:50'),
  (111, 'sku_003', 600.00, '2021-08-24 10:33:50')
  ```

  ![image-20210824180611388](images/image-20210824180611388.png)

  手动合并，查看效果 到期后，指定的字段数据归 0

  ```SQL
  node02 :) optimize table t_order_mt3 final;
  
  OPTIMIZE TABLE t_order_mt3 FINAL
  
  Query id: fe32e737-213b-4bf3-a5dc-a5bac2751efa
  
  Ok.
  
  0 rows in set. Elapsed: 0.004 sec. 
  
  node02 :) 
  node02 :) select * from t_order_mt3;
  
  SELECT *
  FROM t_order_mt3
  
  Query id: cb80fe21-9e5d-4597-a995-fb407d9ed04a
  
  ┌──id─┬─sku_id──┬─total_amount─┬─────────create_time─┐
  │ 106 │ sku_001 │      1000.00 │ 2021-08-24 18:03:30 │
  │ 107 │ sku_002 │      2000.00 │ 2021-08-24 18:03:30 │
  │ 110 │ sku_003 │       600.00 │ 2021-08-24 18:03:30 │
  └─────┴─────────┴──────────────┴─────────────────────┘
  
  3 rows in set. Elapsed: 0.006 sec. 
  
  node02 :) show create table t_order_mt3;
  
  SHOW CREATE TABLE t_order_mt3
  
  Query id: 5b947f2b-c487-43c2-8857-e7382e3ed509
  
  ┌─statement──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ CREATE TABLE default.t_order_mt3
  (
      `id` UInt32,
      `sku_id` String,
      `total_amount` Decimal(16, 2) TTL create_time + toIntervalSecond(50),
      `create_time` DateTime
  )
  ENGINE = MergeTree
  PARTITION BY toYYYYMMDD(create_time)
  PRIMARY KEY id
  ORDER BY (id, sku_id)
  SETTINGS index_granularity = 8192 │
  └────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
  
  1 rows in set. Elapsed: 0.005 sec. 
  
  node02 :) 
  
  root@node02:/var/lib/clickhouse# date
  Tue Aug 24 10:29:05 UTC 2021
  
  -- 查看服务器的时间是 UTC时间错了 8 个小时呢， 我说为啥没有过期呢,但是即使我设置了正确的时间还是没有把过期的列值置为0
  node02 :) select * from t_order_mt3;
  
  SELECT *
  FROM t_order_mt3
  
  Query id: e368526f-df4e-4272-9145-85f152979b90
  
  ┌──id─┬─sku_id──┬─total_amount─┬─────────create_time─┐
  │ 106 │ sku_001 │      1000.00 │ 2021-08-24 18:03:30 │
  │ 107 │ sku_002 │      2000.00 │ 2021-08-24 18:03:30 │
  │ 108 │ sku_001 │      1000.00 │ 2021-08-24 10:33:50 │
  │ 109 │ sku_002 │      2000.00 │ 2021-08-24 10:33:50 │
  │ 110 │ sku_003 │       600.00 │ 2021-08-24 18:03:30 │
  │ 111 │ sku_003 │       600.00 │ 2021-08-24 10:33:50 │
  └─────┴─────────┴──────────────┴─────────────────────┘
  
  6 rows in set. Elapsed: 0.004 sec. 
  
  -- 难道非得重启 clickhouse 服务吗？（要不等15分钟后看看）
  -- 课上老师是重启 clickhouse 服务后，才生效的，老师给出的解释是执行合并任务是重新开启了一个线程，他所使用的服务器资源不是很充足大概是该任务卡住的缘故。
  
  root@node02:/var/lib/clickhouse# sudo clickhouse restart
  /var/run/clickhouse-server/clickhouse-server.pid file exists and contains pid = 1628.
  The process with pid = 1628 is running.
  Sent terminate signal to process with pid 1628.
  Waiting for server to stop
  /var/run/clickhouse-server/clickhouse-server.pid file exists and contains pid = 1628.
  The process with pid = 1628 is running.
  Waiting for server to stop
  /var/run/clickhouse-server/clickhouse-server.pid file exists and contains pid = 1628.
  The process with pid = 1628 is running.
  Waiting for server to stop
  /var/run/clickhouse-server/clickhouse-server.pid file exists and contains pid = 1628.
  The process with pid = 1628 is running.
  Waiting for server to stop
  /var/run/clickhouse-server/clickhouse-server.pid file exists and contains pid = 1628.
  The process with pid = 1628 is running.
  Waiting for server to stop
  /var/run/clickhouse-server/clickhouse-server.pid file exists and contains pid = 1628.
  The process with pid = 1628 is running.
  Waiting for server to stop
  /var/run/clickhouse-server/clickhouse-server.pid file exists and contains pid = 1628.
  The process with pid = 1628 is running.
  Waiting for server to stop
  Now there is no clickhouse-server process.
  Server stopped
   chown --recursive clickhouse '/var/run/clickhouse-server/'
  Will run su -s /bin/sh 'clickhouse' -c '/usr/bin/clickhouse-server --config-file /etc/clickhouse-server/config.xml --pid-file /var/run/clickhouse-server/clickhouse-server.pid --daemon'
  Waiting for server to start
  Waiting for server to start
  Server started
  
  root@node02:/var/lib/clickhouse# 
  
  node02 :) optimize table t_order_mt3 final;
  
  OPTIMIZE TABLE t_order_mt3 FINAL
  
  Query id: 19fe1ab0-5d8c-430e-8a62-6f04da497fc7
  
  Ok.
  
  0 rows in set. Elapsed: 0.002 sec. 
  
  node02 :) use default;
  
  USE default
  
  Query id: a1f027d7-f616-4a7c-ae8c-e14a43e875d7
  
  Ok.
  
  0 rows in set. Elapsed: 0.001 sec. 
  node02 :) select * from t_order_mt3;
  
  SELECT *
  FROM t_order_mt3
  
  Query id: 640496cb-768c-4fdf-8cb3-73f7ee27b084
  
  ┌──id─┬─sku_id──┬─total_amount─┬─────────create_time─┐
  │ 106 │ sku_001 │      1000.00 │ 2021-08-24 18:03:30 │
  │ 107 │ sku_002 │      2000.00 │ 2021-08-24 18:03:30 │
  │ 108 │ sku_001 │      1000.00 │ 2021-08-24 10:33:50 │
  │ 109 │ sku_002 │      2000.00 │ 2021-08-24 10:33:50 │
  │ 110 │ sku_003 │       600.00 │ 2021-08-24 18:03:30 │
  │ 111 │ sku_003 │       600.00 │ 2021-08-24 10:33:50 │
  └─────┴─────────┴──────────────┴─────────────────────┘
  
  6 rows in set. Elapsed: 0.008 sec. 
  
  node02 :) 
  -- 我重启了clickhouse后，重新手动合并了，但是还没置0
  
  ```

  

  

- 表级 TTL

  下面的这条语句是数据会在 create_time 之后 10 秒丢失

  ```shell
  alter table t_order_mt3 MODIFY TTL create_time + INTERVAL 10 SECOND;
  ```

  设计判断的字段必须是 Date 或者 Datetime 类型，推荐使用分区的日期字段。

  能够使用的时间周期

  ```SHELL
  - SECOND
  - MINUTE
  - HOUR
  - DAY
  - WEEK
  - MONTH
  - QUARTER
  - YEAR
  ```

  

  



## 4.5 ReplacingMergeTree（最终的一致性）

	ReplacingMergeTree 是 MergeTree 的一个变种，它存储特性完全继承了 MergeTree, 只是多了一个**去重**的功能。尽管 MergeTree 可以设置主键，但是 primary key 其实没有唯一约束功能。如果你想处理掉重复的数据，可以借助这个 ReplacingMergeTree。



**去重时机**

	数据的去重只会在合并的过程中出现。合并会在未知的时间在后台进行，所以你无法预先做出计划。有一些数据可能仍未被处理。

**去重范围**

	如果表经过了分区，去重只会在分区内部进行去重，不能执行跨分区的去重。
	
	所以 ReplacingMergeTree 能力有限， ReplacingMergeTree 适用于在后台清除重复的数据以节省空间，但是它不保证没有重复的数据出现。



> > 案例演示

* 创建表

  ```shell
  create table t_order_rmt
  (
  	id UInt32,
  	sku_id String,
  	total_amount Decimal(16,2),
  	create_time Datetime
  )engine=ReplacingMergeTree(create_time)
  partition by toYYYYMMDD(create_time)
  primary key(id)
  order by(id, sku_id);;
  ```

  **ReplacingMergeTree() 填入的参数为版本字段，重复数据保留版本字段值最大的。如果不填版本字段，默认按照插入顺序保留最后一条**

* 向表中插入数据

  ```shell
  insert into t_order_rmt values
  (101, 'sku_001', 1000.00, '2020-06-01 12:00:00'),
  (102, 'sku_002', 2000.00, '2020-06-01 11:00:00'),
  (102, 'sku_004', 2500.00, '2020-06-01 12:00:00'),
  (102,'sku_002', 2000.00, '2020-06-01 13:00:00'),
  (102, 'sku_002', 1200.00, '2020-06-01 13:00:00'),
  (102, 'sku_002', 600.00, '2020-06-02 12:00:00');;
  ```

* 执行第一次查询

  ```shell
  node02 :) select * from t_order_rmt;
  
  SELECT *
  FROM t_order_rmt
  
  Query id: 3b19ebc5-7e54-4d9a-bd98-106dade91365
  
  ┌──id─┬─sku_id──┬─total_amount─┬─────────create_time─┐
  │ 102 │ sku_002 │       600.00 │ 2020-06-02 12:00:00 │
  └─────┴─────────┴──────────────┴─────────────────────┘
  ┌──id─┬─sku_id──┬─total_amount─┬─────────create_time─┐
  │ 101 │ sku_001 │      1000.00 │ 2020-06-01 12:00:00 │
  │ 102 │ sku_002 │      1200.00 │ 2020-06-01 13:00:00 │
  │ 102 │ sku_004 │      2500.00 │ 2020-06-01 12:00:00 │
  └─────┴─────────┴──────────────┴─────────────────────┘
  
  4 rows in set. Elapsed: 0.003 sec. 
  
  # 我们向表中插入了6条数据，当我执行查询的时候只有4条，少了(102, 'sku_002', 2000.00, '2020-06-01 11:00:00'), (102,'sku_002', 2000.00, '2020-06-01 13:00:00'), 首先当 id和sku_id 都相同的时候，即重复数据保留版本字段值即 create_time 最大的即 (102,'sku_002', 2000.00, '2020-06-01 13:00:00'), 和 (102, 'sku_002', 1200.00, '2020-06-01 13:00:00'), 当create_time 也相同时，保留插入顺序最后一条的，即(102, 'sku_002', 1200.00, '2020-06-01 13:00:00'), ， 所以我们就看到了 (102, 'sku_002', 2000.00, '2020-06-01 11:00:00'), (102,'sku_002', 2000.00, '2020-06-01 13:00:00'), 这两条被过滤掉了。
  ```

* 再次插入一遍数据

  ```sql
  node02 :) select * from t_order_rmt;
  
  SELECT *
  FROM t_order_rmt
  
  Query id: 3b19ebc5-7e54-4d9a-bd98-106dade91365
  
  ┌──id─┬─sku_id──┬─total_amount─┬─────────create_time─┐
  │ 102 │ sku_002 │       600.00 │ 2020-06-02 12:00:00 │
  └─────┴─────────┴──────────────┴─────────────────────┘
  ┌──id─┬─sku_id──┬─total_amount─┬─────────create_time─┐
  │ 101 │ sku_001 │      1000.00 │ 2020-06-01 12:00:00 │
  │ 102 │ sku_002 │      1200.00 │ 2020-06-01 13:00:00 │
  │ 102 │ sku_004 │      2500.00 │ 2020-06-01 12:00:00 │
  └─────┴─────────┴──────────────┴─────────────────────┘
  
  4 rows in set. Elapsed: 0.003 sec. 
  
  node02 :) 
  node02 :) insert into t_order_rmt values
  :-] (101, 'sku_001', 1000.00, '2020-06-01 12:00:00'),
  :-] (102, 'sku_002', 2000.00, '2020-06-01 11:00:00'),
  :-] (102, 'sku_004', 2500.00, '2020-06-01 12:00:00'),
  :-] (102,'sku_002', 2000.00, '2020-06-01 13:00:00'),
  :-] (102, 'sku_002', 1200.00, '2020-06-01 13:00:00'),
  :-] (102, 'sku_002', 600.00, '2020-06-02 12:00:00');;
  
  INSERT INTO t_order_rmt VALUES
  
  Query id: 3567593c-6ab4-4e21-8100-cef46c1da46b
  
  Ok.
  
  6 rows in set. Elapsed: 0.005 sec. 
  
  node02 :) select * from t_order_rmt;
  
  SELECT *
  FROM t_order_rmt
  
  Query id: 20246f21-f739-417c-8f05-9f2712a2b020
  
  ┌──id─┬─sku_id──┬─total_amount─┬─────────create_time─┐
  │ 102 │ sku_002 │       600.00 │ 2020-06-02 12:00:00 │
  └─────┴─────────┴──────────────┴─────────────────────┘
  ┌──id─┬─sku_id──┬─total_amount─┬─────────create_time─┐
  │ 102 │ sku_002 │       600.00 │ 2020-06-02 12:00:00 │
  └─────┴─────────┴──────────────┴─────────────────────┘
  ┌──id─┬─sku_id──┬─total_amount─┬─────────create_time─┐
  │ 101 │ sku_001 │      1000.00 │ 2020-06-01 12:00:00 │
  │ 102 │ sku_002 │      1200.00 │ 2020-06-01 13:00:00 │
  │ 102 │ sku_004 │      2500.00 │ 2020-06-01 12:00:00 │
  └─────┴─────────┴──────────────┴─────────────────────┘
  ┌──id─┬─sku_id──┬─total_amount─┬─────────create_time─┐
  │ 101 │ sku_001 │      1000.00 │ 2020-06-01 12:00:00 │
  │ 102 │ sku_002 │      1200.00 │ 2020-06-01 13:00:00 │
  │ 102 │ sku_004 │      2500.00 │ 2020-06-01 12:00:00 │
  └─────┴─────────┴──────────────┴─────────────────────┘
  
  8 rows in set. Elapsed: 0.007 sec. 
  
  node02 :) 
  node02 :) select * from t_order_rmt;
  
  SELECT *
  FROM t_order_rmt
  
  Query id: cc4442f6-7633-4b32-96d7-4bd1038211a8
  
  ┌──id─┬─sku_id──┬─total_amount─┬─────────create_time─┐
  │ 102 │ sku_002 │       600.00 │ 2020-06-02 12:00:00 │
  └─────┴─────────┴──────────────┴─────────────────────┘
  ┌──id─┬─sku_id──┬─total_amount─┬─────────create_time─┐
  │ 102 │ sku_002 │       600.00 │ 2020-06-02 12:00:00 │
  └─────┴─────────┴──────────────┴─────────────────────┘
  ┌──id─┬─sku_id──┬─total_amount─┬─────────create_time─┐
  │ 101 │ sku_001 │      1000.00 │ 2020-06-01 12:00:00 │
  │ 102 │ sku_002 │      1200.00 │ 2020-06-01 13:00:00 │
  │ 102 │ sku_004 │      2500.00 │ 2020-06-01 12:00:00 │
  └─────┴─────────┴──────────────┴─────────────────────┘
  ┌──id─┬─sku_id──┬─total_amount─┬─────────create_time─┐
  │ 101 │ sku_001 │      1000.00 │ 2020-06-01 12:00:00 │
  │ 102 │ sku_002 │      1200.00 │ 2020-06-01 13:00:00 │
  │ 102 │ sku_004 │      2500.00 │ 2020-06-01 12:00:00 │
  └─────┴─────────┴──────────────┴─────────────────────┘
  
  8 rows in set. Elapsed: 0.011 sec. 
  
  
  -- 手动强制合并
  node02 :) select * from t_order_rmt;
  
  SELECT *
  FROM t_order_rmt
  
  Query id: dadd6d26-7f48-4603-8137-81f788e8914a
  
  ┌──id─┬─sku_id──┬─total_amount─┬─────────create_time─┐
  │ 102 │ sku_002 │       600.00 │ 2020-06-02 12:00:00 │
  └─────┴─────────┴──────────────┴─────────────────────┘
  ┌──id─┬─sku_id──┬─total_amount─┬─────────create_time─┐
  │ 101 │ sku_001 │      1000.00 │ 2020-06-01 12:00:00 │
  │ 102 │ sku_002 │      1200.00 │ 2020-06-01 13:00:00 │
  │ 102 │ sku_004 │      2500.00 │ 2020-06-01 12:00:00 │
  └─────┴─────────┴──────────────┴─────────────────────┘
  
  4 rows in set. Elapsed: 0.005 sec. 
  
  node02 :) 
  
  ```

  

  

  ![image-20210824224001533](images/image-20210824224001533.png)



**手动强制合并分区, 然后查看**

![image-20210824224339564](images/image-20210824224339564.png)



			**我们从上面框起来的两条数据可以看出，去重是针对同一个分区内的数据而言，不同分区不存在着去重规则**
	
			**21年的新版本是在我们首次插入的时候就帮我们完成了去重，老版本不会**
	
	**通过测试得到结论**

+ 实际上是使用 order by 字段作为唯一键
+ 去重不能跨分区
+ 只有同一批插入（新版本）或合并分区时才会进行去重
+ 认定重复的数据保留，版本字段值最大的
+ 如果版本字段相同则按插入顺序保留最后一笔





## 4.6 SummingMergeTree

		对于不查询明细，只关心以维度进行汇总聚合结果的场景。如果只使用普通的MergeTree的话，无论是存储空间的开销，还是查询临时聚合的开销都比较大。
	
		ClickHouse 为了这种场景，提供了一种能够 “预聚合” 的引擎 SummingMergeTree

> 案例演示

* 创建表

  ```shell
  create table t_order_smt
  (
  	id UInt32,
  	sku_id String,
  	total_amount Decimal(16,2),
  	create_time Datetime
  )engine=SummingMergeTree(total_amount)
  partition by toYYYYMMDD(create_time)
  primary key (id)
  order by(id, sku_id);;
  ```

* 插入数据

  ```sql
  -- 为 t_order_smt values
  insert into t_order_smt values
  (101, 'sku_001', 1000.00, '2020-06-01 12:00:00'),
  (102, 'sku_002', 2000.00, '2020-06-01 11:00:00'),
  (102, 'sku_004', 2500.00, '2020-06-01 12:00:00'),
  (102,'sku_002', 2000.00, '2020-06-01 13:00:00'),
  (102, 'sku_002', 12000.00, '2020-06-01 13:00:00'),
  (102, 'sku_002', 600.00, '2020-06-02 12:00:00');;
  ```

* 执行第一次查询

  ```sql
  node02 :) select * from t_order_smt;
  
  SELECT *
  FROM t_order_smt
  
  Query id: cdb0d27d-64fd-443b-b504-5ccbd7f2cbc5
  
  ┌──id─┬─sku_id──┬─total_amount─┬─────────create_time─┐
  │ 102 │ sku_002 │       600.00 │ 2020-06-02 12:00:00 │
  └─────┴─────────┴──────────────┴─────────────────────┘
  ┌──id─┬─sku_id──┬─total_amount─┬─────────create_time─┐
  │ 101 │ sku_001 │      1000.00 │ 2020-06-01 12:00:00 │
  │ 102 │ sku_002 │     16000.00 │ 2020-06-01 11:00:00 │
  │ 102 │ sku_004 │      2500.00 │ 2020-06-01 12:00:00 │
  └─────┴─────────┴──────────────┴─────────────────────┘
  
  4 rows in set. Elapsed: 0.006 sec. 
  
  -- 再插入一条数据
  node02 :) insert into t_order_smt values (101, 'sku_001', 2000.00, '2020-06-01 13:00:00');;
  
  INSERT INTO t_order_smt VALUES
  
  Query id: 121f8580-a8f0-4e6d-939f-d61da781c6e0
  
  Ok.
  
  1 rows in set. Elapsed: 0.007 sec. 
  
  node02 :) select * from t_order_smt;
  
  SELECT *
  FROM t_order_smt
  
  Query id: d41e713e-63e9-40c7-9655-e04f15fc2b42
  
  ┌──id─┬─sku_id──┬─total_amount─┬─────────create_time─┐
  │ 101 │ sku_001 │      2000.00 │ 2020-06-01 13:00:00 │
  └─────┴─────────┴──────────────┴─────────────────────┘
  ┌──id─┬─sku_id──┬─total_amount─┬─────────create_time─┐
  │ 102 │ sku_002 │       600.00 │ 2020-06-02 12:00:00 │
  └─────┴─────────┴──────────────┴─────────────────────┘
  ┌──id─┬─sku_id──┬─total_amount─┬─────────create_time─┐
  │ 101 │ sku_001 │      1000.00 │ 2020-06-01 12:00:00 │
  │ 102 │ sku_002 │     16000.00 │ 2020-06-01 11:00:00 │
  │ 102 │ sku_004 │      2500.00 │ 2020-06-01 12:00:00 │
  └─────┴─────────┴──────────────┴─────────────────────┘
  
  5 rows in set. Elapsed: 0.005 sec. 
  
  node02 :) 
  -- 手动强制合并分区
  node02 :) optimize table t_order_smt final;;
  
  OPTIMIZE TABLE t_order_smt FINAL
  
  Query id: edd5247a-4f5e-48ec-b19a-b61e14c57721
  
  Ok.
  
  0 rows in set. Elapsed: 0.004 sec. 
  
  node02 :) select * from t_order_smt;
  
  SELECT *
  FROM t_order_smt
  
  Query id: 57430131-2876-4376-820a-73330a9fd098
  
  ┌──id─┬─sku_id──┬─total_amount─┬─────────create_time─┐
  │ 102 │ sku_002 │       600.00 │ 2020-06-02 12:00:00 │
  └─────┴─────────┴──────────────┴─────────────────────┘
  ┌──id─┬─sku_id──┬─total_amount─┬─────────create_time─┐
  │ 101 │ sku_001 │      3000.00 │ 2020-06-01 12:00:00 │
  │ 102 │ sku_002 │     16000.00 │ 2020-06-01 11:00:00 │
  │ 102 │ sku_004 │      2500.00 │ 2020-06-01 12:00:00 │
  └─────┴─────────┴──────────────┴─────────────────────┘
  
  4 rows in set. Elapsed: 0.006 sec. 
  
  node02 :) 
  ```

**通过结果可以得到以下结论**

* 以 SummingMergeTree()  中指定的列作为汇总数据列
* 可以填写多列必须数字列，如果不填，以所有非维度列且为数字列的字段为汇总数据列
* 以 order by 的列为准，作为维度列
* 其他的列按插入顺序保留第一行
* 不在一个分区的数据不会聚合
* 只有在同一批次插入（新版本）或分片合并时才会进行聚合



**开发建议**

设计聚合表的话，唯一键值、流水号可以去掉，所有字段全部是维度、度量或者时间戳。



**问题**

能不能直接执行以下SQL得到汇总值

```sql
select total_amount from yyy where province_name='' and create_date='xxx';;
```

**不行，可能会包含一些还没来得及聚合的临时明细**

如果要是获取汇总值，还是需要使用 sum 进行聚合，这样效率会有一定的提高，但本身 ClickHouse 是列式存储的，效率提升有限，不会特别明显。

```sql
select sum(total_amount) from province_name='' and create_date='xxx';
```



# 第5章 clickhouse备份与恢复

## 5.1 手动实现备份及恢复

### 5.1.1 备份数据表

#### 1、确定shadow目录是否存在以及存在是否为空

```shell
cd /var/lib/clickhouse
mkdir shadow
chown -R clickhouse:clickhouse shadow
```



#### 2、冻结ClickHouse数据表

```shell
# 冻结该表
root@node02:/var/lib/clickhouse/shadow# echo -n 'alter table t_order_mt freeze' | clickhouse-client
```



```sql
-- 完之后，该表还是可以进行读与写的操作
node02 :) select * from t_order_mt;

SELECT *
FROM t_order_mt

Query id: 6afb271a-c666-4359-aa13-fbe86c9c2ea9

┌──id─┬─sku_id──┬─total_amount─┬─────────create_time─┐
│ 102 │ sku_002 │       600.00 │ 2020-06-02 12:00:00 │
│ 102 │ sku_002 │       600.00 │ 2020-06-02 12:00:00 │
│ 102 │ sku_002 │       600.00 │ 2020-06-02 12:00:00 │
└─────┴─────────┴──────────────┴─────────────────────┘
┌──id─┬─sku_id──┬─total_amount─┬─────────create_time─┐
│ 101 │ sku_001 │      1000.00 │ 2020-06-01 12:00:00 │
│ 101 │ sku_001 │      1000.00 │ 2020-06-01 12:00:00 │
│ 101 │ sku_001 │      1000.00 │ 2020-06-01 12:00:00 │
│ 102 │ sku_002 │      2000.00 │ 2020-06-01 11:00:00 │
│ 102 │ sku_002 │      2000.00 │ 2020-06-01 13:00:00 │
│ 102 │ sku_002 │     12000.00 │ 2020-06-01 13:00:00 │
│ 102 │ sku_002 │      2000.00 │ 2020-06-01 11:00:00 │
│ 102 │ sku_002 │      2000.00 │ 2020-06-01 13:00:00 │
│ 102 │ sku_002 │     12000.00 │ 2020-06-01 13:00:00 │
│ 102 │ sku_002 │      2000.00 │ 2020-06-01 11:00:00 │
│ 102 │ sku_002 │      2000.00 │ 2020-06-01 13:00:00 │
│ 102 │ sku_002 │     12000.00 │ 2020-06-01 13:00:00 │
│ 102 │ sku_004 │      2500.00 │ 2020-06-01 12:00:00 │
│ 102 │ sku_004 │      2500.00 │ 2020-06-01 12:00:00 │
│ 102 │ sku_004 │      2500.00 │ 2020-06-01 12:00:00 │
└─────┴─────────┴──────────────┴─────────────────────┘

18 rows in set. Elapsed: 0.009 sec. 

node02 :) insert into t_order_mt values　(101, 'sku_001', 1000.00, '2020-06-01 12:00:00'),　(102, 'sku_002', 2000.00, '2020-06-01 11:00:00'),　(102, 'sku_004', 2500.00, '2020-06-01 12:00:00'),　(102,'sku_002', 2000.00, '2020-06-01 13:00:00'),　(102, 'sku_002', 12000.00, '2020-06-01 13:00:00'),　(102, 'sku_002', 600.00, '2020-06-02 12:00:00');;

INSERT INTO t_order_mt VALUES

Query id: 3fe21843-7c8f-4f39-8be5-9eca30a0ac20

Ok.

6 rows in set. Elapsed: 0.004 sec. 

node02 :) select * from t_order_mt;

SELECT *
FROM t_order_mt

Query id: b08f3225-ea8a-4eb6-b9fa-8af98c9eef63

┌──id─┬─sku_id──┬─total_amount─┬─────────create_time─┐
│ 102 │ sku_002 │       600.00 │ 2020-06-02 12:00:00 │
│ 102 │ sku_002 │       600.00 │ 2020-06-02 12:00:00 │
│ 102 │ sku_002 │       600.00 │ 2020-06-02 12:00:00 │
└─────┴─────────┴──────────────┴─────────────────────┘
┌──id─┬─sku_id──┬─total_amount─┬─────────create_time─┐
│ 102 │ sku_002 │       600.00 │ 2020-06-02 12:00:00 │
└─────┴─────────┴──────────────┴─────────────────────┘
┌──id─┬─sku_id──┬─total_amount─┬─────────create_time─┐
│ 101 │ sku_001 │      1000.00 │ 2020-06-01 12:00:00 │
│ 101 │ sku_001 │      1000.00 │ 2020-06-01 12:00:00 │
│ 101 │ sku_001 │      1000.00 │ 2020-06-01 12:00:00 │
│ 102 │ sku_002 │      2000.00 │ 2020-06-01 11:00:00 │
│ 102 │ sku_002 │      2000.00 │ 2020-06-01 13:00:00 │
│ 102 │ sku_002 │     12000.00 │ 2020-06-01 13:00:00 │
│ 102 │ sku_002 │      2000.00 │ 2020-06-01 11:00:00 │
│ 102 │ sku_002 │      2000.00 │ 2020-06-01 13:00:00 │
│ 102 │ sku_002 │     12000.00 │ 2020-06-01 13:00:00 │
│ 102 │ sku_002 │      2000.00 │ 2020-06-01 11:00:00 │
│ 102 │ sku_002 │      2000.00 │ 2020-06-01 13:00:00 │
│ 102 │ sku_002 │     12000.00 │ 2020-06-01 13:00:00 │
│ 102 │ sku_004 │      2500.00 │ 2020-06-01 12:00:00 │
│ 102 │ sku_004 │      2500.00 │ 2020-06-01 12:00:00 │
│ 102 │ sku_004 │      2500.00 │ 2020-06-01 12:00:00 │
└─────┴─────────┴──────────────┴─────────────────────┘
┌──id─┬─sku_id──┬─total_amount─┬─────────create_time─┐
│ 101 │ sku_001 │      1000.00 │ 2020-06-01 12:00:00 │
│ 102 │ sku_002 │      2000.00 │ 2020-06-01 11:00:00 │
│ 102 │ sku_002 │      2000.00 │ 2020-06-01 13:00:00 │
│ 102 │ sku_002 │     12000.00 │ 2020-06-01 13:00:00 │
│ 102 │ sku_004 │      2500.00 │ 2020-06-01 12:00:00 │
└─────┴─────────┴──────────────┴─────────────────────┘

24 rows in set. Elapsed: 0.008 sec. 

node02 :) 

```

![image-20210824101506035](images/image-20210824101506035.png)



#### 3、将备份数据和建表语句保存到其他路径

```shell
cd /var/lib/clickhouse
sudo mkdir -p backup/defualt/t_order_mt
cp metadata/default/t_order_mt.sql    backup/default/t_order_mt/
cp -r shadow/*  backup/default/t_order_mt
chown -R clickhouse:clickhouse  backup/
```



#### 4、为下次备份准备，删除 shadow 目录下的数据

```shell
cd /var/lib/clickhosue
rm -rf shadow/*
```



### 5.1.2 恢复你的备份

#### 1 删除测试表

![image-20210824114948137](images/image-20210824114948137.png)





#### 2 用备份的元数据中 t_order-mt.sql 重新创建表结构

```shell
root@node02:/var/lib/clickhouse# echo 'drop table t_order_mt' |clickhouse-client
root@node02:/var/lib/clickhouse# cat backup/default/t_order_mt/t_order_mt.sql |clickhouse-client
Received exception from server (version 21.8.4):
Code: 57. DB::Exception: Received from localhost:9000. DB::Exception: Mapping for table with UUID=59a9a8aa-efa8-463e-99a9-a8aaefa8963e already exists. It happened due to UUID collision, most likely because some not random UUIDs were manually specified in CREATE queries.. 
root@node02:/var/lib/clickhouse# 
root@node02:/var/lib/clickhouse# ls
access  data              flags           metadata          preprocessed_configs  status  tmp
backup  dictionaries_lib  format_schemas  metadata_dropped  shadow                store   user_files
root@node02:/var/lib/clickhouse# cd backup/
root@node02:/var/lib/clickhouse/backup# ls
default
root@node02:/var/lib/clickhouse/backup# cd default/t_order_mt/
root@node02:/var/lib/clickhouse/backup/default/t_order_mt# ls
1  increment.txt  t_order_mt.sql
root@node02:/var/lib/clickhouse/backup/default/t_order_mt# cat t_order_mt.sql 
ATTACH TABLE _ UUID '59a9a8aa-efa8-463e-99a9-a8aaefa8963e'
(
    `id` UInt32,
    `sku_id` String,
    `total_amount` Decimal(16, 2),
    `create_time` DateTime
)
ENGINE = MergeTree
PARTITION BY toYYYYMMDD(create_time)
PRIMARY KEY id
ORDER BY (id, sku_id)
SETTINGS index_granularity = 8192

# 修改
vi t_order_mt.sql
create TABLE t_order_mt
(
    `id` UInt32,
    `sku_id` String,
    `total_amount` Decimal(16, 2),
    `create_time` DateTime
)
ENGINE = MergeTree
PARTITION BY toYYYYMMDD(create_time)
PRIMARY KEY id
ORDER BY (id, sku_id)
SETTINGS index_granularity = 8192
```

#### 3 把备份复制到相对应的表 "detached" 目录下

```shell
cd /var/lib/clickhouse
cp -rl backup/default/t_order_mt/1/store/*/*/*  data/default/t_order_mt/detached/
chown -R clickhouse:clickhouse /data/default/t_order_mt/detached/
```



![image-20210824122011733](images/image-20210824122011733.png)

ClickHouse 使用文件系统硬链接来实现即时备份，而不会导致 ClickHouse 服务停机（或锁定）。这些硬链接可以进一步用于有效的备份存储。在支持硬链接的文件系统（例如本地文件系统或 NFS ）上，将 cp 与 -l 标志一起使用（或将 rsync 与 --hard-links 和 -numeric-ids 标志一起使用）以避免复制数据。

**注意：仅拷贝分区目录，注意目录所属的用户和组都要是clickhouse**



#### 4 attach 恢复表的相对应分区及查询表数据

```shell
root@node02:/var/lib/clickhouse# cp -rl backup/default/t_order_mt/1/store/*/*/* data/default/t_order_mt/detached/
root@node02:/var/lib/clickhouse# echo 'alter table t_order_mt attach' |clickhouse-client
Code: 62. DB::Exception: Syntax error: failed at position 31 (end of query): . Expected one of: PARTITION, PART

root@node02:/var/lib/clickhouse# echo 'alter table t_order_mt attach partition' |clickhouse-client
Code: 62. DB::Exception: Syntax error: failed at position 41 (end of query): . Expected one of: EXTRACT, TIMESTAMPADD, TIMESTAMPDIFF, TIMESTAMP_DIFF, TRIM expression, lambda expression, number, logical-NOT expression, substitution, nullity checking, DATE_ADD, DoubleColon, RIGHT, tuple, TIMESTAMP, qualified asterisk, literal, SELECT subquery, DATE_ADD expression, asterisk, EXTRACT expression, DATE, NULL, compound identifier, OpeningRoundBracket, string concatenation expression, logical-OR expression, identifier, MySQL-style global variable, array element expression, TIMESTAMP operator expression, element of expression, expression with prefix unary operator, DATE operator expression, list, delimited by operator of variable arity, DATE_DIFF, parenthesized expression, COLUMNS matcher, RIGHT expression, array, ID, TRIM, DATE_DIFF expression, case, string literal, INTERVAL operator expression, DATESUB, TIMESTAMPSUB, CAST AS expression, INTERVAL, expression with ternary operator, CASE, LEFT expression, LEFT, CAST operator, CAST, additive expression, logical-AND expression, SUBSTRING, list of elements, partition, RTRIM, DATEDIFF, SUBSTRING expression, BETWEEN expression, NOT, function, DATEADD, DATE_SUB, tuple element expression, comparison expression, Arrow, collection of literals, TIMESTAMP_ADD, list, delimited by binary operators, CAST expression, COLUMNS, TIMESTAMP_SUB, token, LTRIM, multiplicative expression, unary expression

root@node02:/var/lib/clickhouse# echo 'alter table t_order_mt attach partition 20200601' |clickhouse-client
Received exception from server (version 21.8.4):
Code: 1001. DB::Exception: Received from localhost:9000. DB::Exception: std::__1::__fs::filesystem::filesystem_error: filesystem error: in directory_iterator::directory_iterator(...): Permission denied [/var/lib/clickhouse/store/19c/19cd9c4e-87c6-4b25-99cd-9c4e87c68b25/detached/attaching_20200601_1_5_2/]. 
root@node02:/var/lib/clickhouse# echo 'alter table t_order_mt attach partition 20200601' |clickhouse-client
root@node02:/var/lib/clickhouse# echo 'alter table t_order_mt attach partition 20200602' |clickhouse-client
root@node02:/var/lib/clickhouse# 

```



```shell
# 正确恢复语法 attach 附加上去 
echo 'alter table t_order_mt attach partition 20200601' | clickhouse-client
# 检查验证-测试环境使用
select * from t_order_count; # 测试环境，数据量很少使用
# 检查验证-生产环境使用
select count() from t_order_mt | clickhouse-client

```

![image-20210824140214125](images/image-20210824140214125.png)



扩展：生产环境 ClickHouse 中会有好几个库，每个库中又有几张、几十张表像这种情况我们应该如何备份与恢复呢？



## 5.2 使用clickhouse-backup

上面的过程，我们可以使用 ClickHouse 的备份工具 clickhouse-backup 帮我们自动化实现。

工具地址： https://github.com/AlexAkulov/clickhouse-backup



### 5.2.1 上传并安装

将 clickhouse-backup-1.0.0-1.x86_64.rpm 上传至 /opt/software/ 目录下，安装：

```shell
sudo rpm -ivh clickhouse-backup-1.0.0-1.x86_64.rpm
```



### 5.2.2 配置文件



### 5.2.3 创建备份

查看可用命令

```shell
clickhosue-backup help
```

显示要备份的表

```shell
root@node02:/var/lib/clickhouse# clickhouse-backup tables
default.m_order_mm  647B  default  
default.n_order_nn  647B  default  
default.t_order_tt  647B  default  
```

创建备份

```shell
root@node02:/var/lib/clickhouse# clickhouse-backup create
2021/08/24 08:37:35  info done                      backup=2021-08-24T08-37-35 operation=create table=default.m_order_mm
2021/08/24 08:37:35  info done                      backup=2021-08-24T08-37-35 operation=create table=default.n_order_nn
2021/08/24 08:37:35  info done                      backup=2021-08-24T08-37-35 operation=create table=default.t_order_tt
2021/08/24 08:37:35  info done                      backup=2021-08-24T08-37-35 operation=create
root@node02:/var/lib/clickhouse# ls
access  data              flags           metadata          preprocessed_configs  status  tmp
backup  dictionaries_lib  format_schemas  metadata_dropped  shadow                store   user_files
root@node02:/var/lib/clickhouse# cd backup/
root@node02:/var/lib/clickhouse/backup# ls
2021-08-24T07-57-27  2021-08-24T08-37-35
```

查看现有的本地备份

```shell
root@node02:/var/lib/clickhouse# clickhouse-backup list
2021-08-24T07-57-27   1.23KiB   24/08/2021 07:57:27   local      
2021/08/24 08:36:01 error InvalidParameter: 1 validation error(s) found.
- minimum field size of 1, ListObjectsV2Input.Bucket.
```

备份存储在 /var/lib/clickhouse/backup/BACKUPNAME。 备份名称默认为时间戳，但是可以选择使用 -name 标志指定备份名称。备份包含两个目录：一个 “metadata” 目录，其中包含重新创建架构所需要的 DDL SQL 语句；以及一个 "shadow" 目录， 其中包含作为 ALTER TABLE ... FREEZE 操作结果的数据。



```shell
# 操作步骤
root@node02:/var/lib/clickhouse/backup# ls
default
root@node02:/var/lib/clickhouse/backup# rm -rf default/
root@node02:/var/lib/clickhouse/backup# ls
root@node02:/var/lib/clickhouse/backup# 
root@node02:/var/lib/clickhouse/backup# pwd
/var/lib/clickhouse/backup
root@node02:/var/lib/clickhouse/backup# cd ..
root@node02:/var/lib/clickhouse# ls
access  data              flags           metadata          preprocessed_configs  status  tmp
backup  dictionaries_lib  format_schemas  metadata_dropped  shadow                store   user_files
root@node02:/var/lib/clickhouse# clickhouse-client list
Code: 552. DB::Exception: Unrecognized option 'list'
root@node02:/var/lib/clickhouse# clickhouse-backup list
2021/08/24 07:57:10 error InvalidParameter: 1 validation error(s) found.
- minimum field size of 1, ListObjectsV2Input.Bucket.

root@node02:/var/lib/clickhouse# clickhouse-backup tables
default.t_order_mt  713B  default  
root@node02:/var/lib/clickhouse# clickhouse-backup create
2021/08/24 07:57:27  info done                      backup=2021-08-24T07-57-27 operation=create table=default.t_order_mt
2021/08/24 07:57:27  info done                      backup=2021-08-24T07-57-27 operation=create
root@node02:/var/lib/clickhouse# ls
access  data              flags           metadata          preprocessed_configs  status  tmp
backup  dictionaries_lib  format_schemas  metadata_dropped  shadow                store   user_files
root@node02:/var/lib/clickhouse# cd shadow/
root@node02:/var/lib/clickhouse/shadow# ls
increment.txt
root@node02:/var/lib/clickhouse/shadow# cat increment.txt 
1
root@node02:/var/lib/clickhouse/shadow# cd ..
root@node02:/var/lib/clickhouse# ls
access  data              flags           metadata          preprocessed_configs  status  tmp
backup  dictionaries_lib  format_schemas  metadata_dropped  shadow                store   user_files
root@node02:/var/lib/clickhouse# cd backup/
root@node02:/var/lib/clickhouse/backup# ls
2021-08-24T07-57-27
root@node02:/var/lib/clickhouse/backup# cd 2021-08-24T07-57-27/
root@node02:/var/lib/clickhouse/backup/2021-08-24T07-57-27# ls
metadata  metadata.json  shadow
root@node02:/var/lib/clickhouse/backup/2021-08-24T07-57-27# cd ../../
root@node02:/var/lib/clickhouse# ls
access  data              flags           metadata          preprocessed_configs  status  tmp
backup  dictionaries_lib  format_schemas  metadata_dropped  shadow                store   user_files
root@node02:/var/lib/clickhouse# tree shadow
shadow
└── increment.txt

0 directories, 1 file
root@node02:/var/lib/clickhouse# tree backup
backup
└── 2021-08-24T07-57-27
    ├── metadata
    │   └── default
    │       └── t_order_mt.json
    ├── metadata.json
    └── shadow
        └── default
            └── t_order_mt
                └── default
                    ├── 20200601_1_1_2
                    │   ├── checksums.txt
                    │   ├── columns.txt
                    │   ├── count.txt
                    │   ├── data.bin
                    │   ├── data.mrk3
                    │   ├── default_compression_codec.txt
                    │   ├── minmax_create_time.idx
                    │   ├── partition.dat
                    │   └── primary.idx
                    └── 20200602_2_2_2
                        ├── checksums.txt
                        ├── columns.txt
                        ├── count.txt
                        ├── data.bin
                        ├── data.mrk3
                        ├── default_compression_codec.txt
                        ├── minmax_create_time.idx
                        ├── partition.dat
                        └── primary.idx

9 directories, 20 files
root@node02:/var/lib/clickhouse# 

```





### 5.2.4 从备份恢复数据

(1)模拟删除备份过的表

```shell
echo 'drop table t_order_rmt' | clickhouse-client
```

![image-20210824160524408](images/image-20210824160524408.png)

(2)从备份还原

```shell
root@node02:/var/lib/clickhouse# clickhouse-backup restore 2021-08-24T07-57-27 --table=default.t_order_mt
2021/08/24 08:15:56  info done                      backup=2021-08-24T07-57-27 operation=restore table=default.t_order_mt
2021/08/24 08:15:56  info done                      backup=2021-08-24T07-57-27 operation=restore
root@node02:/var/lib/clickhouse# 

	--schema 参数： 只还原表结构
	--data 参数：只还原数据
	--table 参数： 备份（或还原）特定表。也可以使用一个正则表达式，例如：针对特定的数据库：--table=db.name.*。
```

![image-20210824161845825](images/image-20210824161845825.png)



(3)模拟删除3个表中一个表

```sql
node02 :) show tables;

SHOW TABLES

Query id: bdb2f530-67eb-4707-b6e7-f940d3c2a178

┌─name───────┐
│ m_order_mm │
│ n_order_nn │
│ t_order_tt │
└────────────┘

3 rows in set. Elapsed: 0.006 sec. 

node02 :) drop table  n_order_nn;

DROP TABLE n_order_nn

Query id: cf37d536-6e26-4eae-ab6d-73a2df434ac2

Ok.

0 rows in set. Elapsed: 0.002 sec. 

node02 :) show tables;

SHOW TABLES

Query id: 8b7212f0-029d-42df-8d1e-6be66a929d64

┌─name───────┐
│ m_order_mm │
│ t_order_tt │
└────────────┘

2 rows in set. Elapsed: 0.005 sec. 

node02 :) 

-- 从备份中还原表 n_order_nn 
root@node02:/var/lib/clickhouse# clickhouse-backup restore 2021-08-24T08-37-35 --table=default.n_order_nn
root@node02:/var/lib/clickhouse# clickhouse-backup restore 2021-08-24T08-37-35 --table=default.n_order_nn
2021/08/24 08:47:03 error can't create table `default`.`n_order_nn`: code: 57, message: Directory for table data store/581/58163474-b4ac-4175-9816-3474b4acb175/ already exists after 1 times, please check your schema depencncies
root@node02:/var/lib/clickhouse# clickhouse-backup restore 2021-08-24T08-37-35 --table=n_order_nn
2021/08/24 08:47:50 error no have found schemas by n_order_nn in 2021-08-24T08-37-35

root@node02:/var/lib/clickhouse# clickhouse-backup restore 2021-08-24T08-37-35
2021/08/24 08:55:48  warn can't create table 'default.m_order_mm': code: 57, message: Table default.m_order_mm already exists., will try again
2021/08/24 08:55:48  warn can't create table 'default.t_order_tt': code: 57, message: Table default.t_order_tt already exists., will try again
2021/08/24 08:55:48 error can't create table `default`.`m_order_mm`: code: 57, message: Table default.m_order_mm already exists. after 3 times, please check your schema depencncies

	--schema 参数： 只还原表结构
	--data 参数：只还原数据
	--table 参数： 备份（或还原）特定表。也可以使用一个正则表达式，例如：针对特定的数据库：--table=db.name.*。
	
root@node02:/var/lib/clickhouse/store# ls
19c  2b8  332  4c9  581  59a  60f  62a  686  8ce  912  b85

root@node02:/var/lib/clickhouse/store# ls
19c  2b8  332  4c9  581  59a  60f  62a  686  8ce  912  b85
node02 :) select version();

SELECT version()

Query id: 474aae67-0907-4edf-8ba8-6ece36de79ba

┌─version()─┐
│ 21.8.4.51 │
└───────────┘

1 rows in set. Elapsed: 0.003 sec.
clickhouse-backup 1.0.0 17-06-2021 备份工具和ClickHouse的版本不兼容吗？

```



(4)模拟删除3个表中的两个表--报错

```shell
root@node02:/var/lib/clickhouse# clickhouse-backup restore 2021-08-24T08-37-35
2021/08/24 09:10:08  warn can't create table 'default.n_order_nn': code: 57, message: Directory for table data store/581/58163474-b4ac-4175-9816-3474b4acb175/ already exists, will try again
2021/08/24 09:10:08  warn can't create table 'default.t_order_tt': code: 57, message: Directory for table data store/62a/62a37f37-0c8b-497e-a2a3-7f370c8bd97e/ already exists, will try again
2021/08/24 09:10:08 error can't create table `default`.`n_order_nn`: code: 57, message: Directory for table data store/581/58163474-b4ac-4175-9816-3474b4acb175/ already exists after 3 times, please check your schema depencncies
```



(5)模拟删除3个表中的全部表--报错

```shell
root@node02:/var/lib/clickhouse# clickhouse-backup restore 2021-08-24T08-37-35
2021/08/24 09:10:08  warn can't create table 'default.n_order_nn': code: 57, message: Directory for table data store/581/58163474-b4ac-4175-9816-3474b4acb175/ already exists, will try again
2021/08/24 09:10:08  warn can't create table 'default.t_order_tt': code: 57, message: Directory for table data store/62a/62a37f37-0c8b-497e-a2a3-7f370c8bd97e/ already exists, will try again
2021/08/24 09:10:08 error can't create table `default`.`n_order_nn`: code: 57, message: Directory for table data store/581/58163474-b4ac-4175-9816-3474b4acb175/ already exists after 3 times, please check your schema depencncies

```



**原因是：删除数据和恢复数据时间间隔太近，以至于/var/lib/clickhouse/store/b85 、/var/lib/clickhouse/store/581、/var/lib/clickhosue/store/62a 目录下关于删除表的有关信息还在呢，所以报上面的错误表数据的目录已经存在，删除表后这个需要等大概15分钟后，等我们查看/var/lib/clickhouse/store/b85、/var/lib/clickhouse/store/581、/var/lib/clickhosue/store/62a 目录下是为空的时候，我们在进行恢复操作**

```shell
root@node02:/var/lib/clickhouse/store/b85# cd b85ddff6-18f2-4ae3-b85d-dff618f29ae3/
root@node02:/var/lib/clickhouse/store/b85/b85ddff6-18f2-4ae3-b85d-dff618f29ae3# ls
detached  format_version.txt
root@node02:/var/lib/clickhouse/store# ls
19c  2b8  332  4c9  581  59a  60f  62a  686  8ce  912  b85
root@node02:/var/lib/clickhouse/store# cd 62a/
root@node02:/var/lib/clickhouse/store/62a# ls
62a37f37-0c8b-497e-a2a3-7f370c8bd97e
root@node02:/var/lib/clickhouse/store/62a# 
root@node02:/var/lib/clickhouse/store/62a# 
root@node02:/var/lib/clickhouse/store/62a# 
root@node02:/var/lib/clickhouse/store/62a# cd 62a37f37-0c8b-497e-a2a3-7f370c8bd97e/
root@node02:/var/lib/clickhouse/store/62a/62a37f37-0c8b-497e-a2a3-7f370c8bd97e# ls
detached  format_version.txt

# 删除数据表后，大概15分钟后，我们查看
root@node02:/var/lib/clickhouse/store# ls
19c  2b8  332  4c9  581  59a  60f  62a  686  8ce  912  b85
root@node02:/var/lib/clickhouse/store# 
root@node02:/var/lib/clickhouse/store# 
root@node02:/var/lib/clickhouse/store# tree 581/
581/

0 directories, 0 files
root@node02:/var/lib/clickhouse/store# 
root@node02:/var/lib/clickhouse/store# 
root@node02:/var/lib/clickhouse/store# tree 62a
62a

0 directories, 0 files
root@node02:/var/lib/clickhouse/store# tree b85
b85

0 directories, 0 files
root@node02:/var/lib/clickhouse/store# 

# 开始恢复表数据
root@node02:/var/lib/clickhouse# clickhouse-backup restore 2021-08-24T08-37-35
2021/08/24 09:44:39  info done                      backup=2021-08-24T08-37-35 operation=restore table=default.m_order_mm
2021/08/24 09:44:39  info done                      backup=2021-08-24T08-37-35 operation=restore table=default.n_order_nn
2021/08/24 09:44:39  info done                      backup=2021-08-24T08-37-35 operation=restore table=default.t_order_tt
2021/08/24 09:44:39  info done                      backup=2021-08-24T08-37-35 operation=restore

# 查看表中数据
node02 :) show tables;

SHOW TABLES

Query id: 5b9c39b3-af2f-48f2-bf72-a2933694e918

Ok.

0 rows in set. Elapsed: 0.003 sec. 

node02 :) show tables;

SHOW TABLES

Query id: 0e3586d6-8782-41fb-9357-f41358dfe51a

┌─name───────┐
│ m_order_mm │
│ n_order_nn │
│ t_order_tt │
└────────────┘

3 rows in set. Elapsed: 0.004 sec. 

node02 :) 

```

查看删除的三个表全部恢复了

![image-20210824175125651](images/image-20210824175125651.png)

### 5.2.5 其他说明

（1）API文档：https://github.com/AlexAkulov/clickhouse-backup#api

（2）注意事项： 切勿更改文件夹 /var/lib/clickhouse/backup 的权限，可能会导致数据损坏。

（3）远程备份

- 较新版本采支持，需要设置 config 里的 s3 相关配置
- 上传到远程存储：sudo clickhouse-backup upload xxxx
- 从远程存储下载： sudo clickhouse-backup download xxxx
- 保存周期： 
  - backups_to_keep_local, 本地保存周期，单位天
  - backups_to_keep_remote, 远程存储保存周期，单位天
  - 0 均表示不删除



# 第6章 物化视图

ClickHouse 的物化视图是一种查询结果的持久化，它确实给我们带来了查询效率的提升。用户查起来跟表没有区别，它就是一张表，它也像是一张时刻在预计算的表，创建的过程它是用了一个特殊引擎，加上后来 as select，就是 create 一个 table as select 的写法。

“查询结果集”的范围很广泛，可以是基础表中部分数据的一份简单拷贝，也可以是多表join 之后产生的结果和其子集，或者原始数据的聚合指标等等。所以，物化视图不会随着基础表的变化而变化，所以它也称为快照（snapshot）。

## 6.1 概述

### 6.1.1 物化视图与普通视图的区别

普通视图不保存数据，保存的仅仅是查询语句，查询的时候还是从原表读取数据，可以将普通视图理解为是个子查询。物化视图则是把查询的结果根据相应的引擎存入到了磁盘或内存中，对数据重新进行了组织，你可以理解物化视图是完全的一张新表。



### 6.1.2 优缺点

优点：查询速度**快**，要是把物化视图这些规则全部写好，它比原数据查询快了很多，总的行数少了，因为都预算好了。

缺点：它的本质是一个流式数据的使用场景，是累加式的计数，所以要用历史数据做去重、去核这样的分析，在物化视图里面是不太好用的。在某些场景的使用也是有限的。而且如果一张表加了好多物化视图，在写这张表的时候，就会消耗很多机器的资源，比如数据带宽占满、存储一下子增加了很多。



### 6.1.3 基本语法

也是create语法，会创建一个隐藏的目标表来保存视图数据。也可以 TO 表名，保存到一张显式的表。没有加 TO 表名，表名默认就是 .inner.物化视图名

```sql
CREATE [MATERIALLZED] VIEW [IF NOT EXISTS] [db.]table_name [TO[db.]name] [ENGINE=engine] [POPULATE] AS SELECT ...
```

**(1)创建物化视图的限制**

1. 必须指定物化视图的 engine 用于数据存储
2. TO[db].[table]语法的时候，不得使用 POPULATE.
3. 查询语句(select)可以包含下面的句子：DISTINCT,GROUP BY,ORDER BY,LIMIT...
4. 物化视图的 alter 操作有些限制，操作起来不太方便。

对于一些确定的数据模型，可将统计指标通过物化视图的方式进行构建，这样可避免查询时重复计算的过程，物化视图会在有新数据插入时进行更新。



## 6.2 案例实操

### 6.2.1 准备测试用表和数据

**1) 建表**

```sql
# 建表语句
CREATE TABLE hits_test
(
    EventDate Date,
    CounterID UInt32,
    UserID UInt64,
    URL String,
    Income UInt8
)
ENGINE = MergeTree()
PARTITION BY toYYYYMM(EventDate)
ORDER BY (CounterID, EventDate, intHash32(UserID))
SAMPLE BY intHash32(UserID)
SETTINGS index_granularity = 8192;;
```

**2)导入一些数据**

```sql
INSERT INTO hits_test
    SELECT
        EventDate,
        CounterID,
        UserID,
        URL,
        Income
FROM hits_v1
limit 10000;
```



### 6.2.2 创建物化视图

```sql
# 建表语句
CREATE MATERIALIZED VIEW hits_mv
ENGINE=SummingMergeTree
PARTITION BY toYYYYMM(EventDate) ORDER BY (EventDate, intHash32(UserID))
AS SELECT
UserID,
EventDate,
count(URL) as ClickCount,
sum(Income) AS IncomeSum
FROM hits_test
WHERE EventDate >= '2014-03-20'
GROUP BY UserID, EventDate;;
```



### 6.2.3 导入增量数据

```sql
# 导入增量数据
INSERT INTO hits_test
SELECT
    EventDate,
    CounterID,
    UserID,
    URL,
    Income
FROM hits_v1
WHERE EventDate >= '2014-03-23'
limit 10;


# 查询物化视图
SELECT * FROM hits_mv;
zookeeper01 :) CREATE TABLE hits_test
:-] (
:-] EventDate Date,
:-]     CounterID UInt32,
:-]     UserID UInt64,
:-]     URL String,
:-]     Income UInt8
:-] )
:-] ENGINE = MergeTree()
:-] PARTITION BY toYYYYMM(EventDate)
:-] ORDER BY (CounterID, EventDate, intHash32(UserID))
:-] SAMPLE BY intHash32(UserID)
:-] SETTINGS index_granularity = 8192;;

CREATE TABLE hits_test
(
    `EventDate` Date,
    `CounterID` UInt32,
    `UserID` UInt64,
    `URL` String,
    `Income` UInt8
)
ENGINE = MergeTree
PARTITION BY toYYYYMM(EventDate)
ORDER BY (CounterID, EventDate, intHash32(UserID))
SAMPLE BY intHash32(UserID)
SETTINGS index_granularity = 8192

Query id: fd00123d-f598-441f-8b18-5be09ccafabb

Ok.

0 rows in set. Elapsed: 0.018 sec. 

zookeeper01 :) INSERT INTO hits_test
:-] SELECT
:-] EventDate,
:-] CounterID,
:-] UserID,
:-] URL,
:-] Income
:-] FROM hits_v1
:-] limit 10000;

INSERT INTO hits_test SELECT
    EventDate,
    CounterID,
    UserID,
    URL,
    Income
FROM hits_v1
LIMIT 10000

Query id: 10fec06c-b5bf-4ce1-a5c4-f25c7f2a2bf2

Ok.

0 rows in set. Elapsed: 0.093 sec. Processed 10.00 thousand rows, 1.06 MB (108.01 thousand rows/s., 11.46 MB/s.)

zookeeper01 :) CREATE MATERIALIZED VIEW hits_mv
:-] ENGINE=SummingMergeTree
:-] PARTITION BY toYYYYMM(EventDate) ORDER BY (EventDate, intHash32(UserID))
:-] AS SELECT
:-] UserID,
:-] EventDate,
:-] count(URL) as ClickCount,
:-] sum(Income) AS IncomeSum
:-] FROM hits_test
:-] WHERE EventDate >= '2014-03-20'
:-] GROUP BY UserID, EventDate;;

CREATE MATERIALIZED VIEW hits_mv
ENGINE = SummingMergeTree
PARTITION BY toYYYYMM(EventDate)
ORDER BY (EventDate, intHash32(UserID)) AS
SELECT
    UserID,
    EventDate,
    count(URL) AS ClickCount,
    sum(Income) AS IncomeSum
FROM hits_test
WHERE EventDate >= '2014-03-20'
GROUP BY
    UserID,
    EventDate

Query id: 390b0b44-ed49-44f8-a7fe-ee6ff187331e

Ok.

0 rows in set. Elapsed: 0.026 sec. 

zookeeper01 :) show tables;

SHOW TABLES

Query id: 4ba20110-533e-462e-a44a-a48624d7d7ea

┌─name───────────┐
│ .inner.hits_mv │
│ hits_mv        │
│ hits_test      │
│ hits_v1        │
│ hits_v2        │
│ test_a         │
│ view_test_a    │
│ visits_v1      │
│ visits_v2      │
└────────────────┘

9 rows in set. Elapsed: 0.005 sec. 

zookeeper01 :) select * from hits_mv;

SELECT *
FROM hits_mv

Query id: 3f79ed6a-3876-4ca9-9f41-da55753f1508

Ok.

0 rows in set. Elapsed: 0.003 sec. 

zookeeper01 :) INSERT INTO hits_test
:-] SELECT
:-] EventDate,
:-] CounterID,
:-] UserID,
:-] URL,
:-] Income
:-] FROM hits_v1
:-] WHERE EventDate >= '2014-03-23'
:-] limit 10;

INSERT INTO hits_test SELECT
    EventDate,
    CounterID,
    UserID,
    URL,
    Income
FROM hits_v1
WHERE EventDate >= '2014-03-23'
LIMIT 10

Query id: 59417dbb-a4e1-4018-a72a-6c52b9eae96f

Ok.

0 rows in set. Elapsed: 0.078 sec. Processed 16.38 thousand rows, 1.03 MB (209.26 thousand rows/s., 13.12 MB/s.)

zookeeper01 :) select * from hits_mv;

SELECT *
FROM hits_mv

Query id: 212a5b95-b4b8-4df8-ba52-55f641f6caad

┌──────────────UserID─┬──EventDate─┬─ClickCount─┬─IncomeSum─┐
│ 8585742290196126178 │ 2014-03-23 │          8 │        16 │
│ 1095363898647626948 │ 2014-03-23 │          2 │         0 │
└─────────────────────┴────────────┴────────────┴───────────┘

2 rows in set. Elapsed: 0.004 sec. 
```





### 6.2.4 导入历史数据

```sql
# 导入增量数据
INSERT INTO hits_mv
SELECT
    UserID,
    EventDate,
    count(URL) as ClickCount,
    sum(Income) AS IncomeSum
FROM hits_test
WHERE EventDate = '2014-03-20'
GROUP BY UserID,EventDate;;

# 查询物化视图
SELECT * FROM hits_mv;
```
