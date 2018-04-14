---
title: redis 常用命令
date: 2017-6-11 13:19:04
tags: [redis]

---
# redis 常用命令


redis 命令支持自动补全

### 查看所有数据个数
    dbsize
### 查看所有数据
	keys *
### 删除所有数据（单个库）
	flushdb
### 删除所有库的数据（16个库）
	flushall
### 切换库
	select 7 (这个7是角标，默认共有0-15 一个16个)
### 递增操作
    set k2  2
	incr k2  (每次加一)
	incrby k2 2 (后面的可以指定增加的步长)
### 递减操作
	decr （同 incr）
### getrange 操作
    set k2 ab12345
	
	getrange k2 0 2  (获取角标0-2 返回为 ab1)

### redis的回应
	起效为 1 或者 非空 或 OK
	不起效为 0
	错误为报异常
###  setex(set with expire)键秒值
 	setex:设置带过期时间的key，动态设置。
	setex k1 15 hello  (设置k1的过期时间为15秒 值为hello)
### setnx(set if not exist)

## list的命令
### RpopLpush 命令
	rpoplpush list2 list1


```
	list2			list1
 q w e r          1 2 3 4 5

	rpoplpush list2 list1 后

 q w e  		r 1 2 3 4 5
就是将list2 最right方出一个 
进入 list1 的 最 left 方
```

## hash的命令
### hkeys hgetall命令  查看hash内所有列表
```
hset hash1 field1 1
hset hash1 field2 2
hset hash1 field3 3

## 使用hkeys
101.132.177.62:6379> hkeys hash1
1) "field"
2) "field2"
3) "field3"

## 使用hvals
101.132.177.62:6379> hvals hash1
1) "1"
2) "2"
3) "3"
101.132.177.62:6379>

## 使用hgetall
101.132.177.62:6379> hgetall hash1
1) "field"
2) "1"
3) "field2"
4) "2"
5) "field3"
6) "3"
101.132.177.62:6379>
101.132.177.62:6379>
```



redis 的基本类型



## Redis五种数据类型
### String：key-value（做缓存）
Redis中所有的数据都是字符串。命令不区分大小写，key是区分大小写的。Redis是单线程的。Redis中不适合保存内容大的数据。
- get、set、
- incr：加一（生成id）
- Decr：减一

### Hash：key-fields-values（做缓存）
相当于一个key对于一个map，map中还有key-value
使用hash对key进行归类。
- Hset：向hash中添加内容
- Hget：从hash中取内容

### List：有顺序可重复
```
192.168.25.153:6379> lpush list1 a b c d
(integer) 4
192.168.25.153:6379> lrange list1 0 -1
1) "d"
2) "c"
3) "b"
4) "a"
192.168.25.153:6379> rpush list1 1 2 3 4
(integer) 8
192.168.25.153:6379> lrange list1 0 -1
1) "d"
2) "c"
3) "b"
4) "a"
5) "1"
6) "2"
7) "3"
8) "4"
192.168.25.153:6379> 
192.168.25.153:6379> lpop list1 
"d"
192.168.25.153:6379> lrange list1 0 -1
1) "c"
2) "b"
3) "a"
4) "1"
5) "2"
6) "3"
7) "4"
192.168.25.153:6379> rpop list1
"4"
192.168.25.153:6379> lrange list1 0 -1
1) "c"
2) "b"
3) "a"
4) "1"
5) "2"
6) "3"
192.168.25.153:6379> 
```
### Set：元素无顺序，不能重复
```
192.168.25.153:6379> sadd set1 a b c c c d
(integer) 4
192.168.25.153:6379> smembers set1
1) "b"
2) "c"
3) "d"
4) "a"
192.168.25.153:6379> srem set1 a
(integer) 1
192.168.25.153:6379> smembers set1
1) "b"
2) "c"
3) "d"
192.168.25.153:6379> 
还有集合运算命令，自学。
```

## SortedSet（zset）：有顺序，不能重复
```
192.168.25.153:6379> zadd zset1 2 a 5 b 1 c 6 d
(integer) 4
192.168.25.153:6379> zrange zset1 0 -1
1) "c"
2) "a"
3) "b"
4) "d"
192.168.25.153:6379> zrem zset1 a
(integer) 1
192.168.25.153:6379> zrange zset1 0 -1
1) "c"
2) "b"
3) "d"
192.168.25.153:6379> zrevrange zset1 0 -1
1) "d"
2) "b"
3) "c"
192.168.25.153:6379> zrange zset1 0 -1 withscores
1) "c"
2) "1"
3) "b"
4) "5"
5) "d"
6) "6"
192.168.25.153:6379> zrevrange zset1 0 -1 withscores
1) "d"
2) "6"
3) "b"
4) "5"
5) "c"
6) "1"
192.168.25.153:6379> 
```
## Key命令
设置key的过期时间。
- Expire key second：设置key的过期时间
- Ttl key：查看key的有效期  -1 永久保存  -2 不存在
- Persist key：清除key的过期时间。Key持久化。

192.168.25.153:6379> expire Hello 100
(integer) 1
192.168.25.153:6379> ttl Hello
(integer) 77
