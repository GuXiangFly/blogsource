---




title: Kafka学习笔记
date: 2020-7-11 13:09:04
tags: [Kafka]

---

## Kafka的基础概念


### kafka工作流程

![image-20200518155036500](http://guxiangflyimagebucket.oss-cn-beijing.aliyuncs.com/img/image-20200518155036500.png)

kafka单独一个topic内，也会进行分区，kafka只能保证单独分区内，消息是有序的.



 ![image-20200914164905228](http://guxiangflyimagebucket.oss-cn-beijing.aliyuncs.com/img/image-20200914164905228.png)

#### kafka的文件存储

视频连接 [https://www.bilibili.com/video/BV1a4411B7V9?p=12]



![image-20200518174054937](http://guxiangflyimagebucket.oss-cn-beijing.aliyuncs.com/img/image-20200518174054937.png)

.log文件存储的是kafka队列里面的数据

.index 记录的是kafka的某个consumer的

![image-20200518173852677](http://guxiangflyimagebucket.oss-cn-beijing.aliyuncs.com/img/image-20200518173852677.png)

![image-20200518174400952](http://guxiangflyimagebucket.oss-cn-beijing.aliyuncs.com/img/image-20200518174400952.png)

有一个全局的segment list：



<img src="http://guxiangflyimagebucket.oss-cn-beijing.aliyuncs.com/img/image-20210209111755507.png" alt="image-20210209111755507" style="zoom:67%;" />

**.log 和 .index 都是以当前segment的第一条消息的offset命名的**。下图为 index和log文件的结构示意图

> .index 文件存储大量的索引信息，  .log文件存储大量的数据信息

![image-20200518191544556](http://guxiangflyimagebucket.oss-cn-beijing.aliyuncs.com/img/image-20200518191544556.png)

![image-20210209112059142](http://guxiangflyimagebucket.oss-cn-beijing.aliyuncs.com/img/image-20210209112059142.png)

由于kafka的消息头，会存储message的长度，所以，然后就能直接读取到相应的数据结尾。



kafka读取日志的顺序：

1. 首先会读取一个全局的segment list

##### kafka分区的原因

- **方便在集群中拓展**，每个partition可以通过调整适应它所在的机器，而一个topic又可以有多个partition组成，因此可以适应任意大小的数据。
- **可以提高并发**， 因为可以以partation为单位读写。



![image-20210430111638110](http://guxiangflyimagebucket.oss-cn-beijing.aliyuncs.com/img/image-20210430111638110.png)





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
- 10、controller：这是kafka中相对block的一个概念，如果一个topic1中有partitionA 和 partitionB   Topic1-partitionA的leader partition挂了或 topic1-partitionA的leader partition所在的block挂了，那么需要使用controller来从Topic1-partitionA的ISR集合中选取一个leader partition 。  
- 11、coordinator：coordinator 是相对consumer group来说的， kafka中会有一个 coordinator来专门协调 consumer 和  topic的关系



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









### Kafka 的rebalance流程

触发时机：

- topic 的 partition出现增加和减少

  - ![image-20210525214613414](http://guxiangflyimagebucket.oss-cn-beijing.aliyuncs.com/img/image-20210525214613414.png)

- 消费者组中，消费者出现增加和减少

  ![image-20210525214717361](http://guxiangflyimagebucket.oss-cn-beijing.aliyuncs.com/img/image-20210525214717361.png)

  由于消费者可以消费多个topic， topic 的数量发生了变化（不常用）

  

  ![image-20210525214907538](http://guxiangflyimagebucket.oss-cn-beijing.aliyuncs.com/img/image-20210525214907538.png)

- 触发时机总结：
  - 消费者数量发生变化
    - 某个consumer  奔溃
    - 新增 consumer
  - topic的数量发生变化
    - 某个topic被删除
  - partition的数量发生变化
    - 删除partition
    - 新增partition
- 不良影响
  - rebalance过程会对consumer group 产生非常严重的影响，rebalance的过程中，所有的消费这都会停止工作，直到rebalance完成了。



#### rebalance分配策略

- Range分配策略

  - 算法公式：
    - n = 分区数量/消费者数量
    - ![image-20210525220358215](http://guxiangflyimagebucket.oss-cn-beijing.aliyuncs.com/img/image-20210525220358215.png)

- RoundRobin轮询策略

- stricky黏性分配策略

  从kafka0.11开始引入此策略。主要目的：

  - 分区尽可能均匀
  - 在发生rebalance时候，分区尽可能和上一次保持一致

  没有发生rebalance时，striky黏性分配策略和roundrobin分配策略类似。 

  如果发生rebalance， RoundRobin策略会重新走轮询进行分配。而 stricky会尽量保证和上次一致。减少分区的一些切换。

- **rebalance会出现什么问题**

```
1、可能重复消费: Consumer被踢出消费组，可能还没有提交offset，Rebalance时会Partition重新分配其它Consumer,会造成重复消费，虽有幂等操作但耗费消费资源，亦增加集群压力

2、集群不稳定：Rebalance扩散到整个ConsumerGroup的所有消费者，因为一个消费者的退出，导致整个Group进行了Rebalance，并在一个比较慢的时间内达到稳定状态，影响面较大

3、影响消费速度：频繁的Rebalance反而降低了消息的消费速度，大部分时间都在重复消费和Rebalance
```

![image-20211013000009386](http://guxiangflyimagebucket.oss-cn-beijing.aliyuncs.com/img/image-20211013000009386.png)

由于发生rebalance， consumer成员会新生成generation，于是所有的consumer是需要重连topic的partition的。

这种情况下，假设是consumerA的策略是自动提交，提交间隔是5s，   提交完后3s出现了 rebalance，超时提交位移是200ms，所有consumer重连partition，consumer会从上次提交的offset进行消费。  会导致 consumerA 重复消费0s~3s的数据。



### kafka动态重平衡策略详解

架构师杨波

https://time.geekbang.org/course/intro/100053601  

Kafka动态重平衡是如何工作的

![image-20211024204315366](http://guxiangflyimagebucket.oss-cn-beijing.aliyuncs.com/img/image-20211024204315366.png)

- kafka为了解决动态重平衡问题 使用了比较复杂的重平衡协议 主要由两个子协议构成Group Member Protocal 和 Consumer Embeded Protocol
  - 在 kafka的动态重平衡协议适用场景非常广泛，不仅
    - 用于消费者的分区分配
    - kafka connect 组件用这个协议给worker分配任务
    - kafka stream 上也使用了动态重平衡协议
  - Group Member Protocol  （主要用于组成员的管理）这个协议主要是在broker上实现  包括有
    - JoinGroup 
    - SyncGroup
    - HeartBeat
    - LeaveGroup
  -  Consumer Embeded Protocol （主要是用于分区的分配的） 主要在客户端实现



![image-20211024215303994](http://guxiangflyimagebucket.oss-cn-beijing.aliyuncs.com/img/image-20211024215303994.png)

![image-20211024214516326](http://guxiangflyimagebucket.oss-cn-beijing.aliyuncs.com/img/image-20211024214516326.png)

1. 对于每个 consumer group， blocker集群上会选出一个对应的 coordinator 用于消费者组管理
2. 当消费者启动，它们会先找到对应的协调者，然后向他发送 joinGroup的请求。请求中包含了
   1. group id 
   2. 超时时间  （后面协调者会通过超时时间来判断组成员是否存活， 可能一个full GC 会导致一个rebalance）
   3. 协议类型 
   4. 支持的算法 订阅的topic
3. 协调者收到这个join group请求，就知道哪些消费者需要加入组，coordinator不会立马响应，会将这个请求hold一个超时间隔， 如果这时候 消费者数量不再发生变化，那么就会开启这个kafka的重平衡策略。
	![image-20211024215453601]	(http://guxiangflyimagebucket.oss-cn-beijing.aliyuncs.com/img/image-20211024215453601.png)
4. 协调者会将第一个发送 join group请求的 consumer作为leader。 执行一个分区分配算法。 leader 将这个分配结果通过一个 sync group请求发送给 coordinator。其他消费者也会发 sync group请求。但是是空请求。
5. 发起 sync group 请求后会拿到响应。每个consumer就接收到了各自对应的partition，然后进行 onpartitionassigned()。
6. 然后 consumer开始 pull 消息
7. 同时，会定期发送 heartbeat心跳给 coordinator。表明自己活着。 但如果 coordinator说需要进行rebalance，会通过 heartbeat返回告诉 consumer需要重新 join Group。
8. **rebalance会导致 stop-the-world的如果发生**
   1. 假设 consumer1需要升级更新，我们需要将consumer1停止，  在停止前consumer1会向 coordinator发送一个 leaveGroup请求。
   2. 其他消费者也收到通知，需要重新发起一个joinGroup/syncgroup请求，来重新分配
   3. 只要我们的 consumer group没发生处理完重分配策略，  consumer就无法继续消费 message。 
   4. 上面就是 stop-the-world



重平衡的缺点：

​	1. 重平衡具有 stop-the-world的



![image-20211024221418053](http://guxiangflyimagebucket.oss-cn-beijing.aliyuncs.com/img/image-20211024221418053.png)




https://www.bilibili.com/video/BV1Pq4y1P73r?p=24&spm_id_from=pageDriver

### kafka的Contoller 和 coordinator

- controller：这个是相对于kafka集群中block机器的一个概念
  - kafka启动时候，会在所有的broker中选出controller

- kafka中的 leader和follow是针对partition的，controller是针对整个broker集群的。

- 创建topic，添加分区，修改副本数这类管理任务，都是通过controller来实现。

- kafka的leader选举也是由controller决定。

  

  ##### controller的概念

  - kafka集群启动的时候，每个broker都会尝试去zookeeper上注册序号节点，序号节点最小的blocker 就成为了controller

  - **controller的功能：**如果一个topic1中有partitionA 和 partitionB   Topic1-partitionA的leader partition挂了或 topic1-partitionA的leader partition所在的block挂了，那么需要使用controller来从Topic1-partitionA的ISR集合中选取一个leader partition 。  
    - topic1-partitionA 的leader节点 挂了，  controller会在ISR中选取新leader
    - topic1-partitionA  新增了follower节点，  controller会通知，并且维护ISR集合
    - topic1 增加了partitionD，那么也需要controller来通知topic1的其他partition



  ##### 		coordinator的概念

-  coordinator是相对 consumer group来说的， consumer group中 consumer 数量发生变化,会通过coordinator来发起 rebalance    
-   [相对controller：如果  topic1中partition 的变化 由 controller来调控] 
- rebalance三个策略
  - Range分配策略
  - RoundRobin
  - stricky





# 面试题专区

## Kafka生产者写数据流程

kafka异步发送的源码

```java
    public static void producerSend(){
        Properties properties = new Properties();
        properties.put(ProducerConfig.BOOTSTRAP_SERVERS_CONFIG,"192.168.220.128:9092");
        properties.put(ProducerConfig.ACKS_CONFIG,"all");
        properties.put(ProducerConfig.RETRIES_CONFIG,"0");
        properties.put(ProducerConfig.BATCH_SIZE_CONFIG,"16384");
        properties.put(ProducerConfig.LINGER_MS_CONFIG,"1");
        properties.put(ProducerConfig.BUFFER_MEMORY_CONFIG,"33554432");

        properties.put(ProducerConfig.KEY_SERIALIZER_CLASS_CONFIG,"org.apache.kafka.common.serialization.StringSerializer");
        properties.put(ProducerConfig.VALUE_SERIALIZER_CLASS_CONFIG,"org.apache.kafka.common.serialization.StringSerializer");

        // Producer的主对象
        Producer<String,String> producer = new KafkaProducer<>(properties);

        // 消息对象 - ProducerRecoder
        for(int i=0;i<10;i++){
            ProducerRecord<String,String> record =
                    new ProducerRecord<>(TOPIC_NAME,"key-"+i,"value-"+i);

            producer.send(record);
        }
        // 所有的通道打开都需要关闭
        producer.close();
    }
```



![image-20201121162444033](http://guxiangflyimagebucket.oss-cn-beijing.aliyuncs.com/img/image-20201121162444033.png)





注：broker是kafka集群    ，生产者是程序员自己写的java代码

1. java代码中发出消息，先进行封装
2. 封装后进行代码的序列化
3. 第三步对消息进行分区，分区器会先到集群上获取集群的元数据，然后分区器决定将消息发送到对应topic的哪个分区。，就损。 （kafka 0.8版本会直接在这时候将消息发出） 
4. kafka先将要发送的消息进行缓存（在kafka 0.10后的一个动作）
5. 有一个守护线程sender线程会将 recordaccumulator的缓存数据封装为一个个16k的batch，然后进行发送。 （如果消息一直达不到16k，那么100ms后就会进行发送）



##### kafka producer  解析步骤

KafkaProducer 创建的源码

1. 配置一个监控 metricConfig

2. 加载负载均衡器

3. 初始化serializer

4. 初始化recordaccumulator（一个计数器）

5. 创建 newSender线程 /并且启动   （创建/启动 一个守护线程 ）

   --  由于 newSender 来发送数据，所以KafkaProducer的send是线程安全的



kafka  producer 发送的核心

- 直接发送（kafka会直接发送数据到计算后partition的leader节点上，就算bootstrap节点写的不是leader节点，也会通过缓存 leader节点ip的方式发送到leader节点上）
- 负载均衡 （客户端可以决定 数据具体发送到哪个 partition上）
- 异步/并且批量发送    

<img src="http://guxiangflyimagebucket.oss-cn-beijing.aliyuncs.com/img/image-20210409002831071.png" alt="image-20210409002831071" style="zoom:50%;" />

kafka 是如何保证 exactly  once，

- 配置 ack_config= all： 代表leader需要等待所有备份都成功写入follower 才返回，这样只要有一个follow不丢就不会有问题。
-  通过配置 ack_config 保证 at least once，  然后通过





### KAFKA 对应的api

<img src="http://guxiangflyimagebucket.oss-cn-beijing.aliyuncs.com/img/image-20210408224940687.png" alt="image-20210408224940687" style="zoom:50%;" />





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
> ``







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







#### Kafka为什么快？

1. 日志的顺序读写和快速检索。

   1. 日志分段记录，单独一个partition中，每1g会新创建

      <img src="http://guxiangflyimagebucket.oss-cn-beijing.aliyuncs.com/img/image-20210209111755507.png" alt="image-20210209111755507" style="zoom:67%;" />

      

2. producer会批量发送数据， 并且由于是批量发送数据，于是kafka能方便做数据排序

4. 通过sendfile实现了零拷贝原则

   1. 正常来说  消费者进程需要读取文件，需要先 
      1. 从磁盘文件进行读取到内核态缓冲区 ，
      2. 然后读取到用户态缓冲区，
      3. 然后读取到内核态的socket缓冲区，
      4. 然后通过网卡传输给消费者
   2. ![image-20210209113227842](http://guxiangflyimagebucket.oss-cn-beijing.aliyuncs.com/img/image-20210209113227842.png)
   3. KAFKA 的 sendfile 操作实现原理
      1. 减少了内核态和用户态之间的上下文切换
      2. 
   4. ![image-20210209114402905](http://guxiangflyimagebucket.oss-cn-beijing.aliyuncs.com/img/image-20210209114402905.png)







