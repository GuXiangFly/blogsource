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

#### zookeeper的节点类
- 持久（persistent）：客户端与服务器断开连接后，创建的节点不删除  
    持久中又有两种类型节点
    - 持久化目录节点
    -出九华顺序编号牡蛎节点
- 短暂（ephemeral）：客户端与服务器断开连接后，创建的节点自己删除


## 面试题
- zookeeper的部署方式有哪几种
    - （1）单机 集群
- 集群的角色有哪些
    - leader follower
- 集群中最少需要多少台机器
    - 3台

## zookeeper监听原理
1. 首先 有个main线程
2. 创建zkClient  在创建Zookeeper Client 的时候会有创建两个线程，一个负责网络连接（connet）
一个负责监听（listener）
3. 通过 connct线程将注册的监听事件发给zookeeper
4. zookeeper监听到数据或者路径有变化后，就会将消息发给 listener线程，线程内部会调用 process（）方法
![](https://i.loli.net/2019/11/03/1QhdgYV3KlrNLyS.png)


## zookeeper ZAB原子广播协议
- ZAB原子广播协议主要有两块
    - 广播模式（二阶段提交）
    - 恢复模式
    





![image-20201215155850788](https://gitee.com/guxiangfly/blogimage/raw/master/img/image-20201215155850788.png)

 假设有1,2,3三个服务器
![zookeeper集群示意图](https://i.loli.net/2019/11/11/Yq57jkirITHSEtd.png)

- 假设有客户端对 follower1 进行了写请求  
follower1是不能直接进行写请求的，它会内部把写请求发送给leader节点进行写处理  
leader节点进行write，要进行二阶段提交

### zookeeper write请求的处理过程
- 1. write请求（事务请求）进入leader节点的时候，会生成一个zxid（zookeeper事务Id），（唯一的,全局的,顺序的 ZXID）
- 2. leader节点会将这个 write请求 带着他的  zxid  通知给它的follower节点
- 3. follower节点被通知到这个 write请求后 会发送一个ack确认给leader节点
- 4. leader节点收到这个ack请求，会统计一下这个ack请求的数量。
- 5. 只要有半数以上的follower返回了ack确认，那么leader就会进行一下commit，并且通知他的follower也进行commit。

### 集群启动时的leader节点

![image-20201215160808488](https://gitee.com/guxiangfly/blogimage/raw/master/img/image-20201215160808488.png)

### 服务器运行时的leader选举

![image-20201215161355634](https://gitee.com/guxiangfly/blogimage/raw/master/img/image-20201215161355634.png)



## zookeeper假死和脑裂
- 什么是脑裂问题
- 