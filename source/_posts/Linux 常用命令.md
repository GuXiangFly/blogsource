---
title: Linux 常用命令
date: 2017-6-11 13:19:04
tags: [Linux]

---

# Linux 开发常用命令

----
## 端口以及杀进程
### lsof -i:端口号
查看端口是否被占用
lsof（list open files）

---------
## redis
进入redis 的bin目录 
### ./redis-server  ./redis/conf
打开redis服务器
### ./redis-cli -p 6379
打开redis客户端
### SHOUTDOWN 
在客户端中写shutdown用以关闭redis的服务
---

## 文件上传下载
### yum install lrzsz
### sz filename：将选定的文件发送（send）到本地机器
### rz：从服务器下载

------

## zookeeper

###  开启 ./zkServer.sh start
###  关闭 ./zkServer.sh stop
###  查看状态 ./zkServer.sh status
如果不能成功启动zookeeper，需要删除data目录下的zookeeper_server.pid文件。
 
----

## 关闭防火墙
### service iptables stop
### chkconfig iptables off
永久关闭修改配置开机不启动防火墙


## VIM常用命令
### : set nu  用于显示行数

## linux中下载外网东西
wget http://sdfsfaf.zip    (随便一个url 它会进行爬虫)


## linux中一些文件的路径  


### centos6  yum源 .repo 文件路径
```
cd /etc/yum.repos.d/ 
```


## 解决tomcat unknown hostname 与 activemq jetty 503
```
vim /etc/hosts  里面添加 当前的 hostname
```
