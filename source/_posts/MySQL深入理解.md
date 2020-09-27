---
title: MySQL深入理解
date: 2019-12-24 20:11:44
tags: [MySQL]

---



## InnoDB 数据读取

在InnoDB中, 数据会存储到磁盘上, 使用时候先将数据加载到内存`select * from table1 where  id=100`读取某些记录时, InnoDB存储引擎不需要一条一条的把记录从磁盘上读出来.   

- **InnoDB采取的方式是** : 将数据划分为若干个页, 以页作为磁盘和内存之间交互的基本单位, InnoDB中页的大小一般为16KB, 也就是说, 当需要从磁盘中读取数据时每一次最少将从磁盘中读取16KB的内容到内存中, 每一次最少也会把内存中的16KB内容写入到磁盘中.

- **为什么要读取16KB**： 计算机里有个著名的局部性原理

  ```
  当一个数据被用到时，其附近的数据也通常会马上被使用。
  ```

  ```sql
  show global status like 'innodb_page_size';   --可以通过这个命令查看到数据页的大小
  ```

  

  为了尽量减少磁盘I/O，磁盘往往不是严格按需读取，而是每次都会预读，即使只需要一个字节，磁盘也会从这个位置开始，顺序向后读取一定长度的数据放入内存。   注：磁盘顺序读取的效率很高（不需要寻道时间，只需很少的旋转时间）

  预读的长度一般为页（page）的整倍数（在许多操作系统中，页的大小通常为4k）。一般设置为16KB（这个16KB 可以自定义）

```sql
show global variables like '%datadir%';  --查看mysql存储数据的位置
```





## 页结构

页的本质就是一块`16KB`大小的存储空间。

InnoDB将不同功能的页划分为不同的类型，其中用于存放记录的页也称为数据页。



