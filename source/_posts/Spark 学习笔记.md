---
title: Scala study Note
date: 2018-8-27 20:09:04
tags: [大数据]

---


## Spark 学习


Spark 相当于是一个虚拟机  Spark 

### RDD  Resilient Distributed Dataset
RDD 是一个类
RDD 的弹性

存储的弹性： 内存和磁盘的自动切换
容错的弹性： 数据丢失的可以自动恢复（当数据丢失的时候，spark可以从数据的源头重新将数据计算回来）
计算的弹性： 计算出错重试机制
分片的弹性： 根据需求重新分片

RDD是一块数据 它可以从 HDFS中读取  从 scala中读取
RDD 的转换 并不是把它原来的的对象完全变成为另一个对象而是 将 原来的A对象任然保留  创造一个新的A' 对象


//*************  什么是RDD【弹性分布式数据集】 ****************

  1、RDD是整个Spark的计算基石。是分布式数据的抽象，为用户屏蔽了底层复杂的计算和映射环境
  		1、RDD是不可变的，如果需要在一个RDD上进行转换操作，则会生成一个新的RDD
  		2、RDD是分区的，RDD里面的具体数据是分布在多台机器上的Executor里面的。堆内内存和堆外内存 + 磁盘。
  		3、RDD是弹性的。
  			 1、存储：Spark会根据用户的配置或者当前Spark的应用运行情况去自动将RDD的数据缓存到内存或者磁盘。他是一个对用户不可见的封装的功能。
  			 2、容错：当你的RDD数据被删除或者丢失的时候，可以通过血统或者检查点机制恢复数据。这个用户透明的。
  			 3、计算：计算是分层的，有应用->JOb->Stage->TaskSet-Task  每一层都有对应的计算的保障与重复机制。保障你的计算不会由于一些突发因素而终止。
  			 4、分片：你可以根据业务需求或者一些算子来重新调整RDD中的数据分布。

  2、Spark Core干了什么东西，其实就是在操作RDD
        RDD的创建--》RDD的转换(转换并不会把原来是数据删除，而是将原来的数据复制一份进行转换)--》RDD的缓存--》RDD的行动--》RDD的输出。


