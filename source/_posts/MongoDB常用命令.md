---
title: MongoDB常用命令.md
date: 2017-11-1 13:22:54
tags: [MongoDB,java]

---
MongoDB常用命令
======

开启服务器：
```
mongod -f mongod.cfg
```

开启链接:
```
mongo localhost:27017  (默认是 localhost:27017 可以不加)
```

### 说明
MongoDB命令是区分大小写的，使用的命名规则是驼峰命名法。
对于database和collection无需主动创建，在插入数据时，如果database和collection不存在则会自动创建(这个原因是由于mongodb的语法是由JS引擎去解析的，使用JS引擎解析操作，没有的东西就会自动添加)。

use 命令
```
【use demodb】，创建demodb，不用担心demodb不会创建，当使用use demodb
命令创建第一个collection时会自动创建数据库demodb
```



### 查看当前在哪个数据库
```
db
```

### Mongod 参数说明
```
mongodb的参数说明：
--dbpath    数据库路径(数据文件)
--logpath   日志文件路径
--master    指定为主机器
--slave     指定为从机器
--source    指定主机器的IP地址
--pologSize 指定日志文件大小不超过64M.因为resync是非常操作量大且耗时，最好通过设置一个足够大的oplogSize来避免resync(默认的 oplog大小是空闲磁盘大小的5%)。
--logappend 日志文件末尾添加
--port      启用端口号
--fork      在后台运行
--only      指定只复制哪一个数据库
--slavedelay 指从复制检测的时间间隔
--auth       是否需要验证权限登录(用户名和密码)

-f          通过配置文件启动
```

### MongoDB的启动
```
mongod --dbpath=D:\serversoftware\MongoDBpath (--fork 代表后台启动)

也可以通过配置文件启动
mongod -f D:\mongodb\conf\mongo.conf
```


###  备份和还原不能在原本的mongodb的命令行中写
![mark](http://p5uenqci6.bkt.clouddn.com/blog/180319/K6ffj3AfdA.png)

### 将原本有的数据备份到备份目录
```
mongodump -h localhost:27017 -d local -o d://serversoftware//MongoDBpathBeifeng

(local) 是一个数据库名称
```

### 将备份的数据还原
```
mongorestore -h localhost:27017 -d local2 -directoryperdb d://serversoftware//MongoDBpathBeifeng//test
```

### 将集合的数据导出
```
mongoexport -h dbhost -d dbname -c collectionName -o output

 mongoexport -h localhost:27017 -d test -c c1 -o d://serversoftware//MongoDBpathBeifeng/c1.txt

 -o 意思为 output
 文件如果不存在 会自动创建
```

### 将集合的json数据导入
```
 mongoimport -h localhost:27017 -d test -c c3 d://serversoftware//MongoDBpathBeifeng/c1.txt

```

### 主从复制操作
```
主操作
 mongod --dbpath=D:\serversoftware\MongoDBmaster --port 10001 --master

从操作
 mongod --dbpath=D:\serversoftware\MongoDBslave --port 10002 --slave  --source 127.0.0.1:10001
```


### 副本集配置
```
启动节点1：
mongod --dbpath D:\mongodb\dbs\node1 --logpath D:\mongodb\logs\node1\logs.txt --logappend --port 10001 --replSet guxiangreplset/localhost:10002  --master


```


### 分布式集群
```
普通节点（存放配置信息）
mongod --dbpath=D:\serversoftware\MongoDBDistributed\mongoconfigdb
--port 2222

路由进程 mongos
mongos --port 3333 --configdb=127.0.0.1:2222

(分布式节点)
mongod --dbpath=D:\serversoftware\MongoDBDistributed\node4444 --port 4444

mongod --dbpath=D:\serversoftware\MongoDBDistributed\node5555 --port 5555

mongod --dbpath=D:\serversoftware\MongoDBDistributed\node6666 --port 6666



登录路由节点的admin进入数据库 （在分布式存储中，都是对）
mongo 127.0.0.1:3333/admin

db.runCommand({"addshard":"127.0.0.1:4444","allowLocal":true})

db.runCommand({"addshard":"127.0.0.1:5555","allowLocal":true})

db.runCommand({"addshard":"127.0.0.1:6666","allowLocal":true})

将每个node下的test 数据库 进行分片存储
db.runCommand({"enablesharding":"test"})

test 数据库下的 person集合  将会以 age字段的大小 作为分片的依据
db.runCommand({"shardcollection":"test.person","key":{"age":1}})

for(var i=1;i<=10000000;i++){
    db.person.insert({age:i,name:"guxiang"})
}
```


### 使用JAVA代码对MongoDB进行增删改查
```java
    public void testAdd() throws Exception{
        Mongo mongo = new Mongo("127.0.0.1", 5555);
        DB db = mongo.getDB("test");
        DBCollection person2 = db.getCollection("person2");

        DBObject dbObject = new BasicDBObject();

        dbObject.put("name","guxiang");
        dbObject.put("desc","单身dog");
        person2.insert(dbObject);
    }

    public void testFind() throws Exception{
        Mongo mongo = new Mongo("127.0.0.1", 5555);
        DB db = mongo.getDB("test");
        DBCollection person2 = db.getCollection("person2");
        DBCursor cursor = person2.find();
        while (cursor.hasNext()){
            DBObject dbObject = cursor.next();
            System.out.println(dbObject.toString());
            System.out.println(dbObject.get("name"));
        }
    }
```


### 让MongoDB随着计算机的启动而启动
```
vim /etc/rc.local
在这个文件下添加一行
mongod --dbpath=D:\serversoftware\MongoDBpath  --fork
```

### MongoDB的结束
```
一定要使用
pkill mongod 或者
killall mongod

不能使用
kill -9  进程号
这会导致mongod无法启动
如果无法启动mongod，就将data目录下的 mongod.lock 文件删除 这个lock文件是将进程锁住了
```

