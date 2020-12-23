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

### Lambda架构 是什么

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
> • JobManager 会先接收到要执行的应用程序，这个应用程序会包括：作业图（JobGraph）、逻辑数据流图（logical dataflow graph）和打包了所有的类、库和其它资源的JAR包。
>
> • JobManager 会把JobGraph转换成一个物理层面的数据流图，这个图被叫做“执行图”（ExecutionGraph），包含了所有可以并发执行的任务。
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



### Slot 子任务分配

<img src="https://gitee.com/guxiangfly/blogimage/raw/master/img/image-20201223104512500.png" alt="image-20201223104512500" style="zoom:50%;" />

Q1: 为什么 C 和 B能共享一个Slot？

A1：因为slot就是一个线程，我可以先执行玩B后 再执行C 。 然后再执行B  再执行C



#### 程序与数据流（DataFlow）

<img src="https://gitee.com/guxiangfly/blogimage/raw/master/img/image-20201223111253912.png" alt="image-20201223111253912" style="zoom: 67%;" />

- 所有的Flink程序都是由三部分组成的： Source 、Transformation 和 Sink。
- Source 负责读取数据源，Transformation 利用各种算子进行处理加工，Sink 负责输出。



#### 执行图（ExecutionGraph）

-  Flink 中的执行图可以分成四层：StreamGraph -> JobGraph -> ExecutionGraph -> 物理执行图 

- StreamGraph：是根据用户通过 Stream API 编写的代码生成的最初的图。用来表示程序的拓扑结构。

-  JobGraph：StreamGraph经过优化后生成了 JobGraph，提交给 JobManager 的数据结构。主要的优化为，将多个符合条件的节点 chain 在一起作为一个节点

-  ExecutionGraph：JobManager 根据 JobGraph 生成ExecutionGraph。ExecutionGraph是JobGraph的并行化版本，是调度层最核心的数据结构。

- 物理执行图：JobManager 根据 ExecutionGraph 对 Job 进行调度后，在各个

- TaskManager 上部署 Task 后形成的“图”，并不是一个具体的数据结构。

<img src="https://gitee.com/guxiangfly/blogimage/raw/master/img/image-20201223113023464.png" alt="image-20201223113023464" style="zoom:67%;" />

Q1： 为何 keyby 不作为一个计算算子？

A1：  因为 keyBy 实际上是按key的hash 进行一个重分区的操作而已，并不是做真正的计算。



#### 数据传输形式有哪些

 两种（one-to-one，Redistributing）

- 一个程序中，不同的算子可能具有不同的并行度

