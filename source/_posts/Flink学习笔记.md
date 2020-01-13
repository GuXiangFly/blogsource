---
title: Flink计算模型
date: 2019-03-27 20:09:04
tags: [大数据]

---
## Flink 与 spark 的对比

- Flink 

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
####比较普通的几个
- map：输入一个元素，然后返回一个元素，中间可以做一些清洗转换等操作
- flatmap：输入一个元素，可以返回零个，一个或者多个元素
- filter：过滤函数，对传入的数据进行判断，符合条件的数据会被留下
- keyBy：根据指定的key进行分组，相同key的数据会进入同一个分区【典型用法见备注】
- reduce：对数据进行聚合操作，结合当前元素和上一次reduce返回的值进行聚合操作，然后返回一个新的值
- aggregations：sum(),min(),max()等
- window：在后面单独详解

####不普通的几个

- Union：合并多个流，新的流会包含所有流中的数据，但是union是一个限制，就是所有合并的流类型必须是一致的。
- Connect：和union类似，但是只能连接两个流，两个流的数据类型可以不同，会对两个流中的数据应用不同的处理方法。
- CoMap, CoFlatMap：在ConnectedStreams中需要使用这种函数，类似于map和flatmap
- Split：根据规则把一个数据流切分为多个流
- Select：和split配合使用，选择切分后的流
