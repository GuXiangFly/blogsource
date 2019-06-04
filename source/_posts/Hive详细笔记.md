---
title: Hive 学习笔记
date: 2018-8-27 20:09:04
tags: [大数据]

---

HDFS 适合于 一次写入 多次读取

数据是存储在 RegionServer中 

RegionServer内部有一个  HLog    有一个叫做 WAL 的技术（write  ahead  log  WAL） namenode  是丢了就丢了 但是数据库中不能这么干

HLog 先在本地写  写完HLog后 会将 Hlog存储到 HDFS上 (Hlog 所存储的不仅仅是数据本身  他存储的是 数据库应该做 还没有做的操作  Hlog 写入成功  会写入到 Memory store  如果 Menory Store 成功了，那么我们会将 Mem Store数据生成   就写入  region 中并且会删除 Hlog和Memory Store 的数据， 仅将数据存储在 Region 中  但是值得注意的是  region是存储在 HDFS 上的  HDFS 一般会有3份备份， )

![](https://raw.githubusercontent.com/GuXiangFly/imagerepo/master/20181223204551.png)


RDBMS 和  Hbase 的对比

RDBMS 是支持向上扩展 （我们有一个4g内存 不够用了 买一个8g内存 换上去 就变成8g 这个是向上扩展）

Hbase 是横向扩展的 （）


Hbase 数据类型 全部是Bit

运行java jar 包
```
cp: 是 classpath 的简称
java -cp  xxx.jar;bbb.jar   com.guxiangfly.Maina
```
给student  y为 1001 的 列族为 info 的 列名 添加value 为Thomas
![](https://raw.githubusercontent.com/GuXiangFly/imagerepo/master/20181224023721.png)


## 数据倾斜
数据倾斜，就是在进行MapReduce 时候 ，某一个 reducer过大 导致整个 MR 程序执行过慢
在hive中 我们会将空key 给一个随机数 让它 执行 “空” 这个字段reducer 的时候  不要过多