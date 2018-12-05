---
title: ConcurrentHashMap and hashmap
date: 2018-2-27 20:09:04
tags: [Activiti]

---

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


## ArrayList 和 LinkedList的区别

 LinkedList每次增加的时候，会new 一个Node对象来存新增加的元素，所以当数据量小的时候，这个时间并不明显，而ArrayList需要扩容，所以LinkedList的效率就会比较高，其中如果ArrayList出现不需要扩容的时候，那么ArrayList的效率应该是比LinkedList高的，当数据量很大的时候，new对象的时间大于扩容的时间，那么就会出现ArrayList'的效率比Linkedlist高了
