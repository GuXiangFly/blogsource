# 尚硅谷大数据技术StarRocks



# **第1章** **StarRocks****简介**

## **1.1** **StarRocks****介绍**

StarRocks是新一代极速全场景MPP数据库

StraRocks充分吸收关系型OLAP数据库和分布式存储系统在大数据时代的优秀研究成果，在业界实践的基础上，进一步改进优化、升级架构，并增添了众多全新功能，形成了全新的企业级产品。

StarRocks致力于构建极速统一分析体验，满足企业用户的多种数据分析场景，支持多种数据模型(明细模型、聚合模型、更新模型)，多种导入方式（批量和实时），可整合和接入多种现有系统(Spark、Flink、Hive、 ElasticSearch)。

StarRocks兼容MySQL协议，可使用MySQL客户端和常用BI工具对接StarRocks来进行数据分析。

StarRocks采用分布式架构，对数据表进行水平划分并以多副本存储。集群规模可以灵活伸缩，能够支持10PB级别的数据分析; 支持MPP框架，并行加速计算; 支持多副本，具有弹性容错能力。

StarRocks采用关系模型，使用严格的数据类型和列式存储引擎，通过编码和压缩技术，降低读写放大；使用向量化执行方式，充分挖掘多核CPU的并行计算能力，从而显著提升查询性能。

## **1.****2****StarRocks****适合什么场景**

 StarRocks可以满足企业级用户的多种分析需求，包括OLAP多维分析、定制报表、实时数据分析和Ad-hoc数据分析等。具体的业务场景包括：

（1）OLAP多维分析：用户行为分析、用户画像、财务报表、系统监控分析

（2）实时数据分析：电商数据分析、直播质量分析、物流运单分析、广告投放分析

（3）高并发查询：广告主表分析、Dashbroad多页面分析

（4）统一分析：通过使用一套系统解决上述场景，降低系统复杂度和多技术栈开发成本

## **1.****3****StarRocks****基本概念**

（1）FE：FrontEnd简称FE，是StarRocks的前端节点，负责管理元数据，管理客户端连接，进行查询规划，查询调度等工作。

（2）BE：BackEnd简称BE，是StarRocks的后端节点，负责数据存储，计算执行，以及compaction，副本管理等工作

（3） Broker：StarRocks中和外部HDFS/对象存储等外部数据对接的中转服务，辅助提供导入导出功能。

（4）StarRocksManager：StarRocks的管理工具，提供StarRocks集群管理、在线查询、故障查询、监控报警的可视化工具。

（5）Tablet：StarRocks中表的逻辑分片，也是StarRocks中副本管理的基本单位，每个表根据分区和分桶机制被划分成多个Tablet存储在不同BE节点上。

## **1.****4****StarRocks****系统架构**

### ![img](file:////private/var/folders/68/kg2tdk0x03xbzs4mk_l5g3dw0000ks/T/com.kingsoft.wpsoffice.mac/wps-didi/ksohtml/wpsaD7ldo.jpg)**组件介绍**

StarRocks集群由FE和BE构成, 可以使用MySQL客户端访问StarRocks集群。

#### ***\*FE\****

FE接收MySQL客户端的连接, 解析并执行SQL语句。

管理元数据, 执行SQL DDL命令, 用Catalog记录库, 表, 分区, tablet副本等信息。

FE高可用部署, 使用复制协议选主和主从同步元数据, 所有的元数据修改操作, 由FE leader节点完成, FE follower节点可执行读操作。 元数据的读写满足顺序一致性。  FE的节点数目采用2n+1, 可容忍n个节点故障。  当FE leader故障时, 从现有的follower节点重新选主, 完成故障切换。

FE的SQL layer对用户提交的SQL进行解析, 分析, 改写, 语义分析和关系代数优化, 生产逻辑执行计划。

FE的Planner负责把逻辑计划转化为可分布式执行的物理计划, 分发给一组BE。

FE监督BE, 管理BE的上下线, 根据BE的存活和健康状态, 维持tablet副本的数量。

FE协调数据导入, 保证数据导入的一致性。

#### ***\*BE\****

BE管理tablet副本, tablet是table经过分区分桶形成的子表, 采用列式存储。

BE受FE指导, 创建或删除子表。

BE接收FE分发的物理执行计划并指定BE coordinator节点, 在BE coordinator的调度下, 与其他BE worker共同协作完成执行。

BE读本地的列存储引擎获取数据,并通过索引和谓词下沉快速过滤数据。

BE后台执行compact任务, 减少查询时的读放大。

数据导入时, 由FE指定BE coordinator, 将数据以fanout的形式写入到tablet多副本所在的BE上。

 

# 第2章 **手动部署（需要JDK环境）**

（1）安装之前先使用命令检查CPU是否支持，有信息输出则支持，没信息输出则不支持建议更换机器

[root@hadoop103 software]# cat /proc/cpuinfo |grep avx2

（2）下载tar包,并重命名

[root@hadoop103 software]# wget https://www.starrocks.com/zh-CN/download/request-download/4

[root@hadoop103 software]# mv 4 StarRocks-1.19.1.tar.gz

（3）解压tar包

[root@hadoop103 software]# tar -zxvf StarRocks-1.19.1.tar.gz -C /opt/module/

（4）部署FE，修改配置文件，添加jvm参数，建议-Xmx参数设置到16G以上

[root@hadoop103 software]# cd /opt/module/StarRocks-1.19.1/fe/conf/

[root@hadoop103 conf]# vim fe.conf 

JAVA_OPTS = "-Xmx4096m -XX:+UseMembar -XX:SurvivorRatio=8 -XX:MaxTenuringThreshold=7 -XX:+PrintGCDateStamps -XX:+PrintGCDetails -XX:+UseConcMarkSweepGC -XX:+UseParNewGC -XX:+CMSClassUnloadingEnabled -XX:-CMSParallelRemarkEnabled -XX:CMSInitiatingOccupancyFraction=80 -XX:SoftRefLRUPolicyMSPerMB=0 -Xloggc:$STARROCKS_HOME/log/fe.gc.log"

 

（5）创建元数据目录

[root@hadoop103 conf]# cd ..

[root@hadoop103 fe]# mkdir -p meta

（6）分发给hadoop101,hadoop102

[root@hadoop103 module]# scp -r StarRocks-1.19.1/ hadoop101:/opt/module/

[root@hadoop103 module]# scp -r StarRocks-1.19.1/ hadoop102:/opt/module/

（7）启动hadoop101 FE节点

[root@hadoop101 fe]# bin/start_fe.sh --daemon

（8）启动mysql客户端，访问FE，查看FE状况

[root@hadoop101 fe]# mysql -h hadoop101 -uroot -P9030

mysql> SHOW PROC '/frontends'\G

