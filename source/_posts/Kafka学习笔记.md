---


title: Kafka学习笔记
date: 2019-7-11 13:09:04
tags: [Kafka]

---

## Kafka的基础概念


### kafka工作流程

![image-20200518155036500](https://gitee.com/guxiangfly/blogimage/raw/master/img/image-20200518155036500.png)

kafka单独一个topic内，也会进行分区，kafka只能保证单独分区内，消息是有序的.



 ![image-20200914164905228](https://gitee.com/guxiangfly/blogimage/raw/master/img/image-20200914164905228.png)

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









# 面试题专区

## Kafka生产者写数据流程

![image-20201121162444033](https://gitee.com/guxiangfly/blogimage/raw/master/img/image-20201121162444033.png)





注：broker是kafka集群    ，生产者是程序员自己写的java代码

1. java代码中发出消息，先进行封装
2. 封装后进行代码的序列化
3. 第三步对消息进行分区，分区器会先到集群上获取集群的元数据，然后分区器决定将消息发送到对应topic的哪个分区。 （kafka 0.8版本会直接在这时候将消息发出）
4. kafka先将要发送的消息进行缓存（在kafka 0.10后的一个动作）
5. 有一个sender线程会将 recordaccumulator的缓存数据封装为一个个16k的batch，然后进行发送。 （如果消息一直达不到16k，那么100ms后就会进行发送）







### Kafka的面试题

1.Kafka 中的 ISR(InSyncRepli)、OSR(OutSyncRepli)、AR(AllRepli)代表什么？

2.Kafka 中的 HW、LEO 等分别代表什么？

> HW： high water mark， 消费者可见的最大的offset。一般是所有的副本取最小的LEO

3.Kafka 中是怎么体现消息顺序性的？

> 分区内是有序的

4.Kafka 中的分区器、序列化器、拦截器是否了解？它们之间的处理顺序是什么？

> 

5.Kafka 生产者客户端的整体结构是什么样子的？使用了几个线程来处理？分别是什么？

6.“消费组中的消费者个数如果超过 topic 的分区，那么就会有消费者消费不到数据”这句

话是否正确？

7.消费者提交消费位移时提交的是当前消费到的最新消息的 offset 还是 offset+1？

8.有哪些情形会造成重复消费？

9.那些情景会造成消息漏消费？

10.当你使用 kafka-topics.sh 创建（删除）了一个 topic 之后，Kafka 背后会执行什么逻辑？

​	1）会在 zookeeper 中的/brokers/topics 节点下创建一个新的 topic 节点，如：/brokers/topics/first

​	2）触发 Controller 的监听程序

​	3）kafka Controller 负责 topic 的创建工作，并更新 metadata cache

11.topic 的分区数可不可以增加？如果可以怎么增加？如果不可以，那又是为什么？

12.topic 的分区数可不可以减少？如果可以怎么减少？如果不可以，那又是为什么？

13.Kafka 有内部的 topic 吗？如果有是什么？有什么所用？

14.Kafka 分区分配的概念？

15.简述 Kafka 的日志目录结构？

> Index  和  segment

16.如果我指定了一个 offset，Kafka Controller 怎么查找到对应的消息？

17.聊一聊 Kafka Controller 的作用？

> 1. controller 
> 2. Leader 

18.Kafka 中有那些地方需要选举？这些地方的选举策略又有哪些？

19.失效副本是指什么？有那些应对措施？

20.Kafka 的哪些设计让它有如此高的性能？

> kafka 是分布式的
>
> 顺序写磁盘的，使用LSM tree
>
> 







1.Kafka 中的 ISR(InSyncRepli)、OSR(OutSyncRepli)、AR(AllRepli)代表什么？

2.Kafka 中的 HW、LEO 等分别代表什么？

3.Kafka 中是怎么体现消息顺序性的？

4.Kafka 中的分区器、序列化器、拦截器是否了解？它们之间的处理顺序是什么？

5.Kafka 生产者客户端的整体结构是什么样子的？使用了几个线程来处理？分别是什么？

6.“消费组中的消费者个数如果超过 topic 的分区，那么就会有消费者消费不到数据”这句

话是否正确？

7.消费者提交消费位移时提交的是当前消费到的最新消息的 offset 还是 offset+1？

8.有哪些情形会造成重复消费？

9.那些情景会造成消息漏消费？