![image.png](https://i.loli.net/2020/01/09/dCcuIWgESmjZ4wY.png)



|        名称         |       中文名       | 占用空间大小 |       简单描述       |
| :-----------------: | :----------------: | :----------: | :------------------: |
|     File Header     |       文件头       |    38字节    |     描述页的信息     |
|     Page Header     |        页头        |    56字节    |     页的状态信息     |
| Infimum  + SupreMum | 最小记录和最大记录 |    26字节    |   两个虚拟的行记录   |
|    User Records     |      用户记录      |    不确定    | 实际存储的行记录内容 |
|     Free Space      |      空闲空间      |    不确定    |  页中尚未使用的空间  |
|   Page Directory    |       页目录       |    不确定    |  页中的记录相对位置  |
|    File Trailer     |      文件结尾      |    8字节     |        结尾信        |





## 行格式

MySQL 行格式默认为 Dynamic  

行格式有 Compact,Redundant,Dynamic和Compressed 四种

```sql
show table status like 'table_name'  #这条sql 可以查看行格式

CREATE TABLE table_name (列信息) ROW_FORMAT=行格式名称

ALTER TABLE table_name  ROW_FORMAT=行格式名称
```

### compact 行格式

格式如下



![image.png](https://i.loli.net/2020/01/08/4DbZYAKkz619F7h.png)

- **变长字段长度列表**  (按顺序存储每一行 varchar字符实际使用的长度) 

   注：varchar(M)，M代表最大能存多少个字符。( MySQL5.0.3以前是字节，以后就是字符)
	注：如果没有varchar字段，这个 变长字段长度列表可以去掉


- **NULL值列表**
	compact行格式管理 可以为null的列表统一管理起来，如果表中没有允许存储null的列，null值列表就不存在。  
	二进制列表为1时代表null，二进制列表为0时代表这一列不是null
	
	注：**MySQL建议列属性尽量为NOT NULL** 这样就没有null值列表了 
	
	```
	NULL columns require additional space in the rowto record whether their values are NULL. For MyISAM tables, each NULL columntakes one bit extra, rounded up to the nearest byte.  ---来自mysql的官方文档
	```
	
	( 高性能mysql 4.1节里面有讲到。
	
	但是，通常把可为NULL的列改为NOT NULL带来的性能提升比较小，所 
	
	以（调优时）没有必要首先在现有schema中查找并修改掉这种情况）
	
	注： NULL值列表的大小 随着可为null的字段的个数而增加
	
	```sql
	create table sizetest(
	    test char(65535) not null,
	) charset ='ascii' row_format=compact;  
	
	mysql一行最多是存 65535个字节
	这一条sql会报错，由于test 是 varchar类型，而且不是not null 需要留长度给变长字段长度列表和null值列表
	```
	
	上面所说，一行一共可以存储65535个字节，但是其实一页只有 16KB （16384个字节）  这个导致一个行溢出，

![image.png](https://i.loli.net/2020/01/08/eoK6ZA57gRWphVP.png)







![image-20200114164422934](/Users/mtdp/Library/Application Support/typora-user-images/image-20200114164422934.png)



- **记录头信息**

  |      名称      | 大小（单位：bit） |                             描述                             |
  | :------------: | :---------------: | :----------------------------------------------------------: |
  |   `预留位1`    |        `1`        |                           没有使用                           |
  |   `预留位2`    |        `1`        |                           没有使用                           |
  | `delete_mask`  |        `1`        |                     标记该记录是否被删除                     |
  | `min_rec_mask` |        `1`        |         标记该记录是否为B+树的非叶子节点中的最小记录         |
  |   `n_owned`    |        `4`        |                    表示当前槽管理的记录数                    |
  |   `heap_no`    |       `13`        |                表示当前记录在记录堆的位置信息                |
  | `record_type`  |        `3`        | 表示当前记录的类型，`0`表示普通记录，`1`表示B+树非叶节点记录，`2`表示最小记录，`3`表示最大记录 |
  | `next_record`  |       `16`        |                   表示下一条记录的相对位置                   |

- **记录的真实数据 于其中的隐藏列**

  ​	隐藏列归类于记录的真实数据

  - row_id                  行id
  - Transcation_id    6个字节  事务id  (最近一次修改的事务id是哪个)
  - roll_pointer         7个字节  回滚指针









## 索引


假设我们插入学生表数据如下

```sql
create table s1
(
    id       int auto_increment primary key,
    username varchar(255) null,
    money    int          null
) engine = 'innodb';


INSERT INTO mysql_study.s1 (id, username, money) VALUES (1, '小明', 1002);
INSERT INTO mysql_study.s1 (id, username, money) VALUES (4, '小刚', 1233);
INSERT INTO mysql_study.s1 (id, username, money) VALUES (2, '小红', 1000);
INSERT INTO mysql_study.s1 (id, username, money) VALUES (3, '小芳', 2312);
INSERT INTO mysql_study.s1 (id, username, money) VALUES (5, '小刘', 1235);

使用 select * from s1 查询出来会自动按主键排序
1,小明,1002
2,小红,1000
3,小芳,2312
4,小刚,1233
5,小刘,1235
```



```sql
create table s2
(
    id       int auto_increment primary key,
    username varchar(255) null,
    money    int          null
) engine = 'MyISAM';


INSERT INTO mysql_study.s2 (id, username, money) VALUES (1, '小明', 1002);
INSERT INTO mysql_study.s2 (id, username, money) VALUES (4, '小刚', 1233);
INSERT INTO mysql_study.s2 (id, username, money) VALUES (2, '小红', 1000);
INSERT INTO mysql_study.s2 (id, username, money) VALUES (3, '小芳', 2312);
INSERT INTO mysql_study.s2 (id, username, money) VALUES (5, '小刘', 1235);


使用 select * from s1 查询出来不会自动按主键排序
1,小明,1002
4,小刚,1233
2,小红,1000
3,小芳,2312
5,小刘,1235

```



上数据发现，innodb的数据是会默认按id主键排序的。  这是由于mysql聚集索引的特性。



### 聚集索引



在一个 16KB 的数据页中 内含一个 **Page Directory  页目录**

这个页目录

![image.png](https://i.loli.net/2020/01/13/Zzui6I7gUTtyWVF.png)

单个放大来看是这样的。

![](https://i.loli.net/2020/01/13/pVaWUvm9cOZ67qh.png)



简单一点画就是这样： 在单个 page 数据页中，用户数据的存放是有序的。单挑数据的行格式的头记录信息中，有一个next_record 字段记录着它的下一个行数据。 并且 page directory 类似有点类似skiplist跳表，  如果查询id 为5的数据，先比对 page directory 找到4，page directory 的4 指向到 id 为5 的数据。

![image.png](https://i.loli.net/2020/01/13/rTifyIPbX1KEoUu.png)



- **对于聚集索引而言:**
  - 如果主键被定义了，那么主键为聚集索引的id
  - 如果没有主键，那么选取第一个唯一非空索引作为密集索引
  - 如果不满足以上条件，innodb中有一个隐藏列叫做 row_id 它是索引







这就引出一个面试题， 为何不用UUID 作为分布式ID的主键。

```
1. MySQL官方有明确的建议主键要尽量越短越好[4]，36个字符长度的UUID不符合要求。
2. 对MySQL索引不利：如果作为数据库主键，在InnoDB引擎下，UUID的无序性可能会引起数据位置频繁变动，严重影响性能。
```

https://tech.meituan.com/2017/04/21/mt-leaf.html



假设 主键占

B+ 树  高度为2的时候 可以存储  两万多条数据  高度为3  可以存储 两千万多条数据。



- 聚集索引的 具体展现：

  ```
  索引的所有节点都是一个数据页
  聚集索引的叶子节点存储真实的行数据，
  非叶子节点存储 主键+页号指针
  
  假设 一行数据 1kb   一个叶子节点16kb    主键bigint占8个字节，页号指针6个字节  
  非叶子节点可以存储的kv对为 （16*1024/(8+6)）=1170 个
  一个叶子节点  16kb/1kb = 16 
  高度为2的B+树  存储  16*1170 =18720 个
  高度为3的B+树可存储   16*1170*1170 = 21902400 个
  ```

  

![image.png](https://i.loli.net/2020/01/13/1XBD3xhmQrbcFiL.png)





### 稀疏索引（辅助键索引）

稀疏索引： 稀疏缩影的叶子节点不存数据， 只存对应的索引值和主键。拿到对应的主键，去聚集索引中寻找具体的数据。  

![image.png](https://i.loli.net/2020/01/13/RkgmClpu5zsHYIG.png)

分聚集索引和稀疏索引的好处：

- 这样如果更新了一个值就只需要更新 聚集索引 其他索引不用动

  



## 





## mysql事务实现原理

Innodb行格式中，存在有

- 三个隐藏列
  - row_id                  行id
  - Transcation_id    每次对某条记录进行改动时，都会把对应的事务id赋值给trx_id隐藏列。
  - roll_pointer        每次对某条记录进行改动时，这个隐藏列会存一个指针，可以通过这个指针找到该记 录修改前的信息。

- 脏读、幻读、不可重复读的概念

  - 脏读 ：所谓脏读是指一个事务中访问到了另外一个事务未提交的数据
  - 幻读： 一个事务读取2次，得到的记录条数不一致（第一次读取起来有3条数据 第二次读取起来有4条数据） 
  - 不可重复读：一个事务读取同一条记录2次，得到的结果不一致
  - 幻读针对的是多行，不可重复读针对的是1行

- ReadView

  ​	对于使用Read uncommitted隔离级别的事务来说，直接读取记录的最新版本就好了，对于使用 SERIALIZABLE隔离级别的事务来说，使用加锁的方式来访问记录。对于使用READ COMMITTED和 REPEATABLE READ隔离级别的事务来说，就需要用到我们上边所说的版本链了，核心问题就是:需要判断一下 版本链中的哪个版本是当前事务可见的。

  

  - m_ids   ReadView 里面有一个 m_ids 里面记录着活跃的还没有提交的活跃事务id   m_ids:[200,199,198]

    ```
    按照下图而言，
    在Read Committed隔离级别下： 
    1. 现在有一个事务A事务id为202，它来查询一条sql， m_ids里面有[200，199，198]。那么就会顺着版本链找下去，一直找到 197 这条事务，A事务就会将 tx_id为 197的事务给找出来。
    2. 现在假设 200这条事务已经commit了，那么200这条事务就不在m_ids里面了  m_ids变成[199，198], 按版本链直接读取到 tx_id 为200的事务，就好了
    
    read commit：
    A		B
    1		1改为2
    1   2
    		commit
    2
    
    
    
    可重复读：
    A		B	
    1		1改为2
    		commit;
    1
    A事务第一次读取出来是 1  
B事务把1改为2，并且B提交了
    A再去读 还是 1

    在 Repeatable Read （可重复读）的隔离级别下：
    A事务会缓存第一次加载到的 m_ids 列表。直接读取第一次缓存的m_ids列表，进行读取。
    
    以上就是MVCC
    ```
    
    
    
    ![image.png](https://i.loli.net/2020/01/14/Q43oZfCMwdRSkXt.png)



### undoLog与redoLog

#### undo log

undo log有两个作用：提供回滚和多个行版本控制(MVCC)。

在数据修改的时候，不仅记录了redo，还记录了相对应的undo，如果因为某些原因导致事务失败或回滚了，可以借助该undo进行回滚。



### 当前读和快照读

- 当前读：select ... lock in share mode；  select ... for update ； 加锁的增删改语句 update；delete；insert
- 快照读：不加锁的非阻塞读，select





#### GAP锁 间隙锁

```sql
============== session1
begin;
select * from s1 where money =1000 for update ;
commit;

============== session2
begin;
INSERT INTO mysql_study.s1 ( username, money) VALUES ( 'Tom3', 1001);  
commit;
```

- read committed ： 只会对查询出的数据进行加锁。 对于上条数据，由于read committed没有对 money为 1001的进行加锁

- repeatable read： 

   read committed级别下，这个不会被锁住。

  但是在 repeatable read 隔离级别下，这个insert会被锁住

###### 再举个例子

```sql
select * from test_innodb_lock
```

![image-20200518115642259](https://gitee.com/guxiangfly/blogimage/raw/master/img/image-20200518115642259.png)



```sql
session1:  update test_innodb_lock set b='0629' where a >1 and a <6   

session2:  insert into test_innodb_lock values(2,'2000')     #session2会被 session1阻塞，session1执行完成后，才会之心session2
```

结果如下：

![image-20200518115406957](https://gitee.com/guxiangfly/blogimage/raw/master/img/image-20200518115406957.png)

######  什么是间隙锁

> 当我们使用范围条件而不是相等条件检索数据时，并且请求共享或者排它锁 类似update操作， innoDB会给符合条件的已有数据记录的索引项加锁，对于剑指在条件氛围内胆并不存在的记录，叫做“间隙（GAP）”
>
> InnoDB也会对这个间隙加锁，这种锁机制就是所谓的间隙锁 （Next-key锁）

###### 危害

> 因为Query过程会锁定范围内的所有的索引值，即使这个键值并不存在。
>
> 间隙锁缺点： 间隙锁会锁定整个范围内的所有键值， 造成锁定的时候无法插入锁定键值范围内的任何数据。某些场景下可能对性能有较大危害
>
> 注：  这也是为何公司会将数据进行逻辑删除，而不会真的删除一行数据。



###### MySQL InnoDB支持三种行锁定方式：

- 行锁（Record Lock）:锁直接加在索引记录上面，锁住的是key。

-  间隙锁（Gap Lock）:锁定索引记录间隙，确保索引记录的间隙不变。间隙锁是针对事务隔离级别为可重复读或以上级别而已的。

-  Next-Key Lock ：行锁和间隙锁组合起来就叫Next-Key Lock。







会使用MDP建立的新组件





如果BD  







![image-20200720143003260](https://gitee.com/guxiangfly/blogimage/raw/master/img/image-20200720143003260.png)







##### innodb架构图

![image-20200720143138180](https://gitee.com/guxiangfly/blogimage/raw/master/img/image-20200720143138180.png)



##### 左边： 内存结构

- Buffer Pool: 缓冲池几乎占mysql服务器内存的 80%
  
  - buffer pool 是以每个页为单位去管理的，每个页的大小为16K
  - 里面有
    - 1.数据页
    - 2.索引页
    - 3.lock信息
    - 4.自适应hash索引 （用于对热点数据页进行索引）
    - 5.字典信息
  
  - buffer  Pool 里面的page分为三类
    - 1. Free Page （空闲页）
      2. Clean Page （已经存储到内存中数据的页）
      3. Dirty Page （脏页，已经存储到内存中数据的页，因为发生了修改或者删除操作，数据在内存和磁盘中产生了不一致）
  - buffer Pool 通过三个链表来管理page：
    - 1. Free List ： 管理 free page ， insert语句就是从 Free List中选择其中一个数据Page进行数据的写入
      2. LRU List：管理 Clean Page  和 Dirty Page，也就是说，只要使用了的Page都在这里进行管理
  - page使用步骤：
    - 1. 先使用free page
- Change Buffer：优化增删改的操作性能
- 测试
- 
##### 右边： 磁盘结构
- System Tablespace (系统表空间)
  - 所有表共享一个表空间存储表数据和其他数据
  - ibdataN   这个文件只会变大，不会变小   undo log就存在此表中
    - 
  
- File-Per-Table  独占表空间 （mysql 5.6之后，数据默认存储在独占表空间）
  - 表现为 ` /var/lib/mysql/数据库DB名字/表名字.ibd`    的文件
  - ibd文件内部：数据内容和索引内容
  - （注： 另一个  ` /var/lib/mysql/数据库DB名字/表名字.frm`文件，这个是表示表结构的文件   ）
  
- Undo TableSpace（Undo表空间    Undo:取消/撤销）
  -    可以查看此表
  - Undo记录默认被记录到系统表空间(ibdata)
  - Undo log用于保证事务特性中的一致性，原子性，隔离性 （undo log也是数据页）
    - Undo Log 分为 insert  undo log  和  update undo log
      - insert  undo log     **INSERT**操作在事务提交前只对当前事务可见，因此产生的**Undo日志可以在事务提交后直接删除**
      - Update undo log   **UPDATE/DELETE**则需要维护多版本信息，在InnoDB里，**UPDATE和DELETE操作产生的Undo日志被归成一类，即update_undo**。
        - 在update 一条行记录之前，需要将之前的数据进行备份（方便回滚使用）  这个备份的数据就是记录在update undo log 中
        - 
  
- Redo Log   (Redo:重做) 

  > redo Log  有点类似于 WAL 预写入日志顺序写

  - ib_logfile0 
  - Ib_logfile1 
  - Redo Log 默认是两个文件，可以配置多个
  - 每个文件大小相同
  - 作用：保证事务的持久化

<img src="https://gitee.com/guxiangfly/blogimage/raw/master/img/image-20200722164429879.png" alt="image-20200722164429879" style="zoom: 25%;" />





> mysql 的持久化有两种机制来保证
>
> 1. WAL预写入日志（redo Log）
>
> 2. 脏页落盘   当脏页产生后，会将该数据页的物理修改操作，记录到redo log buffer中
>
>    数据提交或者每秒钟将 redo log buffer 进行落盘操作
>
>    
>
>    只有脏页落盘失败的时候，redo log 才有用，否则该文件其实一直就是起到一个保险的作用，没有真正被数据加载
>
>    当脏页落盘成功后，对应的redo log buffer 会进行进行清理，所以redo log buffer可以循环使用

<img src="https://gitee.com/guxiangfly/blogimage/raw/master/img/image-20200914152313367.png" alt="image-20200914152313367" style="zoom:50%;" />





#### 



![image-20200809213409775](https://gitee.com/guxiangfly/blogimage/raw/master/img/image-20200809213409775.png)