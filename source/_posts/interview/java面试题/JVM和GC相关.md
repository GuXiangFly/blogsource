---

title: JVM和GC相关
date: 2017-11-11 13:09:04
tags: [JVM,java]

---

1、 Jvm堆内存区，有两个S区有什么作用？

**参考答案**

S区即Survivor区，位于年轻代。年轻代分三个区。一个Eden 区，两个Survivor 区。大部分对象在Eden 区中生成。当Eden 区满时，还存活的对象将被复制到Survivor 区（两个中的一个），当这个Survivor 区满时，此区的存活对象将被复制到另外一个Survivor 区，当这个Survivor 去也满了的时候，从第一个Survivor 区复制过来的并且此时还存活的对象，将被复制年老区(Tenured)。需要注意，Survivor 的两个区是对称的，没先后关系，所以同一个区中可能同时存在从Eden 复制过来对象，和从前一个Survivor 复制过来的对象，而复制到年老区的只有从第一个Survivor 去过来的对象。而且，Survivor 区总有一个是空的。
**解题思路：**基础知识
**考察点：**JVM 内存结构
**分类：**JVM GC {校招，社招}
**难度分级：**P4

## 2、有遇到过OOM么，什么情况，怎么发现的，怎么查原因的？

**参考答案：**

http://outofmemory.cn/c/java-outOfMemoryError(OOM分类)

http://www.51testing.com/html/92/77492-203728.html(jstat使用)

http://my.oschina.net/shaorongjie/blog/161385(MAT使用)

**解题思路：**基础知识
**考察点：**jstat mat工具 jvm 
**分类：**JVM GC {校招，社招}
**难度分级：**P4，P5

## 3、内存分配策略 

**参考答案：**

1)对象优先在Eden分配;2)大对象直接进入老年代;3)长期存活的对象将进入老年代;4)动态对象年龄判定

**参考文献：**http://www.cnblogs.com/liangzh/archive/2012/07/03/2575252.html

**解题思路：**基础知识
**考察点：** jvm 
**分类：**JVM GC {校招，社招}
**难度分级：**P4，P5

## 4、线程内存和主内存是如何交互的? 

**参考答案：**

假设某条线程执行一个synchronized代码段，其间对某变量进行操作，JVM会依次执行如下动作：
(1) 获取同步对象monitor (lock)
(2) 从主存复制变量到当前工作内存 (read and load)
(3) 执行代码，改变共享变量值 (use and assign)
(4) 用工作内存数据刷新主存相关内容 (store and write)
(5) 释放同步对象锁 (unlock)

**解题思路：**基础知识
**考察点：** jvm 
**分类：**JVM GC {校招，社招}
**难度分级：**P4，P5 

## 5、线上环境JVM参数Xms Xmx是如何设置的， 如果大小是一至，为什么这样设置？

**参考答案：**

Xmx设置JVM 的最大可用内存，Xms 设置JVM实际使用内存，一般Xmx和Xms相同，这是因为当Xmx内存空间不够用时，将进行扩容导致Full GC。将Xmx和Xms设置成相同的值，避免因Xms偏小导致频繁重新分配内存，影响应用使用。

**解题思路：**基础知识
**考察点：** jvm 
**分类：**JVM GC {校招，社招}
**难度分级：**P4，P5 

## 6、如何定位一个CPU Load过高的Java线程？

**参考答案：**    

1、jps -v列出所有的java进程 , top找出cpu占用过高的对应的java 进程pid 

2、使用top -H -p PID 命令查看对应进程里的哪个线程占用CPU过高,取该线程pid 

3、将线程的pid 转成16进制

4、jstack [进程pid]|grep -A 100 [线程pid的16进制]  dump出jvm该线程的后100行,或者整个输出到文件

jstack -l pid > xxxfile

