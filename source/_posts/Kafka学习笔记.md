---


title: Kafka学习笔记
date: 2019-7-11 13:09:04
tags: [Kafka]

---

## Kafka的基础概念


### kafka工作流程

![image-20200518155036500](https://gitee.com/guxiangfly/blogimage/raw/master/img/image-20200518155036500.png)

kafka单独一个topic内，也会进行分区，kafka只能保证单独分区内，消息是有序的.





#### kafka的文件存储

视频连接 [https://www.bilibili.com/video/BV1a4411B7V9?p=12]

![image-20200518174054937](https://gitee.com/guxiangfly/blogimage/raw/master/img/image-20200518174054937.png)

.log文件存储的是kafka队列里面的数据

.index 记录的是kafka的某个consumer的

![image-20200518173852677](https://gitee.com/guxiangfly/blogimage/raw/master/img/image-20200518173852677.png)

![image-20200518174400952](https://gitee.com/guxiangfly/blogimage/raw/master/img/image-20200518174400952.png)

**.log 和 .index 都是以当前segment的第一条消息的offset命名的**。下图为 index和log文件的结构示意图

> .index 文件存储大量的索引信息，  .log文件存储大量的数据信息

![image-20200518191544556](https://gitee.com/guxiangfly/blogimage/raw/master/img/image-20200518191544556.png)



##### kafka分区的原因

- **方便在集群中拓展**，每个partition可以通过调整适应它所在的机器，而一个topic又可以有多个partition组成，因此可以适应任意大小的数据。
- **可以提高并发**， 因为可以以partation为单位读写。







![](https://i.loli.net/2019/11/05/WpMfsVAKSUR4Hij.png)

- 1、Producer ：消息生产者，就是向kafka broker发消息的客户端；
- 2、Consumer ：消息消费者，向kafka broker取消息的客户端；
- 3、Consumer Group （CG）：**消费者组，由多个consumer组成。消费者组内每个消费者负责消费不同分区的数据，一个分区只能由一个消费者消费；消费者组之间互不影响。所有的消费者都属于某个消费者组，即消费者组是逻辑上的一个订阅者。**
- 4、Broker ：一台kafka服务器就是一个broker。一个集群由多个broker组成。一个broker可以容纳多个topic。
- 5、Topic ：可以理解为一个队列，生产者和消费者面向的都是一个topic；
- 6、Partition：为了实现扩展性，一个非常大的topic可以分布到多个broker（即服务器）上，一个topic可以分为多个partition，每个partition是一个有序的队列；
- 7、Replica：副本，为保证集群中的某个节点发生故障时，该节点上的partition数据不丢失，且kafka仍然能够继续工作，kafka提供了副本机制，一个topic的每个分区都有若干个副本，一个leader和若干个follower。
- 8、leader：每个分区多个副本的“主”，生产者发送数据的对象，以及消费者消费数据的对象都是leader。
- 9、follower：每个分区多个副本中的“从”，实时从leader中同步数据，保持和leader数据的同步。leader发生故障时，某个follower会成为新的follower。



同一个 Consumer Group 里的 consumer 不能消费同一个topic的同一个partition

也就是说，在一个Consumer Group内， TopicA 的 Partition X  只能被一个 consumer消费

可以这么消费

===================================

Topic A 有  TopicA-partition1， TopicA-partition2， TopicA-partition3

Topic B 有  TopicB-partition1， TopicB-partition2， TopicB-partition3

一个consumer group下

GroupA-Consumer1 消费 TopicA-partition1 ， TopicA-partition2 ，TopicB-partition1，TopicB-partition2

GroupA-Consumer2 消费 TopicA-partition3 ， TopicB-partition3=

====================================






## ISR 的概念





## 需要修改的kafka server.properties
```
修改配置文件
[atguigu@hadoop102 kafka]$ cd config/
[atguigu@hadoop102 config]$ vi server.properties
输入以下内容：
#broker的全局唯一编号，不能重复
broker.id=0
#删除topic功能使能
delete.topic.enable=true
#处理网络请求的线程数量
num.network.threads=3
#用来处理磁盘IO的现成数量
num.io.threads=8
#发送套接字的缓冲区大小
socket.send.buffer.bytes=102400
#接收套接字的缓冲区大小
socket.receive.buffer.bytes=102400
#请求套接字的缓冲区大小
socket.request.max.bytes=104857600
#kafka运行日志存放的路径	
log.dirs=/opt/module/kafka/logs
#topic在当前broker上的分区个数
num.partitions=1
#用来恢复和清理data下数据的线程数量
num.recovery.threads.per.data.dir=1
#segment文件保留的最长时间，超时将被删除
log.retention.hours=168
#配置连接Zookeeper集群地址
zookeeper.connect=hadoop102:2181,hadoop103:2181,hadoop104:2181
```


## Kafka创建 topic的流程
```
kafka进行
```

## Kafka常用命令

- kafka启动

```bash
bin/kafka-server-start.sh -daemon config/server.properties

# 在使用 kafka manager的时候 可能需要指定JMX端口
JMX=9988 bin/kafka-server-start.sh -daemon config/server.properties
```

#### kafka 相关内容创建

```
 --topic 定义topic名
 --replication-factor  定义副本数
 --partitions  定义分区数
```

- 创建Topic
```
bin/kafka-topics.sh --zookeeper hadoop101:2181 --create --replication-factor 1 --partitions 1 --topic first
```
- 列出 topic
```
bin/kafka-topics.sh --zookeeper hadoop101:2181 --list
```
- 查看topic详情
```
bin/kafka-topics.sh --zookeeper hadoop101:2181 --describe --topic first
```
- 查看topic的消息内容
```
bin/kafka-console-consumer.sh  --zookeeper hadoop101:2181  --topic first --from-beginning
```

- 删除topic
```
bin/kafka-topics.sh --zookeeper hadoop102:2181 --delete --topic first
```
- 生产者生产topic
```bash

```

- Kafka创建消费者

```bash
bin/kafka-console-consumer.sh --bootstrap-server hadoop101:9092 --from-beginning --topic first
```

- Kafka 生产消费者

```

```

## Kafka 分区数只能增加不能减少


## ISR 的概念
ISR 是和leader保持同步的follower



## kafka monitor

- Kafka monitor 启动命令

  ```
  java -cp KafkaOffsetMonitor-assembly-0.4.6-SNAPSHOT.jar \
  com.quantifind.kafka.offsetapp.OffsetGetterWeb \
  --offsetStorage kafka \
  --kafkaBrokers hadoop101:9092 \
  --kafkaSecurityProtocol PLAINTEXT \
  --zk hadoop101:2181 \
  --port 8086 \
  --refresh 10.seconds \
  --retain 2.days \
  --dbName offsetapp_kafka &
  ```

  

![](https://i.loli.net/2019/12/10/6RB9HxuMOhsdbz2.png)

- commitedOffSet 表示 消费者消费掉的消息数量
- LogEndOffset     表示  生产者生产出来的消息数量
- Lag    表示 滞后的数量

![](https://i.loli.net/2019/12/10/C7k2pbK1OJfWYAI.png)



## kafka manager 使用

- 启动命令

```bash
bin/kafka-manager
```

- 