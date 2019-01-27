---
title: Redis 学习笔记
date: 2018-9-11 13:19:04
tags: [redis]

---
# redis 常用命令

Redis的基本数据类型
- String 最大能存储512M
- Hash  （hmset  hget）
- List
- Zset
- Set
- HyperLogLog 存储日志  Geo 存地理位置信息



## Redis单线程为何这么快
一般可以支持 100000+ QPS （query per second，每秒内查询次数）
- 完全基于内存，绝大部分请求是单纯的内存操作，执行效率高
- 数据结构简单，数据操作简单（没有类似外键这种约束）
- Redis的单线程 指的是它的主线程是单线程的， 多个客户端对Redis处理 避免了上下文的切换和锁的竞争
  （不过值得注意的是 一个Redis server 并不是单进程单线程的 Redis在持久化的时候，会根据不同的业务情况以子进程或者子线程的方式 来进行持久化 ）
- Redis使用了 IO多路复用 （在不同编译环境操作系统中 会使用不同的多路复用函数 epoll/kqueue/evport/select  默认会优先使用复杂度为O（1）级别的多路复用函数  select 是 O（n）多数操作系统都是支持select的）

FD: file descripte


## 如何使用redis使用分布式锁

