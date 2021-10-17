---

title: Redis面试
date: 2018-1-2 20:09:04
tags: [Redis]
---

### 什么是redis

> redis 是内存数据库，kv数据库，以及数据结构数据库

![image-20210207152014758](https://gitee.com/guxiangfly/blogimage/raw/master/img/image-20210207152014758.png)

### 如何理解redis？

操作redis，就想相当于操作 unordered_map

```c++
template class<T>
unordered_map<string,T>
  
unordered_map 采用的是hashtable的底层实现
  和  map 的
```

> T支持string，list，set，zset，hash

 ```C++

#include<unordered_map>
#include<unordered_set>
#include<set>
#include<string>
using namespace std;
 
//string
unordered_map<string, string> strings;
 
//list
unordered_map<string, list<string>> lists;
 
//set
unordered_map<string, unordered_set<string>> sets;
 
//zset
unordered_map<string, skiplist<string, string>> zsets;
 
//hash
unordered_map < string, unordered_map<string, string>  hashs;
 ```

> 要点：
>
> 1. redis中的字符串并非C结构中的字符串，它是一个二进制安全的字符串, 不会被特殊字符(\0) 隔断
>
> 2. map采用红黑树（平衡二叉搜索树）实现，而unordered_map 采用hash表；redis中的dict也是采用 hash表的方式存储的
>
> 3. 红黑树是有序的树结构，查找需要比较key，时间复杂度为 O(logn)；而hash表是无序的，查抄不需要比较key，应为通过hash函数生成整数，然后映射到数组当中，它的时间复杂度为o(1)
>
> 4. set一般是采用有序的结构来存储实现，因为集合中可能涉及到交集，并集，差集的运算（为何这些运算要求结构有序？）
>
> 5. skiplist是一个多层级的有序链表，并且方便进行范围查询；与B+树实现的功能类似，但是比B+效率高（这句话我个人认为有争议）
>
>    ![image-20210207232258797](https://gitee.com/guxiangfly/blogimage/raw/master/img/image-20210207232258797.png)



redis 的字符串类型是： SDS （simple dynamic  string）

原因：

- 不同语言的序列化问题
- 二进制安全

#### SDS (redis3.2 及其之前的实现方式)

```c
struct sdshdr {
    unsigned int len;
    unsigned int free;
    char buf[];
};
```

- char buf[] = "guxiang"  变成   "guxiang123"
  - addlen = 3     原来的len = 7     假设原来的free=0
  - 这种情况分配到字节大小 = （len + addlen）x 2 = （3+7）x2  = 20byte   （不过redis的成倍分配在大于1M后就每次只增加1M）
  -  变成    len = 10   free = 20-10 =10    （下次就不用频繁分配内存）

#### SDS（redis 6.0的实现方式）

```C
struct __attribute__ ((__packed__)) sdshdr5 {
    unsigned char flags; /* 3 lsb of type, and 5 msb of string length */
    char buf[];
};
struct __attribute__ ((__packed__)) sdshdr8 {
    uint8_t len; /* used */
    uint8_t alloc; /* excluding the header and null terminator */
    unsigned char flags; /* 3 lsb of type, 5 unused bits */
    char buf[];
};
struct __attribute__ ((__packed__)) sdshdr16 {
    uint16_t len; /* used */
    uint16_t alloc; /* excluding the header and null terminator */
    unsigned char flags; /* 3 lsb of type, 5 unused bits */
    char buf[];
};
```



sdshdr5 的内存记录

![image-20210220211059292](https://gitee.com/guxiangfly/blogimage/raw/master/img/image-20210220211059292.png)

sdshdr8 的内存记录

![image-20210220210952219](https://gitee.com/guxiangfly/blogimage/raw/master/img/image-20210220210952219.png)

#### redis的数据结构通用的3个结构特性

> 1. 二进制安全的数据结构
> 2. 提供内存预分配的能力，避免频繁的分配内存
> 3. 兼容C语言的函数库

### 如何操作redis

操作redis 是使用RESP协议, 通过发送命令，返回数据的方式操作我们的 unordered_map

```
redis采用cs结构模式，采用resp协议进行通信，客户通过请求响应来操作redis
client----------->server   redis unordered_map<string,T>  resp请求
client<---------- server   redis响应  resp响应
```





![image-20210207232236277](https://gitee.com/guxiangfly/blogimage/raw/master/img/image-20210207232236277.png)



### Redis的数据结构

redis由于是一个 kv 数据库。  对于kv, 其实redis的内部对应的结构是一个类似的hashmap

redis内部是一个hashmap，通过数组+链表（没使用红黑树） 来构建

redis的 rehash是一个渐进式的rehash.：



下图的对应数据结构，有相应的时间复杂度



如下图所示：redis有16个 redisDb，每个redisDb内部维护了一个 dict (也就是hashmap) 如下面代码。

dict中维护有两个dicht,用于实现渐进式rehash：当size和used到1：1的时候当扩展哈希表需要将 `ht[0]` 里面的所有键值对 rehash 到 `ht[1]` 里面， 但是， 这个 rehash 动作并不是一次性、集中式地完成的， 而是分多次、渐进式地完成的。

http://redisbook.com/preview/dict/incremental_rehashing.html

```c++
typedef struct redisDb {
    dict *dict;                 /* The keyspace for this DB */
    dict *expires;              /* Timeout of keys with a timeout set */
    dict *blocking_keys;        /* Keys with clients waiting for data (BLPOP)*/
    dict *ready_keys;           /* Blocked keys that received a PUSH */
    dict *watched_keys;         /* WATCHED keys for MULTI/EXEC CAS */
    int id;                     /* Database ID */
    long long avg_ttl;          /* Average TTL, just for stats */
    unsigned long expires_cursor; /* Cursor of the active expire cycle. */
    list *defrag_later;         /* List of key names to attempt to defrag one by one, gradually. */
} redisDb;
```

```C
typedef struct dict {
    dictType *type;
    void *privdata;
    dictht ht[2];
    long rehashidx; /* rehashing not in progress if rehashidx == -1 */
    unsigned long iterators; /* number of iterators currently running */
} dict;

typedef struct dictht {
    dictEntry **table;
    unsigned long size;
    unsigned long sizemask;
    unsigned long used;
} dictht;


typedef struct dictEntry {
    void *key;
    union {
        void *val;
        uint64_t u64;
        int64_t s64;
        double d;
    } v;
    struct dictEntry *next;
} dictEntry;


typedef struct redisObject {
    unsigned type:4;
    unsigned encoding:4;
    unsigned lru:LRU_BITS; /* LRU time (relative to global lru_clock) or
                            * LFU data (least significant 8 bits frequency
                            * and most significant 16 bits access time). */
    int refcount;
    void *ptr;
} robj;
```

![image-20210221155056824](https://gitee.com/guxiangfly/blogimage/raw/master/img/image-20210221155056824.png)

![image-20210220220606841](https://gitee.com/guxiangfly/blogimage/raw/master/img/image-20210220220606841.png)



Dict 有dict

![image-20210207232851838](https://gitee.com/guxiangfly/blogimage/raw/master/img/image-20210207232851838.png)



![image-20210221195229556](https://gitee.com/guxiangfly/blogimage/raw/master/img/image-20210221195229556.png)



### redis数据结构的存储规则

![image-20210207224056227](https://gitee.com/guxiangfly/blogimage/raw/master/img/image-20210207224056227.png)

dict 就是C语言中的 hashtable

### string结构的以及细节

![image-20210207233522229](https://gitee.com/guxiangfly/blogimage/raw/master/img/image-20210207233522229.png)

> 相当于操作： unordered_map<string,string>
>
> - 字符串长度小于等于20且能转为整数   -- int
> - 字符串长度大于44    raw
> -  字符长度小于44     embstr

<img src="https://gitee.com/guxiangfly/blogimage/raw/master/img/image-20210207233848739.png" alt="image-20210207233848739"  />



### list结构以及应用

 ![image-20210208012046235](https://gitee.com/guxiangfly/blogimage/raw/master/img/image-20210208012046235.png)



quicklist当中的节点存储的就是 压缩列表

![image-20210208014329695](https://gitee.com/guxiangfly/blogimage/raw/master/img/image-20210208014329695.png)

```
BRPOP key timeout  // 它是 RPOP的阻塞版本，因为这个命令会在给定list无法弹出任何元素的时候阻塞连接
```



- 阻塞队列

  ```
  LPUSH + BROPO
  或者
  RPUSH + BLPOP
  ```

  

- 百度测试



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





<img src="https://gitee.com/guxiangfly/blogimage/raw/master/img/image-20200927191957310.png" alt="image-20200927191957310" style="zoom:43%;" />

```java
    @GetMapping("/getUserById")
    public User getUserById(Integer id){
        //1.查询缓存中是否有数据,如果有数据就返回数据。
        User user = cacheHelper.get(String.valueOf(id));
        if (user!=null){
            return user;
        }

        //2.缓存中没有数据，就去db中查询
        User userInDdById = getUserInDdById(id);
        if (userInDdById!=null){
           //3.查询到数据并且存入DB，并且设置过期时间
            cacheHelper.setUserToCache(String.valueOf(id), user,30);
            return userInDdById;
        }
        return null;
    }

```

- 缓存穿透  
  - 描述：  缓存中没有，数据库中也没有 （既然穿透了，那么肯定是两层墙都被打穿了，缓存没有，mysql也没有）
    - 类似上述代码，如果 id查询为 111，但是数据库里面没有 id为111的，那么就产生了缓存穿透
  - 解决方法：  
    - 缓存空对象 (缺点：1.会占用大量内存,  2.数据过期后也会  )
    - 布隆过滤器
- 缓存击穿 
  - 描述： 缓存中没有，但是数据库中有。   （击穿，是只击穿一层墙， 那么就是缓存墙被击穿了，另一层墙mysql层没有被击穿）
    - 热点数据
    - 假设刚上新一个商品（热点数据）， 突然有10000个请求同时访问此产品， 第1个请求还没往redis缓存中存储进去， 第2到第10000个请求已经打到机器， 这样也会导致数据库宕机
  - 解决方法:
    - 热点数据不过期 或 错开时间过期
    - 加互斥锁：使用分布式锁，保证每个key只有一个线程去查询后端服务
- 缓存雪崩
  - 描述： 大量缓存数据过期不可用， 或者甚至缓存挂掉。
  - 解决办法：
    - 主从模式  集群模式
    - 双11停掉部分服务，保证主要的服务可用（比如双11停止退款服务）
    -  数据预热

##### 三个问题的解决代码

``` java

    @Autowired
    CacheHelper cacheHelper;

    @Autowired
    RedisLock redisLock;


    private static int size = 1000000;

    private static BloomFilter<Integer> bloomFilter = BloomFilter.create(Funnels.integerFunnel(), size, 0.0001);


    @GetMapping("/getUserById")
    public Result getUserById(Integer id) {

        // 布隆过滤器过滤 解决缓存穿透问题
        if (!bloomFilter.mightContain(id)) {
            return Result.error("无数据");
        }

        //查询缓存中是否有数据,如果有数据就返回数据。
        User user = cacheHelper.get(String.valueOf(id));
        if (user != null) {
            return Result.success(user);
        }

        // 使用分布式锁解决 缓存击穿问题
        redisLock.lock(String.valueOf(id));
        try {

            //查询缓存中是否有数据,如果有数据就返回数据。
            User user2 = cacheHelper.get(String.valueOf(id));
            if (user2 != null) {
                return Result.success(user2);
            }
            //2.缓存中没有数据，就去db中查询
            User userInDdById = getUserInDdById(id);
            if (userInDdById != null) {
                cacheHelper.setUserToCache(String.valueOf(id), user, 30);
                return Result.success(userInDdById);
            }
        }catch (Exception e){
            e.printStackTrace();
        }finally {
            redisLock.unLock(String.valueOf(id));
        }


        return Result.error("无数据");
    }
```





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

- Redis. worker    的id
- 

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







### Redis线程模型

![image-20201207221959145](https://gitee.com/guxiangfly/blogimage/raw/master/img/image-20201207221959145.png)



![image-20201210201333070](https://gitee.com/guxiangfly/blogimage/raw/master/img/image-20201210201333070.png)



Redis 内部使用文件事件处理器 `file event handler`


1. 当一个 Socket01 客户端发起一个请求和redis server 的连接，我们产生后

2. 测试







#### redis的日活统计方式

```shell
bitmap 范围 0~ (2^32-1)    bitmap 限制在512M以下

setbit/ getbit 
setbit   keyname   offset    value
setbit    login:2020:10:12    7    1       #(7是userid，用userid代为offset)
setbit    login:2020:10:13    7    1       #(7是userid，用userid代为offset)
setbit    login:2020:10:13    6    1       #(7是userid，用userid代为offset)

bitcount  login:2020:10:13      # 可以统计2020:10:13 的uv

bitop  and  result:12:13  login:2020:10:12  login:2020:10:13  #使用按位与的方式，统计连续登陆的用户
bitop  or  result:12:13  login:2020:10:12  login:2020:10:13  #使用按位或的方式，统计近几天有登陆的用户
```

![image-20210221185754046](https://gitee.com/guxiangfly/blogimage/raw/master/img/image-20210221185754046.png)







## Redis是单线程还是多线程

- redis 在 5.x 及其之前
  - redis 处理网络请求的主worker线程，是单线程的







## 面试点：

redis的 zset如何实现排序，增删改的速度