![img](file:////private/var/folders/68/kg2tdk0x03xbzs4mk_l5g3dw0000ks/T/com.kingsoft.wpsoffice.mac/wps-didi/ksohtml/wpssTAg6X.jpg) 

（9）添加其他FE节点，角色也分为FOLLOWER,OBSERVER

mysql> ALTER SYSTEM ADD FOLLOWER "hadoop102:9010";

mysql> ALTER SYSTEM ADD OBSERVER "hadoop103:9010";

（10）启动hadoop102,hadoop103 FE节点，第一次启动需指定--helper参数，后续再启动无需指定此参数

[root@hadoop102 fe]# bin/start_fe.sh --helper hadoop101:9010 --daemon

[root@hadoop103 fe]# bin/start_fe.sh --helper hadoop101:9010 --daemon

（11）全部启动完毕后，再使用mysql客户端查看FE的状况,alive全显示true则无问题

mysql> SHOW PROC '/frontends'\G

![img](file:////private/var/folders/68/kg2tdk0x03xbzs4mk_l5g3dw0000ks/T/com.kingsoft.wpsoffice.mac/wps-didi/ksohtml/wpsPMZllg.jpg) 

![img](file:////private/var/folders/68/kg2tdk0x03xbzs4mk_l5g3dw0000ks/T/com.kingsoft.wpsoffice.mac/wps-didi/ksohtml/wps3mNkAv.jpg) 

![img](file:////private/var/folders/68/kg2tdk0x03xbzs4mk_l5g3dw0000ks/T/com.kingsoft.wpsoffice.mac/wps-didi/ksohtml/wpsSi9ppd.jpg) 

(12) 部署BE，用户可以使用命令直接将BE添加到集群中，一般至少布置3个BE，每个BE实例添加步骤相同

[root@hadoop101 module]# cd StarRocks-1.19.1/be/

[root@hadoop101 be]# mkdir -p storage

（13）使用mysql客户端添加hadoop101对应be节点

mysql> ALTER SYSTEM ADD BACKEND "hadoop101:9050";

（14）添加完毕后，启动hadoop101 BE节点

[root@hadoop101 be]# bin/start_be.sh --daemon 

（15）查看BE状况,也是同样alive为true是正常运行

mysql> SHOW PROC '/backends'\G

![img](file:////private/var/folders/68/kg2tdk0x03xbzs4mk_l5g3dw0000ks/T/com.kingsoft.wpsoffice.mac/wps-didi/ksohtml/wpsrwHhvu.jpg) 

（16）同样步骤在hadoop102,hadoop103部署BE，并添加节点

[root@hadoop102 module]# cd StarRocks-1.19.1/be/

[root@hadoop102 be]# mkdir -p storage

[root@hadoop103 module]# cd StarRocks-1.19.1/be/

[root@hadoop103 be]# mkdir -p storage

mysql> ALTER SYSTEM ADD BACKEND "hadoop102:9050";

mysql> ALTER SYSTEM ADD BACKEND "hadoop103:9050";

[root@hadoop102 be]# bin/start_be.sh --daemon 

[root@hadoop103 be]# bin/start_be.sh --daemon 

（17）部署Broker,此角色主要用于后续Broker load使用,启动安装目录的Broker服务

[root@hadoop101 StarRocks-1.19.1]# cd apache_hdfs_broker/

[root@hadoop101 apache_hdfs_broker]# bin/start_broker.sh --daemon

[root@hadoop102 StarRocks-1.19.1]# cd apache_hdfs_broker/

[root@hadoop102 apache_hdfs_broker]# bin/start_broker.sh --daemon

[root@hadoop103 StarRocks-1.19.1]# cd apache_hdfs_broker/

[root@hadoop103 apache_hdfs_broker]# bin/start_broker.sh --daemon

（18）使用mysql添加对应节点

mysql> ALTER SYSTEM ADD BROKER broker1 "hadoop101:8000";

mysql> ALTER SYSTEM ADD BROKER broker2 "hadoop102:8000";

mysql> ALTER SYSTEM ADD BROKER broker3 "hadoop103:8000";

（19）查看状态

mysql> SHOW PROC "/brokers"\G

![img](file:////private/var/folders/68/kg2tdk0x03xbzs4mk_l5g3dw0000ks/T/com.kingsoft.wpsoffice.mac/wps-didi/ksohtml/wps3A6Rin.jpg) 

# 第3章 **表设计**

## **3.1列式存储**

![img](file:////private/var/folders/68/kg2tdk0x03xbzs4mk_l5g3dw0000ks/T/com.kingsoft.wpsoffice.mac/wps-didi/ksohtml/wpscU9s9d.jpg) 

StarRocks的表和关系型数据相同, 由行和列构成. 每行数据对应用户一条记录, 每列数据有相同数据类型. 所有数据行的列数相同, 可以动态增删列.  StarRocks中, 一张表的列可以分为维度列(也成为key列)和指标列(value列), 维度列用于分组和排序, 指标列可通过聚合函数SUM, COUNT, MIN, MAX, REPLACE, HLL_UNION, BITMAP_UNION等累加起来. 因此, StarRocks的表也可以认为是多维的key到多维指标的映射.

在StarRocks中, 表中数据按列存储, 物理上, 一列数据会经过分块编码压缩等操作, 然后持久化于非易失设备, 但在逻辑上, 一列数据可以看成由相同类型的元素构成的数组.  一行数据的所有列在各自的列数组中保持对齐, 即拥有相同的数组下标, 该下标称之为序号或者行号. 该序号是隐式, 不需要存储的, 表中的所有行按照维度列, 做多重排序, 排序后的位置就是该行的行号.

查询时, 如果指定了维度列的等值条件或者范围条件, 并且这些条件中维度列可构成表维度列的前缀, 则可以利用数据的有序性, 使用range-scan快速锁定目标行. 例如: 对于表table1: (event_day, siteid, citycode, username)➜(pv); 当查询条件为event_day > 2020-09-18 and siteid = 2, 则可以使用范围查找; 如果指定条件为citycode = 4 and username in ["Andy", "Boby", "Christian", "StarRocks"], 则无法使用范围查找.

## **3.2稀疏索引**

 当进行范围查询时，StarRocks如何快速定位到起始目标行呢？答案是使用shortkey index. shortkey index为稀疏索引。

![img](file:////private/var/folders/68/kg2tdk0x03xbzs4mk_l5g3dw0000ks/T/com.kingsoft.wpsoffice.mac/wps-didi/ksohtml/wps9TecbT.jpg) 

表中组织由三个部分组成：

（1）shortkey index表:  表中数据每1024行, 构成一个逻辑block. 每个逻辑block在shortkey index表中存储一项索引, 内容为表的维度列的前缀, 并且不超过36字节.  shortkey index为稀疏索引, 用数据行的维度列的前缀查找索引表, 可以确定该行数据所在逻辑块的起始行号.

（2）Per-column data block: 表中每一列数据按64KB分块存储,  数据块作为一个单位单独编码压缩, 也作为IO单位, 整体写回设备或者读出.

（3）Per-column cardinal index:  表中的每列数据有各自的行号索引表,  列的数据块和行号索引项一一对应, 索引项由数据块的起始行号和数据块的位置和长度信息构成, 用数据行的行号查找行号索引表, 可以获取包含该行号的数据块所在位置, 读取目标数据块后, 可以进一步查找数据.

由此可见, 查找维度列的前缀的查找过程为:  先查找shortkey index, 获得逻辑块的起始行号, 查找维度列的行号索引, 获得目标列的数据块, 读取数据块, 然后解压解码, 从数据块中找到维度列前缀对应的数据项.

## **3.3加速数据处理**

（1）预先聚合:  StarRocks支持聚合模型, 维度列取值相同数据行可合并一行, 合并后数据行的维度列取值不变, 指标列的取值为这些数据行的聚合结果, 用户需要给指标列指定聚合函数.  通过预先聚合, 可以加速聚合操作.

（2）分区分桶:  事实上StarRocks的表被划分成tablet, 每个tablet多副本冗余存储在BE上, BE和tablet的数量可以根据计算资源和数据规模而弹性伸缩. 查询时, 多台BE可并行地查找tablet快速获取数据. 此外, tablet的副本可复制和迁移, 增强了数据的可靠性, 避免了数据倾斜. 总之, 分区分桶保证了数据访问的高效性和稳定性.

（3）RollUp表索引: shortkey index可加速数据查找, 然后shortkey index依赖维度列排列次序. 如果使用非前缀的维度列构造查找谓词, 则无法使用shortkey index. 用户可以为数据表创建若干RollUp表索引, RollUp表索引的数据组织和存储和数据表相同, 但RollUp表拥有自身的shortkey index. 用户创建RollUp表索引时, 可选择聚合的粒度, 列的数量, 维度列的次序; 使频繁使用的查询条件能够命中相应的RollUp表索引.

（4）列级别的索引技术:  Bloomfilter可快速判断数据块中不含所查找值, ZoneMap通过数据范围快速过滤待查找值, Bitmap索引可快速计算出枚举类型的列满足一定条件的行.

## **3.4数据模型**

目前StarRocks根据摄入数据和实际存储数据之间的映射关系，分为明细模型（Duplicate key）、聚合模型（Aggregate key）、更新模型（Unique key）和主键模型（Primary key）。

四中模型分别对应不同业务场景

### **3.4.1明细模型**

  StarRocks建表默认采用明细模型，排序列使用稀疏索引，可以快速过滤数据。明细模型用于保存所有历史数据，并且用户可以考虑将过滤条件中频繁使用的维度列作为排序键，比如用户经常需要查看某一时间，可以将事件时间和事件类型作为排序键

  使用：

（1）建表，在建表时指定模型和排序键

mysql> create database test;

mysql> use test;

CREATE TABLE IF NOT EXISTS detail (

  event_time DATETIME NOT NULL COMMENT "datetime of event",

  event_type INT NOT NULL COMMENT "type of event",

  user_id INT COMMENT "id of user",

  device_code INT COMMENT "device of ",

  channel INT COMMENT "")DUPLICATE KEY(event_time, event_type)DISTRIBUTED BY HASH(user_id) BUCKETS 8

（2）建完表后，插入测试数据

INSERT INTO detail VALUES('2021-11-18 12:00:00.00',1,1001,1,1);

INSERT INTO detail VALUES('2021-11-17 12:00:00.00',2,1001,1,1);

INSERT INTO detail VALUES('2021-11-16 12:00:00.00',3,1001,1,1);

INSERT INTO detail VALUES('2021-11-15 12:00:00.00',1,1001,1,1);

INSERT INTO detail VALUES('2021-11-14 12:00:00.00',2,1001,1,1);

（3）查询数据，5条明细数据都在。此种模型的表用来存储所有历史明细数据。

SELECT *FROM detail;

![img](http://guxiangflyimagebucket.oss-cn-beijing.aliyuncs.com/img/wpsYjFHfV.jpg) 

### **3.4.2聚合模型**

在数据分析中，很多场景需要基于明细数据进行统计和汇总，这个时候就可以使用聚合模型了。比如：统计app访问流量、用户访问时长、用户访问次数、展示总量、消费统计等等场景。

适合聚合模型来分析的业务场景有以下特点：

（1）业务方进行查询为汇总类查询，比如sum、count、max

（2）不需要查看原始明细数据

（3）老数据不会被频繁修改，只会追加和新增

  使用：

（1）建表，指定聚合模型

CREATE TABLE IF NOT EXISTS aggregate_tbl (

  site_id LARGEINT NOT NULL COMMENT "id of site",

  DATE DATE NOT NULL COMMENT "time of event",

  city_code VARCHAR(20) COMMENT "city_code of user",

  pv BIGINT SUM DEFAULT "0" COMMENT "total page views",

  mt BIGINT MAX

)

DISTRIBUTED BY HASH(site_id) BUCKETS 8;

（2）插入测试数据

```sql
INSERT INTO aggregate_tbl VALUES(1001,'2021-11-18 12:00:00.00',100,1,5);
INSERT INTO aggregate_tbl VALUES(1001,'2021-11-18 12:00:00.00',100,1,10);
INSERT INTO aggregate_tbl VALUES(1001,'2021-11-18 12:00:00.00',100,1,15);
INSERT INTO aggregate_tbl VALUES(1001,'2021-11-18 12:00:00.00',100,1,100);
INSERT INTO aggregate_tbl VALUES(1001,'2021-11-18 12:00:00.00',100,1,20);
INSERT INTO aggregate_tbl VALUES(1002,'2021-11-18 12:00:00.00',100,1,5);
INSERT INTO aggregate_tbl VALUES(1002,'2021-11-18 12:00:00.00',100,3,25);
INSERT INTO aggregate_tbl VALUES(1002,'2021-11-18 12:00:00.00',100,1,15);
```



（3）查询测试数据，可以看到pv是sum累计的值，mt是明细中最大的值。如果只需要查看聚合后的指标，那么使用此种模型将会大大减少存储的数据量。

mysql> select *from aggregate_tbl;

![img](file:////private/var/folders/68/kg2tdk0x03xbzs4mk_l5g3dw0000ks/T/com.kingsoft.wpsoffice.mac/wps-didi/ksohtml/wpsI2qchT.jpg) 

### **3.4.3更新模型**

有些分析场景之下，数据需要进行更新比如拉链表，StarRocks则采用更新模型来满足这种需求,比如电商场景中，订单的状态经常会发生变化，每天的订单更新量可突破上亿。这种业务场景下，如果只靠明细模型下通过delete+insert的方式，是无法满足频繁更新需求的，因此，用户需要使用更新模型来满足分析需求。但是如果用户需要更加实时/频繁的更新操作，建议使用主键模型。

使用更新模型的场景特点：

（1）已经写入的数据有大量的更新需求

（2）需要进行实时数据分析

 使用：

（1）建表，指定更新模型

```sql
CREATE TABLE IF NOT EXISTS update_detail (
  create_time DATE NOT NULL COMMENT "create time of an order",
  order_id BIGINT NOT NULL COMMENT "id of an order",
  order_state INT COMMENT "state of an order",
  total_price BIGINT COMMENT "price of an order"
)
UNIQUE KEY(create_time, order_id)
DISTRIBUTED BY HASH(order_id) BUCKETS 8
```



（2）插入测试数据，注意：现在是指定create_time和order_id为唯一键，那么相同日期相同订单的数据会进行覆盖操作

```sql
INSERT INTO update_detail VALUES('2011-11-18',1001,1,1000);
INSERT INTO update_detail VALUES('2011-11-18',1001,2,2000);
INSERT INTO update_detail VALUES('2011-11-17',1001,2,500);
INSERT INTO update_detail VALUES('2011-11-18',1002,3,3000);
INSERT INTO update_detail VALUES('2011-11-18',1002,4,4500);
```



（3）查询结果，可以看到如果日期和订单相同则会进行覆盖操作。

select *from update_detail;

![img](file:////private/var/folders/68/kg2tdk0x03xbzs4mk_l5g3dw0000ks/T/com.kingsoft.wpsoffice.mac/wps-didi/ksohtml/wpsHXsKku.jpg) 

 

 

 

### **3.4.4主键模型**

   相比较更新模型，主键模型可以更好地支持实时/频繁更新的功能。虽然更新模型也可以实现实时对数据的更新，但是更新模型采用Merge on Read读时合并策略会大大限制查询功能，在主键模型更好地解决了行级的更新操作。配合Flink-connector-starrocks可以完成Mysql CDC实时同步的方案。

需要注意的是：由于存储引擎会为主键建立索引，导入数据时会把索引加载到内存中，所以主键模型对内存的要求更高，所以不适合主键模型的场景还是比较多的。

目前比较适合使用主键模型的场景有这两种：

（1）数据冷热特征，比如最近几天的数据才需要修改，老的冷数据很少需要修改，比如订单数据，老的订单完成后就不在更新，并且分区是按天进行分区的，那么在导入数据时历史分区的数据的主键就不会被加载，也就不会占用内存了，内存中仅会加载近几天的索引。

（2）大宽表（数百列数千列），主键只占整个数据的很小一部分，内存开销比较低。比如用户状态/画像表，虽然列非常多，但总的用户数量不大（千万-亿级别），主键索引内存占用相对可控。

原理：由于更新模型采用Merge策略，使得谓词无法下推和索引无法使用，严重影响

查询性能。所以主键模型通过主键约束，保证同一个主键仅存一条数据的记录，这样就规避了Merge操作。

StarRocks收到对某记录的更新操作时，会通过主键索引找到该条数据的位置，并对其标记为删除，再插入一条数据，相当于把update改写为delete+insert

 

使用：

（1）建表，指定主键模型

```sql
CREATE TABLE users (
  user_id BIGINT NOT NULL,
  NAME STRING NOT NULL,
  email STRING NULL,
  address STRING NULL,
  age TINYINT NULL,
  sex TINYINT NULL
) PRIMARY KEY (user_id)
DISTRIBUTED BY HASH(user_id) BUCKETS 4
```



（2）插入测试数据，和更新模型类似，当user_id相同发送冲突时会进行覆盖

```sql
INSERT INTO users VALUES(1001,'张三','111@qq.com','AAA',17,'0');
INSERT INTO users VALUES(1001,'李四','222@qq.com','BBB',18,'1');
INSERT INTO users VALUES(1002,'aaa','222@qq.com','aaa',18,'0');
INSERT INTO users VALUES(1002,'bbb','222@qq.com','bbb',18,'1');
```



（3）查询数据

mysql> select *from users;

![img](file:////private/var/folders/68/kg2tdk0x03xbzs4mk_l5g3dw0000ks/T/com.kingsoft.wpsoffice.mac/wps-didi/ksohtml/wpsMBULnA.jpg) 

### **3.4.5排序键**

StarRocks中为加速查询，在内部组织并存储数据时，会把表中数据按照指定的列进行排序，这部分用于排序的列（可以是一个或多个列），可以称之为Sort Key。明细模型中Sort Key就是指定的用于排序的列（即 DUPLICATE KEY 指定的列），聚合模型中Sort Key列就是用于聚合的列（即 AGGREGATE KEY 指定的列），更新模型中Sort Key就是指定的满足唯一性约束的列（即 UNIQUE KEY 指定的列）。下图中的建表语句中Sort Key都为 (site_id、city_code)。

CREATE TABLE site_access_duplicate(

site_id INT DEFAULT '10',

city_code SMALLINT,

user_name VARCHAR(32) DEFAULT '',

pv BIGINT DEFAULT '0')

DUPLICATE KEY(site_id, city_code)

DISTRIBUTED BY HASH(site_id) BUCKETS 10;

 

CREATE TABLE site_access_aggregate(

site_id INT DEFAULT '10',

city_code SMALLINT,

pv BIGINT SUM DEFAULT '0')

AGGREGATE KEY(site_id, city_code)

DISTRIBUTED BY HASH(site_id) BUCKETS 10;

 

CREATE TABLE site_access_unique(

site_id INT DEFAULT '10',

city_code SMALLINT,

user_name VARCHAR(32) DEFAULT '',

pv BIGINT DEFAULT '0')

UNIQUE KEY(site_id, city_code)

DISTRIBUTED BY HASH(site_id) BUCKETS 10;

三种表对应的sort key都为site_id,city_code。创建排序列需要注意以下两点：

（1）排序列的定义必须出现在建表语句中其他列的定义之前。以图5.1中的建表语句为例，三个表的排序列可以是site_id、city_code，或者site_id、city_code、user_name，但不能是city_code、user_name，或者site_id、city_code、pv。

（2）排序列的顺序是由create table语句中的列顺序决定的。DUPLICATE/UNIQUE/AGGREGATE KEY中顺序需要和create table语句保持一致。以site_access_duplicate表为例，也就是说下面的建表语句会报错。

-- 错误的建表语句

CREATE TABLE site_access_duplicate(

site_id INT DEFAULT '10',

city_code SMALLINT,

user_name VARCHAR(32) DEFAULT '',

pv BIGINT DEFAULT '0')

DUPLICATE KEY(city_code, site_id)

DISTRIBUTED BY HASH(site_id) BUCKETS 10;

 

 

-- 正确的建表语句

```sql
CREATE TABLE site_access_duplicate(
  site_id INT DEFAULT '10',
  city_code SMALLINT,
  user_name VARCHAR(32) DEFAULT '',
pv BIGINT DEFAULT '0')
DUPLICATE KEY(site_id, city_code)
DISTRIBUTED BY HASH(site_id) BUCKETS 10;
```



 使用时注意事项：

（1）用户查询时如果条件包含上述两列，则可以大幅地降低扫描数据行，如：
```sql
select sum(pv) from site_access_duplicate where site_id = 123 and city_code = 2;
```



（2）如果查询只包含site_id一列，也能定位到只包含site_id的数据行，如：
```sql
select sum(pv) from site_access_duplicate where site_id = 123;
```



（3）如果查询只包含city_code一列，那么需要扫描所有的数据行，排序的效果相当于大打折扣，如：
```sql
select sum(pv) from site_access_duplicate where city_code = 2; //使用时和mysql索引规则一样，缺少最佳左前缀原则，索引会失效
```



使用排序键本质就是在进行二分查找，所以排序列指定的越多，那么消耗的内存也会越大，StarRocks为了避免这种情况发生也对排序键做了限制：

shortkey 的列只能是排序键的前缀;

shortkey 列数不超过3;

字节数不超过36字节;

不包含FLOAT/DOUBLE类型的列;

VARCHAR类型列只能出现一次, 并且是末尾位置;

当shortkey index的末尾列为CHAR或者VARCHAR类型时, shortkey的长度会超过36字节;

当用户在建表语句中指定PROPERTIES {short_key = "integer"}时, 可突破上述限制;

### **3.4.6物化视图**

   Materialized Views 表：简称 MVs，物化视图

   使用场景：

在实际的业务场景中，通常存在两种场景并存的分析需求：对固定维度的聚合分析 和 对原始明细数据任意维度的分析。

例如，在销售场景中，每条订单数据包含这几个维度信息（item_id, sold_time, customer_id, price）。在这种场景下，有两种分析需求并存：

\1. 业务方需要获取某个商品在某天的销售额是多少，那么仅需要在维度（item_id, sold_time）维度上对 price 进行聚合即可。

\2. 分析某个人在某天对某个商品的购买明细数据。

在现有的 StarRocks 数据模型中，如果仅建立一个聚合模型的表，比如（item_id, sold_time, customer_id, sum(price)）。由于聚合损失了数据的部分信息，无法满足用户对明细数据的分析需求。如果仅建立一个 Duplicate 模型，虽可以满足任意维度的分析需求，但由于不支持 Rollup，分析性能不佳，无法快速完成分析。如果同时建立一个聚合模型和一个 Duplicate 模型，虽可以满足性能和任意维度分析，但两表之间本身无关联，需要业务方自行选择分析表。不灵活也不易用。

   如何使用：

使用聚合函数（如sum和count）的查询，在已经包含聚合数据的表中可以更高效地执行。这种改进的效率对于查询大量数据尤其适用。表中的数据被物化在存储节点中，并且在增量更新中能和 Base 表保持一致。用户创建 MVs 表后，查询优化器支持选择一个最高效的 MVs 映射，并直接对 MVs 表进行查询而不是 Base 表。由于 MVs 表数据通常比 Base 表数据小很多，因此命中 MVs 表的查询速度会快很多。

（1）基于文档上述明细模型表，创建测试物化视图

CREATE MATERIALIZED VIEW test_detail_view

AS SELECT user_id,MAX(event_type),COUNT(device_code),SUM(channel) FROM detail GROUP BY user_id;

（2）创建完视图后，用户并不感知创建成功，可以通过explain来分析是否命中视图。可以看到上面物化视图对event_type字段使用max函数，那么rollup命中的数据源为创建的物化视图。

mysql> explain select max(event_type) from detail;

![img](file:////private/var/folders/68/kg2tdk0x03xbzs4mk_l5g3dw0000ks/T/com.kingsoft.wpsoffice.mac/wps-didi/ksohtml/wpsNq3otx.jpg) 

（3）那么如果使用对event_type字段使用count函数，又可以看到rollup命中的是detail表。explain select count(event_type) from detail;

![img](file:////private/var/folders/68/kg2tdk0x03xbzs4mk_l5g3dw0000ks/T/com.kingsoft.wpsoffice.mac/wps-didi/ksohtml/wpseWD436.jpg) 

（4）那么建立物化视图，就可以帮助用户对于不同场景都起到加速查询的作用。目前物化视图支持的函数如下有：count、max、min、sum、percentile_approx、hill_union、bitmap_union

### **3.4.7Bitmap索引**

  StarRocks支持基于BitMap索引，对于Filter的查询有明显的加速效果。

***\*原理：\****

Bitmap是元素为bit的， 取值为0、1两种情形的, 可对某一位bit进行置位(set)和清零(clear)操作的数组。Bitmap的使用场景有：

用一个long型表示32位学生的性别，0表示女生，1表示男生。

用Bitmap表示一组数据中是否存在null值，0表示元素不为null，1表示为null。

一组数据的取值为(Q1, Q2, Q3, Q4)，表示季度，用Bitmap表示这组数据中取值为Q4的元素，1表示取值为Q4的元素, 0表示其他取值的元素。

 

***\*什么是Bitmap索引：\****

![img](file:////private/var/folders/68/kg2tdk0x03xbzs4mk_l5g3dw0000ks/T/com.kingsoft.wpsoffice.mac/wps-didi/ksohtml/wpsilHA8m.jpg) 

Bitmap只能表示取值为两种情形的列数组, 当列的取值为多种取值情形枚举类型时, 例如季度(Q1, Q2, Q3, Q4),  系统平台(Linux, Windows, FreeBSD, MacOS), 则无法用一个Bitmap编码; 此时可以为每个取值各自建立一个Bitmap的来表示这组数据; 同时为实际枚举取值建立词典.

如上图所示，Platform列有4行数据，可能的取值有Android、Ios。StarRocks中会首先针对Platform列构建一个字典，将Android和Ios映射为int，然后就可以对Android和Ios分别构建Bitmap。具体来说，我们分别将Android、Ios 编码为0和1，因为Android出现在第1，2，3行，所以Bitmap是0111，因为Ios出现在第4行，所以Bitmap是1000。

假如有一个针对包含该Platform列的表的SQL查询，select xxx from table where Platform = iOS，StarRocks会首先查找字典，找出iOS对于的编码值是1，然后再去查找 Bitmap Index，知道1对应的Bitmap是1000，我们就知道只有第4行数据符合查询条件，StarRocks就会只读取第4行数据，不会读取所有数据。

 

***\*适用场景：\****

 使用Bitmap可以大大减少判断过滤时间，提高查询效率

（1）当需要对表数据进行非前置列（排序键）进行过滤时，可以创建bitmap索引加速效率。

（2）对表数据进行多列过滤，也可以考虑对多列分别创建bitmap索引加速效率

 

***\*使用：\****

（1） 创建测试表

CREATE TABLE IF NOT EXISTS user_dup (

  user_id INT,

  sex INT ,

  age INT 

  )DUPLICATE KEY(user_id)DISTRIBUTED BY HASH(user_id) BUCKETS 8

（2） 插入测试数据

```sql
  INSERT INTO user_dup VALUES(1001,0,18);
  INSERT INTO user_dup VALUES(1002,1,18);
  INSERT INTO user_dup VALUES(1003,0,18);
  INSERT INTO user_dup VALUES(1004,1,18);
  INSERT INTO user_dup VALUES(1005,0,18);
  INSERT INTO user_dup VALUES(1006,1,18);
  INSERT INTO user_dup VALUES(1007,0,18);
  INSERT INTO user_dup VALUES(1008,1,18);
```



（3） 创建位图索引

  CREATE INDEX user_sex_index ON user_dup(sex) USING bitmap;

（4） 创建完后查看表中索引

SHOW INDEX FROM user_dup;

![img](file:////private/var/folders/68/kg2tdk0x03xbzs4mk_l5g3dw0000ks/T/com.kingsoft.wpsoffice.mac/wps-didi/ksohtml/wpsZFugSi.jpg) 

 

***\*注意事项：\****

（1）对于明细模型，所有列都可以建Bitmap 索引；对于聚合模型，只有Key列可以建Bitmap 索引。

（2）Bitmap索引, 应该在取值为枚举型, 取值大量重复, 较低基数, 并且用作等值条件查询或者可转化为等值条件查询的列上创建.

（3）不支持对Float、Double、Decimal 类型的列建Bitmap 索引。

（4）如果要查看某个查询是否命中了Bitmap索引，可以通过查询的[Profile](#profile分析)信息查看。

 

### **3.4.8****Bloom** **F****ilter 索引**

***\*什么是Bloom Filter:\****

Bloom Filter（布隆过滤器）是用于判断某个元素是否在一个集合中的数据结构，优点是空间效率和时间效率都比较高，缺点是有一定的误判率。

![img](file:////private/var/folders/68/kg2tdk0x03xbzs4mk_l5g3dw0000ks/T/com.kingsoft.wpsoffice.mac/wps-didi/ksohtml/wpsoMvQTy.jpg) 

布隆过滤器是由一个Bit数组和n个哈希函数构成。Bit数组初始全部为0，当插入一个元素时，n个Hash函数对元素进行计算, 得到n个slot，然后将Bit数组中n个slot的Bit置1。

当我们要判断一个元素是否在集合中时，还是通过相同的n个Hash函数计算Hash值，如果所有Hash值在布隆过滤器里对应的Bit不全为1，则该元素不存在。当对应Bit全1时, 则元素的存在与否, 无法确定.  这是因为布隆过滤器的位数有限,  由该元素计算出的slot, 恰好全部和其他元素的slot冲突.  所以全1情形, 需要回源查找才能判断元素的存在性。

***\*什么是Bloom Filter 索引:\****

StarRocks的建表时, 可通过PROPERTIES{"bloom_filter_columns"="c1,c2,c3"}指定需要建BloomFilter索引的列，查询时, BloomFilter可快速判断某个列中是否存在某个值。如果Bloom Filter判定该列中不存在指定的值，就不需要读取数据文件；如果是全1情形，此时需要读取数据块确认目标值是否存在。另外，Bloom Filter索引无法确定具体是哪一行数据具有该指定的值。

***\*使用：\****

（1）建表时指定需要加Bloom Filter索引的列，创建一张测试表

CREATE TABLE test_bf(

id INT,

event_type INT,

email INT,

sex INT,

age INT

)DUPLICATE KEY(id) DISTRIBUTED BY HASH(id) BUCKETS 8

PROPERTIES("bloom_filter_columns"="event_type,sex");

（2）查看Bloom Filter索引。使用show index查看不到Bloom Filter索引，得用show create table 命令

SHOW CREATE TABLE test_bf

![img](file:////private/var/folders/68/kg2tdk0x03xbzs4mk_l5g3dw0000ks/T/com.kingsoft.wpsoffice.mac/wps-didi/ksohtml/wpsIjShKH.jpg) 

（3）删除索引

alter table test_bf set("bloom_filter_columns"="");

 

***\*注意事项：\****

（1）不支持对Tinyint、Float、Double 类型的列建Bloom Filter索引。

（2）Bloom Filter索引只对in和=过滤查询有加速效果。

（3）如果要查看某个查询是否命中了Bloom Filter索引，可以通过查询的Profile信息查看（TODO：加上查看Profile的链接）。

 

 

# 第4章 **数据导入与查询**

## **4.1Stream Load**

StarRocks支持从本地直接导入数据，支持CSV格式。数据量在10G以下，可以使用Stream Load导入，这种导入方式是通过用户发送HTTP请求将本地文件或数据流导入到StarRocks中。Stream Load同步执行导入并返回结果。用户可以直接通过返回结果判断是否导入成功。

基本原理：Steam Load中，用户通过HTTP协议提交导入命令，提交到FE节点，FE节点则会通过HTTP 重定向指令请求转发给某一个BE节点，用户也可以直接提交导入命令指定BE节点。

![img](file:////private/var/folders/68/kg2tdk0x03xbzs4mk_l5g3dw0000ks/T/com.kingsoft.wpsoffice.mac/wps-didi/ksohtml/wpso290oc.jpg) 

***\*使用：\****

（1）以user表为例，创建对应的CSV文件

[root@hadoop101 ~]# vim test.csv

1001,'test1',123456@.qqcom,'测试地址1',18,1

1002,'test2',123456@.qqcom,'测试地址2',18,1

1003,'test3',123456@.qqcom,'测试地址3',20,0

1004,'test4',123456@.qqcom,'测试地址4',21,1

1005,'test5',123456@.qqcom,'测试地址5',23,0

1006,'test6',123456@.qqcom,'测试地址6',22,1

1007,'test7',123456@.qqcom,'测试地址7',18,0

1008,'test8',123456@.qqcom,'测试地址8',25,1

1009,'test9',123456@.qqcom,'测试地址9',19,0

1010,'test10',123456@.qqcom,'测试地址10',10,1

1011,'test11',123456@.qqcom,'测试地址11',18,1

（2）根据官网语法将CSV数据导入对应user表中，官网语法：curl --location-trusted -u user:passwd [-H ""...] -T data.file -XPUT  http://fe_host:http_port/api/{db}/{table}/_stream_load

注意：命令-H 为头部信息 column_separator为测试文件中字段间隔符，虽然官网写着支持csv但默认是\t，默认支持tsv所以这把这个参数改成逗号

[root@hadoop101 ~]# curl --location-trusted -u root -T test.csv -H "column_separator:," http://hadoop101:8030/api/test/users/_stream_load

（3）因为Stream load是同步导入，所以可以立马看到是否导入成功

![img](file:////private/var/folders/68/kg2tdk0x03xbzs4mk_l5g3dw0000ks/T/com.kingsoft.wpsoffice.mac/wps-didi/ksohtml/wpstnidg2.jpg) 

（4）导入成功后，查看对应的users表

mysql> select *from users;

![img](file:////private/var/folders/68/kg2tdk0x03xbzs4mk_l5g3dw0000ks/T/com.kingsoft.wpsoffice.mac/wps-didi/ksohtml/wpsaSzQyj.jpg) 

## **4.2Broker Load**

  StarRocks支持从Apache HDFS、Amazon S3等外部存储系导入数据，支持CSV、ORCFile、Parquet等文件格式。数据量在几十GB到上百GB 级别。

在Broker Load模式下，通过部署的Broker程序，StarRocks可读取对应数据源（如HDFS, S3）上的数据，利用自身的计算资源对数据进行预处理和导入。这是一种异步的导入方式，用户需要通过MySQL协议创建导入，并通过查看导入命令检查导入结果。

***\*基本原理：\****

![img](file:////private/var/folders/68/kg2tdk0x03xbzs4mk_l5g3dw0000ks/T/com.kingsoft.wpsoffice.mac/wps-didi/ksohtml/wpsG7l7hn.jpg) 

***\*使用：\****

（1）先保证启动broker进程

[root@hadoop101 ~]# /opt/module/StarRocks-1.19.1/apache_hdfs_broker/bin/start_broker.sh --daemon

[root@hadoop102 ~]# /opt/module/StarRocks-1.19.1/apache_hdfs_broker/bin/start_broker.sh --daemon 

[root@hadoop103 ~]# /opt/module/StarRocks-1.19.1/apache_hdfs_broker/bin/start_broker.sh --daemon

（2）这里演示Apache HDFS导入StarRocks,将Hadoop集群的hdfs-site.xml文件复制到对应broker conf 目录下

[root@hadoop101 ~]# cp /opt/module/hadoop-3.1.3/etc/hadoop/hdfs-site.xml /opt/module/StarRocks-1.19.1/apache_hdfs_broker/conf/

[root@hadoop102 ~]# cp /opt/module/hadoop-3.1.3/etc/hadoop/hdfs-site.xml /opt/module/StarRocks-1.19.1/apache_hdfs_broker/conf/

[root@hadoop103 ~]# cp /opt/module/hadoop-3.1.3/etc/hadoop/hdfs-site.xml /opt/module/StarRocks-1.19.1/apache_hdfs_broker/conf/

（3）Broker Load任务语法如下图：

![img](file:////private/var/folders/68/kg2tdk0x03xbzs4mk_l5g3dw0000ks/T/com.kingsoft.wpsoffice.mac/wps-didi/ksohtml/wpsNdiLkc.jpg) 

（4）启动hadoop集群，进入到hive中创建一张测试表,采用parquet列式存储，snappy压缩

create external table test_member(

  uid int,

  ad_id int,

  birthday string,

  email string,

  fullname string) 

partitioned by(

  dt string,

  dn string)  

  ROW FORMAT DELIMITED

STORED AS PARQUET TBLPROPERTIES('parquet.compression'='SNAPPY');

（5）插入几条测试数据

insert into test_member values(1001,1,'1990-01-01','111@qq.com','test1','2021-11-20','A'),

(1002,2,'1990-01-01','111@qq.com','test1','2021-11-20','A'),

(1003,3,'1990-01-01','111@qq.com','test1','2021-11-20','A'),

(1004,4,'1990-01-01','111@qq.com','test1','2021-11-20','A'),

(1005,5,'1990-01-01','111@qq.com','test1','2021-11-20','A');

（6）创建对应StartRocks表

CREATE TABLE test_bl( uid INT, ad_id INT, birthday varchar(20), email varchar(20), fullname varchar(20), dt varchar(20), dn varchar(20) )DUPLICATE KEY(uid) DISTRIBUTED BY HASH(uid) BUCKETS 8;

（7）据官方语法创建Broker Load将数据导入到StartRocks

LOAD LABEL test.label1

(

  DATA INFILE("hdfs://mycluster/user/hive/warehouse/test_member/dt=2021-11-20/dn=A/*")

  INTO TABLE test_bl

  FORMAT AS "parquet"

  (uid,ad_id,birthday,email,fullname)

  SET

  (

​    uid=uid,

​    ad_id=ad_id,

​    birthday=birthday,

​    email=email,

​    fullname=fullname,

​    dt='2021-11-20',

​    dn='A'

  )

)

WITH BROKER "broker1"

(

 "dfs.nameservices"="mycluster",

 "dfs.ha.namenodes.mycluster"="nn1,nn2,nn3",

 "dfs.namenode.rpc-address.mycluster.nn1"= "hadoop101:8020",

 "dfs.namenode.rpc-address.mycluster.nn2"= "hadoop102:8020",

 "dfs.namenode.rpc-address.mycluster.nn3"="hadoop103:8020",

 "dfs.client.failover.proxy.provider.mycluster"="org.apache.hadoop.hdfs.server.namenode.ha.ConfiguredFailoverProxyProvider"      

)

PROPERTIES

(

  "timeout" = "3600"

);

（8）查看load计划，

show load where label='label1';

![img](file:////private/var/folders/68/kg2tdk0x03xbzs4mk_l5g3dw0000ks/T/com.kingsoft.wpsoffice.mac/wps-didi/ksohtml/wpsLH2G40.jpg) 

（9）查看StarRock表数据

select *from test_bl;

![img](file:////private/var/folders/68/kg2tdk0x03xbzs4mk_l5g3dw0000ks/T/com.kingsoft.wpsoffice.mac/wps-didi/ksohtml/wpsWjDytD.jpg) 

## **4.3Rountine Load**

   Routine Load 是一种例行导入方式，StarRocks通过这种方式支持从Kafka持续不断的导入数据，并且支持通过SQL控制导入任务的暂停、重启、停止。本节主要介绍该功能的基本原理和使用方式。

  

   ***\*基本原理：\****

![img](file:////private/var/folders/68/kg2tdk0x03xbzs4mk_l5g3dw0000ks/T/com.kingsoft.wpsoffice.mac/wps-didi/ksohtml/wpsPAoWBj.jpg) 

（1）用户通过支持MySQL协议的客户端向 FE 提交一个Kafka导入任务。

（2）FE将一个导入任务拆分成若干个Task，每个Task负责导入指定的一部分数据。

（3）每个Task被分配到指定的 BE 上执行。在 BE 上，一个 Task 被视为一个普通的导入任务， 通过 Stream Load 的导入机制进行导入。

（4）BE导入完成后，向 FE 汇报。

（5）FE 根据汇报结果，继续生成后续新的 Task，或者对失败的 Task 进行重试。

（6）FE 会不断的产生新的 Task，来完成数据不间断的导入。

 

 ***\*环境要求：\****

（1）支持访问无认证或使用 SSL 方式认证的 Kafka 集群。

（2）支持的消息格式为 CSV 文本格式，每一个 message 为一行，且行尾不包含换行符。

（3）仅支持 Kafka 0.10.0.0(含) 以上版本。

 

 ***\*使用：\****

（1）语法如下图

![img](file:////private/var/folders/68/kg2tdk0x03xbzs4mk_l5g3dw0000ks/T/com.kingsoft.wpsoffice.mac/wps-didi/ksohtml/wpsoO5kaE.jpg) 

（2）启动kafka集群，创建一个测试用的topic，编写代码往测试topic发送测试数据

package com.atguigu.starrocks.test;

import org.apache.kafka.clients.producer.KafkaProducer;
import org.apache.kafka.clients.producer.ProducerRecord;

import java.util.Properties;

public class TestKafkaProducer {
  public static void main(String[] args) {
    Properties props = new Properties();
    props.put("bootstrap.servers", "hadoop101:9092,hadoop102:9092,hadoop103:9092");
    props.put("acks", "-1");
    props.put("batch.size", "1048576");
    props.put("linger.ms", "5");
    props.put("compression.type", "snappy");
    props.put("buffer.memory", "33554432");
    props.put("key.serializer",
        "org.apache.kafka.common.serialization.StringSerializer");
    props.put("value.serializer",
        "org.apache.kafka.common.serialization.StringSerializer");
    KafkaProducer<String, String> producer = new KafkaProducer<String, String>(props);
    for (int i = 0; i < 10000; i++) {
      producer.send(new ProducerRecord<String, String>("test", "kafaktest-" + i + ",1,2000-01-01,222@qq.com,test2,2021-11-20,A"));
    }
    producer.flush();
    producer.close();
  }
}

（3）创建load将kafka中的数据导入到test_bl中;

CREATE ROUTINE LOAD  rl_test on test_bl

COLUMNS TERMINATED BY ","

PROPERTIES

(

  "desired_concurrent_number"="3",

  "max_error_number"="1000"

)

FROM KAFKA

(

  "kafka_broker_list"= "hadoop101:9092,hadoop102:9092,hadoop103:9092",

"kafka_topic" = "test",

"property.group.id" = "start-rocks-test",

"property.kafka_default_offsets" = "OFFSET_BEGINNING"

);

 

（4）查看load任务，可以看到接收到了数据，并且任务一直是running正在运行状态

SHOW ROUTINE LOAD\G;

![img](file:////private/var/folders/68/kg2tdk0x03xbzs4mk_l5g3dw0000ks/T/com.kingsoft.wpsoffice.mac/wps-didi/ksohtml/wpsLIegvh.jpg) 

（5）查看test_bl表数据,已有数据，由于uid是int类型和kafka数据类型不匹配所以为null

mysql> select *from test_bl limit 100;

![img](file:////private/var/folders/68/kg2tdk0x03xbzs4mk_l5g3dw0000ks/T/com.kingsoft.wpsoffice.mac/wps-didi/ksohtml/wpsZ22HEe.jpg) 

（6）因为load是常驻的，所以可以再往kafka里继续发送测试数据，测试数据是否会实时同步到StartRocks中

package com.atguigu.starrocks.test;

import org.apache.kafka.clients.producer.KafkaProducer;
import org.apache.kafka.clients.producer.ProducerRecord;

import java.util.Properties;

public class TestKafkaProducer {
  public static void main(String[] args) {
    Properties props = new Properties();
    props.put("bootstrap.servers", "hadoop101:9092,hadoop102:9092,hadoop103:9092");
    props.put("acks", "-1");
    props.put("batch.size", "1048576");
    props.put("linger.ms", "5");
    props.put("compression.type", "snappy");
    props.put("buffer.memory", "33554432");
    props.put("key.serializer",
        "org.apache.kafka.common.serialization.StringSerializer");
    props.put("value.serializer",
        "org.apache.kafka.common.serialization.StringSerializer");
    KafkaProducer<String, String> producer = new KafkaProducer<String, String>(props);
    for (int i = 10000; i < 20000; i++) {
      producer.send(new ProducerRecord<String, String>("test",  i + ",1,2000-01-01,222@qq.com,test2,2021-11-20,A"));
    }
    producer.flush();
    producer.close();
  }
}

（7）发送完毕后，查询test_bl uid大于10000的数据,可以看到数据实时同步到StarRocks中

select *from test_bl where uid>10000 limit 100;

![img](file:////private/var/folders/68/kg2tdk0x03xbzs4mk_l5g3dw0000ks/T/com.kingsoft.wpsoffice.mac/wps-didi/ksohtml/wps5AyYSH.jpg) 

 

## **4.4Insert into导入**

Insert Into 语句的使用方式和 MySQL 等数据库中 Insert Into 语句的使用方式类似。 但在 StarRocks 中，所有的数据写入都是 一个独立的导入作业 。

语法：

INSERT INTO table_name[ PARTITION (p1, ...) ][ WITH LABEL label][ (column [, ...]) ][ [ hint [, ...] ] ]

{ VALUES ( { expression | DEFAULT } [, ...] ) [, ...] | query }

## **4.5Flink Connector**

flink的用户想要将数据sink到StarRocks当中，但是flink官方只提供了flink-connector-jdbc, 不足以满足导入性能要求，为此StarRocks新增了一个flink-connector-starrocks，内部实现是通过缓存并批量由stream load导入。

 

***\*使用：\****

（1）创建maven工程，导入flink所需依赖

<properties>     <flink.version>1.13.0</flink.version>     <scala.version>2.12.10</scala.version>     <scala.binary.version>2.12</scala.binary.version>     <log4j.version>1.2.17</log4j.version>     <slf4j.version>1.7.22</slf4j.version>     <iceberg.version>0.11.1</iceberg.version> </properties>   <dependencies>     <dependency>         <groupId>org.apache.flink</groupId>         <artifactId>flink-java</artifactId>         <version>${flink.version}</version>         <exclusions>             <exclusion>                 <groupId>log4j</groupId>                 <artifactId>*</artifactId>             </exclusion>             <exclusion>                 <groupId>org.slf4j</groupId>                 <artifactId>slf4j-log4j12</artifactId>             </exclusion>         </exclusions>     </dependency>     <dependency>         <groupId>org.apache.flink</groupId>         <artifactId>flink-streaming-java_${scala.binary.version}</artifactId>         <version>${flink.version}</version>         <exclusions>             <exclusion>                 <groupId>log4j</groupId>                 <artifactId>*</artifactId>             </exclusion>             <exclusion>                 <groupId>org.slf4j</groupId>                 <artifactId>slf4j-log4j12</artifactId>             </exclusion>         </exclusions>     </dependency>     <dependency>         <groupId>org.scala-lang</groupId>         <artifactId>scala-library</artifactId>         <version>${scala.version}</version>     </dependency>      <!-- https://mvnrepository.com/artifact/org.apache.flink/flink-table -->      <!-- https://mvnrepository.com/artifact/org.apache.flink/flink-table-common -->     <dependency>         <groupId>org.apache.flink</groupId>         <artifactId>flink-table-common</artifactId>         <version>${flink.version}</version>     </dependency>     <!-- https://mvnrepository.com/artifact/org.apache.flink/flink-table-api-java -->     <dependency>         <groupId>org.apache.flink</groupId>         <artifactId>flink-table-api-java</artifactId>         <version>${flink.version}</version>     </dependency>     <!-- https://mvnrepository.com/artifact/org.apache.flink/flink-table-api-java-bridge -->     <dependency>         <groupId>org.apache.flink</groupId>         <artifactId>flink-table-api-java-bridge_${scala.binary.version}</artifactId>         <version>${flink.version}</version>     </dependency>     <!-- https://mvnrepository.com/artifact/org.apache.flink/flink-table-planner -->     <dependency>         <groupId>org.apache.flink</groupId>         <artifactId>flink-table-planner_${scala.binary.version}</artifactId>         <version>${flink.version}</version>     </dependency>      <!-- https://mvnrepository.com/artifact/org.apache.flink/flink-table-planner-blink -->     <dependency>         <groupId>org.apache.flink</groupId>         <artifactId>flink-table-planner-blink_${scala.binary.version}</artifactId>         <version>${flink.version}</version>     </dependency>     <dependency>         <groupId>org.apache.flink</groupId>         <artifactId>flink-clients_${scala.binary.version}</artifactId>         <version>${flink.version}</version>     </dependency>     <dependency>         <groupId>com.starrocks</groupId>         <artifactId>flink-connector-starrocks</artifactId>         <version>1.1.10_flink-1.13</version>     </dependency>     <dependency>         <groupId>com.google.code.gson</groupId>         <artifactId>gson</artifactId>         <version>2.8.9</version>     </dependency> </dependencies>

（2）访问StarRocks，创建测试表

CREATE TABLE IF NOT EXISTS flink_student (

  uid INT,

  name VARCHAR(20),

  age INT,

  email VARCHAR(20),

  sex VARCHAR(10)

   )DUPLICATE KEY(uid)DISTRIBUTED BY HASH(uid) BUCKETS 8

（3）编写代码将数据插入到对应测试表中，那么插入方式也有两种用stream或者sql。先使用stream方式插入表中

package com.atguigu.starrocks.test;

import com.google.gson.Gson;
import com.starrocks.connector.flink.StarRocksSink;
import com.starrocks.connector.flink.table.StarRocksSinkOptions;
import org.apache.flink.streaming.api.datastream.DataStreamSource;
import org.apache.flink.streaming.api.environment.StreamExecutionEnvironment;

import java.util.Arrays;

public class FlinkToStarRocksTest {
  public static void main(String[] args) throws Exception {
    StreamExecutionEnvironment env = StreamExecutionEnvironment.getExecutionEnvironment();
    FlinkToStarRocksTest ft = new FlinkToStarRocksTest();
    ft.useStream(env);
    env.execute();
  }

  void useStream(StreamExecutionEnvironment env) {
    Gson gson = new Gson();
    DataStreamSource<String> studentDataStreamSource = env.fromCollection(Arrays.asList(gson.toJson(new Student(1001, "张三", 18, "111@qq.com", "男")),
        gson.toJson(new Student(1002, "李四", 19, "222@qq.com", "女")),
        gson.toJson(new Student(1003, "王五", 20, "333@qq.com", "男"))));
    studentDataStreamSource.addSink(StarRocksSink.sink(
        StarRocksSinkOptions.builder()
            .withProperty("jdbc-url", "jdbc:mysql://hadoop101:9030")
            .withProperty("load-url", "hadoop101:8030;hadoop102:8030;hadoop103:8030")
            .withProperty("username", "root")
            .withProperty("password", "")
            .withProperty("table-name", "flink_student")
            .withProperty("database-name", "test")
            .withProperty("sink.properties.format", "json")
            .withProperty("sink.properties.strip_outer_array", "true")
            .build()
        )
    );
  }

}

class Student {
  private int uid;
  private String name;
  private int age;
  private String email;
  private String sex;

  public Student(int uid, String name, int age, String email, String sex) {
    this.uid = uid;
    this.name = name;
    this.age = age;
    this.email = email;
    this.sex = sex;
  }
}

（4）因为当前StarRocks集群安装阿里云环境上，并且使用的是阿里云私有ip，那么如果使用local模式使用用户本机主机直接写数据会出现私有ip访问不通的错，所以搭建flink客户端采用on yarn模式写入StarRocks。

[root@hadoop103 software]# wget https://downloads.apache.org/flink/flink-1.13.3/flink-1.13.3-bin-scala_2.12.tgz

[root@hadoop103 software]# tar -zxvf flink-1.13.3-bin-scala_2.12.tgz -C /opt/module/

[root@hadoop103 software]# cd /opt/module/flink-1.13.3/

[root@hadoop103 flink-1.13.3]# cd lib/

[root@hadoop103 lib]# wget https://repo1.maven.org/maven2/com/starrocks/flink-connector-starrocks/1.1.10_flink-1.13/flink-connector-starrocks-1.1.10_flink-1.13.jar

[root@hadoop103 lib]# cd ..

[root@hadoop103 bin]# vim /etc/profile

export HADOOP_CLASSPATH=`hadoop classpath`

[root@hadoop103 bin]# source /etc/profile

（5）将代码打成jar包，上传运行yarn模式任务

[root@hadoop103 flink-1.13.3]# bin/flink run -m yarn-cluster -ynm teststarrocks -p 12 -ys 4 -yjm 1024 -ytm 2048m -d -c com.atguigu.starrocks.test.FlinkToStarRocksTest  -yqu flink /opt/software/starrocks_demo-1.0-SNAPSHOT-jar-with-dependencies.jar 

（6）yarn模式运行完毕后查看startrocks表

mysql> select *from flink_student;

![img](file:////private/var/folders/68/kg2tdk0x03xbzs4mk_l5g3dw0000ks/T/com.kingsoft.wpsoffice.mac/wps-didi/ksohtml/wpsJRy0e3.jpg) 

（6）可以看到已经有数据了，尝试第二种方式使用sql的方式导入。先删除表数据。

   truncate table flink_student;

（7）删除表数据之后，再编写代码

public class FlinkToStarRocksTest {
  public static void main(String[] args) throws Exception {
    StreamExecutionEnvironment env = StreamExecutionEnvironment.getExecutionEnvironment();
    StreamTableEnvironment tableEnv = StreamTableEnvironment.create(env);
    FlinkToStarRocksTest ft = new FlinkToStarRocksTest();
    ft.useSql(tableEnv);
  }

 void useSql(StreamTableEnvironment env) {
  env.executeSql("CREATE TABLE flink_student(\n" +
      "         uid INT,\n" +
      "         name VARCHAR(20),\n" +
      "         age INT,\n" +
      "         email VARCHAR(20),\n" +
      "         sex VARCHAR(10)\n" +
      "         )WITH(\n" +
      "         'connector' = 'starrocks',\n" +
      "         'jdbc-url'='jdbc:mysql://hadoop101:9030',\n" +
      "         'load-url'='hadoop101:8030;hadoop102:8030;hadoop103:8030',\n" +
      "         'username'='root',\n" +
      "         'password'='',\n" +
      "         'table-name'='flink_student', \n" +
      "         'database-name'='test',\n" +
      "         'sink.properties.format'='json',\n" +
      "         'sink.properties.strip_outer_array'='true' \n" +
      "         )");
  StatementSet statementSet = env.createStatementSet();
  statementSet.addInsertSql("insert into flink_student values(1001,'李四',19,'111.qq.com','女')," +
      "(1002,'张三',20,'222@qq.com','男')");
  statementSet.execute();

  }
}

（8）运行yarn模式进行测试。并查询对flink_student表

mysql> select *from flink_student;

![img](file:////private/var/folders/68/kg2tdk0x03xbzs4mk_l5g3dw0000ks/T/com.kingsoft.wpsoffice.mac/wps-didi/ksohtml/wpslDZweG.jpg) 

 

## **4.6Datax Writer**

StarRocksWriter 插件实现了写入数据到 StarRocks 的目的表的功能。在底层实现上，StarRocksWriter 通过Stream load以csv或 json 格式导入数据至StarRocks。内部将reader读取的数据进行缓存后批量导入至StarRocks，以提高写入性能。总体数据流是 source -> Reader -> DataX channel -> Writer -> StarRocks

  

***\*使用：\****

（1）下载datax,并解压。下载starrockswriter并解压，剪切到datax插件目录

[root@hadoop103 software]# wget http://datax-opensource.oss-cn-hangzhou.aliyuncs.com/datax.tar.gz

[root@hadoop103 software]# tar -zxvf datax.tar.gz -C /opt/module/

[root@hadoop103 software]# wget https://github.com/StarRocks/DataX/releases/download/v1.1.3/starrockswriter.tar.gz

[root@hadoop103 software]# tar -zxvf starrockswriter.tar.gz -C /opt/module/

[root@hadoop103 module]# mv starrockswriter/ datax/plugin/writer/

 

（2）在这里就模拟使用datax读取mysql再导入starrocks，如果是其他方式读取可以参考datax官网。连接mysql，创建一张mysql的测试表，并插入测试数据。

[root@hadoop101 ~]# mysql -uroot -p000000

mysql> use test_db;

CREATE TABLE datax_test(

id INT,

NAME VARCHAR(20),

k1 VARCHAR(20),

k2 VARCHAR(20)

);

INSERT INTO datax_test VALUES(1,'张三','kkkk1','kkkk2'),(2,'李四','kkk1','kkk2');

（3）同样，访问starrocks创建对应结构的测试表

[root@hadoop101 ~]# mysql -uroot -P 9030 -hhadoop101

CREATE TABLE datax_test(

id INT,

NAME VARCHAR(20),

k1 VARCHAR(20),

k2 VARCHAR(20)

)DUPLICATE KEY(id)DISTRIBUTED BY HASH(id) BUCKETS 4;

（4）使用datax将mysql数据读出并写入到StarRocks中。编写json文件，并执行相应python

{

  "job": {

​    "setting": {

​      "speed": {

​         "channel": 3

​      }

​    },

​    "content": [

​      {

​        "reader": {

​          "name": "mysqlreader",

​          "parameter": {

​            "username": "root",

​            "password": "123456",

​            "column": [ "id", "name", "k1", "k2" ],

​            "connection": [

​              {

​                "table": [ "datax_test" ],

​                "jdbcUrl": [

​                   "jdbc:mysql://hadoop101:3306/test_db"

​                ]

​              }

​            ]

​          }

​        },

​        "writer": {

​          "name": "starrockswriter",

​          "parameter": {

​            "username": "root",

​            "password": "",

​            "database": "test",

​            "table": "datax_test",

​            "column": ["id", "name", "k1", "k2"],

​            "preSql": ["truncate  table test.datax_test"],

​            "postSql": [], 

​            "jdbcUrl": "jdbc:mysql://hadoop101:9030/",

​            "loadUrl": ["hadoop101:8030", "hadoop102:8030","hadoop103:8030"],

​            "loadProps": {}

​          }

​        }

​      }

​    ]

  }

}

（5）运行datax命令

[root@hadoop103 module]# python datax/bin/datax.py datax-test.json

# 第5章 **使用StarRocks**

## **5.1Colocate join**

   colocation join 可以避免数据网络传输开销，核心思想是将同一个 Colocation Group 中表，采用一致的分桶键、一致的副本数量和一致副本放置方式，因此如果 join 列为分桶键，则计算节点只需做本地 join 即可，无须从其他节点获取数据，从而规避网络shuffle的过程。

 

***\*使用：\****

（1）创建两张测试表，并标记同一个group属性,让表与表join可以得到优化。并且两张表桶的个数保持一致。

CREATE TABLE `tbl1` (

  `k1` date NOT NULL COMMENT "",

  `k2` int(11) NOT NULL COMMENT "",

  `v1` int(11) SUM NOT NULL COMMENT ""

) ENGINE=OLAP

AGGREGATE KEY(`k1`, `k2`)

DISTRIBUTED BY HASH(`k2`) BUCKETS 8

PROPERTIES (

  "colocate_with" = "group1"

);

 

CREATE TABLE `tbl2` (

  `k1` date NOT NULL COMMENT "",

  `k2` int(11) NOT NULL COMMENT "",

  `v1` int(11) SUM NOT NULL COMMENT ""

) ENGINE=OLAP

AGGREGATE KEY(`k1`, `k2`)

DISTRIBUTED BY HASH(`k2`) BUCKETS 8

PROPERTIES (

  "colocate_with" = "group1"

);

（2）创建表之后再进行两表join,并可以使用explain进行分析。如果优化生效执行计划里可看到colocate为true

mysql> explain SELECT * FROM tbl1 INNER JOIN tbl2 ON (tbl1.k2 = tbl2.k2);

![img](file:////private/var/folders/68/kg2tdk0x03xbzs4mk_l5g3dw0000ks/T/com.kingsoft.wpsoffice.mac/wps-didi/ksohtml/wpshy92vf.jpg) 

## **5.2外部表**

StarRocks 支持以外部表的形式，接入其他数据源。外部表指的是保存在其他数据源中的数据表，而 StartRocks 只保存表对应的元数据，并直接向外部表所在数据源发起查询。目前 StarRocks 已支持的第三方数据源包括 MySQL、ElasticSearch、Hive以及StarRocks。对于StarRocks数据源，现阶段只支持Insert写入，不支持读取，对于其他数据源，现阶段只支持读取，还不支持写入。

 

### **5.2.1MySql外部表**

星型模型中，数据一般划分为维度表和事实表。维度表数据量少，但会涉及 UPDATE 操作。目前 StarRocks 中还不直接支持 UPDATE 操作（可以通过 Unique 数据模型实现），在一些场景下，可以把维度表存储在 MySQL 中，查询时直接读取维度表。

  

***\*使用：\****

（1）登录mysql，先创建测试表

[root@hadoop101 ~]# mysql -uroot -p123456

mysql> use test_db;

CREATE TABLE test_t1(

id INT,

`name` VARCHAR(20),

age INT);

（2）插入测试数据

INSERT INTO test_t1 VALUES(1001,'张三',14),(1002,'李四',15),(1003,'王五',16);

（3）再登录starrocks，创建mysql外部表

[root@hadoop101 StarRocks-1.19.1]# mysql -uroot -P 9030 -hhadoop101

mysql> use test;

create external table mysql_t1(

id int,

name varchar(20),

age int)

ENGINE=mysql

PROPERTIES

(

  "host" = "hadoop101",

  "port" = "3306",

  "user" = "root",

  "password" = "123456",

  "database" = "test_db",

  "table" = "test_t1"

);

（1）查询mysql外部表，可以直接查询到数据。

mysql> select *from mysql_t1;

![img](file:////private/var/folders/68/kg2tdk0x03xbzs4mk_l5g3dw0000ks/T/com.kingsoft.wpsoffice.mac/wps-didi/ksohtml/wpsjYqtQ2.jpg) 

（2）修改mysql表中数据，并查看starrcoks中外部表情况。可以看到已发生变化

mysql> update test_t1 set name='haha' where id=1001;

mysql> select *from mysql_t1;

![img](file:////private/var/folders/68/kg2tdk0x03xbzs4mk_l5g3dw0000ks/T/com.kingsoft.wpsoffice.mac/wps-didi/ksohtml/wpso72vCh.jpg) 

### **5.2.2Hive外部表**

（1）启动hadoop集群，启动hive的元数据服务和hiveserver2服务

（2）在default库创建hive测试表

create table test_t1(

id int ,

name string,

age int);

（3）插入测试数据

hive (default)> INSERT INTO test_t1 VALUES(1001,'张三',14),(1002,'李四',15),(1003,'王五',16);

（4）在starrocks中创建hive源,starrocks中可通过show resources命令查看源

CREATE EXTERNAL RESOURCE "hive0"

PROPERTIES (

 "type" = "hive",

 "hive.metastore.uris" = "thrift://172.26.143.117:9083");

（5）创建hive外部表

create external table hive_t1(

id int,

name varchar(20),

age int)

ENGINE=HIVE

PROPERTIES (

 "resource" = "hive0",

 "database" = "default",

 "table" = "test_t1"

);

（6）查询hive_t1表

## **5.3数组**

字段类型，数组。在建表时指定字段类型。

 

***\*使用：\****

（1）使用一维数组

create table t0(

 c0 INT,

 c1 ARRAY<INT>

)

duplicate key(c0)

distributed by hash(c0) buckets 3;

（2）插入数据

mysql> INSERT INTO t0 VALUES(1, [1,2,3]);

（3）如果要查询数组列的具体某个值，可用下标的方式取值，注意下标从1开始。比如我要查询[1,2,3]中的2，sql语句如下

mysql> select c1[2] from t0;

![img](file:////private/var/folders/68/kg2tdk0x03xbzs4mk_l5g3dw0000ks/T/com.kingsoft.wpsoffice.mac/wps-didi/ksohtml/wpsJ3TFoL.jpg) 

（4）使用嵌套数组，创建测试表。

create table t1(

 c0 INT,

 c1 ARRAY<ARRAY<VARCHAR(10)>>

)

duplicate key(c0)

distributed by hash(c0) buckets 3;

（5）插入数据

mysql> INSERT INTO t1 VALUES(1, [[1,2,3],[1,2,3],[4,5,6]]);

（3）查询数据，同样比如要查询[[1,2,3],[1,2,3],[4,5,6]]要查询其中的5，那就是下标为3中的数组下标为2的数值。

mysql> select c1[3][2] from t1;

![img](file:////private/var/folders/68/kg2tdk0x03xbzs4mk_l5g3dw0000ks/T/com.kingsoft.wpsoffice.mac/wps-didi/ksohtml/wpskwbLQL.jpg) 

（4）数组的使用有以下限制

1.只能在duplicate table中定义数组列

2.数组列不能作为key列(以后可能支持)

3.数组列不能作为distribution列

4.数组列不能作为partition列

 

# **第6章集群管理**

## **5.1集群端口**

| 端口名称               | 默认端口                          | 作用                                             |
| ---------------------- | --------------------------------- | ------------------------------------------------ |
| http_port              | 8030（与resourcemanager端口冲突） | FE在http server上的端口                          |
| rpc_port               | 9020                              | FE在thrift server上的端口                        |
| query_port             | 9030                              | FE在mysql server上的端口                         |
| edit_log_port          | 9020                              | FE Group(master follower observer)之间的通信端口 |
| be_port                | 9060                              | BE在thrift server上的端口                        |
| webserver_port         | 8040（与nodemanager冲突）         | BE上http server的端口                            |
| heartbeat_service_port | 9050                              | BE上心跳服务端口（thrift）,用于接收来自FE的心跳  |

 

## **5.****2参数配置**

https://docs.starrocks.com/zh-cn/main/administration/Configuration

 

# **遇到的问题**

1.![img](file:////private/var/folders/68/kg2tdk0x03xbzs4mk_l5g3dw0000ks/T/com.kingsoft.wpsoffice.mac/wps-didi/ksohtml/wpsncsaYC.jpg)

 

 