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


## Zookeeper面试

Zookeeeper = 文件系统+监听通知机制

客户端注册监听它所关心的节点，当目录节点发生变化的时候（数据改变，被删除，增加）zookeeper会通知所有注册了监听它的客户端。

但是值得注意的是 zookeeper不会把节点改变的数据传回给客户端
1.一方面是节约资源，
2.另一方面是不一定需要。
3. Zookeeper有着非常多的连接，担任非常重要的工作 绝对不能挂掉



### zookeeper的集群
 zookeeper集群选举后， 只有leader能执行 write命令， 其他 leader follower 都能执行 read 操作
  但是 如果 follower接受到一个 write 操作 write操作发给 leader 
   leader 会生成一个 唯一的 全局的 顺序的 zxid（zookeeper transaction id） 
   带着这个zxid 和 write操作 向 所有follower都发一份，然后让其他follower都发一个确认 有半数以上都ack后 就 leader会执行 commit操作 并且通知其他follower也进行 commit操作。  主要是为了保证数据一致性
zookeeper功能

### zookeeper 集群leader选举原理
 如果 原有leader挂了  每个follower都会 投出自己的（myid，zxid） 给其他的节点。 zookeeper底层没有用 paxOS算法使用的ZAB原子广播协议
 首先比较 zxid 哪个大 如果B zxid大 那么 A 会跟新自己的zxid 并且把票投给 B ，如果zxid一样大 那么选 myid大的那个投
![](https://raw.githubusercontent.com/GuXiangFly/imagerepo/master/img20181121010846.png)
1. 分布式配置中心
2. 实现服务的注册与发现


如果遇到缓存雪崩





zookeeper的角色

![image-20201215155702091](https://gitee.com/guxiangfly/blogimage/raw/master/img/image-20201215155702091.png)