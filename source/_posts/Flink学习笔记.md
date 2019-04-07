##Flink计算模型
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