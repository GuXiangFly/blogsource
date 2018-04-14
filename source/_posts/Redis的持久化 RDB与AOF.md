---
title: 在分布式数据库中CAP原理CAP+BASE
date: 2017-6-21 13:09:04
tags: [redis,分布式]

---

# 在分布式数据库中CAP原理CAP+BASE
---



## Redis的 RDB

### RDB是什么
RDB是整个内存压缩过的SnapShot，RDB 的数据结构，可以配置复合的快照触发条件。  
设置的格式为  
```
 save <seconds> <changes>
默认有以下
save 900 1
save 30 10
save 60 10000

 save "" 这个为关闭RDB的触发
```
```
################################ SNAPSHOTTING  ################################
#
#   Save the DB on disk:
#
#   save <seconds> <changes>
#
#   Will save the DB if both the given number of seconds and the given
#   number of write operations against the DB occurred.
#
#   In the example below the behaviour will be to save:
#   after 900 sec (15 min) if at least 1 key changed
#   after 300 sec (5 min) if at least 10 keys changed
#   after 60 sec if at least 10000 keys changed
#
#   Note: you can disable saving completely by commenting out all "save" lines.
#
#   It is also possible to remove all the previously configured save
#   points by adding a save directive with a single empty string argument
#   like in the following example:
#
#   save ""

save 900 1
save 30 10
save 60 10000

```

### fork
fork的作用是复制一个与当前进程一样的进程。新进程的所有数据（变量、环境变量、程序计数器等）
数值都和原进程一致，但是是一个全新的进程，并作为原进程的子进程

fork由于会复制一份文件 所以有时会导致内存不足
### Redis的持久化操作
Redis会单独创建（fork）一个子进程来进行持久化，会先将数据写入到
一个临时文件中，待持久化过程都结束了，再用这个临时文件替换上次持久化好的文件。
整个过程中，主进程是不进行任何IO操作的，这就确保了极高的性能
如果需要进行大规模数据的恢复，且对于数据恢复的完整性不是非常敏感，那RDB方式要比AOF方式更加的高效。RDB的缺点是最后一次持久化后的数据可能丢失。

---

## Redis的AOF
##### 在持久化恢复的时候，appendonly.aof 会优先于 dump.rdb加载，如果appendonly.aof 内部有破坏，那么redis是起不来的。

我们可以通过以下命令，完成AOF的语法纠错
```
redis-check-aof  --fix appendonly.aof
```

出厂默认设置是每秒都能记录