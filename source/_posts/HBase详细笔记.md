---
title: Hbase 学习笔记
date: 2018-2-27 20:09:04
tags: [大数据]

---

数据是存储在 RegionServer中 

RegionServer内部有一个  HLog    有一个叫做 WAL 的技术（write  ahead  log  WAL） namenode  是丢了就丢了 但是数据库中不能这么干

整体 HLog 记录在 HDFS 上