---

title: Flink计算模型
date: 2020-03-27 20:09:04
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



#### 1. WindowAssigner函数

window() 方法接收的输入参数是一个 WindowAssigner

• WindowAssigner 负责将每条输入的数据分发到正确的 window 中 

• Flink 提供了通用的 WindowAssigner

➢ 滚动窗口（tumbling window） 

➢ 滑动窗口（sliding window） 

➢ 会话窗口（session window） 

➢ 全局窗口（global window）





对于 TimeWindow，可以根据窗口实现原理的不同分成四类：滚动窗口（Tumbling Window）、滑动窗口（Sliding Window）和会话窗口（Session Window）。

Window 可以分成四类：

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

  - 一段时间没有接收到新数据就会判断为session结束，一个窗口结束。 窗口结束后来数据代表窗口开启了。
  
  - >  由一系列事件组合一个指定时间长度的 timeout 间隙组成，类似于 web 应用的session，也就是一段时间没有接收到新数据就会生成新的窗口。
    >
    > **特点：时间无对齐。**
  
- Globalwindow  （全局窗口）

  - 所有数据放入同一个分区



####  2. window function

window function 定义了要对窗口中收集的数据做的计算操作，主要可以分为两类：

- 增量聚合函数（incremental aggregation functions）

  > 每条数据到来就进行计算，保持一个简单的状态。典型的增量聚合函数有
  >
  > ReduceFunction, AggregateFunction。 

- 全窗口函数（full window functions）

  > 先把窗口所有数据收集起来，等到计算的时候会遍历所有数据。
  >
  > ProcessWindowFunction，windowFunction 就是一个全窗口函数。



#### window其他可选api

- trigger() —— 触发器

  ➢ 定义  window 什么时候关闭，触发计算并输出结果

- evictor() —— 移除器

  ➢ 定义移除某些数据的逻辑

- allowedLateness() —— 允许处理迟到的数据

  ​	sideOutputLateData() —— 将迟到的数据放入侧输出流

- getSideOutput() —— 获取侧输出流



window 窗口分配器



### 时间语义与 Watermark(waterMark只有结合了窗口才有意义)

#### Flink 中的时间语义

- **Event Time**：是事件创建的时间。它通常由事件中的时间戳描述，例如采集的日志数据中，每一条日志都会记录自己的生成时间，Flink 通过时间戳分配器访问事件时间戳。
- **Ingestion Time**：是数据进入 Flink 的时间。
- **Processing Time**：是每一个执行基于时间操作的算子的本地系统时间，与机器相关，默认的时间属性就是 Processing Time。



####  EventTime 的引入

​		**在** **Flink** **的流式处理中，绝大部分的业务都会使用** **eventTime**，一般只在eventTime 无法使用时，才会被迫使用 ProcessingTime 或者 IngestionTime。

#### Watermark