-  算子之间传输数据的形式可以是 one-to-one (forwarding) 的模式也可以是redistributing 的模式，具体是哪一种形式，取决于算子的种类
  - One-to-one：stream维护着分区以及元素的顺序（比如source和map之间）。 这意味着map 算子的子任务看到的元素的个数以及顺序跟 source 算子的子任务生产的元素的个数、顺序相同。map、fliter、flatMap等算子都是one-to-one的对应关系。
  - Redistributing：stream的分区会发生改变。每一个算子的子任务依据所选择的transformation发送数据到不同的目标任务。
    - 例如，keyBy 基于 hashCode 重分区、而 broadcast 和 rebalance 会随机重新分区，这些算子都会引起redistribute过程，而 **redistribute 过程就类似于 Spark 中的 shuffle 过程**。

  ![image-20201223114506719](https://gitee.com/guxiangfly/blogimage/raw/master/img/image-20201223114506719.png)

  - 图中 forward   就是 one-to-one   （one-to-one 的slot才能合并） （类似spark 的窄分区）
  - hash  是基于hashcode进行重分区，是redistributing。 （类似spark的宽分区）

#### 任务链（Operator Chains） 

- Flink 采用了一种称为任务链的优化技术，可以在特定条件下减少本地通信的开销。为了满足任务链的要求，必须将两个或多个算子设为相同的并行度，并通过本地转发（local forward）的方式进行连接

- **相同并行度**的 **one-to-one** 操作，Flink 这样相连的算子链接在一起形成一个 task，原来的算子成为里面的 subtask

- 并行度相同、并且是 one-to-one 操作，两个条件缺一不可。
- 将两个task进行合并的好处：可以  节省了两个task之间的数据通信传输开销，不用序列化了。 条件就是 必须是**并行度相同的one-to-one操作，并且必须要是在同一个slot共享组里**
- 使用 disableOperatorChaining 或者 那么就不会进行 task的合并。

<img src="https://gitee.com/guxiangfly/blogimage/raw/master/img/image-20201223115016900.png" alt="image-20201223115016900" style="zoom: 67%;" />

## Flink流处理计算



#### 基本转换算子

Map, flatmap,  filter  同属于 one-to-one 操作

- map   假设 inputStream一行是一个 string， 进入是一个string，返回也必须是单个值
- flatmap    假设 inputStream一行是一个 string， 进入是一个string，返回可以是多个值。将 string 打成一个个 char。  最后多个 string  回合成为多个 char
- filter     返回一个true 代表我要这个数据， 返回一个false，代表我不要这个数据

 ```java
public class TransformTest1_Base {
    public static void main(String[] args) throws Exception{
        StreamExecutionEnvironment env = StreamExecutionEnvironment.getExecutionEnvironment();
        env.setParallelism(1);

        // 从文件读取数据
        DataStream<String> inputStream = env.readTextFile("D:\\Projects\\BigData\\FlinkTutorial\\src\\main\\resources\\sensor.txt");

        // 1. map，把String转换成长度输出
        DataStream<Integer> mapStream = inputStream.map(new MapFunction<String, Integer>() {
            @Override
            public Integer map(String value) throws Exception {
                return value.length();
            }
        });

        // 2. flatmap，按逗号分字段
        DataStream<String> flatMapStream = inputStream.flatMap(new FlatMapFunction<String, String>() {
            @Override
            public void flatMap(String value, Collector<String> out) throws Exception {
                String[] fields = value.split(",");
                for( String field: fields ) {
                    out.collect(field);
                }
            }
        });

        // 3. filter, 筛选sensor_1开头的id对应的数据
        DataStream<String> filterStream = inputStream.filter(new FilterFunction<String>() {
            @Override
            public boolean filter(String value) throws Exception {
                return value.startsWith("sensor_1");
            }
        });

        // 打印输出
        mapStream.print("map");
        flatMapStream.print("flatMap");
        filterStream.print("filter");

        env.execute();
    }
}
 ```



#### 滚动聚合算子（Rolling Aggregation）

> Flink 所有的聚合操作，必须进行分组后才能操作

下面这些算子必须在keyby后才能操作

- sum()
- min()
- max()
- minBy()
- maxBy()



####  Flink 的 **Reduce** 

>  **KeyedStream** **→** **DataStream**：一个分组数据流的聚合操作，合并当前的元素和上次聚合的结果，产生一个新的值，返回的流中包含每一次聚合的结果，而不是只返回最后一次聚合的最终结果。

```java
public class TransformTest3_Reduce {
    public static void main(String[] args) throws Exception {
        StreamExecutionEnvironment env = StreamExecutionEnvironment.getExecutionEnvironment();
        env.setParallelism(1);
        // 从文件读取数据
        DataStream<String> inputStream = env.readTextFile("/Users/mtdp/dev/ideaworkspace/guxiangwork/technology-study/flink-java-learn/src/main/resources/sensor.txt");
        // 转换成SensorReading类型
        DataStream<SensorReading> dataStream = inputStream.map(line -> {
            String[] fields = line.split(",");
            return new SensorReading(fields[0], new Long(fields[1]), new Double(fields[2]));
        });
        // 分组
        KeyedStream<SensorReading, Tuple> keyedStream = dataStream.keyBy("id");
        // reduce聚合，取最大的温度值，以及当前最新的时间戳
        SingleOutputStreamOperator<SensorReading> resultStream = keyedStream.reduce(new ReduceFunction<SensorReading>() {
            @Override
            public SensorReading reduce(SensorReading value1, SensorReading value2) throws Exception {
                return new SensorReading(value1.getId(), value2.getTimestamp(), Math.max(value1.getTemperature(), value2.getTemperature()));
            }
        });

        keyedStream.reduce( (curState, newData) -> {
            return new SensorReading(curState.getId(), newData.getTimestamp(), Math.max(curState.getTemperature(), newData.getTemperature()));
        });

        resultStream.print();
        env.execute();
    }
}

```



#### 4. Flink 的  **Split** **和** Select

<img src="https://gitee.com/guxiangfly/blogimage/raw/master/img/image-20201223222431471.png" alt="image-20201223222431471" style="zoom:50%;" />

​		**DataStream** **→** **SplitStream**：根据某些特征把一个 DataStream 拆分成两个或者多个 DataStream。

<img src="https://gitee.com/guxiangfly/blogimage/raw/master/img/image-20201223222908480.png" alt="image-20201223222908480" style="zoom:50%;" />

​		**SplitStream** **→** **DataStream** ：从一个 SplitStream 中获取一个或者多个DataStream。



#### 5. Flink的**Connect** **和** **CoMap**

<img src="https://gitee.com/guxiangfly/blogimage/raw/master/img/image-20201223224215315.png" alt="image-20201223224215315" style="zoom:50%;" />

#### 6. Flink 的 Union

<img src="https://gitee.com/guxiangfly/blogimage/raw/master/img/image-20201223224020726.png" alt="image-20201223224020726" style="zoom:50%;" /



<img src="https://gitee.com/guxiangfly/blogimage/raw/master/img/image-20201223224247502.png" alt="image-20201223224247502" style="zoom:50%;" />

##### union 和  comap- connect 的不同：  

1. Union 之前两个流的类型必须是一样，Connect 可以不一样，在之后的 coMap中再去调整成为一样的。

2. Connect 只能操作两个流，Union 可以操作多个。



### Flink 支持的数据类型

Flink 底层有一个 typeinformation



#### 1.基础数据类型
Flink 支持所有的 Java 和 Scala 基础数据类型，Int, Double, Long, String, …

#### 2.**Java** **和** **Scala** 元组（Tuples）
Flink 支持所有的 Java 和 Scala 基础数据类型，Int, Double, Long, String, …

#### 3. **Scala** 样例类（case classes）
Flink 支持所有的 Java 和 Scala 基础数据类型，Int, Double, Long, String, …

#### 4.其它（Arrays, Lists, Maps, Enums,** **等等）**
Flink 支持所有的 Java 和 Scala 基础数据类型，Int, Double, Long, String, …







### 数据重分配（partition）

- keyby  通过key的hashcode 取模来定义分区
- shuffle： 随机将各个数据 分配到不同的  task slot
- forward：不重新分区了
- rebalance ： 1 放到 partition1上   2放到partition2上    3放到partition1上  4放到partition2上
- global： 全部数据全部放到  partition1上  





### window概念







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
nc -lk 9000
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

