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
插入在头部， 如果插入在链表尾部 那么还需要遍历一下链表，浪费时间
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


# ConcurrentHashMap 面试
 视频教程地址 [https://www.bilibili.com/video/av69066235?from=search&seid=9719965469283553311]
## ConcurrentHashMap默认长度为16  默认的并发等级是16 可以自己指定

## segment是一个 可重入锁 ReentrantLock