- watermark的分配器

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
      > ![image-20210408130605309](https://gitee.com/guxiangfly/blogimage/raw/master/img/image-20210408130605309.png)
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



#### Checkpoint 检查点

- flink 的 jobmanager 会周期性得自动进行保存

<img src="https://gitee.com/guxiangfly/blogimage/raw/master/img/image-20210104193417161.png" alt="image-20210104193417161" style="zoom:67%;" />





source 会重新去 



<img src="https://gitee.com/guxiangfly/blogimage/raw/master/img/image-20210105191712936.png" alt="image-20210105191712936" style="zoom:67%;" />



#### Savepoints 保存点

- 原则上，创建保存点使用的算法与检查点完全相同，因此保存点可以认为就是具有一些额外元数据的检查点
- flink不会自动创建 savepoints，
- 保存点是一个强大的功能。除了故障恢复外，保存点可以用于：有计划的手动备份，更新应用程序，版本迁移，暂停和重启应用，等等





## Flink状态一致性

> 当在分布式系统中引入状态时，自然也引入了一致性问题。一致性实际上是"正确性级别"的另一种说法，也就是说在成功处理故障并恢复之后得到的结果，与没有发生任何故障时得到的结果相比，前者到底有多正确？举例来说，假设要对最近一小时登录的用户计数。在系统经历故障之后，计数结果是多少？如果有偏差，是有漏掉的计数还是重复计数？

### 一致性级别

- at-most-once: 这其实是没有正确性保障的委婉说法——故障发生之后，计数结果可能丢失。同样的还有 udp。 

- at-least-once:  这表示计数结果可能大于正确值，但绝不会小于正确值。也就是说，计数程序在发生故障后可能多算，但是绝不会少算。 （这个类似uv统计可以使用此）

- exactly-once: 这指的是系统保证在发生故障后得到的计数结果与正确值一致。



### 端到端（end-to-end）状态一致性



​		端到端的一致性保证，意味着结果的正确性贯穿了整个流处理应用的始终；每一个组件都保证了它自己的一致性，整个端到端的一致性级别取决于所有组件中一致性最弱的组件。具体可以划分如下：



具体可以划分如下：

- 内部保证 —— 依赖 checkpoint

- source 端 —— 需要外部源可重设数据的读取位置

- sink 端 —— 需要保证从故障恢复时，数据不会重复写入外部系统



​		而对于 sink 端，又有两种具体的实现方式：幂等（Idempotent）写入和事务性

（Transactional）写入。



- 幂等写入 Idempotent

  >  所谓幂等操作，是说一个操作，可以重复执行很多次，但只导致一次结果更改，也就是说，后面再重复执行就不起作用了。 

- 事务写入 Transactional

  需要构建事务来写入外部系统，构建的事务对应着 checkpoint，等到 checkpoint 真正完成的时候，才把所有对应的结果写入 sink 系统中。

  对于事务性写入，具体又有两种实现方式：

  - 预写日志（WAL）
    - DataStream API 提供了 GenericWriteAheadSink 模板类实现
  - 两阶段提交（2PC）
    - DataStream API 提供了 TwoPhaseCommitSinkFunction 接口，可以方便地实现这两种方式的事务性写入。



<img src="https://gitee.com/guxiangfly/blogimage/raw/master/img/image-20210105205855997.png" alt="image-20210105205855997" style="zoom:67%;" />









### Exactly-once 两阶段提交的步骤

Flink 如何通估 2PC 保证端到端的状态一致性

<img src="https://gitee.com/guxiangfly/blogimage/raw/master/img/image-20210105213855496.png" alt="image-20210105213855496" style="zoom:67%;" />



<img src="https://gitee.com/guxiangfly/blogimage/raw/master/img/image-20210105215128428.png" alt="image-20210105215128428" style="zoom:50%;" />

下面是只看处理到sink部分

- 第一条数据发现需要sink后，开启一个 transaction1 ，正常写入kafka，分区日志，但是标记为未提交，算预提交。
- sink连接器收到 barrier ，保存当前状态，存入 checkpoint，并且通知jobmanager，同时为第二条数据开启下一阶段事务transaction2，为了第二条数据
- jobmanager收到任务通知完成 checkpoint操作。
- sink 任务收到 jobmanager的确认信息，正式提交这段时间的数据。
- 外部
- 1





（state backend  是在taskmanager 的机器上的，默认是内存，也可以是文件）

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



## Flink  stream  Join

https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/stream/operators/joining.html



Flink 内部的join有两种   window join   和  interval join



####  窗口连接（ window join ）

<img src="https://gitee.com/guxiangfly/blogimage/raw/master/img/image-20210107162500661.png" alt="image-20210107162500661" style="zoom:50%;" />

window join 一般是将 两条流，在同一个窗口的数据 进行一个笛卡尔积





####  区间连接 （interval join）

![image-20210107163337645](https://gitee.com/guxiangfly/blogimage/raw/master/img/image-20210107163337645.png)

interval join ，假设  stream a  要 和 stream  b 进行join。

流a 的 event e 会和    (a流event e发生时间 + lowerBound )   到    (  a流event e发生时间 + upperBound)  这个区间内发生的  流b的 event b  list   去做join 

```
b.timestamp ∈ [a.timestamp + lowerBound; a.timestamp + upperBound] 
```



#### 普通连接 regular join









## Flink 的 监控

![image-20210423173719797](https://gitee.com/guxiangfly/blogimage/raw/master/img/image-20210423173719797.png)

- gauge
- histogram ： 给一段时间，这个一段时间做一个详细的指标









## Flink 内存模型

JVM的内存问题：

- JVM 内存管理的不足：

  **1**）**Java** **对象存储密度低。**Java 的对象在内存中存储包含 3 个主要部分：对象头、实例数据、对齐填充部分。例如，一个只包含boolean 属性的对象占 16byte：对象头占 8byte，boolean 属性占 1byte，为了对齐达到 8 的倍数额外占 7byte。而实际上只需要一个 bit（1/8

  字节）就够了。

  **2**）**Full GC** **会极大地影响性能。**尤其是为了处理更大数据而开了很大内存空间的 JVM来说，GC 会达到秒级甚至分钟级。

  **3**）**OOM** **问题影响稳定性。**OutOfMemoryError 是分布式计算框架经常会遇到的问题，当JVM中所有对象大小超过分配给JVM的内大小时，就会发生OutOfMemoryError错误，导致 JVM 崩溃，分布式框架的健壮性和性能都会受到影响。

  **4**）缓存未命中问题。**CPU 进行计算的时候，是从 CPU 缓存中获取数据。现代体系的CPU 会有多级缓存，而加载的时候是以Cache Line 为单位加载。如果能够将对象连续存储，这样就会大大降低 Cache Miss。

- Flink中的一些改进

  > Flink 并不是将大量对象存在堆内存上，而是将对象都序列化到一个预分配的内存块上，
  >
  > 这个内存块叫做 MemorySegment，它代表了一段固定长度的内存（默认大小为 32KB），也
  >
  > 是 Flink 中最小的内存分配单元，并且提供了非常高效的读写方法，很多运算可以直接操作
  >
  > 二进制数据，不需要反序列化即可执行。每条记录都会以序列化的形式存储在一个或多个
  >
  > MemorySegment 中。



#### Flink 的 jobmanager的内存模型

<img src="https://gitee.com/guxiangfly/blogimage/raw/master/img/image-20210526182444355.png" alt="image-20210526182444355" style="zoom:50%;" />



#### Flink 的taskmanager 的内存模型

![image-20210526182007925](https://gitee.com/guxiangfly/blogimage/raw/master/img/image-20210526182007925.png)

<img src="https://gitee.com/guxiangfly/blogimage/raw/master/img/image-20210526182537748.png" alt="image-20210526182537748" style="zoom:50%;" />







#### 网络传输中的内存管理

![image-20210527172537465](https://gitee.com/guxiangfly/blogimage/raw/master/img/image-20210527172537465.png)

> 网络上传输的数据会写到 Task 的 InputGate（IG）中，经过 Task 的处理后，再由 Task 
>
> 写到 ResultPartition（RS） 中。每个 Task 都包括了输入和输入，输入和输出的数据存在
>
> Buffer 中（都是字节数据）。Buffer 是 MemorySegment 的包装类。
>
> 1）TaskManager（TM）在启动时，会先初始化 NetworkEnvironment 对象，TM 中所有
>
> 与网络相关的东西都由该类来管理（如 Netty 连接），其中就包括 NetworkBufferPool。根据
>
> 配置， Flink 会 在 NetworkBufferPool 中 生 成 一 定 数 量 （ 默 认 2048 ） 的 内 存 块
>
> MemorySegment（关于 Flink 的内存管理，后续文章会详细谈到），内存块的总数量就代表
>
> 了网络传输中所有可用的内存。NetworkEnvironment 和 NetworkBufferPool 是 Task 之间共
>
> 享的，每个 TM 只会实例化一个。
>
> 2）Task 线程启动时，会向 NetworkEnvironment 注册，NetworkEnvironment 会为 Task 
>
> 的 InputGate（IG）和 ResultPartition（RP） 分别创建一个 LocalBufferPool（缓冲池）并设
>
> 置可申请的 MemorySegment（内存块）数量。IG 对应的缓冲池初始的内存块数量与 IG 中
>
> InputChannel 数量一致，RP 对应的缓冲池初始的内存块数量与 RP 中的 ResultSubpartition 
>
> 数量一致。不过，每当创建或销毁缓冲池时，NetworkBufferPool 会计算剩余空闲的内存块
>
> 数量，并平均分配给已创建的缓冲池。注意，这个过程只是指定了缓冲池所能使用的内存块
>
> 数量，并没有真正分配内存块，只有当需要时才分配。为什么要动态地为缓冲池扩容呢？因
>
> 为内存越多，意味着系统可以更轻松地应对瞬时压力（如 GC），不会频繁地进入反压状态，
>
> 所以我们要利用起那部分闲置的内存块。
>
> 3）在 Task 线程执行过程中，当 Netty 接收端收到数据时，为了将 Netty 中的数据拷
>
> 贝到 Task 中，InputChannel（实际是 RemoteInputChannel）会向其对应的缓冲池申请内存
>
> 块（上图中的①）。如果缓冲池中也没有可用的内存块且已申请的数量还没到池子上限，则
>
> 会向 NetworkBufferPool 申请内存块（上图中的②）并交给 InputChannel 填上数据（上图
>
> 中的③和④）。如果缓冲池已申请的数量达到上限了呢？或者 NetworkBufferPool 也没有可
>
> 用内存块了呢？这时候，Task 的 Netty Channel 会暂停读取，上游的发送端会立即响应停止
>
> 发送，拓扑会进入反压状态。当 Task 线程写数据到 ResultPartition 时，也会向缓冲池请求
>
> 内存块，如果没有可用内存块时，会阻塞在请求内存块的地方，达到暂停写入的目的。
>
> 4）当一个内存块被消费完成之后（在输入端是指内存块中的字节被反序列化成对象了，
>
> 在输出端是指内存块中的字节写入到 Netty Channel 了），会调用 Buffer.recycle() 方法，会
>
> 将内存块还给 LocalBufferPool （上图中的⑤）。如果 LocalBufferPool 中当前申请的数量超
>
> 过了池子容量（由于上文提到的动态容量，由于新注册的 Task 导致该池子容量变小），则
>
> LocalBufferPool 会将该内存块回收给 NetworkBufferPool（上图中的⑥）。如果没超过池子容
>
> 量，则会继续留在池子中，减少反复申请的开销。
>
> - 反压的过程
>
> ![image-20210527173318394](https://gitee.com/guxiangfly/blogimage/raw/master/img/image-20210527173318394.png)
>
> 1）记录“A”进入了 Flink 并且被 Task 1 处理。（这里省略了 Netty 接收、反序列化
>
> 等过程）
>
> 2）记录被序列化到 buffer 中。
>
> 3）该 buffer 被发送到 Task 2，然后 Task 2 从这个 buffer 中读出记录。
>
> 记录能被 Flink 处理的前提是：必须有空闲可用的 Buffer。
>
> 结合上面两张图看：Task 1 在输出端有一个相关联的 LocalBufferPool（称缓冲池 1），
>
> Task 2 在输入端也有一个相关联的 LocalBufferPool（称缓冲池 2）。如果缓冲池 1 中有空闲
>
> 可用的 buffer 来序列化记录 “A”，我们就序列化并发送该 buffer。
>
> 注意两个场景：
>
> 1）本地传输：如果 Task 1 和 Task 2 运行在同一个 worker 节点（TaskManager），该
>
> buffer 可以直接交给下一个 Task。一旦 Task 2 消费了该 buffer，则该 buffer 会被缓冲池 1
>
> 回收。如果 Task 2 的速度比 1 慢，那么 buffer 回收的速度就会赶不上 Task 1 取 buffer 
>
> 的速度，导致缓冲池 1 无可用的 buffer，Task 1 等待在可用的 buffer 上。最终形成 Task 1 
>
> 的降速。
>
> 2）远程传输：如果 Task 1 和 Task 2 运行在不同的 worker 节点上，那么 buffer 会在
>
> 发送到网络（TCP Channel）后被回收。在接收端，会从 LocalBufferPool 中申请 buffer，然
>
> 后拷贝网络中的数据到 buffer 中。如果没有可用的 buffer，会停止从 TCP 连接中读取数据。
>
> 在输出端，通过 Netty 的水位值机制来保证不往网络中写入太多数据（后面会说）。如果网
>
> 络中的数据（Netty 输出缓冲中的字节数）超过了高水位值，我们会等到其降到低水位值以
>
> 下才继续写入数据。这保证了网络中不会有太多的数据。如果接收端停止消费网络中的数据
>
> （由于接收端缓冲池没有可用 buffer），网络中的缓冲数据就会堆积，那么发送端也会暂停
>
> 发送。另外，这会使得发送端的缓冲池得不到回收，writer 阻塞在向 LocalBufferPool 请求
>
> buffer，阻塞了 writer 往 ResultSubPartition 写数据。
>
> 这种固定大小缓冲池就像阻塞队列一样，保证了 Flink 有一套健壮的反压机制，使得
>
> Task 生产数据的速度不会快于消费的速度。我们上面描述的这个方案可以从两个 Task 之
>
> 间的数据传输自然地扩展到更复杂的 pipeline 中，保证反压机制可以扩散到整个 pipeline。





Flink  1.13的升级

![image-20210623165438362](https://gitee.com/guxiangfly/blogimage/raw/master/img/image-20210623165438362.png)

