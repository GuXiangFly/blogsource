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





### Flink实现UDF函数

####  函数类（Function Classes）

####  匿名函数（Lambda Functions）

####  富函数（Rich Functions）

> “富函数”是 DataStream API 提供的一个函数类的接口，所有 Flink 函数类都有其 Rich 版本。它与常规函数的不同在于，可以获取运行环境的上下文，并拥有一些生命周期方法，所以可以实现更复杂的功能。

每个udf函数类，都有对应的rich版本

- RichMapFunction

- RichFlatMapFunction

- RichFilterFunction

- ...

Rich Function 有一个生命周期的概念。典型的生命周期方法有： 

- open()方法是 rich function 的初始化方法，当一个算子例如 map 或者 filter被调用之前 open()会被调用。

- close()方法是生命周期中的最后一个调用的方法，做一些清理工作。

- getRuntimeContext()方法提供了函数的 RuntimeContext 的一些信息，例如函数执行的并行度，任务的名字，以及 state 状态






### 数据重分配（partition）

- keyby  通过key的hashcode 取模来定义分区
- shuffle： 随机将各个数据 分配到不同的  task slot
- forward：不重新分区了
- rebalance ： 1 放到 partition1上   2放到partition2上    3放到partition1上  4放到partition2上
- global： 全部数据全部放到  partition1上  



### window函数

对于 TimeWindow，可以根据窗口实现原理的不同分成三类：滚动窗口（Tumbling Window）、滑动窗口（Sliding Window）和会话窗口（Session Window）。

Window 可以分成三类：

- CountWindow：按照指定的数据条数生成一个 Window，与时间无关。

- TimeWindow：按照时间生成 Window。

  - 滚动窗口（Tumbling Windows）

    > 将数据依据固定的窗口长度对数据进行切片。
    >
    > **特点：时间对齐，窗口长度固定，没有重叠。**
    
  - 滑动窗口（Sliding Windows）

    > 滑动窗口是固定窗口的更广义的一种形式，滑动窗口由固定的窗口长度和滑动间隔组成。
    >
    > **特点：时间对齐，窗口长度固定，可以有重叠。**

- Session Window

  - >  由一系列事件组合一个指定时间长度的 timeout 间隙组成，类似于 web 应用的session，也就是一段时间没有接收到新数据就会生成新的窗口。
    >
    > **特点：时间无对齐。**



####  window function

window function 定义了要对窗口中收集的数据做的计算操作，主要可以分为两类：

- 增量聚合函数（incremental aggregation functions）

  > 每条数据到来就进行计算，保持一个简单的状态。典型的增量聚合函数有ReduceFunction, AggregateFunction。 

- 全窗口函数（full window functions）

  > 先把窗口所有数据收集起来，等到计算的时候会遍历所有数据。ProcessWindowFunction 就是一个全窗口函数。





### 时间语义与 Wartermark

#### Flink 中的时间语义

- **Event Time**：是事件创建的时间。它通常由事件中的时间戳描述，例如采集的日志数据中，每一条日志都会记录自己的生成时间，Flink 通过时间戳分配器访问事件时间戳。
- **Ingestion Time**：是数据进入 Flink 的时间。
- **Processing Time**：是每一个执行基于时间操作的算子的本地系统时间，与机器相关，默认的时间属性就是 Processing Time。



####  EventTime 的引入

​		**在** **Flink** **的流式处理中，绝大部分的业务都会使用** **eventTime**，一般只在eventTime 无法使用时，才会被迫使用 ProcessingTime 或者 IngestionTime。

#### Watermark



### Flink 的状态编程

<img src="https://gitee.com/guxiangfly/blogimage/raw/master/img/image-20201224233043826.png" alt="image-20201224233043826" style="zoom:50%;" />

Flink的状态分成两大类

- Managed State(托管状态)
  - 由***\*Flink Runtime\****控制和管理状态数据，并将状态数据转换成为内存的Hash tables或 RocksDB的对象存储，然后将这些数据通过内部的接口持久化到checkpoints中，任务异常时可以通过这些状态数据恢复任务
