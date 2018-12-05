---
title: Zookeeper使用教程
date: 2017-11-1 13:22:54
tags: [MongoDB,java]

---
Zookeeper使用教程
======

开启服务器：
```
bin/zkServer.sh start

如果遇见 already running as process 去 zoo.cfg配置的 data目录 删除zookeeper_server.pid 文件

./zkServer status 可以查看状态
```

使用zkCli 连接Server
```
bin/zkCli.sh

help命令查看 用法

使用 create命令创建

create /app1/server01 "192.168.25.1xx,123"

格式
create  /znode路径      【数据】

使用get命令取得数据

get /znode路径

```
![mark](http://p5uenqci6.bkt.clouddn.com/blog/180323/a358iLgm3F.png?imageslim)

下面显示Znode的数据的详细信息   cZxid 是 create 创建  mZxid是 modify 修改  用于事务控制

![mark](http://p5uenqci6.bkt.clouddn.com/blog/180323/C0eBAkg87g.png?imageslim)

#### Znode有两种类型：
- 短暂（ephemeral）（断开连接自己删除）
- 持久（persistent）（断开连接不删除）
#### Znode有四种形式的目录节点（默认是persistent ）
- PERSISTENT
- PERSISTENT_SEQUENTIAL（持久序列/test0000000019 ）
- EPHEMERAL
- EPHEMERAL_SEQUENTIAL


创建 ephemeral（朝生暮死的  客户端与zookeeper的连接断开ephemeral类型的znode就自动删除）
```
create -e  /app-ephemeral  "这边填写数据"
```


#### 监听节点
```
 get /app1/server01  watch
 这个节点如果值被修改了，那么会报出如下的信息

 #WATCHER::
 #WatchedEvent state:SyncConnected type:NodeDataChanged path:/zk

注意： 这个信息只会报出一次 第二次修改 watch监听就失效了

还有一种节点监听
ls /app1 watch

ls 是监听子节点
这样 如果是子节点发生变化，那么也会响应事件
```
