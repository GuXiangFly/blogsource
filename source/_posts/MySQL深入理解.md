---


title: MySQL深入理解
date: 2019-12-24 20:11:44
tags: [MySQL]

---



## innoDB 数据读取

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

14

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
	
	注：**MySQL建议列属性尽量为NOT NULL** 这样就没有null值列表了 (高性能mysql 4.1节里面有讲到。
	
	但是，通常把可为NULL的列改为NOT NULL带来的性能提升比较小，所 
	
	以（调优时）没有必要首先在现有schema中查找并修改掉这种情况）
	
	注： NULL值列表的大小 随着可为null的字段的个数而增加
	
	```sql
	create table sizetest(
	    test varchar(65535)
	) charset ='ascii' row_format=compact;  
	
	mysql一行最多是存 65535个字节
	这一条sql会报错，由于test 是 varchar类型，而且不是not null 需要留长度给变长字段长度列表和null值列表
	```
	
	上面所说，一行一共可以存储65535个字节，但是其实一页只有 16KB （16384个字节）  这个导致一个行溢出，

![image.png](https://i.loli.net/2020/01/08/eoK6ZA57gRWphVP.png)

- **记录头信息**

  头记录里面有个 next_record  是指向下一个行格式

- **记录的真实数据 于其中的隐藏列**

  ​	隐藏列归类于记录的真实数据

  - row_id                  行id
  - Transcation_id    6个字节  事务id
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



上图数据发现，innodb的数据是会默认按id主键排序的。  这是由于mysql聚集索引的特性。



### 聚集索引



在一个 16KB 的数据页中 内含一个 **Page Directory  页目录**

这个页目录

![image.png](https://i.loli.net/2020/01/13/Zzui6I7gUTtyWVF.png)

单个放大来看是这样的。

![](https://i.loli.net/2020/01/13/pVaWUvm9cOZ67qh.png)



简单一点画就是这样： 在单个 page 数据页中，用户数据的存放是有序的。单挑数据的行格式的头记录信息中，有一个next_record 字段记录着它的下一个行数据。 并且 page directory 类似有点类似skiplist跳表，  如果查询id 为5的数据，先比对 page directory 找到4，page directory 的4 指向到 id 为5 的数据。

![image.png](https://i.loli.net/2020/01/13/rTifyIPbX1KEoUu.png)



这就引出一个面试题，为何不用UUID 作为分布式ID的主键。

```
1. MySQL官方有明确的建议主键要尽量越短越好[4]，36个字符长度的UUID不符合要求。
2. 对MySQL索引不利：如果作为数据库主键，在InnoDB引擎下，UUID的无序性可能会引起数据位置频繁变动，严重影响性能。
```

https://tech.meituan.com/2017/04/21/mt-leaf.html



假设 主键占

B+ 树  高度为2的时候 可以存储  两万多条数据  高度为3  可以存储 两千万多万条数据。







- 聚集索引的 具体展现：

  ```
  索引的所有节点都是一个数据页
  聚集索引的叶子节点存储真实的行数据，
  非叶子节点存储 主键+页号指针
  
  假设 一行数据 1kb   一个叶子节点16kb    主键bigint占8个字节，页号指针6个字节  
  非叶子节点可以存储的kv对为（16*1024/(8+6)）=1170 个
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

  