- RawState(原生状态)
  - 由算子自己管理数据结构，当触发Checkpoint操作过程中，Flink并不知道状态数据内部的数据结构，只是将数据转换成bytes数据存储在Checkpoints中，当从Checkpoints恢复任务时，算子自己再反序列化出状态的数据结构



在 Flink 中，常用的就是 managed state，下面讲的也是managed state，状态始终与特定算子相关联。在我们的 flatmap操作里面可以绑定一个状态，在reduce操作里面，可以绑定一个状态，在window操作内，也可以绑定状态。

总的来说，managed state有两种类型的状态：

- 算子状态（operator state） 

  - 算子状态的作用范围限定为算子任务。   只要是在同一个分区，那么数据就是一样的

  - 类似 reduce， window ，所有在 reduce处理的数据，都能访问到这个状态。 只要在同一个分区，不论key是啥，都是访问同一个状态

  - <img src="https://gitee.com/guxiangfly/blogimage/raw/master/img/image-20201224234239191.png" alt="image-20201224234239191" style="zoom:50%;" />

  - Flink 为算子状态提供三种基本数据结构：

    - 列表状态（List state）

      > 将状态表示为一组数据的列表。主要是为了方便状态重新分配。
    >
      > <img src="https://gitee.com/guxiangfly/blogimage/raw/master/img/image-20210102021543975.png" alt="image-20210102021543975" style="zoom:67%;" />
    >
      > 假设并行度原本是2，并行度 A1，A2上都有一个size为3的list state。 下一个算子任务并行度调整为3后，那么 B1,B2,B3可以各拿都拿 size为2的 list state。、

    -  联合列表状态（Union list state）

      > 也将状态表示为数据的列表。它与常规列表状态的区别在于，在发生故障时，或者从保存点（savepoint）启动应用程序时如何恢复。
    
    -  广播状态（Broadcast state） (所有分区的 state 都相同)
    
      > 如果一个算子有多项任务，而它的每项任务状态又都相同，那么这种特殊情况最适合应用广播状态。

- 键控状态（keyed state）

  -  只有当前key的数据，才能访问到当前key对应的状态。主要个这么几种数据结构

    - 列表状态（List state） 

      > 将状态表示为一组数据的列表

    - 联合列表状态（Union list state） 

      >也将状态表示为数据的列表。它与常规列表状态的区别在于，在发生故障时，或者从保存点（savepoint）启动应用程序时如何恢复

    - 映射状态（Map state）  

      > 将状态表示为一组 Key-Value 对 

    - 聚合状态（Reducing state & Aggregating State） 

      > 将状态表示为一个用于聚合操作的列表

  -   keyed state 必须使用 rich function。

### 状态后端（state  backend）

- MemoryStateBackend
  - 存级的状态后端，会将键控状态作为内存中的对象进行管理，将它们存储在TaskManager 的 JVM 堆上，而将 checkpoint 存储在 JobManager 的内存中 
  - 特点：快速、低延迟，但不稳定
- FsStateBackend  （默认使用此FileSystem）
  - 将 checkpoint 存到远程的持久化文件系统（FileSystem）上，而对于本地状态，跟 MemoryStateBackend 一样，也会存在 TaskManager 的 JVM 堆上
  - 同时拥有内存级的本地访问速度，和更好的容错保证
- RocksDBStateBackend
  - 将所有状态序列化后，存入本地的 RocksDB 中存储。 （状态编程，状态存在 rocksDB,   rocksDB 在 taskmanager上）





### 容错机制



## WaterMark的概念

