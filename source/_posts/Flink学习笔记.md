---

title: Flink计算模型
date: 2019-03-27 20:09:04
tags: [大数据]

---
## Flink的世界观

![image-20201220134317825](https://gitee.com/guxiangfly/blogimage/raw/master/img/image-20201220134317825.png)

Flink的世界观一切都是流。

- 如果是正常流处理，那么就是无界流
- 如果是批处理，那么就是有界流



## Flink分层API

![image-20201220135523650](https://gitee.com/guxiangfly/blogimage/raw/master/img/image-20201220135523650.png)

Flink 分层

- SQL/ Table 的 api， 里面的方法非常容易理解
- DataStream API   数据流API,用的比较多,   DataSet API，批处理API
- ProcessFunction   比较底层。



## 有状态的流式处理

<img src="https://gitee.com/guxiangfly/blogimage/raw/master/img/image-20201220182002249.png" alt="image-20201220182002249" style="zoom:50%;" />

当我们进行一个状态计算的时候，比方说我们统计一个pv，用户过来一次，我存count+1， 放到内存中。 一个过来，我内存中+1，

为了实现故障恢复，我在远程设计一个周期性的检查点，checkpoint。  

问题： 这种无法保证数据的顺序。





## 有状态的流式处理

![image-20201220182506650](https://gitee.com/guxiangfly/blogimage/raw/master/img/image-20201220182506650.png)

<img src="https://gitee.com/guxiangfly/blogimage/raw/master/img/image-20201220193727095.png" alt="image-20201220193727095" style="zoom:50%;" />

### Lambda 是什么

>  Lambda架构是twitter的工程师  Nathan Marz提出的。同时他是storm项目的发起人

- lambda系统架构体用了一个 结合实时数据处理和批处理的数据环境的混合平台，用以提供一个实时的数据视图。

- 分层架构
  - 批处理层
    - 处理历史数据
  - 实时处理层
    - 实时处理新的数据，和批处理层阐释的服务层视图进行关联，返回给query
  - 服务层
    - 服务层会主动触发查询，查询批处理层和实时处理层产生的视图数据，进行整合。query用户查询的时候，就只需要查询服务层整合完的数据

>  整体是批处理层处理历史数据，生成批处理视图，给服务层，



机器学习里的lambda架构

> batch层使用用户的历史数据行为进行建模。
>
> speed 实时层通过获取用户的最新行为。
>
> servring 服务层将用户的行为通过模型进行推荐

缺点：

- 做一个需求，我们需要做两套系统，一个批处理系统，一个实时处理系统。



## Flink 和 spark 的区别

- 数据模型
  - spark采用RDD计算，spark streaming的DStream 实际上是一对对rdd



<img src="https://gitee.com/guxiangfly/blogimage/raw/master/img/image-20201220202636957.png" alt="image-20201220202636957" style="zoom:50%;" />

### Flink 运行时的组件

#### 1. 作业管理器（JobManager） 

一个job 只有一个 jobmanager。 我们作业是提交给jobmanager。

- jobmanager  将图转换为 执行图，然后将图中的任务分发给一个taskmanager的各个slot

- 协调检查

> 控制一个应用程序执行的主进程，也就是说，每个应用程序都会被一个不同的
>
> JobManager 所控制执行。
>
> • JobManager 会先接收到要执行的应用程序，这个应用程序会包括：作业图
>
> （JobGraph）、逻辑数据流图（logical dataflow graph）和打包了所有的类、
>
> 库和其它资源的JAR包。
>
> • JobManager 会把JobGraph转换成一个物理层面的数据流图，这个图被叫做
>
> “执行图”（ExecutionGraph），包含了所有可以并发执行的任务。
>
> • JobManager 会向资源管理器（ResourceManager）请求执行任务必要的资源，
>
> 也就是任务管理器（TaskManager）上的插槽（slot）。一旦它获取到了足够的
>
> 资源，就会将执行图分发到真正运行它们的TaskManager上。而在运行过程中，
>
> JobManager会负责所有需要中央协调的操作，比如说检查点（checkpoints）
>
> 的协调。

#### 2.任务管理器（TaskManager）

TaskManager会将自己有多少个 slot 等信息，注册到 resourcemanager上。

TaskManager之间可能会传输一些数据。

> • Flink中的工作进程。通常在Flink中会有多个TaskManager运行，每一个TaskManager都包含了一定数量的插槽（slots）。插槽的数量限制了TaskManager能够执行的任务数量。
>
> • 启动之后，TaskManager会向资源管理器注册它的插槽；收到资源管理器的指令后，TaskManager就会将一个或者多个插槽提供给JobManager调用。JobManager就可以向插槽分配任务（tasks）来执行了。
>
> • 在执行过程中，一个TaskManager可以跟其它运行同一应用程序的TaskManager交换数据。

#### 3.资源管理器（ResourceManager） 

ResourceManager可以和 YARN 或 K8s  standalone等做适配。 并且

> 主要负责管理任务管理器（TaskManager）的插槽（slot），TaskManger 插槽是Flink中定义的处理资源单元。
>
> • Flink为不同的环境和资源管理工具提供了不同资源管理器，比如YARN、Mesos、K8s，以及standalone部署。
>
> • 当JobManager申请插槽资源时，ResourceManager会将有空闲插槽的TaskManager分配给JobManager。如果ResourceManager没有足够的插槽来满足JobManager的请求，它还可以向资源提供平台发起会话，以提供启动TaskManager进程的容器。



#### 4.分发器（Dispatcher） 

这个某些架构是可以删除不是必须的，这个就是提供一个web UI 的入口，让我们提交  flink的job，并且给出一些web ui的监控

> • 可以跨作业运行，它为应用提交提供了REST接口。 
>
> • 当一个应用被提交执行时，分发器就会启动并将应用移交给一个JobManager。 
>
> • Dispatcher也会启动一个Web UI，用来方便地展示和监控作业执行的信息。 
>
> • Dispatcher在架构中可能并不是必需的，这取决于应用提交运行的方式。





#### Flink 任务提交的流程

<img src="https://gitee.com/guxiangfly/blogimage/raw/master/img/image-20201222222109616.png" alt="image-20201222222109616" style="zoom:50%;" />

Q1： 为啥我们要启动Jobmanager，其实我们每个flink-job 都对应一个jobmanager， 它是一一对应的。

Q2:  并行的任务，需要占用多少个slot。





#### Flink 在Yarn 上提交任务的流程



这个图上的 ResourceManager  是yarn 的resourcemanager

<img src="https://gitee.com/guxiangfly/blogimage/raw/master/img/image-20201222223015179.png" alt="image-20201222223015179" style="zoom:50%;" />

#### 任务调度的原理

<img src="https://gitee.com/guxiangfly/blogimage/raw/master/img/image-20201222222939932.png" alt="image-20201222222939932" style="zoom:50%;" />





#### Flink中 TaskManager 和 Slots





<img src="https://gitee.com/guxiangfly/blogimage/raw/master/img/image-20201222225014978.png" alt="image-20201222225014978" style="zoom: 67%;" />

> slot什么情况下可合并：
>
> 类似这个， Source 和 Map  其实可以合并。 因为两个Slot直接进行交互， Map 和 keyby 阶段， Map的两个slot 和 keyby的两个slot 都有交互，所以不能合并。
>
> 需要几个slot才能将job跑起来：
>
> 2个，因为看图而言，最大的并行度是2。  因为默认情况下，slot是允许共享的。
>
> 同一时间，并行的任务，slot必须分开，  顺序执行的slot，可以共享。
>
> 
>
> 不同任务共享slot的好处：
>
> - 可以让每个计算资源都得到充分的利用。
>
>   假设 source耗时只有 1ms，windows计算耗时得有 100ms，如果分slot计算 source 1个slot，window一个slot，那么会让 source下来的数据积压等待，共享的话，就可以有两个slot，计算 source和window
>
>   默认是可以共享的，共享组默认名称叫做 default ，但是如果不想共享，那么可以设置不同的slot共享组(slotSharingGroup)
>
>   如果不设置共享组，那么和前面的Task使用同一个slotsharinggroup，  比方说前面设置的red组，那么后面task不显示设置共享组那么就是 red这个共享组

一个特定算子的 子任务（subtask）的个数被称之为其并行度（parallelism）。一般情况下，一个 stream 的并行度，可以认为就是其所有算子中最大的并行度。

<img src="https://gitee.com/guxiangfly/blogimage/raw/master/img/image-20201222225241307.png" alt="image-20201222225241307" style="zoom:50%;" />![image-20201222230133112](https://gitee.com/guxiangfly/blogimage/raw/master/img/image-20201222230133112.png)

<img src="https://gitee.com/guxiangfly/blogimage/raw/master/img/image-20201222230148934.png" alt="image-20201222230148934" style="zoom:50%;" />

Flink 中每一个 TaskManager 都是一个JVM进程，它可能会在独立的线程上执

建议每个TaskManager的 slot个数，是这个taskmanager所在的机器的 CPU核心数，这样能最大利用CPU

## Flink计算模型

- 标准  流处理的计算模型 应该如此
有一条数据进入第一个节点，节点1处理后立马放入缓存中，节点2看见缓存中有数据，立马执行节点2的操作
![](https://raw.githubusercontent.com/GuXiangFly/imagerepo/master/20190324201333.png)
- 标准 批处理模型 应该如此
有一条数据进入第一个节点，节点1处理后立马放入缓存中，节点2等待缓存中有指定个数的数据后，节点2才开始执行

## 实现Stream 的滑动窗口
```java

public class SocketWindowWordCountJava {

    public static class WordWithCount{
        public String word;
        public long count;
        public  WordWithCount(){}
        public WordWithCount(String word,long count){
            this.word = word;
            this.count = count;
        }
        @Override
        public String toString() {
            return "WordWithCount{" +
                    "word='" + word + '\'' +
                    ", count=" + count +
                    '}';
        }
    }

    public static void main(String[] args) throws Exception {
        int port;
        try {
            ParameterTool parameterTool = ParameterTool.fromArgs(args);
            port = parameterTool.getInt("port");
        } catch (Exception e) {
            System.err.println("No port set");
            port = 9000;
        }
        StreamExecutionEnvironment env = StreamExecutionEnvironment.getExecutionEnvironment();

        String hostname = "hadoop101";
        String delimiter = "\n";
        //连接socket获取输入的数据
        DataStreamSource<String> text = env.socketTextStream(hostname, port, delimiter);
        // a a c

        // a 1
        // a 1
        // c 1
        DataStream<WordWithCount> windowCounts = text.flatMap(new FlatMapFunction<String, WordWithCount>() {
            @Override
            public void flatMap(String value, Collector<WordWithCount> out) throws Exception {
                String[] splits = value.split("\\s");
                for (String word : splits) {
                    out.collect(new WordWithCount(word, 1L));
                }
            }
        }).keyBy("word")
                //指定时间窗口大小为2秒，指定时间间隔为1秒
                .timeWindow(Time.seconds(2), Time.seconds(1))
                //.sum("count")
                .reduce(new ReduceFunction<WordWithCount>() {
                    @Override
                    public WordWithCount reduce(WordWithCount a, WordWithCount b) throws Exception {
                        return new WordWithCount(a.word, +b.count + a.count);
                    }
                });
        // 并行的度为1
        windowCounts.print().setParallelism(1);
        env.execute("Socket window count");
    }
}
```

### linux 中打开端口 发送数据
nc命令是一个功能强大的网络工具，全称是netcat。

```bash
nc -l 9000
```


### Flink scala shell 调试代码
我们可以直接 local 启动  Flink 的 scala shell  
可以启动本地的 也可以 让 scala  shell 去链接 远程的 spark
```bash
bin/start-scala-shell.sh local
```

- benv  是  batch env 是批处理环境
- senv  是 streaming env  流处理环境

```bash
scala> val text = benv.fromElements("hello you","hello world");
text: org.apache.flink.api.scala.DataSet[String] = org.apache.flink.api.scala.DataSet@1a1f22f2

scala> val counts = text.flatMap { _.toLowerCase.split("\\W+") }.map { (_, 1) }.groupBy(0).sum(1)  
counts: org.apache.flink.api.scala.AggregateDataSet[(String, Int)] = org.apache.flink.api.scala.AggregateDataSet@53c39950

scala> counts.print()
(hello,2)
(world,1)
(you,1)
```

### Flink的 自定义数据源
Flink自定义数据源有三种
- 实现SourceFunction
```java
import org.apache.flink.streaming.api.functions.source.SourceFunction;

/**
 * 自定义实现并行度为1的source
 *
 * 模拟产生从1开始的递增数字
 *
 * 注意：
 * SourceFunction 和 SourceContext 都需要指定数据类型，如果不指定，代码运行的时候会报错
 * Caused by: org.apache.flink.api.common.functions.InvalidTypesException:
 * The types of the interface org.apache.flink.streaming.api.functions.source.SourceFunction could not be inferred.
 * Support for synthetic interfaces, lambdas, and generic or raw types is limited at this point
 */
public class MyNoParalleSource implements SourceFunction<Long>{

    private long count = 1L;

    private boolean isRunning = true;

    /**
     * 主要的方法
     * 启动一个source
     * 大部分情况下，都需要在这个run方法中实现一个循环，这样就可以循环产生数据了
     *
     * @param ctx
     * @throws Exception
     */
    @Override
    public void run(SourceContext<Long> ctx) throws Exception {
        while(isRunning){
            ctx.collect(count);
            count++;
            //每秒产生一条数据
            Thread.sleep(1000);
        }
    }

    /**
     * 取消一个cancel的时候会调用的方法
     *
     */
    @Override
    public void cancel() {
        isRunning = false;
    }
}
```

- 实现ParallelSourceFunction 
```java
import org.apache.flink.streaming.api.functions.source.ParallelSourceFunction;

/**
 * 自定义实现一个支持并行度的source
 */
public class MyParalleSource implements ParallelSourceFunction<Long> {

    private long count = 1L;
    private boolean isRunning = true;
    /**
     * 主要的方法
     * 启动一个source
     * 大部分情况下，都需要在这个run方法中实现一个循环，这样就可以循环产生数据了
     *
     * @param ctx
     * @throws Exception
     */
    @Override
    public void run(SourceContext<Long> ctx) throws Exception {
        while(isRunning){
            ctx.collect(count);
            count++;
            Thread.sleep(1000);
        }
    }

    /**
     * 取消一个cancel的时候会调用的方法
     */
    @Override
    public void cancel() {
        isRunning = false;
    }
}
```
- 继承RichParallelSourceFunction 
```
RichParallelSourceFunction 会额外提供open和close方法
针对source中如果需要获取其他链接资源，那么可以在open方法中获取资源链接，在close中关闭资源链接
```
```java
import org.apache.flink.configuration.Configuration;
import org.apache.flink.streaming.api.functions.source.RichParallelSourceFunction;

/**
 * 自定义实现一个支持并行度的source
 *
 * RichParallelSourceFunction 会额外提供open和close方法
 * 针对source中如果需要获取其他链接资源，那么可以在open方法中获取资源链接，在close中关闭资源链接
 *
 * Created by xuwei.tech on 2018/10/23.
 */
public class MyRichParalleSource extends RichParallelSourceFunction<Long> {

    private long count = 1L;

    private boolean isRunning = true;

    /**
     * 主要的方法
     * 启动一个source
     * 大部分情况下，都需要在这个run方法中实现一个循环，这样就可以循环产生数据了
     *
     * @param ctx
     * @throws Exception
     */
    @Override
    public void run(SourceContext<Long> ctx) throws Exception {
        while(isRunning){
            ctx.collect(count);
            count++;
            //每秒产生一条数据
            Thread.sleep(1000);
        }
    }

    /**
     * 取消一个cancel的时候会调用的方法
     *
     */
    @Override
    public void cancel() {
        isRunning = false;
    }

    /**
     * 这个方法只会在最开始的时候被调用一次
     * 实现获取链接的代码
     * @param parameters
     * @throws Exception
     */
    @Override
    public void open(Configuration parameters) throws Exception {
        System.out.println("open.............");
        super.open(parameters);
    }
    /**
     * 实现关闭链接的代码
     * @throws Exception
     */
    @Override
    public void close() throws Exception {
        System.out.println("close.............");
        super.close();
    }
}
```

### Flink中的分区
#### Random partitioning：随机分区  
dataStream.shuffle()
#### Rebalancing：对数据集进行再平衡，重分区，消除数据倾斜  
dataStream.rebalance()
#### Rescaling：解释见备注  
dataStream.rescale()
#### Custom partitioning：自定义分区  
自定义分区需要实现Partitioner接口  
dataStream.partitionCustom(partitioner, "someKey")  
或者dataStream.partitionCustom(partitioner, 0);
Broadcasting：在后面单独详解
#### 



### Flink中的算子
#### 比较普通的几个

- map：输入一个元素，然后返回一个元素，中间可以做一些清洗转换等操作
- flatmap：输入一个元素，可以返回零个，一个或者多个元素
- filter：过滤函数，对传入的数据进行判断，符合条件的数据会被留下
- keyBy：根据指定的key进行分组，相同key的数据会进入同一个分区【典型用法见备注】
- reduce：对数据进行聚合操作，结合当前元素和上一次reduce返回的值进行聚合操作，然后返回一个新的值
- aggregations：sum(),min(),max()等
- window：在后面单独详解

 #### 不普通的几个

- Union：合并多个流，新的流会包含所有流中的数据，但是union是一个限制，就是所有合并的流类型必须是一致的。
- Connect：和union类似，但是只能连接两个流，两个流的数据类型可以不同，会对两个流中的数据应用不同的处理方法。
- CoMap, CoFlatMap：在ConnectedStreams中需要使用这种函数，类似于map和flatmap
- Split：根据规则把一个数据流切分为多个流
- Select：和split配合使用，选择切分后的流



### Flink 编写步骤

#### 编写思路四步走

1. env
2. 

