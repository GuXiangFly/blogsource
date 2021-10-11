---

title: ClickHouse学习
date: 2017-10-27 20:09:04
tags: [ElasticSearch]

---


clickhouse环境设置
```
在 hadoop102 的 /etc/security/limits.conf 与  vim /etc/security/limits.d/20-nproc.conf
文件的末尾加入以下内容
[atguigu@hadoop102 ~]$ sudo vim /etc/security/limits.conf
* soft nofile 65536
* hard nofile 65536
* soft nproc 131072
* hard nproc 131072

有时候 /etc/security/limits.conf 这个文件 /etc/security/limits.d/20-nproc.conf 会被这个文件所覆盖
所以两个都需要配置
```
nofile 是 number of file  ： 表示最大文件数
nproc  是 number  process  ：表示最大进程数
由于clickhouse需要存储巨大的文件，并且需要为了最大程度发挥硬件性能，并计算需要配置最大进程数


由于使用 rpm安装目录情况
```
bin/    -----> /usr/bin/
conf/    -----> /etc/clickhouse-server/
lib/    -----> /var/lib/clickhouse
log/    -----> /var/log/clickhouse
```