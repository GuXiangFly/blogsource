---
title: HashMap与ConcurrentHashMap面试
date: 2017-03-11 13:09:04
tags: [java]

---


# HashMap面试

视频教程地址

## java7和 java8 hashmap的不同
```
java7 的hashmap 由数组和链表组成
java8 的hashmap由 数组 和链表+红黑树组成
```
## java8的默认数组长度为多少
```
默认数组长度为 源码中写是 1<<<4    也就是 16  

并且是在第一次put的时候 分配空间的
```
## 链表是插入在头部还是尾部
```
- JDK1.8之前 插入在头部， 如果插入在链表尾部 那么还需要遍历一下链表，浪费时间。
- JDK1.8及其之后， 插入在尾部，有效避免扩容的时候链表成环的问题。 
https://juejin.cn/post/6844903942720061447
```

## 为什么java8 在链表长度为8的时候 转为红黑树
```
个人认为两个原因都有道理：
1.  jdk给出的官方原因：泊松分布在 拓展因子为0.75的时候， 链表长度到8的概率 极低 只有 0.00000006
    长度大于等于8的时候  新增的概率已经很小了，为了查询的效率就选用了红黑树
     * Because TreeNodes are about twice the size of regular nodes, we
     * use them only when bins contain enough nodes to warrant use
     * (see TREEIFY_THRESHOLD). And when they become too small (due to
     * removal or resizing) they are converted back to plain bins.  In
     * usages with well-distributed user hashCodes, tree bins are
     * rarely used.  Ideally, under random hashCodes, the frequency of
     * nodes in bins follows a Poisson distribution
     * (http://en.wikipedia.org/wiki/Poisson_distribution) with a
     * parameter of about 0.5 on average for the default resizing
     * threshold of 0.75, although with a large variance because of
     * resizing granularity. Ignoring variance, the expected
     * occurrences of list size k are (exp(-0.5) * pow(0.5, k) /
     * factorial(k)). The first values are:
     *
     * 0:    0.60653066
     * 1:    0.30326533
     * 2:    0.07581633
     * 3:    0.01263606
     * 4:    0.00157952
     * 5:    0.00015795
     * 6:    0.00001316
     * 7:    0.00000094
     * 8:    0.00000006
     * more: less than 1 in ten million
 
 2. 根据计算可以得出 :
 红黑树的平均查找长度是log(n)，长度为8，查找长度为log(8)=3，链表的平均查找长度为n/2，当长度为8时，平均查找长度为8/2=4，
    这才有转换成树的必要；链表长度如果是小于等于6，6/2=3，虽然速度也很快的，但是转化为树结构和生成树的时间并不会太短。
还有选择6和8的原因是：
　　中间有个差值7可以防止链表和树之间频繁的转换。假设一下，如果设计成链表个数超过8则链表转换成树结构，
    链表个数小于8则树结构转换成链表，如果一个HashMap不停的插入、删除元素，链表个数在8左右徘徊，就会频繁的发生树转链表、链表转树，效率会很低。
```



hashmap 是线程不安全的

```
并发情况下  可能在 transfer 时候出现成环现象，导致get的死循环。

并发问题：
若当前线程此时获得ertry节点，但是被线程中断无法继续执行，此时线程二进入transfer函数，并把函数顺利执行，此时新表中的某个位置有了节点，之后线程一获得执行权继续执行，因为并发transfer，所以两者都是扩容的同一个链表，当线程一执行到e.next = new table[i] 的时候，由于线程二之前数据迁移的原因导致此时new table[i] 上就有ertry存在，所以线程一执行的时候，会将next节点，设置为自己，导致自己互相使用next引用对方，因此产生链表，导致死循环。

解决问题：

使用synchronize ，或者使用collection.synchronizeXXX方法。或者使用concurrentHashmap来解决。
```



# ConcurrentHashMap 面试

 视频教程地址 [https://www.bilibili.com/video/av69066235?from=search&seid=9719965469283553311]
##  

在 JDK1.7及其之前， ConcurrentHashMap默认segment分段锁的个数为16  默认的并发等级是16 可以自己指定。 

但是在JDK1.8及其之后，concurrenthashmap是通过CAS来进行锁的，CAS的锁是针对 concurrenthashmap的单个

## segment是一个 可重入锁 ReentrantLock







## ArrayList 和 LinkedList的区别

 LinkedList每次增加的时候，会new 一个Node对象来存新增加的元素，所以当数据量小的时候，这个时间并不明显，而ArrayList需要扩容，所以LinkedList的效率就会比较高，其中如果ArrayList出现不需要扩容的时候，那么ArrayList的效率应该是比LinkedList高的，当数据量很大的时候，new对象的时间大于扩容的时间，那么就会出现ArrayList'的效率比Linkedlist高了





## TreeSet  和  TreeMap 和  HashMap

TreeMap 内部是使用红黑树来实现



TreeMap 和  HashMap 不合适







阻塞： 是使用 synchronized  或者  lock实现的
非阻塞： 是使用内存操作 CAS 实现的  有点类似 自旋锁
自旋锁： CAS 会根据数据的偏移量来决定是否更新一个数据， 如果数据一样，那么就更新数据，如果不一样那就不更新数据。
HashMap 和 hashtable的区别  HashMap可以是null  HashTable不可以是null
HashTable 的阻塞 是使用 synchronized 来实现的



## HashMap 面试题总结

1. hashmap 是线程不安全的

```
并发情况下  可能在 transfer 时候出现成环现象，导致get的死循环。

并发问题：
若当前线程此时获得ertry节点，但是被线程中断无法继续执行，此时线程二进入transfer函数，并把函数顺利执行，此时新表中的某个位置有了节点，之后线程一获得执行权继续执行，因为并发transfer，所以两者都是扩容的同一个链表，当线程一执行到e.next = new table[i] 的时候，由于线程二之前数据迁移的原因导致此时new table[i] 上就有ertry存在，所以线程一执行的时候，会将next节点，设置为自己，导致自己互相使用next引用对方，因此产生链表，导致死循环。

解决问题：

使用synchronize ，或者使用collection.synchronizeXXX方法。或者使用concurrentHashmap来解决。
```

2. Hashmap 和 TreeMap
   HashMap通过Hashcode对其内容进行快速查找，而 TreeMap中所有的元素都保持着某种固定的顺序，如果你需要得到一个有序的结果你就应该使用TreeMap（HashMap中元素的排列顺序是不固定的）。


## ConcurrentHashMap

JDK 1.7 





## ArrayList 和 LinkedList的区别

 LinkedList每次增加的时候，会new 一个Node对象来存新增加的元素，所以当数据量小的时候，这个时间并不明显，而ArrayList需要扩容，所以LinkedList的效率就会比较高，其中如果ArrayList出现不需要扩容的时候，那么ArrayList的效率应该是比LinkedList高的，当数据量很大的时候，new对象的时间大于扩容的时间，那么就会出现ArrayList'的效率比Linkedlist高了