### RDD创建

 3、RDD怎么创建？
        创建RDD有三种方式：
        1、可以从一个Scala集合里面创建
        	1、sc.parallelize(seq)  把seq这个数据并行化分片到节点
        	2、sc.makeRDD(seq)      把seq这个数据并行化分片到节点，他的实现就是parallelize
        	3、sc.makeRDD(seq[(T,seq)]  这种方式可以指定RDD的存放位置
        2、从外部存储来创建，比如sc.textFile("path")
        3、从另外一个RDD转换过来。

### Scala 的所有操作都是懒执行的
Spark 操作分为两大类  转换 transformations  行动action
（即 只有当行动 action操作出现的时候Spark才会真的去运行）
之所以有这么做是有原因的：
    因为认为写 转换操作 可能不会是最优的  spark 会将转换操作一起 进行一定优化
    然后执行


### spark submit
#### client模式
在master这个机器上新建一个JVM 里面跑一个driver
然后再 worker上生成 另一个JVM进程 executer 
 
####  cluster模式
在worker上随便一个机器上新建一个JVM 里面跑一个driver
### spark 的架构
![](https://raw.githubusercontent.com/GuXiangFly/imagerepo/master/20190205215625.png)

###  action 操作有这些
- reduce
```
首先将第一个和第二个元素，传入call()方法，进行计算，会获取一个结果，比如1 + 2 = 3
接着将该结果与下一个元素传入call()方法，进行计算，比如3 + 3 = 6
以此类推
```
- collect
```
不用foreach action操作，在远程集群上遍历rdd中的元素
而使用collect操作，将分布在远程集群上的doubleNumbers RDD的数据拉取到本地
这种方式，一般不建议使用，因为如果rdd中的数据量比较大的话，比如超过1万条
那么性能会比较差，因为要从远程走大量的网络传输，将数据获取到本地
此外，除了性能差，还可能在rdd中数据量特别大的情况下，发生oom异常，内存溢出
因此，通常，还是推荐使用foreach action操作，来对最终的rdd元素进行处理
```
- count
- take
```
take操作，与collect类似，也是从远程集群上，获取rdd的数据
 但是collect是获取rdd的所有数据，take只是获取前n个数据
```
- saveAsTextFile
```
直接将rdd中的数据，保存在HFDS文件中
但是要注意，我们这里只能指定文件夹，也就是目录
那么实际上，会保存为目录中的/double_number.txt/part-00000文件
```
- countByKey
```
countByKey返回的类型，直接就是Map<String, Object>
```
- foreach
```
foreach 是对rdd中每条数据进行操作 这个是直接在远程集群操作的，而不是像collect一样加载到本地client
```

```java
public class ActionOperation {
	
	public static void main(String[] args) {
		// reduce();
		// collect();
		// count();
		// take();
		// saveAsTextFile();
		countByKey();
	}
	
	private static void reduce() {
		// 创建SparkConf和JavaSparkContext
		SparkConf conf = new SparkConf()
				.setAppName("reduce")
				.setMaster("local");  
		JavaSparkContext sc = new JavaSparkContext(conf);
		
		// 有一个集合，里面有1到10,10个数字，现在要对10个数字进行累加
		List<Integer> numberList = Arrays.asList(1, 2, 3, 4, 5, 6, 7, 8, 9, 10);
		JavaRDD<Integer> numbers = sc.parallelize(numberList);
		
		// 使用reduce操作对集合中的数字进行累加
		// reduce操作的原理：
			// 首先将第一个和第二个元素，传入call()方法，进行计算，会获取一个结果，比如1 + 2 = 3
			// 接着将该结果与下一个元素传入call()方法，进行计算，比如3 + 3 = 6
			// 以此类推
		// 所以reduce操作的本质，就是聚合，将多个元素聚合成一个元素
		int sum = numbers.reduce(new Function2<Integer, Integer, Integer>() {
			
			private static final long serialVersionUID = 1L;

			@Override
			public Integer call(Integer v1, Integer v2) throws Exception {
				return v1 + v2;
			}
			
		});
		
		System.out.println(sum);  
		
		// 关闭JavaSparkContext
		sc.close();
	}
	
	private static void collect() {
		// 创建SparkConf和JavaSparkContext
		SparkConf conf = new SparkConf()
				.setAppName("collect")
				.setMaster("local");  
		JavaSparkContext sc = new JavaSparkContext(conf);
		
		// 有一个集合，里面有1到10,10个数字，现在要对10个数字进行累加
		List<Integer> numberList = Arrays.asList(1, 2, 3, 4, 5, 6, 7, 8, 9, 10);
		JavaRDD<Integer> numbers = sc.parallelize(numberList);
		
		// 使用map操作将集合中所有数字乘以2
		JavaRDD<Integer> doubleNumbers = numbers.map(
				
				new Function<Integer, Integer>() {

					private static final long serialVersionUID = 1L;
		
					@Override
					public Integer call(Integer v1) throws Exception {
						return v1 * 2;
					}
					
				});
		
		// 不用foreach action操作，在远程集群上遍历rdd中的元素
		// 而使用collect操作，将分布在远程集群上的doubleNumbers RDD的数据拉取到本地
		// 这种方式，一般不建议使用，因为如果rdd中的数据量比较大的话，比如超过1万条
			// 那么性能会比较差，因为要从远程走大量的网络传输，将数据获取到本地
			// 此外，除了性能差，还可能在rdd中数据量特别大的情况下，发生oom异常，内存溢出
		// 因此，通常，还是推荐使用foreach action操作，来对最终的rdd元素进行处理
		List<Integer> doubleNumberList = doubleNumbers.collect();
		for(Integer num : doubleNumberList) {
			System.out.println(num);  
		}
		
		// 关闭JavaSparkContext
		sc.close();
	}
	
	private static void count() {
		// 创建SparkConf和JavaSparkContext
		SparkConf conf = new SparkConf()
				.setAppName("count")
				.setMaster("local");  
		JavaSparkContext sc = new JavaSparkContext(conf);
		
		// 有一个集合，里面有1到10,10个数字，现在要对10个数字进行累加
		List<Integer> numberList = Arrays.asList(1, 2, 3, 4, 5, 6, 7, 8, 9, 10);
		JavaRDD<Integer> numbers = sc.parallelize(numberList);
		
		// 对rdd使用count操作，统计它有多少个元素
		long count = numbers.count();
		System.out.println(count);  
		
		// 关闭JavaSparkContext
		sc.close();
	}
	
	private static void take() {
		// 创建SparkConf和JavaSparkContext
		SparkConf conf = new SparkConf()
				.setAppName("take")
				.setMaster("local");  
		JavaSparkContext sc = new JavaSparkContext(conf);
		
		// 有一个集合，里面有1到10,10个数字，现在要对10个数字进行累加
		List<Integer> numberList = Arrays.asList(1, 2, 3, 4, 5, 6, 7, 8, 9, 10);
		JavaRDD<Integer> numbers = sc.parallelize(numberList);
		
		// 对rdd使用count操作，统计它有多少个元素
		// take操作，与collect类似，也是从远程集群上，获取rdd的数据
		// 但是collect是获取rdd的所有数据，take只是获取前n个数据
		List<Integer> top3Numbers = numbers.take(3);
		
		for(Integer num : top3Numbers) {
			System.out.println(num);  
		}
		
		// 关闭JavaSparkContext
		sc.close();
	}
	
	private static void saveAsTextFile() {
		// 创建SparkConf和JavaSparkContext
		SparkConf conf = new SparkConf()
				.setAppName("saveAsTextFile");  
		JavaSparkContext sc = new JavaSparkContext(conf);
		
		// 有一个集合，里面有1到10,10个数字，现在要对10个数字进行累加
		List<Integer> numberList = Arrays.asList(1, 2, 3, 4, 5, 6, 7, 8, 9, 10);
		JavaRDD<Integer> numbers = sc.parallelize(numberList);
		
		// 使用map操作将集合中所有数字乘以2
		JavaRDD<Integer> doubleNumbers = numbers.map(
				
				new Function<Integer, Integer>() {

					private static final long serialVersionUID = 1L;
		
					@Override
					public Integer call(Integer v1) throws Exception {
						return v1 * 2;
					}
					
				});
		
		// 直接将rdd中的数据，保存在HFDS文件中
		// 但是要注意，我们这里只能指定文件夹，也就是目录
		// 那么实际上，会保存为目录中的/double_number.txt/part-00000文件
		doubleNumbers.saveAsTextFile("hdfs://spark1:9000/double_number.txt");   
		
		// 关闭JavaSparkContext
		sc.close();
	}
	
	@SuppressWarnings("unchecked")
	private static void countByKey() {
		// 创建SparkConf
		SparkConf conf = new SparkConf()
				.setAppName("countByKey")  
				.setMaster("local");
		// 创建JavaSparkContext
		JavaSparkContext sc = new JavaSparkContext(conf);
		
		// 模拟集合
		List<Tuple2<String, String>> scoreList = Arrays.asList(
				new Tuple2<String, String>("class1", "leo"),
				new Tuple2<String, String>("class2", "jack"),
				new Tuple2<String, String>("class1", "marry"),
				new Tuple2<String, String>("class2", "tom"),
				new Tuple2<String, String>("class2", "david"));  
		
		// 并行化集合，创建JavaPairRDD
		JavaPairRDD<String, String> students = sc.parallelizePairs(scoreList);
		
		// 对rdd应用countByKey操作，统计每个班级的学生人数，也就是统计每个key对应的元素个数
		// 这就是countByKey的作用
		// countByKey返回的类型，直接就是Map<String, Object>
		Map<String, Object> studentCounts = students.countByKey();
		
		for(Map.Entry<String, Object> studentCount : studentCounts.entrySet()) {
			System.out.println(studentCount.getKey() + ": " + studentCount.getValue());  
		}
		
		// 关闭JavaSparkContext
		sc.close();
	}
	
}
```


### RDD 的持久化
这个是持久化之后的RDD 数据
![](https://raw.githubusercontent.com/GuXiangFly/imagerepo/master/20190205205118.png)
RDD 持久化的策略有以下几种
- MEMORY_ONLY   
以非序列化的Java对象的方式持久化在JVM内存中。如果内存无法完全存储RDD所有的partition，那么那些没有持久化的partition就会在下一次需要使用它的时候，重新被计算。
- MEMORY_AND_DISK

- 
- 1、优先使用MEMORY_ONLY，如果可以缓存所有数据的话，那么就使用这种策略。因为纯内存速度最快，而且没有序列化，不需要消耗CPU进行反序列化操作。
- 2、如果MEMORY_ONLY策略，无法存储的下所有数据的话，那么使用MEMORY_ONLY_SER，将数据进行序列化进行存储，纯内存操作还是非常快，只是要消耗CPU进行反序列化。
- 3、如果需要进行快速的失败恢复，那么就选择带后缀为_2的策略，进行数据的备份，这样在失败时，就不需要重新计算了。
- 4、能不使用DISK相关的策略，就不用使用，有的时候，从磁盘读取数据，还不如重新计算一次。


```java
public class WordCountLocal {
	
	public static void main(String[] args) {
		// 编写Spark应用程序
		// 本地执行，是可以执行在eclipse中的main方法中，执行的
		
		// 第一步：创建SparkConf对象，设置Spark应用的配置信息
		// 使用setMaster()可以设置Spark应用程序要连接的Spark集群的master节点的url
		// 但是如果设置为local则代表，在本地运行
		SparkConf conf = new SparkConf()
				.setAppName("WordCountLocal")
				.setMaster("local");  
		
		// 第二步：创建JavaSparkContext对象
		// 在Spark中，SparkContext是Spark所有功能的一个入口，你无论是用java、scala，甚至是python编写
			// 都必须要有一个SparkContext，它的主要作用，包括初始化Spark应用程序所需的一些核心组件，包括
			// 调度器（DAGSchedule、TaskScheduler），还会去到Spark Master节点上进行注册，等等
		// 一句话，SparkContext，是Spark应用中，可以说是最最重要的一个对象
		// 但是呢，在Spark中，编写不同类型的Spark应用程序，使用的SparkContext是不同的，如果使用scala，
			// 使用的就是原生的SparkContext对象
			// 但是如果使用Java，那么就是JavaSparkContext对象
			// 如果是开发Spark SQL程序，那么就是SQLContext、HiveContext
			// 如果是开发Spark Streaming程序，那么就是它独有的SparkContext
			// 以此类推
		JavaSparkContext sc = new JavaSparkContext(conf);
	
		// 第三步：要针对输入源（hdfs文件、本地文件，等等），创建一个初始的RDD
		// 输入源中的数据会打散，分配到RDD的每个partition中，从而形成一个初始的分布式的数据集
		// 我们这里呢，因为是本地测试，所以呢，就是针对本地文件
		// SparkContext中，用于根据文件类型的输入源创建RDD的方法，叫做textFile()方法
		// 在Java中，创建的普通RDD，都叫做JavaRDD
		// 在这里呢，RDD中，有元素这种概念，如果是hdfs或者本地文件呢，创建的RDD，每一个元素就相当于
		// 是文件里的一行
		JavaRDD<String> lines = sc.textFile("C://Users//Administrator//Desktop//spark.txt");
	
		// 第四步：对初始RDD进行transformation操作，也就是一些计算操作
		// 通常操作会通过创建function，并配合RDD的map、flatMap等算子来执行
		// function，通常，如果比较简单，则创建指定Function的匿名内部类
		// 但是如果function比较复杂，则会单独创建一个类，作为实现这个function接口的类
		
		// 先将每一行拆分成单个的单词
		// FlatMapFunction，有两个泛型参数，分别代表了输入和输出类型
		// 我们这里呢，输入肯定是String，因为是一行一行的文本，输出，其实也是String，因为是每一行的文本
		// 这里先简要介绍flatMap算子的作用，其实就是，将RDD的一个元素，给拆分成一个或多个元素
		JavaRDD<String> words = lines.flatMap(new FlatMapFunction<String, String>() {
			
			private static final long serialVersionUID = 1L;
			
			@Override
			public Iterable<String> call(String line) throws Exception {
				return Arrays.asList(line.split(" "));  
			}
			
		});
		
		// 接着，需要将每一个单词，映射为(单词, 1)的这种格式
			// 因为只有这样，后面才能根据单词作为key，来进行每个单词的出现次数的累加
		// mapToPair，其实就是将每个元素，映射为一个(v1,v2)这样的Tuple2类型的元素
			// 如果大家还记得scala里面讲的tuple，那么没错，这里的tuple2就是scala类型，包含了两个值
		// mapToPair这个算子，要求的是与PairFunction配合使用，第一个泛型参数代表了输入类型
			// 第二个和第三个泛型参数，代表的输出的Tuple2的第一个值和第二个值的类型
		// JavaPairRDD的两个泛型参数，分别代表了tuple元素的第一个值和第二个值的类型
		JavaPairRDD<String, Integer> pairs = words.mapToPair(
				
				new PairFunction<String, String, Integer>() {

					private static final long serialVersionUID = 1L;
		
					@Override
					public Tuple2<String, Integer> call(String word) throws Exception {
						return new Tuple2<String, Integer>(word, 1);
					}
					
				});
		
		// 接着，需要以单词作为key，统计每个单词出现的次数
		// 这里要使用reduceByKey这个算子，对每个key对应的value，都进行reduce操作
		// 比如JavaPairRDD中有几个元素，分别为(hello, 1) (hello, 1) (hello, 1) (world, 1)
		// reduce操作，相当于是把第一个值和第二个值进行计算，然后再将结果与第三个值进行计算
		// 比如这里的hello，那么就相当于是，首先是1 + 1 = 2，然后再将2 + 1 = 3
		// 最后返回的JavaPairRDD中的元素，也是tuple，但是第一个值就是每个key，第二个值就是key的value
		// reduce之后的结果，相当于就是每个单词出现的次数
		JavaPairRDD<String, Integer> wordCounts = pairs.reduceByKey(
				
				new Function2<Integer, Integer, Integer>() {
					
					private static final long serialVersionUID = 1L;
		
					@Override
					public Integer call(Integer v1, Integer v2) throws Exception {
						return v1 + v2;
					}
					
				});
		
		// 到这里为止，我们通过几个Spark算子操作，已经统计出了单词的次数
		// 但是，之前我们使用的flatMap、mapToPair、reduceByKey这种操作，都叫做transformation操作
		// 一个Spark应用中，光是有transformation操作，是不行的，是不会执行的，必须要有一种叫做action
		// 接着，最后，可以使用一种叫做action操作的，比如说，foreach，来触发程序的执行
		wordCounts.foreach(new VoidFunction<Tuple2<String,Integer>>() {
			
			private static final long serialVersionUID = 1L;
			
			@Override
			public void call(Tuple2<String, Integer> wordCount) throws Exception {
				System.out.println(wordCount._1 + " appeared " + wordCount._2 + " times.");    
			}
			
		});
		
		sc.close();
	}
}
```
### Spark 的共享变量
```scala
object AccumulatorVariable {
  def main(args: Array[String]) {
    val conf = new SparkConf()
      .setAppName("AccumulatorVariable")
      .setMaster("local")
    val sc = new SparkContext(conf)
    val sum = sc.accumulator(0)
    val numberArray  =  sc.parallelize(Array(1,2,3,4,6))
  //  numberArray.foreach(sum = sc+_)
    numberArray.foreach(num=> sum+=num)
    println(sum)
  }
}
```


### 小案例 统计每个单词的出现次数 并且按由高到低排序
```scala
import org.apache.spark.{SparkConf, SparkContext}
object SortWordCount {
  def main(args: Array[String]): Unit = {
    val conf = new SparkConf()
      .setAppName("SortWordCount")
      .setMaster("local")

    val sc = new SparkContext(conf)
    val lines = sc.textFile("D:\\serversoftware\\ELK\\logstash-6.1.0\\NOTICE.TXT")
    val words  = lines.flatMap(line => line.split(" "))
    val pairs = words.map(word => (word,1))
    val wordCounts = pairs.reduceByKey(_+_)
    val countWords = wordCounts.map(wordCount => (wordCount._2,wordCount._1))
    val sortWordCounts =  countWords.sortByKey(false)

    sortWordCounts.map(sortWordCount => {
      println(sortWordCount._1,"and ",sortWordCount._2 )
    })
    for (sortWordCount <- sortWordCounts){
      println( sortWordCount._1, sortWordCount._2)
    }
  }
}

```

### 宽依赖和窄依赖
- 窄依赖： 英文全名 narrow dependency。 什么情况叫做窄依赖呢？
一个RDD ，对他的父RDD，只有简单的一对一的依赖关系，也就是说，RDD 的每个partition，
仅仅依赖于父RDD的一个partition，父RDD 和子 RDD 之间的是一一对应的关系
- 宽依赖：英文全名 shuffle dependency。 本质就是shuffle
每一个父
![](https://raw.githubusercontent.com/GuXiangFly/imagerepo/master/20190206200039.png)


### parquet 存储格式
有以下优点
- 列存储： 一般来说我们来分析东西 都是select age from students  这种。如果使用行存储，会将students 的其他类似学号等信息也读出然后
过滤，这个其实还是增加了磁盘的io，使用列存储 更加适合分析问题
= 对存储添加了压缩
- 支持向量运算


###  