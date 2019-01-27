---
title: BigData 学习笔记
date: 2018-2-27 20:09:04
tags: [Activiti]

---


### Scala部分

```scala
class Person 
class Asia extends Person
class Chinese extends Asia

//defined class Group 
这是不变  ji  只能接受自己作为类型传入
class Group[T](t:T)  
val groupAsia:Group[Asia] = new Group(new Asia)  -success
val groupPerson:Group[Person] = groupAsia (这样不行)

这个是 协变 +T Ji 可以接受 定义的类型的 父类型传入
class Group1[+T](t:T)
val group1Asia:Group1[Asia] = new Group1(new Asia)  -success
val group1Person:Group1[Person] = group1Asia (这样可以)
val group1Chinese:Group1[Chinese] = group1Asia (这样不可以)

这个是 逆变 -T Ji 可以接受 定义的类型的 子类型传入
class Group2[-T](t:T)
val group2Asia:Group1[Asia] = new Group2(new Asia)  -success
val group2Person:Group1[Person] = group2Asia (这样不可以)
val group2Chinese:Group1[Chinese] = group2Asia (这样可以)

## 上界   T<:Asia
class Group3[T<:Asia](t: T)  
 -(代表T类型 必须是 Asia 以及 Asia 的子类型)
 val group3Asia:Group3[Asia] = new Group3[Asia](new Asia)
 val group3chinese:Group3[Chinese] = new Group3[Chinese](new Chinese)
 
 
 ## 下界  [T>:Asia
 class Group4[T>:Asia](t: T)
   -(代表T类型 必须是 Asia 以及 Asia 的父类型)
  val group4Asia:Group4[Asia] = new Group4[Asia](new Asia)
  val group4Person:Group4[Person] = new Group4[Person](new Person)
  
  buguo  有个地方值得注意
    val group4Chinese2:Group4[Chinese] = new Group4[Chinese](new Chinese)(这样不行)
   val group4chinese = new Group4(new Chinese)  (这样可以,它会自动将Chinese 转换为 Asia)


协变 中的 上界下界
class Group5[+T](t : T){
	def f1[T](t : T) = {}
	def f2[S <: T](s : S) = {}
	def f3[Z >: T](z : Z) = {}
}

逆变 中的 上界下界 
class Group6[-T](t : T){
	def f1[T](t : T) = {}
	def f2[S <: T](s : S) = {}
	def f3[Z >: T](z : Z) = {}
}


```



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
