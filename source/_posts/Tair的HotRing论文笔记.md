---
title: Tair的HotRing论文笔记
date: 2021-5-15 21:31:44
tags: [paper]  
---

### 简介

- HotRing--  一种热点可感知的内存 KV 存储结构

- 论文原文：https://www.usenix.org/conference/fast20/presentation/chen-jiqiang

  ```
  　热点问题，可以理解为在一个严重倾斜的工作负载下，频繁的访问和操作某一小部分数据。
  
  　　如图，是阿里的不同业务中数据访问分布情况，大量的数据访问只集中在少部分的热点数据中。在平常的情况下，百分之五十的用户访问请求只是针对其中百分之一的数据，在一些极端的情况下，当新产品发售后，大量的粉丝疯狂进行抢购下单，业务的访问量基本都聚集在某一小部分数据上，会出现百分之九十的用户请求针对其中百分之一的数据。
  ```

  ![image-20211018010808873](http://guxiangflyimagebucket.oss-cn-beijing.aliyuncs.com/img/image-20211018010808873.png)



目前有一些方法来解决热点数据问题：

-    使用一致性哈希算法将数据分片，分布到多个节点上，分摊热点访问。（*Scale out using consistent hashing*）
-    将热点数据备份到多个节点上，分摊热点访问。 （*Replication in multi-node*）
-    客户端缓存：通过预先标记热点，设置客户端层面的缓存。减小键值存储系统的负载压力。（*Front-end cache*）

   第一种和第二种方法中因为节点的添加，会使得系统的成本会大大增加。第三种方法，如果用户请求中涉及到很多数据更新的请求，对客户端层面的缓存的数据需要维护，这个过程实现会变得很复杂。

　本篇论文则是从提升单个点对热点数据的处理能力出发（*Improve Single node’s ability to handle hotspots*），设计了一种热点可感知的键值数据结构，实现在严重倾斜的工作负载下，快速的完成用户的访问请求。

### 一些问题场景

- 在某些时刻，缓存系统迎来了巨大的访问量

- 可能存在访问倾斜，大多数访问集中在极少数数据上

对于集群级别的热点监测倍受重视



　在一般情况下，对于更新操作，HotRing可以对不超过8字节的数据进行update-in-place原子更新操作，这种情况下，读取和更新被视作一样的操作。但对于超过8个字节的大数据进行更新，hotring则会使用read-copy-update协议，RCU——更新数据的时候，首先拷贝一个副本，然后对副本进行修改，最后使用一个回调（callback）机制在适当的时机把指向原来数据的指针重新指向新的被修改的数据，这个期间数据都是可以随意读的。

　　当更新的数据项是头指针指向的热数据项时，因为要修改前一个数据项的next指针，需要遍历整个环来获取头节点的前一项。如图，遍历得到热数据的前一项需要花费大量的内存访问开销。论文在这种情况下，更新的只是前一项的计数器，其他项的计数器不变，这样可以使得头指针可以在后面的策略调整中直接指向热数据的前一项，使得对热数据的更新需要的内存访问操作就会减少。

![image-20211018011152018](http://guxiangflyimagebucket.oss-cn-beijing.aliyuncs.com/img/image-20211018011152018.png)

### Rehash过程

  　当冲突环上存在多个热点数据时，键值对存储引擎的性能就会大大降低。因此HotRing设计了无锁rehash策略来解决这一问题。和普通的哈希表不同的是使用负载因子来触发rehash不同，HotRing使用访问开销（即操作平均内存访问次数）来触发rehash，文中设置平均内存访问次数超过2的时候，就会自动触发。HotRing rehash分为3步：

　1. 初始化 ——首先创建线程来专门处理rehash操作，初始化一个2倍大小的散列表，复用tag的最高一位来进行索引，将原先的一个环拆分成了两个环。根据tag范围对数据项进行划分。假设tag最大值为T，tag范围为[0,T)，则两个新的头指针对应tag范围为[0,T/2)和[T/2,T)。然后该线程创建一个rehash node，里面包含2个rehash child item，作为2个新环的头，它的格式和data item一样，但是tag值分别是0和T/2。

![image-20211018010955457](http://guxiangflyimagebucket.oss-cn-beijing.aliyuncs.com/img/image-20211018010955457.png)

　2. 分割——接下来需要分割原有的环到2个新的环。如图，因为itemB和E是tag的范围边界，所以线程会将两个rehash item节点分别插入到itemB和E之前。到目前为止，已经在逻辑上将冲突环一分为二。

3. 删除——最后一步，将每一个环中首尾两部分连接在一起。此外，还有一些收尾工作，包括旧哈希表的回收、以及rehash节点的删除回收等。需要注意的是，在完成删除操作之前，要确保所有对旧哈希表的访问已经结束。只有rehash线程会阻塞一段时间。

![image-20211018011035073](http://guxiangflyimagebucket.oss-cn-beijing.aliyuncs.com/img/image-20211018011035073.png)

### 数据证明

在一台内存容量为32GB的服务器上测试的，测试的时候使用YCSB提供5种工作负载，默认情况下，使用64个线程在两亿五千万个键值对测试负载B，在测试负载中，有百分之97.8的操作是针对其中百分只1的数据，百分之99.8的操作是针对10%的数据，

![image-20211018011253219](http://guxiangflyimagebucket.oss-cn-beijing.aliyuncs.com/img/image-20211018011253219.png)

Deployment

- 　　HotRing-r (random movement strategy)
- 　　HotRing-s (sampling statistics strategy)

Baselines

- Chaining Hash(a lock-free chain-based hash index that is modified from the hash structure in Memcached.)
- FASTER(SIGMOD 2019)
- Masstree
- Memcached

在单线程和多线程情况下，对这几种数据结构的性能进行了测试。Hotring在大量读操作的情况下，可以实现一个很高的性能。
