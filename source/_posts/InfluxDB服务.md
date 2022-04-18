``` java

```



![image-20220301114605288](https://gitee.com/guxiangfly/blogimage/raw/master/img/image-20220301114605288.png)



## RP （数据保留策略）

RP（Retention Policy）是数据库级别

​	   也就是说整个数据库的过期时间是一致的

- shardGroup（一个逻辑上的概念）：
  - 每个shardGroup 只存储对应时间段的数据。不同的shardGroup对应的时间段不会重合。
  - influxDB中数据过期删除的粒度是 shardGroup
  - 可以有效根据时间粒度选择时间分区

- Shard:
  - ShardGroup是一个逻辑上的概念，shard是真正存储数据的



<img src="/Users/didi/Library/Application Support/typora-user-images/image-20220301122658764.png" alt="image-20220301122658764" style="zoom:50%;" />

