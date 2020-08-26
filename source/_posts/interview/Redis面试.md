---
title: Redis面试
date: 2018-1-2 20:09:04
tags: [Redis]
---

## Redis 数据结构
- string
- hash
- set
- list  
- zset （排序的set）

### string类型
```
- 单值操作
    set key value
    DD

- 分布式锁
    SETNX（set if not exsit）的原理：只有在 key为空的时候  才会设置value成功，若键 key 已经存在， 则 SETNX 命令不做任何动作。
    SETNX product:1001 true     //返回1代表获取锁成功
    SETNX product:1001 true     //返回0代表获取锁失败 （第二次操作就会获取锁失败）
    执行业务操作
    DEL product:1001            //删除锁
    SET product:1001 true ex 10 nx
```
### Hash类型
```
Hash 操作
模板：hset  key  field  value
```

### list类型
```
用处：实现常用的数据结构
Stack(栈) = LPUSH + LPOP
Queue(队列) = LPUSH + RPOP
Blocking MQ(阻塞队列) = LPUSH + BRPOP 
阻塞队列的意思： 如果队列为空并且还需要执行 POP操作 那么阻塞队列就会一直等待，（可以加超时时间） 
阻塞队列可以实现 消息队列的 订阅监听
1.A订阅了公众号 X1
2.B订阅了公众号 X1
X1发公众号的时候 会一个个往 A和B的消息的队列中 放入公众号
```

### Set类型
set的运用场景 抽奖
```
将所有抽奖名单加入set 
sadd key  userID

- 添加操作
sadd activity:10001  xiaoming
sadd activity:10001  xiaogang1 
sadd activity:10001  xiaoming2

查看所有的抽奖用户
smembers activity:10001

抽取 2位中奖者
srandmember activity:10001  2

```




![](https://i.loli.net/2019/11/02/yP3W6A2kaE5NpFD.png)


## Redis 缓存
![](https://i.loli.net/2019/11/02/GrwTpmRlUiHDMkq.png)
- Redis更新方式
    - 同步更新 
    - 异步更新
    - 定时更新
    - 失效更新
- 缓存穿透
    - 恶意攻击（可以使用布隆过滤器进行过滤）
    
    
### Redis缓存穿透布隆过滤器
为了应对缓存穿透的问题，我们可以采用布隆过滤器
布隆过滤器的原则: 如果这些点有任何一个0，则被检元素一定不在；如果都是1，则被检元素很可能在。
也就是说:如果被布隆过滤器检测不存在的元素，那么这个元素一定不存在，如果被检测元素布隆过滤器检测存在，那么被检测元素可能存在可能不存在。



### 为什么Redis那么快
- 完全基于内存
- 数据结构简单，对数据操作也简单
- 采用单线程，单线程也能处理高并发请求
- 采用IO多路复用，非阻塞IO

### Redis多路I/O复用模型



### Redis大量Key同时过期的注意事项
- 在设置key过期时间的时候，给每个时间加上随机值，同时删除大量key会产生卡顿
- 

### Redis 事务
redis通过 multi命令开启事务
通过  exec命令 执行事务
通过  discard命令 不执行事务

redis事务的特点

- redis的事务 





#### Bitmaps

```
## 设置bit，将0位 改为1
setBit  bits  0  1    

## 获取0位上的值
getBit bits 0

## 获取10位上的值 （如果10这个位没有被初始值，那么10位上返回默认值0）
getbit bits  10

## 设置10000000这个位上的值为1 （这样如果10000000 前面9999999个值没有设置过，需要补0，实际存储的是00000000000000000000000000.....0001） （比较耗时）

setbit bits 10000000  1 
```