![image-20201231001746191](https://gitee.com/guxiangfly/blogimage/raw/master/img/image-20201231001746191.png)



- watermark 其实是一个特殊的数据记录
- watermark 是单调递增的，用来确保任务的事件时间在向前推移而不是后退
- watermark 是与我们数据的时间戳有关的

流程

> watermark 来个2 代表 2之前的数据都到齐了，  来了个5，代表5之前的数据都到齐了
>
> 如果window函数看到  watermark 5 那么代表要触发 1~5 的窗口操作了 （后面假设 kafka数据4 来了，由于它迟到了，就算它作废了）

<img src="https://gitee.com/guxiangfly/blogimage/raw/master/img/image-20201231012505666.png" alt="image-20201231012505666" style="zoom:67%;" />

> 流程
>
> 1.  假设我们设置了一个滚动窗口，时间间隔为5秒。并且设置watermark为3
> 2.  数据时间为1s  数据-1s 的 会进入 [0,5) 的桶里。
> 3. 日志时间数据-4s 收到，后面插入watermark为4-3= 1，不需要关闭window桶，进入 [0,5) 的桶里。
> 4. 日志时间数据-5s 收到，后面插入watermark为5-3= 2，不需要关闭window桶，进入 [5,10) 的桶里。
> 5. 日志时间数据-2s 收到，后面插入watermark为2-3= -1，不需要关闭window桶，进入 [0,5) 的桶里。
> 6. 日志时间数据-3s 收到，后面插入watermark为3-3= 0，不需要关闭window桶，进入 [0,5) 的桶里。
> 7. 日志时间数据-6s 收到，后面插入watermark为6-3= 3，不需要关闭window桶，进入  [5,10)  的桶里。
> 8. 日志时间数据-7s 收到，后面插入watermark为7-3= 4，不需要关闭window桶，进入  [5,10)  的桶里。
> 9. 日志时间数据-5s 收到，后面插入watermark为5-3= 2，不需要关闭window桶，进入  [5,10)  的桶里。
> 10. 日志时间数据-8s 收到，后面插入watermark为8-3= 5，需要关闭window [0,5) 的桶， [0,5)桶的数据进行聚合计算，数据-8s进入  [5,10)  的桶里。
> 11. 日志时间数据-4.1s 收到，发现window [0,5) 的桶已经被关闭，就被丢弃了（除非设置了）。



不同Task之间 watermark的传递 通过广播来实现，假设Task A 依赖 Task B ,Task C 和 TaskD。 B,C,D 的最小 watermark 为 2，那么 TaskA 就讲 watermark2 广播给 TaskA 的下游。

![image-20201231014349924](https://gitee.com/guxiangfly/blogimage/raw/master/img/image-20201231014349924.png)





## ProcessFunction

DataStream API 提供了一系列的 Low-Level 转换算子。可以**访问时间戳、watermark **以及注册定时事件**。还可以输出**特定的一些事件，例如超时事件等。Process Function 用来构建事件驱动的应用以及实现自定义的业务逻辑(使用之前的window 函数和转换算子无法实现)。例如，Flink SQL 就是使用 Process Function 实现的。

Flink 提供了 8 个 Process Function： 

- ProcessFunction

- KeyedProcessFunction

- CoProcessFunction

- ProcessJoinFunction

- BroadcastProcessFunction

- KeyedBroadcastProcessFunction

- ProcessWindowFunction

- ProcessAllWindowFunction

8.1 KeyedProcess

```java
public class ProcessTest2_ApplicationCase_v2 {
    public static void main(String[] args) throws Exception{
        StreamExecutionEnvironment env = StreamExecutionEnvironment.getExecutionEnvironment();
        env.setParallelism(1);

        // socket文本流
        DataStream<String> inputStream = env.socketTextStream("localhost", 7777);

        // 转换成SensorReading类型
        DataStream<SensorReading> dataStream = inputStream.map(line -> {
            String[] fields = line.split(",");
            return new SensorReading(fields[0], new Long(fields[1]), new Double(fields[2]));
        });

        // 测试KeyedProcessFunction，先分组然后自定义处理
        dataStream.keyBy("id")
                .process( new TempConsIncreWarning(10) )
                .print();

        env.execute();
    }

    // 实现自定义处理函数，检测一段时间内的温度连续上升，输出报警
    public static class TempConsIncreWarning extends KeyedProcessFunction<Tuple, SensorReading, String>{
        // 定义私有属性，当前统计的时间间隔
        private Integer interval;

        public TempConsIncreWarning(Integer interval) {
            this.interval = interval;
        }

        // 定义状态，保存上一次的温度值，定时器时间戳
        private ValueState<Double> lastTempState;
        private ValueState<Long> timerTsState;

        @Override
        public void open(Configuration parameters) throws Exception {
            lastTempState = getRuntimeContext().getState(new ValueStateDescriptor<Double>("last-temp", Double.class, Double.MIN_VALUE));
            timerTsState = getRuntimeContext().getState(new ValueStateDescriptor<Long>("timer-ts", Long.class));
        }

        @Override
        public void processElement(SensorReading value, Context ctx, Collector<String> out) throws Exception {
            // 取出状态
            Double lastTemp = lastTempState.value();
            Long timerTs = timerTsState.value();

            // 如果温度上升并且没有定时器，注册10秒后的定时器，开始等待
            if( value.getTemperature() > lastTemp && timerTs == null ){
                // 计算出定时器时间戳
                Long ts = ctx.timerService().currentProcessingTime() + interval * 1000L;
                ctx.timerService().registerProcessingTimeTimer(ts);
                timerTsState.update(ts);
            }
            // 如果温度下降，那么删除定时器
            else if( value.getTemperature() < lastTemp && timerTs != null ){
                ctx.timerService().deleteProcessingTimeTimer(timerTs);
                timerTsState.clear();
            }

            // 更新温度状态
            lastTempState.update(value.getTemperature());
        }

        @Override
        public void onTimer(long timestamp, OnTimerContext ctx, Collector<String> out) throws Exception {
            // 定时器触发，输出报警信息
            out.collect("传感器" + ctx.getCurrentKey().getField(0) + "温度值连续" + interval + "s上升");
            timerTsState.clear();
        }

        @Override
        public void close() throws Exception {
            lastTempState.clear();
        }
    }
}

```



## Table API 和 Flink SQL

### 在 Catalog 中注册表

#### 1. 表（Table） 的概念

- TableEnvironment 可以注册目录 Catalog，并可以基于 Catalog 注册表。它会维护一个Catalog-Table 表之间的 map。 
- 表（Table）是由一个“标识符”来指定的，由 3 部分组成：Catalog 名、数据库（database）名和对象名（表名 table）。如果没有指定目录或数据库，就使用当前的默认值。 catalog 默认是 defaultcatalog 和 defaultdatabase  。   
- 表可以是常规的（table） 也可以是虚拟的（view）  

常规表（table） 一般用来描述外部数据，比如文件，数据库表，和消息队列的数据，也可以从datastream转换而来

<img src="../../../../../../Library/Application Support/typora-user-images/image-20201229175155661.png" alt="image-20201229175155661" style="zoom:50%;" />



#### table的打印输出

```java
// append
tableEnv.toAppendStream(inputTable,Row.class).print("inputTable");
// restract 撤回的 stream （可以对数据进行修改）
tableEnv.toRetractStream(sqlAggTable,Row.class).print("sqlAggTable");
```





### 更新模式

- 与外部系统交互的消息类型，由更新模式（update mode） 指定
- 追加模式（append）
  - 表只做插入操作，和外部连接器只交换插入（insert） 消息
- 撤回模式（retract）
  - 表和外部链接交换添加 add  和撤回 retract  （撤回就是删除）
  - update 操作就是  retract 撤回一条，然后新添加一条
- 更新模式（upsert）
  - 更新和插入都被编码为upsert消息；删除编码为delete消息 
  - upsert需要额外指定相应的key



####  Table 和 DataStream的转换

- 表转换为流

```java
DataStream<Row> resultAppendStream = tableEnv.toAppendStream(resultTable, Row.class);
DataStream<Tuple2<Boolean, Row>> resultRetractStream = tableEnv.toRetractStream(resultTable, Row.class);
```

- 流转换为表

```java
        // 1. 读取数据
        DataStreamSource<String> inputStream = env.readTextFile("/Users/mtdp/dev/ideaworkspace/guxiangwork/technology-study/flink-java-learn/src/main/resources/sensor.txt");


        // 2. 转换成POJO
        DataStream<SensorReading> dataStream = inputStream.map(line -> {
            String[] fields = line.split(",");
            return new SensorReading(fields[0], new Long(fields[1]), new Double(fields[2]));
        });

        StreamTableEnvironment tableEnv = StreamTableEnvironment.create(env);

        // 4. 基于流创建一张表
        Table dataTable = tableEnv.fromDataStream(dataStream);

			  // 或者
				 Table dataTable2 =tableEnv.fromDataStream(dataStream,"id,timestamp as ts,temperature");
```

<img src="https://gitee.com/guxiangfly/blogimage/raw/master/img/image-20201229234730770.png" alt="image-20201229234730770" style="zoom: 67%;" />



### 关系代数和流处理的区别

<img src="https://gitee.com/guxiangfly/blogimage/raw/master/img/image-20201230001339707.png" alt="image-20201230001339707"  />



流处理是  动态表（Dynamic Tables ）

- 动态表是flink对流数据的table API 和 sql支持的核心概念

- 与表示批处理数据的静态表不同，动态表是随时间变化的

#### 持续查询（continuous query）

  - 动态表可以像静态的批处理表一样进行查询
  - 持续查询永远不会终止，并且会生成另一个动态表。
  - 每输入一条新数据，就会重新查询

动态表和持续查询的流程

<img src="https://gitee.com/guxiangfly/blogimage/raw/master/img/image-20201230002217327.png" alt="image-20201230002217327" style="zoom: 67%;" />

	1. 来一条数据，第一个dynamic table 动态表进行更新（以前的数据也会存在着）
 	2. 第一个dynamic table 动态表进行更新后，触发持续查询，更新后面的第二张 动态表
 	3. 第二张动态表更新后更新变化成的流
 	4. ![image-20201230002837357](https://gitee.com/guxiangfly/blogimage/raw/master/img/image-20201230002837357.png)

对于 restract 流，

![image-20201230003239618](https://gitee.com/guxiangfly/blogimage/raw/master/img/image-20201230003239618.png)

#### Flink Table 的 GroupWindow

输出结果如下

2019-01-17 09:43:10.0 到   2019-01-17 09:43:20.0 的数据只有 sensor_1,1547718199,35.8,2019-01-17 09:43:19.0

```
dataTable> sensor_1,1547718199,35.8,2019-01-17 09:43:19.0
dataTable> sensor_6,1547718201,15.4,2019-01-17 09:43:21.0
dataTable> sensor_7,1547718202,6.7,2019-01-17 09:43:22.0
dataTable> sensor_10,1547718205,38.1,2019-01-17 09:43:25.0
dataTable> sensor_1,1547718207,36.3,2019-01-17 09:43:27.0
dataTable> sensor_1,1547718209,32.8,2019-01-17 09:43:29.0
dataTable> sensor_1,1547718212,37.1,2019-01-17 09:43:32.0

resultTable> (true,sensor_1,1,35.8,2019-01-17 09:43:20.0)
resultTable> (true,sensor_6,1,15.4,2019-01-17 09:43:30.0)
resultTable> (true,sensor_1,2,34.55,2019-01-17 09:43:30.0)
resultTable> (true,sensor_10,1,38.1,2019-01-17 09:43:30.0)
resultTable> (true,sensor_7,1,6.7,2019-01-17 09:43:30.0)
resultTable> (true,sensor_1,1,37.1,2019-01-17 09:43:40.0)
```





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



开窗函数： 那是对每一行， 然后拿这行数据周围的数据，进行聚合，然后将结果也放到这行里面。



### watermark 时间语意
我们当前处理数据的时候
- Event Time：事件创建的时间
- Ingestion Time：数据进入Flink的时间
- Processing Time：执行操作算子的本地系统时间，与机器相关



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
2. env







CataLog