参考文献:[Crm线上机器发布时load过高案例分析阶段总结以及监控工具介绍](http://wiki.sankuai.com/pages/viewpage.action?pageId=85053261) 

**解题思路：**基础知识
**考察点：** jvm 
**分类：**JVM GC {社招}
**难度分级：**P5  

##  7、JmapDump的文件大小和MAT分析工具里显示的大小不一致一般是什么原因导致的？

**参考答案：**

 JmapDump的文件一般比MAT工具大。创建索引期间，MAT会删除部分垃圾收集算法遗留下的不可达的object，因为回收这些较小的object代价较大，一般这些object占比不超过4%。另外不能正确的写JmapDump的文件。尤其在较老的jvm（1.4，1.5）并且使用jmap命令获取JmapDump的文件的时候。

**解题思路：**基础知识
**考察点：** jvm 
**分类：**JVM GC {社招}
**难度分级：**P5 

##  8、如何在Jmap未响应的情况下Dump出内存？

**参考答案：**

加-F参数

**解题思路：**基础知识
**考察点：** jvm 
**分类：**JVM GC {社招}
**难度分级：**P5 

## 9、说出5个JVM的参数以及含义，怎么样配置这样参数？

**参考答案：**

[JVM参数设置](http://wiki.sankuai.com/pages/viewpage.action?pageId=98612034)

**解题思路：**基础知识
**考察点：** jvm 
**分类：**JVM GC {校招,社招}
**难度分级：**P4,P5 

##  10、JVM的一些健康指标和经验值，如何配置最优？

参考答案：
这个是比较开发性试题，偏社招，考察面试者对系统的掌控力，一般都会从垃圾回收的角度来解释，比如用jstat或者gc日志来看ygc的单次时间和频繁程度，full gc的单次时间和频繁程度；ygc的经验时间100ms以下，3秒一次；full gc 1秒以下 1小时一次，每次回收的比率70%等等，也会用jstack和jmap看系统是否有太多的线程和不必要的内存等等。关于如何才能让配置最优，有一些理论支撑，比如高吞吐和延迟低的垃圾收集器选择，比如高并发对象存活时间不长，可以适当加大yong区；但是有经验的面试者会调整一些参数测试来印证自己的想法。

**解题思路：**基础知识
**考察点：** jvm 
**分类：**JVM GC {校招,社招}
**难度分级：**P4,P5

## 11、对象存活算法，常见的有哪几种，JAVA采用的是哪种？

**参考答案：**

(1)引用计数算法

原理**：**给对象添加一个引用计数器，每当有一个地方引用它时，计数器加1；引用失效时，计数器减1；计数器为0说明可被回收。
缺点：很难解决对象相互循环引用的问题（对象相互循环引用，但其实他们都已经没有用了。

(2)可达性分析算法

 原理：通过一些列称为“GC Roots”的对象作为起始点，从这些节点开始向下搜索，搜索所走过的路径称为引用链，当一个对象到GC Roots没有任何引用链相连时，则证明此对象是不可用的。在java语言中，可作为GC Roots的对象包括下面几种:虚拟机栈（栈帧中的本地变量表）中引用的对象、方法区类静态属性引用的对象、方法区中常量引用的对象、本地方法栈中JNI引用的对象、

参考文献:http://blog.csdn.net/chaofanwei/article/details/19541421

**解题思路：**基础知识
**考察点：**JVM GC 
**分类：**JVM GC {校招，社招}
**难度分级：**P4，P5 

## 12、JVM新生代ParNew用的是什么垃圾收集算法？

**参考答案：**复制
**解题思路：**基础知识
 **考察点：**JVM GC 
 **分类：**JVM GC {校招，社招}
 **难度分级：**P4，P5

## 13、JVM垃圾收集复制算法中，Eden:Form:To，为什么是8:1:1，而不是1:1:1？

**参考答案：**
一般情况下，新生代中的对象大多生命周期很短，也就是说当进行垃圾收集时，大部分对象都是垃圾，只有一小部分对象会存活下来，所以只要保留一小部分内存保存存活下来的对象就行了。在新生代中一般将内存划分为三个部分：一个较大的Eden空间和两个较小的Survivor空间（一样大小），每次使用Eden和一个Survivor的内存，进行垃圾收集时将Eden和使用的Survivor中的存活的对象复制到另一个Survivor空间中，然后清除这两个空间的内存，下次使用Eden和另一个Survivor，HotSpot中默认将这三个空间的比例划分为8:1:1，这样被浪费掉的空间就只有总内存的1/10了。
参考文献:http://www.cnblogs.com/angeldevil/p/3803969.html
**解题思路：**基础知识
**考察点：**JVM GC 
**分类：**JVM GC {校招，社招}
**难度分级：**P4，P5

## 14、JVM老年代CMS用的是什么垃圾收集算法？

**参考答案：**

CMS以获取最短回收停顿时间为目标的收集器，使用“标记-清除”算法，分为以下6个步骤

1.STW initial mark：第一次暂停，初始化标记，从root标记old space存活对象（the set of objects reachable from roots (application code)）

2.Concurrent marking：运行时标记，从上一步得到的集合出发，遍历old space，标记存活对象 (all live objects that are transitively reachable from previous set)

3.Concurrent precleaning：并发的标记前一阶段被修改的对象（card table）

4.STW remark：第二次暂停，检查，标记，检查脏页的对象，标记前一阶段被修改的对象 (revisiting any objects that were modified during the concurrent marking phase)

5.Concurrent sweeping：运行过程中清理，扫描old space，释放不可到达对象占用的空间 

6.Concurrent reset：此次CMS结束后，重设CMS状态等待下次CMS的触发
或者4个大步骤：

1，initial mark 2，concurrent mark 3，remark 4，concurrent sweep

 **解题思路：**基础知识

**考察点：**JVM GC 

 **分类：**JVM GC {校招，社招}

 **难度分级：**P4，P5

## 15、young gc和full gc触发条件 

**参考答案：**
young gc :eden空间不足
full gc :显示调用System.GC、旧生代空间不足、Permanet Generation空间满、CMS GC时出现promotion failed和concurrent mode failure、
RMI等的定时触发、YGC时的悲观策略、dump live的内存信息时
参考文献：http://blog.csdn.net/vernonzheng/article/details/8460128
http://blog.sina.com.cn/s/blog_7581a4c301019hsc.html
**解题思路：**基础知识
**考察点：**JVM GC 
**分类：**JVM GC {校招，社招}
**难度分级：**P4，P5

## 16、垃圾回收器种类，垃圾回收扫描算法（root扫描），回收算法（复制，标记清除，标记整理）

**参考答案：**
垃圾回收器种类：
Serial、ParNew、Parallel Scavenge、Serial Old、Parallel Old、CMS(ConCurrent Mark Sweep)、G1(Garbage First)

垃圾回收扫描算法：

垃圾检测通过建立一个根对象的集合（局部变量、栈桢中的操作数，在本地方法中引用的对象，常量池等）并检查从这些根对象开始的可触及性来实现。根对象总是可访问的，如果存在根对象到一个对象的引用路径，那么称这个对象是可触及的或活动对象，否则是不可触及的，不可触及的对象就是垃圾对象。 

 回收算法: 

 标记清除 

 分为标记=E5__清除两个阶段，在标记阶段，垃圾收集器跟踪从根对象的引用，在追踪的过程中对遇到的对象打一个标记，最终未被标记的对象就是垃圾对象，在清除阶段，回收垃圾对象占用的内存。可以在对象本身添加跟踪标记，也可以用一个独立的位图来设置标记。标记清除法是基础的收集      算法，其他算法大多时针对这个算法缺点的改进。存在效率和碎片问题。 

 复制算法

 将内存划分为大小相等的两个区域，每次只使用其中的一个区域，当这个区域的内存用完了，就将可触及的对象直接复制到新的区域并连续存放以消除内存碎片，当可触及对象复制完后，清除旧内存区域，修改引用的值。这种算法明显缺点是浪费内存，故实际使用中常将新生代划分成8:1:1三     个区。

 标记整理

 标记整理算法中标记的过程同标记清理一样，但整理部分不是直接清除掉垃圾对象，而是将活动对象统一移动一内存的一端，然后清除边界外的内存区域，这样就避免了内存碎片。也不会浪费内存，不需要其他内存进行担保

 分代收集 

 大多数程序中创建的大部分对象生命周期都很短，而且会有一小部分生命周期长的对象，为了克服复制收集器中每次垃圾收集都要拷贝所有的活动对象   的缺点，将内存划分为不同的区域，更多地收集短生命周期所在的内存区域，当对象经历一定次数的垃圾收集存活时，提升它的存在的区域。一般是划   分为新生代和老年代。新生代又划分为Eden区，From Survior区和To Survior区 

 自适应收集器

 监听堆中的情形，并且对应地调用合适的垃圾收集技术。 

 参考文献:http://www.cnblogs.com/angeldevil/p/3803969.html

 **解题思路：**基础知识
 **考察点：**JVM GC 
 **分类：**JVM GC {校招，社招}
 **难度分级：**P4，P5

## 17、 cms回收器的标记过程，内存碎片问题 

 **参考答案：**

 cms回收器的标记过程：     

 1.STW initial mark：第一次暂停，初始化标记，从root标记old space存活对象（the set of objects reachable from roots (application code)） 

 2.Concurrent marking：运行时标记，从上一步得到的集合出发，遍历old space，标记存活对象 (all live objects that are transitively reachable from previous set)

 3.Concurrent precleaning：并发的标记前一阶段被修改的对象（card table）

 4.STW remark：第二次暂停，检查，标记，检查脏页的对象，标记前一阶段被修改的对象 (revisiting any objects that were modified during the concurrent marking phase)

 内存碎片问题：

 CMS基于“标记-清除”算法，进行垃圾回收后会存在内存碎片，当申请大的连续内存时可能内存不足，此时需要进行一次Full GC，可以通过参数指定进行Full GC后或进行多少次Full GC后进行一次内存压缩来整理内存碎片。

**解题思路：**基础知识

**考察点：**JVM GC 

**分类：**JVM GC {校招，社招}

**难度分级：**P4，P5

## 18、GC Log分析，给面试者一段具体GC Log 

参考 [jvm gc介绍和日志说明](https://wiki.sankuai.com/:pages:viewpage.action%3FpageId=90843240) 

## 19、画一下JVM内存结构图，各块分别有什么的作用？

**参考答案：**

各模块作用：
程序技术器：是一块很小的内存区域，主要作用是记录当前线程所执行的字节码的行号。
虚拟机栈：是线程私有的，存放当前线程中局部基本类型的变量、部分的返回结果以及Stack Frame，非基本类型的对象的引用。Sun JDK的实现中JVM栈的空间是在物理内存上分配的，而不是从堆上分配。
堆：存储对象实例和数组区域
方法区域：是全局共_=AB的，存放了所加载的类的信息（名称、修饰符等）、类中的静态变量、类中定义为final类型的常量、类中的Field信息、类中的方法信息。
本地方法堆栈：支持native方法的执行，存储每个native方法调用的状态。
**解题思路：**基础知识
**考察点：**JVM 
**分类：**JVM {校招，社招}
**难度分级：**P4，P5

##  20、JVM垃圾收集在ParNew+CMS条件下，哪些情况下会让JVM认为产生了一次FULL GC？

 **参考答案：**

JVM认为在老年代或者永久区发生的gc行为就是Full GC，在ParNew+CMS条件下，发生Full GC的原因通常为：
a) 永久区达到一定比例。
b) 老年代达到一定比例。
c) 悲观策略。
d) System.gc(), jmap -[dump:live](http://dumplive/), jmap -[histo:live](http://histolive/) 等主动触发的。
**解题思路：**
**考察点：**GC收集器 Full GC 
**分类：**JVM GC {校招，社招}
**难度分级：**P4，P5 

## 21、如何查看StringPool大小？ 

**参考答案：**

通过java -XX:+PrintStringTableStatistics命令查看，Number of buckets显示的就是StringPool的默认大小，在jdk7 u40版本以前，它的默认大小是1009，之后便调整为60013。

**解题思路：**JVM基础知识
**考察点：**StringPool 
**分类：**JVM GC {校招，社招}
**难度分级：**P4，P5 

## 22、JmapDump的文件中是否包括StringPool？

 **参考答案：**

StringPool在jdk6中是在永久区，dump heap时，无法输出。在jdk7中，stringpool移到heap中，可以输出。

**解题思路：**JVM基础知识
**考察点：**StringPool 
**分类：**JVM GC {校招，社招}
**难度分级：**P4，P5    