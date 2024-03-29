---

title: JVM笔记
date: 2017-11-11 13:09:04
tags: [JVM,java]

---

## JVM类加载

### 引导类加载器（bootstrapclassloader）
-它用来加载Java的核心库(JAVAHOME/jre/lib/rt.jar,üsun.boot.class.path路径下的内容）是用原生代码来实现的，并不继承自java」ang.ClassLoadero加载扩展类和应用程序类加载器。荆旨定他们的父类加载器。

### 扩展类加载器（extensionsclassloader）
-用来加载Java的扩展库(JAVAHOME/jre/ext/*jar，üjava.ext.dirs路径下的内容）。
Java虚拟机的实现会提供一个扩展库目录。该类加载器在此目录里面找并加载Java
sun.misc.Launcher$ExtClassLoader实现

### 应用程序类加载器（applicationclassloader）
它根据Java应用的类路径（classpath，java.class.path路
一般来说，Java应用的类都是由它来完成加载的。asun.misc.Launcher$AppClassLoader实壬见
### 自定义类加载器
-开发人员可以通过继承java.lang.ClassLoader类的方式
实现自己的类加载器，以满足一些特殊的需求。

https://blog.nowcoder.net/n/a607e6d3db0542dca8d4e33053af02a1


```java
public class Demo02 {
    public static void main(String[] args) {
        System.out.println(ClassLoader.getSystemClassLoader());
        System.out.println(ClassLoader.getSystemClassLoader().getParent());
        System.out.println(ClassLoader.getSystemClassLoader().getParent().getParent());
    }
}

结果如下
sun.misc.Launcher$AppClassLoader@18b4aac2
sun.misc.Launcher$ExtClassLoader@65b54208
null

由于最最上层是 bootstrapclassloader 是原生C/C++实现的java 获取不到
Ext 就是 扩展类加载器（extensionsclassloader）可以获取到

```

### 字节码加载流程

![image-20201212194527279](http://guxiangflyimagebucket.oss-cn-beijing.aliyuncs.com/img/image-20201212194527279.png)



![image-20200518010403696](http://guxiangflyimagebucket.oss-cn-beijing.aliyuncs.com/img/image-20200518010403696.png)

- 类从被加载到虚拟机内存中开始，到卸载出内存为止，它的整个生命周期包括：加载（Loading）、验证（Verification）、准备(Preparation)、解析(Resolution)、初始化(Initialization)、使用(Using)和卸载(Unloading)7个阶段。其中准备、验证、解析3个部分统称为连接（Linking）
- 加载、验证、准备、初始化和卸载这5个阶段的顺序是确定的，类的加载过程必须按照这种顺序按部就班地开始，而解析阶段则不一定：它在某些情况下可以在初始化阶段之后再开始，这是为了支持Java语言的运行时绑定（也称为动态绑定或晚期绑定）。以下陈述的内容都已HotSpot为基准。

![image-20201212195325459](http://guxiangflyimagebucket.oss-cn-beijing.aliyuncs.com/img/image-20201212195325459.png)

对于一段代码，走如上的流程图，先看程序有没有相应的class对象，如果没有就先加载，有就不加载，然后链接，后初始化，然后执行main方法

--------

##### 初始化时机

虚拟机规范中明确规定**只有五种情况必须立即进行‘初始化’（加载，验证，准备）需要在初始化之前**

1. 遇到new指令、getstatic指令、putstatic指令或invokestatic指令这4条字节码指令时，如果类没有进行过初始化，则需要先触发其初始化。生成这4条指令的最常见的Java代码场景是：**a.使用new关键字实例化对象的时候**、**b.读取或设置一个类的静态字段（被final修饰、已在编译期把结果放入常量池的静态字段除外）的时候**，以及**c.调用一个类的静态方法的时候**。
2. 使用java.lang.reflect包的方法对类进行**反射**调用的时候，如果类没有进行过初始化，则需要先触发其初始化。
3. 当初始化一个类的时候，如果**发现其父类还没有进行过初始化**，则需要先触发其父类的初始化。
4. 当虚拟机启动时，用户需要指定一个要**执行的主类**（包含main（）方法的那个类），虚拟机会先初始化这个主类。
5. **当使用JDK1.7的动态语言支持时**，如果一个java.lang.invoke.MethodHandle实例最后的解析结果REF_getStatic、REF_putStatic、REF_invokeStatic的方法句柄，并且这个方法句柄所对应的类没有进行过初始化，则需要先触发其初始化。

####  引入一个面试题

```java
public class ClassLoaderTest{

    @Test
    public void testLoad() throws Exception{
        SingleTonTest singleTonTest = SingleTonTest.getSingleTonTest();
        System.out.println(SingleTonTest.count1);
        System.out.println(SingleTonTest.count2);
    }
}
```



#####  一个SingleTonTest如下(singleTonTest在上)

```java
public class SingleTonTest {
    public static SingleTonTest singleTonTest = new SingleTonTest();
    public static int count1;
    public static int count2 = 0;


    private SingleTonTest(){
        count1++;
        count2++;
    }

    public static SingleTonTest getSingleTonTest(){
        return singleTonTest;
    }
}
```

######  结果

```
1
0
```



#####  一个SingleTonTest如下 (singleTonTest在下)

```java
public class SingleTonTest {

    public static int count1;
    public static int count2 = 0;
    public static SingleTonTest singleTonTest = new SingleTonTest();

    private SingleTonTest(){
        count1++;
        count2++;
    }

    public static SingleTonTest getSingleTonTest(){
        return singleTonTest;
    }
}
```

######  结果

```
1
1
```



面试题：

1. 通过子类引用父类的静态字段，不会导致子类的初始化（此时的静态资源不是属于子类父类的）

<img src="http://guxiangflyimagebucket.oss-cn-beijing.aliyuncs.com/img/image-20200518111255286.png" alt="image-20200518111255286" style="zoom: 50%;" />

2. 







## java的堆栈区别

### Java堆
- 和程序开发密切相关
- 应用系统对象都保存在」ava堆中 
- 所有线程共享Java堆
- 对分代G&:来说堆也是分代的
- GC的主要工作区间 

### Java栈
- 线程私有
- 栈由一系列巾贞组成（因此java栈也叫做帧栈）
- 帧保存一个方法的局部变量、操作数栈、常量池指针
- 每一次方法调用创建一个帧，并压栈


### 可见性
一个线程修改了变量其他线程可以立即知道
- 保证可见性的方法
- volatile
- synchronized（unlock之前写变量值回主存）
- fina|（一旦初始化完成，其他线程就可见） 


## 内存图
![JVM 内存图](https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1534694453&di=a372c6fc205d8da43a39e6cb5dfd6f9d&imgtype=jpg&er=1&src=http%3A%2F%2Fimg.kuqin.com%2Fupimg%2Fallimg%2F160518%2F20521a109-0.png)

![image-20201213003257956](http://guxiangflyimagebucket.oss-cn-beijing.aliyuncs.com/img/image-20201213003257956.png)

!![image-20210209005853554](http://guxiangflyimagebucket.oss-cn-beijing.aliyuncs.com/img/image-20210209005853554.png)



![image-20210209010247606](http://guxiangflyimagebucket.oss-cn-beijing.aliyuncs.com/img/image-20210209010247606.png)

JIT 有的认为应该属于元数据区，有的认为应该单独拿出来

###  JDK 1.6 和 1.7 1.8 有所区别

![](http://guxiangflyimagebucket.oss-cn-beijing.aliyuncs.com/imagerepo/img20181026012129.png)
![](http://guxiangflyimagebucket.oss-cn-beijing.aliyuncs.com/imagerepo/img20181026011620.png)

线程安全的本质
看图 所以有 内存屏障
![](http://guxiangflyimagebucket.oss-cn-beijing.aliyuncs.com/imagerepo/img20181026011844.png)

- 线程共享区
    - 方法区  (永久带 Tenured Gen) 
        ```
            方法区，也叫永久带 JDK8中被取消
            用于存放虚拟机加载的各种类信息 .class 文件，静态的变量 和 常量池（常量池在jdk1.7的时候  被移动到了堆区）
        
            注意： 永久带也可以被回收
            1.该类的实例都被回收。 
            2.加载该类的classLoader已经被回收 
            3.该类不能通过反射访问到其方法，而且该类java.lang.class没有被引用
        
            当满足这3个条件时，是可以回收，但回不回收还得看jvm。
            （周志明. 深入理解Java虚拟机）
        
            在JDK 1.8中 就移除了方法区 也就是也移除了永久带
            引入了metadata（元数据）的概念  metadata是存放在本地内存的
            为什么取出方法区呢：
                用永久带存储类信息不好，
                 如果工程特别庞大，使用的类特别的多，有时候刚刚一启动，
                 就会报出 OutOfMemory 的异常，对有就带调优是非常困难的 于是我们将永久带移除  将类信息存放在 直接内存中   也避免了 Full GC  JVM对本地内存 无法回收
            JAVA8 去掉了  -XX:PermSize  和  -XX:MaxPermSize  
                新增了    -XX:MetaspaceSize  和  -XX:MaxMetaspaceSize
                
                
             
             -Xmx  最大堆空间的大小
        -Xms   初始化堆空间的大小
         设置JVM 的最大可用内存，Xms 设置JVM实际使用内存，一般Xmx和Xms相同，这是因为当Xmx内存空间不够用时，将进行扩容导致Full GC。将Xmx和Xms设置成相同的值，避免因Xms偏小导致频繁重新分配内存，影响应用使用。
        ```
        
    - 堆区
       - Eden
       - Survivor*2  
       - Old 
       
       |                                                              |                           |
       | :----------------------------------------------------------- | :------------------------ |
       | 参数                                                         | 等同于                    |
       | -Xss1024k                                                    | -XX:ThreadStackSize=1024k |
       | -Xms512m   初始化堆空间的大小                                |                           |
       | -Xmx1024m  最大堆空间的大小(设置JVM 的最大可用内存，Xms 设置JVM实际使用内存，一般Xmx和Xms相同，这是因为当Xmx内存空间不够用时，将进行扩容导致Full GC。将Xmx和Xms设置成相同的值，避免因Xms偏小导致频繁重新分配内存，影响应用使用。) | -XX:MaxHeapSize=1024m     |
       | -Xmn512m                                                     |                           |
       | -XX:NewSize=512m                                             |                           |
       | -XX:MaxNewSize=512m                                          |                           |
       | -XX:NewRatio=8                                               |                           |
       | -XX:SurvivorRatio=32                                         |                           |
       | -XX:MinHeapFreeRatio=40                                      |                           |
       | -XX:MaxHeapFreeRatio=70                                      |                           |
       | -XX:MetaspaceSize=128m                                       |                           |
       | -XX:MaxMetaspaceSize=256m                                    |                           |


- 线程独占区

    ![image-20210209001124938](http://guxiangflyimagebucket.oss-cn-beijing.aliyuncs.com/img/image-20210209001124938.png)

    ![image-20210209003850385](http://guxiangflyimagebucket.oss-cn-beijing.aliyuncs.com/img/image-20210209003850385.png)

     线程独占的有

    - 虚拟机栈
        ```
        生命周期：与线程是一致的
        作用：主管java程序的运行，它保存方法的局部变量、部分结果、并且参与方法的调用和返回
        - 局部变量  和  成员变量
        - 基本数据变量  和  引用类型变量
        
        栈是不存在GC的
        
        在相应的线程上，正在执行的每个方法都各自对应一个栈帧（stack Frame）
        ```
        
    - 本地方法栈
        - 本地方法栈和虚拟机栈的不同
         ```
            本地方法栈   为虚拟机执行native方法服务
            JVM虚拟机栈  为虚拟机执行Java方法服务
            （Hotspot 虚拟机中是将他们合二为一的）
         ```
        
    - 程序计数器（也叫做 program counter register 或者  PC寄存器） （记录当前线程执行到哪一条指令）

        - PC寄存器用来存储指向下一条指令的地址，也即将要执行的指令代码。由执行引擎读取下一条指令。
        - 为什么使用PC寄存器来记录当前线程的执行地址
            - 当CPU需要不停的切换各个线程的时候，就得知道接着从哪来开始执行
            - ![image-20210209004311052](http://guxiangflyimagebucket.oss-cn-beijing.aliyuncs.com/img/image-20210209004311052.png)

## JVM 参数调优

![](https://i.loli.net/2019/12/11/vbguOsk4XEyFZRw.png)

-XX:NewSize 

## GC算法

### 引用计数法
- 引用计数器的实现很简单，对于一个对象A，只要有任何一个对象引用了A，则A的引用计数器就加1，当引用失效时，引用计数器就减1。只要对象A的引用计数器的值为0，则对象A就不可能再被使用，然后就释放内存。
![image.png](http://upload-images.jianshu.io/upload_images/6406935-3a7df2dd218d71db.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

### 标记清除算法
- 标记-清除算法是现代垃圾回收算法的思想基础。标记-清除算法将垃圾回收分为两个阶段：标记阶段和清除阶段。一种可行的实现是，在标记阶段，首先通过根节点，标记所有从根节点开始的可达对象。因此，未被标记的对象就是未被引用的垃圾对象。然后，在清除阶段，清除所有未被标记的对象。
![image.png](http://upload-images.jianshu.io/upload_images/6406935-5a569a6f1833174a.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

### 标记压缩算法
- 标记-压缩算法适合用于存活对象较多的场合，如老年代。它在标记-清除算法的基础上做了一些优化。和标记-清除算法一样，标记-压缩算法也首先需要从根节点开始，对所有可达对象做一次标记。但之后，它并不简单的清理未标记的对象，而是将所有的存活对象压缩到内存的一端。之后，清理边界外所有的空间。

### 复制算法
- 与标记-清除算法相比，复制算法是一种相对高效的回收方法，而且不会造成内存碎片
- 不适用于存活对象较多的场合 如老年代
- 将原有的内存空间分为两块，每次只使用其中一块，在垃圾回收时，将正在使用的内存中的存活对象复制到未使用的内存块中，之后，清除正在使用的内存块中的所有对象，交换两个内存的角色，完成垃圾回收


### 使用场景
- 引用计数   （在java中没有使用）
- 标记-清除  （在老年代被使用）
- 标记-压缩  （在老年代被使用）
- 复制算法   （新生代被使用）

- 分代收集算法

### 对象的类型
- 可触及的 
从根节点可以触及到这个对象 
- 可复活的 
一旦所有引用被释放，就是可复活状态  
因为在finalize()中可能复活该对象  
- 不可触及的  
在finalize()后，可能会进入不可触及状态
不可触及的对象不可能复活
可以回收

### 强引用和弱引用
- **强引用**   （垃圾回收，内存溢出也不回收）
```
含义是 内存空间不足，宁愿抛出OOM 也不会回收强引用的对象
Object obj = new Object()
通过将对象设置为null 来弱化引用
```
- **软引用**（垃圾回收，内存不够了，那么就回收）

  - 强引用是宁肯溢出，也不回收，软引用是为了保证不溢出，会来回收。

  - **软引用适合用来做缓存**，比方说缓存了一个1M大小的大Map在内存中，如果本身jvm的内存不够了，那么就将软引用的缓存回收掉，然后再分配内存给需要的对象。

  - ```java
       设置VMoption  -Xmx20m
    public static void main(String[] args) {
            //
            SoftReference<byte[]> m = new SoftReference<>(new byte[1024*1024*10]);
            System.out.println(m.get());
            System.gc();
            try {
                Thread.sleep(500);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
            System.out.println(m.get());
            byte[] bytes = new byte[1024 * 1024 * 11];
            System.out.println(m.get());
        }
    结果：
    [B@60e53b93
    [B@60e53b93
    null     # 由于分配了10M（软） + 11M内存（强），于是直接将10M软引用内存回收了
    ```

    <img src="http://guxiangflyimagebucket.oss-cn-beijing.aliyuncs.com/img/image-20220321191708789.png" alt="image-20220321191708789" style="zoom:50%;" />

- **弱引用**（垃圾回收，不管内存够不够，都回收，任意内存回收都会回收它）
```
String str= new String("abc")
SoftReference<String> softRef = new SoftReference<String>(str)
```

- **虚引用** （这个回收的时候会将数据放入一个队列，一般用来管理直接内存）

  ```java
      private static final List<Object> LIST = new LinkedList<>();
      private static final ReferenceQueue<M> QUEUE = new ReferenceQueue<>();
  
      public static void main(String[] args) {
          PhantomReference<M> phantomReference = new PhantomReference<>(new M(),QUEUE);
          System.out.println(phantomReference.get());
      }
  结果:
  null
  ```

  虚引用：即使没有发生内存回收，结果也为null  new出来的对象根本没法拿到

  作用：用于直接内存的管理，在NIO 和 netty中会经常使用直接内存。

  > 正常模式中，操作系统接受到网络数据，是放在内核态中， JVM如果需要使用，需要将数据拷贝一份到JVM的用户态中。 但是JVM提供这种功能，能直接访问操作系统内核态的数据，既 direct buffer， 虚引用正好用来管理这个内存。

  > 怎么使用：
  >
  > 凡是PhantomReference指向的对象，在回收的时候，都会将要回收的对象放到一个 ReferenceQueue 里面，







有哪些可以作为 GC root  （GCroot）

- **GC root**（一般来说，不在heap 区的能作为 GC root）
  - 虚拟机栈中引用的对象（主要放在虚拟机栈的局部变量表里面）
    - 比如各个线程被调用的方法中使用的参数，局部变量
  - 本地方法栈内JNI引用的对象（主要放在本地方法栈的局部变量表里面）
  - 方法区中静态属性引用的对象（虽然JDK1.8 将静态属性放入常量池了）
    - 比如：Java类的应用类型静态遍历
  - 方法区中常量引用的对象
    - 比如：字符串常量池（String table）里的引用
  - 被同步锁synchronized持有的对象
  - **由系统类加载器(system class loader)加载的对象** （这个在metaspace） （不带有自定义类加载器），这些类是不能够被回收的，他们可以以静态字段的方式保存持有其它对象。我们需要注意的一点就是，通过用户自定义的类加载器加载的类，除非相应的java.lang.Class实例以其它的某种（或多种）方式成为roots，否则它们并不是roots。
  - 
     - 比如各个线程被调用的方法中使用的参数，局部变量
  - 方法区中静态成员或者常量引用的对象（全局对象） （引出JDK1.7之后JVM常量池不存在方法区，1.8后没有了方法区） （方法区中常量的）
  - JNI方法栈中引用对象
  - **活的Thread**
  - 被synchronized 持有的对象

> 小技巧：由于root采用栈的方式存放变量和指针，所以如果一个指针，他保存了堆内存里面的对象，但是自己又不存放在堆内存里面，那么它就是个root



#### Minor GC ， Major GC  与 Full GC的区别

> JVM 在进行垃圾回收的时候，并非每次都对三个内存区域（新生代，老年代，方法区）区域一起回收的
>
> 针对Hotspot VM的实现，它的GC按照回收区域分为两大类，一种是 Partial GC （ 部分收集），一种是 Full GC整堆收集
>
> - 部分收集，不完整的收集整个Java堆的垃圾收集。其中又分为：
>   - 新生代收集（Minor GC/ Young GC）： 只是 新生代（eden，s0，s1）的垃圾收集，eden满了才会触发 Minor GC 
>   - 老年代（Major GC/ Old GC）：只是老年代
>     - 目前只有 CMS GC 会单独进行老年代收集，只有CMS会进行 Major GC
>     - 注意，很多时候 Major GC 和 Full GC 会被搞混。具体分辨是老年代回收还是整堆回收
> - 整堆收集（Full GC）：收集整个新生代以及部分的老年代的垃圾收集。

### 触发Full GC的条件

full GC 和 major GC
与 minor GC 不同 

- 老年代空间不足（如果新生代一次分配了太多的对象，就会挤进老年代，导致老年代空间不足发生full GC）
- 永久代空间不足（永久代如果加载了特别多的class类，也会导致full GC）
- 调用System.gc()
- CMS GC 出现了promotion failed



![image-20211012121323139](http://guxiangflyimagebucket.oss-cn-beijing.aliyuncs.com/img/image-20211012121323139.png)

我们的 CMS垃圾收集器 一般配合 parNew 来进行垃圾收集。  CMS在极端情况下，比如说用户线程内存不够的时候 会变为 Serial Old 收集器。

#### cms收集器

![image-20201215153007134](http://guxiangflyimagebucket.oss-cn-beijing.aliyuncs.com/img/image-20201215153007134.png)



![image-20211012005659791](http://guxiangflyimagebucket.oss-cn-beijing.aliyuncs.com/img/image-20211012005659791.png)

- 在初始标记和重新标记的时候 会进stop-the-world

- CMS的优缺点
  - **CMS优点**
    - 低延迟（只有在  初始标记和重新标记的时候 会进行stop the world，这两个阶段stop the word时间非常短）
    - 并发清除
  - **CMS缺点**
    - 会产生内存碎片， 并发清理后用户先的可用大段空间不足，无法分配大对象的情况下，会产生Full GC。 Full GC 又会导致CMS进行垃圾回收，而且很有可能会在用户线程内存不够的时候临时采用到Serial Old 收集器来重新进行老年代的垃圾手机，时间就很长了。
    - CMS收集器会产生cpu资源
    - 会产生一些浮动垃圾



#### G1垃圾收集器

![image-20211013003042782](http://guxiangflyimagebucket.oss-cn-beijing.aliyuncs.com/img/image-20211013003042782.png)

```
官方给G1设定的目标是在延迟可控的情况下获得尽可能高的吞吐量
G1 是既针对新生代又针对老年代的

---- CMS GC主要爱是针对老年代
```

- G1的优势





![image-20211015100452916](http://guxiangflyimagebucket.oss-cn-beijing.aliyuncs.com/img/image-20211015100452916.png)

G1的回收有三个环节   

![image-20211015100608947](http://guxiangflyimagebucket.oss-cn-beijing.aliyuncs.com/img/image-20211015100608947.png)



![image-20211015100755340](http://guxiangflyimagebucket.oss-cn-beijing.aliyuncs.com/img/image-20211015100755340.png)

![image-20211018130221441](http://guxiangflyimagebucket.oss-cn-beijing.aliyuncs.com/img/image-20211018130221441.png)

- 注意由于 G1 是 region分片的。

![image-20211018130027977](http://guxiangflyimagebucket.oss-cn-beijing.aliyuncs.com/img/image-20211018130027977.png)

![image-20211018131642855](http://guxiangflyimagebucket.oss-cn-beijing.aliyuncs.com/img/image-20211018131642855.png)



![image-20211018131730648](http://guxiangflyimagebucket.oss-cn-beijing.aliyuncs.com/img/image-20211018131730648.png)

G1 会在并发标记的过程中标记一个垃圾对象的活性， 如果活性很低，会在Mix GC 的时候被优先回收掉

![image-20211018132016000](http://guxiangflyimagebucket.oss-cn-beijing.aliyuncs.com/img/image-20211018132016000.png)









历史的垃圾回收期

![image-20211018132156252](http://guxiangflyimagebucket.oss-cn-beijing.aliyuncs.com/img/image-20211018132156252.png)

### 双亲委派机

![image-20201212234316719](http://guxiangflyimagebucket.oss-cn-beijing.aliyuncs.com/img/image-20201212234316719.png)

<img src="http://guxiangflyimagebucket.oss-cn-beijing.aliyuncs.com/img/image-20201213012452190.png" alt="image-20201213012452190" style="zoom: 67%;" />

- 双亲委派的优势
  - 避免类的重复加载
  - 保护程序的安全，防止核心的API被随意篡改
- 双亲委派的劣势
  - 当应用类访问系统类自然是没有问题的，但是系统类访问应用类会出现问题。
  - Tomcat 中类加载机制就和双亲委派模型有些区别。



### 打破双亲委派模型

在像一些Tomcat的源码中，WebappClassLoader会打破双亲委派机制。这里我们也来简单模拟一下。

打破双亲委派机制则不仅要继承ClassLoader类，还要重写loadClass和findClass方法，如下例子：

- 重新定义一个继承ClassLoader的TestClassLoaderN类，这个类与前面的TestClassLoader类很相似，但它除了重写findClass方法外还重写了loadClass方法，默认的loadClass方法是实现了双亲委派机制的逻辑，即会先让父类加载器加载，当无法加载时才由自己加载。这里为了破坏双亲委派机制必须重写loadClass方法，即这里先尝试交由System类加载器加载，加载失败才会由自己加载。它并没有优先交给父类加载器，这就打破了双亲委派机制。





### 线程

- 守护线程： 如果虚拟机中只有守护线程了，那么虚拟机就可以退出了
- 普通线程： 普通线程结束后，jvm才会退出



##### 常见的守护线程

- 虚拟机线程：这种线程执行“stop the world” 的垃圾收集，线程栈收集，偏向锁撤销等。

- 周期任务线程：这种线程是时间周期事件的体现，比如中断。

  



### 创建一个对象的步骤

1. 判断对象对应的类是否被加载、链接、初始化过

   > 虚拟机遇到条new指令，现在metaspace中。判断类的元信息是否存在。如果没有。通过双亲委派模式使用classloader进行加载，如果没有找到就会抛出classnotfoundexception。找到了就进行类加载

2. 为对象分配内存。

   1. 如果内存规整-- 使用指针碰撞
   2. 如果内存不规整-- 虚拟机需要维护一个列表
   3. 内存是否规整，取决于垃圾收集器

3. 处理并发安全问题

4. 初始化分配到的空间

   1. 给属性进行默认初始化， integer 为null ， int 为0

5. 设置对象的对象头

6. 执行init方法




## JVM参数调优
- -Xmn
  - 设置新生代大小
- -XX:NewRatio
  - 新生代（eden+2*s）和老年代（不包含永久区）的比值
  - 4 表示 新生代:老年代=1:4，即年轻代占堆的1/5
- -XX:SurvivorRatio
  - 设置两个Survivor区和eden的比
  - 8表示 两个Survivor :eden=2:8，即一个Survivor占年轻代的1/10

## debug时候的参数
-verbose:gc -XX:+PrintGCDetails  
默认是使用的 parallel 收集器
更换GC收集器使用的参数的是  -XX:+UseSerialGC

## 内存分配策略有如下
- 内存优先分配到Eden （）
- 内存担保策略（即 新生代不够 会向老年代借 将内存分配到老年代）
- 大对象直接进入老年代
    ```
        之所安会有这个策略， 主要是新生代使用了复制算法，大对象进行复制时候 会消耗内存
    ```
    
## 内存屏障问题

## final 域 重排序
对于final 域，编译器和处理器要遵守两个重排序规则：
 - 写重排序： 在构造函数内对一个 final 域的写入，与随后把这个被构造对象的引用赋值给一个引用变量，这两个操作之间不能重排序。

 - 对读的重排序:  先对一个含有final 语义的java对象读取，再对整个final域进行读取，这两个操作不能重排序

 构造函数return之前插入一个StoreStore障屏。读final域的重排序规则要求编译器在读final域的操作前面插入一个LoadLoad屏障。
```
白话说： 如果对象A 中有被 final 修饰的成员变量 
    那么在操作 A a = new A（）；的时候，
    一定是在构造方法之后的 
```
 - 读重排序： 初次读一个包含 final 域的对象的引用，与随后初次读这个 final 域，这两个操作之间不能重排序。
        就是说

# 内存泄漏
        Java中的内存泄露，广义并通俗的说，就是：不再会被使用的对象的内存不能被回收，就是内存泄露。

## CAS 算法
compare and  swap
CAS 算法是硬件对于并发操作共享数据的支持
    CAS 包含3个操作数
- 内存值 V
- 预估值 A
- 更新值 B
    当且仅当 内存值V== 预估值A   的时候  才会让更新值B赋值给内存值V
    当且仅当 V==A 时， V=B  否则什么操作都不做

## CMS 并发标记清除算法 Concurrent Mark Sweep
concurrent Mark sweep 


## 并发与并行的区别
并行是两个或者多个事件在同一时刻发生，


## 垃圾收集器
G1(Garbage First)垃圾收集器是当今垃圾回收技术最前沿的成果之一.
G1 在 java9中被设置为默认的垃圾收集器
![](http://guxiangflyimagebucket.oss-cn-beijing.aliyuncs.com/imagerepo/img20181112030202.png)
G1 中 不太看重 老年代 或者 新生代 
G1采用了分区(Region)的思路，将整个堆空间分成若干个大小相等的内存区域，
有一个global card 管理它。


## JMM 笔记
JMM用处是定义程序中变量的返回规则
- 首先 java中的变量是存放在共享内存 主内存中的  每个线程都有自己的工作内存，工作内存是主内存的变量副本，线程对内存变量的read、write操作，都必须在工作内存中进行
，线程A 修改完变量 是修改的线程的工作内存，对另一个线程B是不可见的。B想可见，必须变量从A的工作内存写回到主内存，B再从主内存读取到自己的工作区 ,B才可见。由于指令重排序的
问题，写和读的顺序会被打乱，所以正常变量有可见性问题。
- Volatile 关键词 强制变量的读取会从主内存刷新，变量的write也会从工作区刷新到主内存
线程A修改完变量后是先修改工作内存的值，再讲





## 四种引用类型

- 强引用
- 弱引用 
- 虚引用  phantomReference 
  - 这个虚引用-其实就是把数据在回收的时候起一个通知作用，因为虚引用会将内存放到一个队列中，等由这个队列来回收它。
    - 在使用直接内存(direct memory)的时候，可以使用虚引用，对内存进行回收。




## ZGC 


# 类加载策略
- 1. 当虚拟机遇到new getstatic putstatic 或者 invokestatic的时候，如果类没有进行过初始化，需要先触发它的初始化（读取类的final修饰的静态字段除外）
- 2. 当reflect包的方法对类进行反射调用的时候，需要


### 不被初始化的例子
- 通过子类引用父类的静态字段，子类不会被初始化
- 通过数组定义引用类 不会被初始化
- 调用类的final修饰的常量





## JVM 排查问题方法

###  OutOfMemoryError排查与解决实战



- jmap -heap <pid>
- jmap -histo <pid>

- 第一步想办法拿到Heap dump

  - ```BASH
    启动的时候,加JVM参数 -XX 代表是 Hotspot虚拟机 私有的
    -XX:+HeapDumpOnOutOfMemoryError
    ```

  - ```bash
    jmap -dump:live,format=b,file=<filepath> <pid>   用这种方法能拿到运行的java程序的heap dump
    ```

  -  绝大多数OOM 不能通过加内存解决， 加内存只能延缓OOM出现的时间


  使用上述的命令后 会拿到一个   .hprof 的文件

​    sftp -oPort=8000 guxiang@fswap.sys.xiaojukeji.com

jmap -dump:live,format=b,file=my_container_battery.hprof  1356

<string>-vm</string><string>/Library/Java/JavaVirtualMachines/jdk1.8.0_311.jdk/Contents/Home/bin/java</string>

- 使用工具分析 hprof

     以 VisualVM 为例

  ![](https://i.loli.net/2019/12/25/wATbBS7NkChXzty.png)

  

  打开 hprof 后，会看到当时的   对象类型， 对象个数， 对象总占用大小  还有一个 **retained**
  
  ```
  解释一下 Retained Size
  Retained Size=当前对象大小+当前对象可直接或间接引用到的对象的大小总和。(间接引用的含义：A->B->C, C就是间接引用)
  
  换句话说，Retained Size就是当前对象被GC后，从Heap上总共能释放掉的内存。
  
  下图中，GC Roots直接引用了A和B两个对象。
  A对象的Retained Size=A对象的Shallow Size
  B对象的Retained Size=B对象的Shallow Size + C对象的Shallow Size
  
  ```
  
  ![](https://i.loli.net/2019/12/25/RyritlsPGdKLJ9I.png)

 ## Heap Dump 分析

- Metaspace/PermGen
  - 主要观察 Class 对象
- Heap Space
  - 主要看占用内存大的 object
- Path to GC root
  - 分析java的内存占用


##  eclipse MAT 分析的步骤

### 方式1 （通过直接的分析）

- 通过MAT 打开 .hprof 文件 （heap profile）（分析的比较慢）

  ![image-20191227153645410](/Users/mtdp/Library/Application Support/typora-user-images/image-20191227153645410.png)

- 关注两个图标
  - Histogram 直方图，会给出java的
  - Leak Suspects   泄露嫌疑   （点一下 会给出出现问题可能的可能原因）





点击Leak Suspects  圈出的为内存分析

![](https://i.loli.net/2019/12/27/j1Sk8cYRul6OqJf.png)

然后通过点击  See stacktrace  能看到分配这个对象的线程栈 

![image.png](https://i.loli.net/2020/01/16/aExbhdk9BiySW31.png)

这样可以找到具体产生这个对象的 object 



### 通过直方图看线程栈

在上一种方法的首页  我们选取点击直方图 Histogram

可见下图，然后选取 retained Heap 最大的那个object  点击上面的 双齿轮，能看到线程调用栈。

![image.png](https://i.loli.net/2020/01/16/KJjbqPVS61HdR4G.png)

  点击上面的 双齿轮，能看到线程调用栈。

![image.png](https://i.loli.net/2020/01/16/KeHQrT5YJZiWPl6.png)

选取Retained Heap 最大的那个线程。

到这一层就可以不用点下去了。  寻找自己写的package的名字。 然后定位到有问题的代码。

![image.png](https://i.loli.net/2020/01/16/yf6XrEwAam8WQ4B.png)



###  MAT使用的注意点

- 注：  MAT 默认xmx为1g 可能不够用  MAC环境修改如下 

  ```
  /Users/mtdp/Downloads/mat.app/Contents/Eclipse/MemoryAnalyzer.ini  
  将 -Xmx 改为  -Xmx10g
  ```

 在弹出

![image.png](https://i.loli.net/2020/01/16/RMYiEmK5s89cCet.png)

选一个 Leak Suspects Report 就可以，不用管下面的 loading





##### 通过MAT查看 GCRoot：

![image-20200519163443352](http://guxiangflyimagebucket.oss-cn-beijing.aliyuncs.com/img/image-20200519163443352.png)

<img src="http://guxiangflyimagebucket.oss-cn-beijing.aliyuncs.com/img/image-20200519163622464.png" alt="image-20200519163622464" style="zoom:50%;" />







### 使用jprofile进行内存分析

###### jprofile打开后如下

![image-20200519164911923](http://guxiangflyimagebucket.oss-cn-beijing.aliyuncs.com/img/image-20200519164911923.png)

###### 双加最大的对象 char[] 选中 incoming references  （来源引用， 这个incoming reference可以帮助分析来源） 

<img src="http://guxiangflyimagebucket.oss-cn-beijing.aliyuncs.com/img/image-20200519165055346.png" alt="image-20200519165055346" style="zoom:50%;" />

###### 进入这个页面后点击 show paths to GC root 选择 single Root

<img src="http://guxiangflyimagebucket.oss-cn-beijing.aliyuncs.com/img/image-20200519165347342.png" alt="image-20200519165347342" style="zoom:50%;" />

<img src="http://guxiangflyimagebucket.oss-cn-beijing.aliyuncs.com/img/image-20200519165452640.png" alt="image-20200519165452640" style="zoom:50%;" />

###### 下图代表这个char 来自于 控制台 PrintStream

![image-20200519165518802](http://guxiangflyimagebucket.oss-cn-beijing.aliyuncs.com/img/image-20200519165518802.png)





1. 整理待办事项
2. 每日重点
3. 给每天设置方向
4. 每天先处理自己的事情
   1. 穷爸爸和富爸爸（pay yourself first）
5. 





分析下GC log，看不出问题可以jmap -histo pid 看下对象的占用排行，实在不行就摘除流量，dump一份heap文件到mat分析下



![image-20211215155422860](http://guxiangflyimagebucket.oss-cn-beijing.aliyuncs.com/img/image-20211215155422860.png)





jstat  -<option> 









## GC 日志分析



通过阅读 Gc 日志，我们可以了解 Java 虚拟机内存分配与回收策略。 内存分配与垃圾回收的参数列表

- `-XX:+PrintGC` 输出 GC 日志。类似：`-verbose:gc`
- `-XX:+PrintGCDetails` 输出 GC 的详细日志
- `-XX:+PrintGCTimestamps` 输出 GC 的时间戳（以基准时间的形式）
- `-XX:+PrintGCDatestamps` 输出 GcC 的时间戳（以日期的形式，如 2013-05-04T21：53：59.234+0800）
- `-XX:+PrintHeapAtGC` 在进行 GC 的前后打印出堆的信息
- `-Xloggc:../logs/gc.log` 日志文件的输出路径



打开 GC 日志

```
-verbose:gc
```

这个只会显示总的 GC 堆的变化，如下：

```
[GC (Allocation Failure) 80832K->19298K(227840K),0.0084018 secs]
[GC (Metadata GC Threshold) 109499K->21465K(228352K),0.0184066 secs]
[Full GC (Metadata GC Threshold) 21465K->16716K(201728K),0.0619261 secs]
```

参数解析

```
GC、Full GC：GC的类型，GC只在新生代上进行，Full GC包括永生代，新生代，老年代。
Allocation Failure：GC发生的原因。
80832K->19298K：堆在GC前的大小和GC后的大小。
228840k：现在的堆大小。
0.0084018 secs：GC持续的时间。
```





打开 GC 日志

```
-verbose:gc -XX:+PrintGCDetails -XX:+PrintGCTimestamps -XX:+PrintGCDatestamps
```

输入信息如下

```
2019-09-24T22:15:24.518+0800: 3.287: [GC (Allocation Failure) [PSYoungGen:136162K->5113K(136192K)] 141425K->17632K(222208K),0.0248249 secs] [Times:user=0.05 sys=0.00,real=0.03 secs]

2019-09-24T22:15:25.559+0800: 4.329: [GC (Metadata GC Threshold) [PSYoungGen:97578K->10068K(274944K)] 110096K->22658K(360960K),0.0094071 secs] [Times: user=0.00 sys=0.00,real=0.01 secs]

2019-09-24T22:15:25.569+0800: 4.338: [Full GC (Metadata GC Threshold) [PSYoungGen:10068K->0K(274944K)][ParoldGen:12590K->13564K(56320K)] 22658K->13564K(331264K),[Metaspace:20590K->20590K(1067008K)],0.0494875 secs] [Times: user=0.17 sys=0.02,real=0.05 secs]
```

说明：带上了日期和实践

如果想把 GC 日志存到文件的话，是下面的参数：

```
-Xloggc:/path/to/gc.log
```

**日志补充说明**

- "`[GC`"和"`[Full GC`"说明了这次垃圾收集的停顿类型，如果有"Full"则说明 GC 发生了"Stop The World"

- 使用 Serial 收集器在新生代的名字是 Default New Generation，因此显示的是"`[DefNew`"

- 使用 ParNew 收集器在新生代的名字会变成"`[ParNew`"，意思是"Parallel New Generation"

- 使用 Parallel scavenge 收集器在新生代的名字是”`[PSYoungGen`"

- 老年代的收集和新生代道理一样，名字也是收集器决定的

- 使用 G1 收集器的话，会显示为"garbage-first heap"

- Allocation Failure

  表明本次引起 GC 的原因是因为在年轻代中没有足够的空间能够存储新的数据了。

- [PSYoungGen：5986K->696K(8704K) ] 5986K->704K(9216K)

  中括号内：GC 回收前年轻代大小，回收后大小，（年轻代总大小）

  括号外：GC 回收前年轻代和老年代大小，回收后大小，（年轻代和老年代总大小）

  - user 代表用户态回收耗时，
  - sys 内核态回收耗时，
  - real 实际耗时。由于多核的原因，user+sys时间总和可能会超过 real 时间

```
Heap（堆）
PSYoungGen（Parallel Scavenge收集器新生代）total 9216K，used 6234K [0x00000000ff600000,0x0000000100000000,0x0000000100000000)
eden space（堆中的Eden区默认占比是8）8192K，768 used [0x00000000ff600000,0x00000000ffc16b08,0x00000000ffe00000)
from space（堆中的Survivor，这里是From Survivor区默认占比是1）1024K， 0% used [0x00000000fff00000,0x00000000fff00000,0x0000000100000000)
to space（堆中的Survivor，这里是to Survivor区默认占比是1，需要先了解一下堆的分配策略）1024K, 0% used [0x00000000ffe00000,0x00000000ffe00000,0x00000000fff00000)

ParOldGen（老年代总大小和使用大小）total 10240K， used 7001K ［0x00000000fec00000,0x00000000ff600000,0x00000000ff600000)
object space（显示个使用百分比）10240K，688 used [0x00000000fec00000,0x00000000ff2d6630,0x00000000ff600000)

PSPermGen（永久代总大小和使用大小）total 21504K， used 4949K [0x00000000f9a00000,0x00000000faf00000,0x00000000fec00000)
object space（显示个使用百分比，自己能算出来）21504K， 238 used [0x00000000f9a00000,0x00000000f9ed55e0,0x00000000faf00000)
```



解释一下含义

```
 par new generation   total 1674880K, used 1286571K [0x000000066b200000, 0x00000006dcb50000, 0x00000006dcb50000)
  eden space 1488832K,  86% used [0x000000066b200000, 0x00000006b9a6aec0, 0x00000006c5ff0000)
  from space 186048K,   0% used [0x00000006d15a0000, 0x00000006d15a0000, 0x00000006dcb50000)
  to   space 186048K,   0% used [0x00000006c5ff0000, 0x00000006c5ff0000, 0x00000006d15a0000)
 concurrent mark-sweep generation total 3723968K, used 1597524K [0x00000006dcb50000, 0x00000007c0000000, 0x00000007c0000000)
 Metaspace       used 103385K, capacity 106805K, committed 107392K, reserved 1144832K
  class space    used 12140K, capacity 12802K, committed 12940K, reserved 1048576K
```

```
eden 0x000000066b200000  eden的内存块起始地址
eden 0x00000006b9a6aec0  eden使用到的地址
eden 0x00000006dcb50000  eden内存块的结束地址

from 0x00000006d15a0000  from的内存块起始地址 应该与 eden内存块的结束地址 相同

```





#### MinorGC 日志

![image-20220922160843676](http://guxiangflyimagebucket.oss-cn-beijing.aliyuncs.com/img/image-20220922160843676.png)



#### Full GC 日志

![image-20220922160930874](http://guxiangflyimagebucket.oss-cn-beijing.aliyuncs.com/img/image-20220922160930874.png)











### 记录一次GC的过程

```java
2022-09-22T11:18:34.652+0800: 493052.537: [GC (Allocation Failure) 2022-09-22T11:18:34.652+0800: 493052.537: [ParNew: 1674880K->186048K(1674880K), 0.3138198 secs] 3864508K->2450468K(5398848K), 0.3141355 secs] [Times: user=1.02 sys=0.69, real=0.32 secs] 
2022-09-22T11:18:36.603+0800: 493054.488: [GC (Allocation Failure) 2022-09-22T11:18:36.603+0800: 493054.488: [ParNew: 1674880K->186048K(1674880K), 0.3307932 secs] 3939300K->2529751K(5398848K), 0.3310608 secs] [Times: user=0.96 sys=0.14, real=0.34 secs] 
2022-09-22T11:18:46.790+0800: 493064.675: [GC (Allocation Failure) 2022-09-22T11:18:46.790+0800: 493064.675: [ParNew: 1674880K->186048K(1674880K), 2.6116474 secs] 4018583K->2914579K(5398848K), 2.6119540 secs] [Times: user=7.59 sys=0.97, real=2.61 secs] 
2022-09-22T11:19:04.651+0800: 493082.536: [GC (Allocation Failure) 2022-09-22T11:19:04.652+0800: 493082.537: [ParNew: 1674880K->186048K(1674880K), 2.9687655 secs] 4403411K->3314010K(5398848K), 2.9691933 secs] [Times: user=8.00 sys=0.90, real=2.97 secs] 
2022-09-22T11:19:07.622+0800: 493085.507: [GC (CMS Initial Mark) [1 CMS-initial-mark: 3127962K(3723968K)] 3319668K(5398848K), 0.0703343 secs] [Times: user=0.23 sys=0.01, real=0.07 secs] 
2022-09-22T11:19:07.693+0800: 493085.578: [CMS-concurrent-mark-start]
2022-09-22T11:19:11.931+0800: 493089.816: [CMS-concurrent-mark: 4.223/4.238 secs] [Times: user=12.05 sys=0.83, real=4.24 secs] 
2022-09-22T11:19:11.931+0800: 493089.816: [CMS-concurrent-preclean-start]
2022-09-22T11:19:11.953+0800: 493089.838: [CMS-concurrent-preclean: 0.021/0.022 secs] [Times: user=0.07 sys=0.01, real=0.02 secs] 
2022-09-22T11:19:11.953+0800: 493089.838: [CMS-concurrent-abortable-preclean-start]
2022-09-22T11:19:12.983+0800: 493090.868: [GC (Allocation Failure) 2022-09-22T11:19:12.983+0800: 493090.868: [ParNew: 1674880K->186048K(1674880K), 1.6535069 secs] 4802842K->3505529K(5398848K), 1.6538739 secs] [Times: user=5.62 sys=0.12, real=1.66 secs] 
2022-09-22T11:19:15.469+0800: 493093.354: [CMS-concurrent-abortable-preclean: 1.849/3.516 secs] [Times: user=9.93 sys=0.51, real=3.52 secs] 
2022-09-22T11:19:15.470+0800: 493093.355: [GC (CMS Final Remark) [YG occupancy: 563240 K (1674880 K)]2022-09-22T11:19:15.470+0800: 493093.355: [Rescan (parallel) , 0.1217527 secs]2022-09-22T11:19:15.592+0800: 493093.477: [weak refs processing, 0.0002445 secs]2022-09-22T11:19:15.592+0800: 493093.477: [class unloading, 0.0953141 secs]2022-09-22T11:19:15.688+0800: 493093.573: [scrub symbol table, 0.0281930 secs]2022-09-22T11:19:15.716+0800: 493093.601: [scrub string table, 0.0017695 secs][1 CMS-remark: 3319481K(3723968K)] 3882722K(5398848K), 0.2698333 secs] [Times: user=1.08 sys=0.04, real=0.27 secs] 
2022-09-22T11:19:15.740+0800: 493093.625: [CMS-concurrent-sweep-start]
2022-09-22T11:19:17.480+0800: 493095.365: [GC (Allocation Failure) 2022-09-22T11:19:17.480+0800: 493095.365: [ParNew: 1674880K->166135K(1674880K), 0.4873480 secs] 4187754K->2790799K(5398848K), 0.4876144 secs] [Times: user=1.82 sys=0.06, real=0.49 secs] 
2022-09-22T11:19:19.837+0800: 493097.722: [GC (Allocation Failure) 2022-09-22T11:19:19.837+0800: 493097.722: [ParNew: 1654967K->177526K(1674880K), 0.7758492 secs] 3651648K->2283028K(5398848K), 0.7760780 secs] [Times: user=2.36 sys=0.04, real=0.77 secs] 
2022-09-22T11:19:21.152+0800: 493099.037: [CMS-concurrent-sweep: 4.138/5.412 secs] [Times: user=14.40 sys=1.51, real=5.41 secs] 
2022-09-22T11:19:21.152+0800: 493099.037: [CMS-concurrent-reset-start]
2022-09-22T11:19:21.161+0800: 493099.046: [CMS-concurrent-reset: 0.008/0.008 secs] [Times: user=0.03 sys=0.00, real=0.01 secs] 
2022-09-22T11:19:22.258+0800: 493100.143: [GC (Allocation Failure) 2022-09-22T11:19:22.258+0800: 493100.143: [ParNew: 1666358K->169797K(1674880K), 0.6865801 secs] 3592736K->2220461K(5398848K), 0.6868040 secs] [Times: user=2.21 sys=0.02, real=0.69 secs] 
2022-09-22T11:19:24.802+0800: 493102.687: [GC (Allocation Failure) 2022-09-22T11:19:24.802+0800: 493102.687: [ParNew: 1658629K->161835K(1674880K), 0.8145777 secs] 3709293K->2322250K(5398848K), 0.8148535 secs] [Times: user=2.76 sys=0.48, real=0.82 secs] 
2022-09-22T11:19:27.636+0800: 493105.521: [GC (Allocation Failure) 2022-09-22T11:19:27.636+0800: 493105.521: [ParNew: 1650667K->186048K(1674880K), 0.9996242 secs] 3811082K->2456200K(5398848K), 0.9998814 secs] [Times: user=3.74 sys=0.12, real=1.00 secs] 
2022-09-22T11:19:30.634+0800: 493108.519: [GC (Allocation Failure) 2022-09-22T11:19:30.634+0800: 493108.519: [ParNew: 1674880K->162174K(1674880K), 1.6438588 secs] 3945032K->2571892K(5398848K), 1.6442090 secs] [Times: user=5.05 sys=0.09, real=1.64 secs] 
2022-09-22T11:19:34.313+0800: 493112.198: [GC (Allocation Failure) 2022-09-22T11:19:34.313+0800: 493112.198: [ParNew: 1651006K->161561K(1674880K), 0.9968208 secs] 4060724K->2681296K(5398848K), 0.9970511 secs] [Times: user=2.83 sys=0.18, real=1.00 secs] 
2022-09-22T11:19:36.956+0800: 493114.841: [GC (Allocation Failure) 2022-09-22T11:19:36.956+0800: 493114.841: [ParNew: 1650393K->169116K(1674880K), 1.0076500 secs] 4170128K->2798767K(5398848K), 1.0079196 secs] [Times: user=2.97 sys=0.04, real=1.01 secs] 
2022-09-22T11:19:42.421+0800: 493120.306: [GC (Allocation Failure) 2022-09-22T11:19:42.421+0800: 493120.306: [ParNew: 1657948K->186048K(1674880K), 1.2147030 secs] 4287599K->2943185K(5398848K), 1.2149973 secs] [Times: user=3.66 sys=0.34, real=1.22 secs] 
2022-09-22T11:19:46.782+0800: 493124.667: [GC (Allocation Failure) 2022-09-22T11:19:46.783+0800: 493124.668: [ParNew (promotion failed): 1637490K->1637490K(1674880K), 120.7397112 secs]2022-09-22T11:21:47.522+0800: 493245.407: [CMS: 2757137K->1597524K(3723968K), 10.8727894 secs] 4394627K->1597524K(5398848K), [Metaspace: 103076K->103076K(1144832K)], 131.6130365 secs] [Times: user=368.07 sys=4.60, real=131.62 secs] 
Heap
 par new generation   total 1674880K, used 1286571K [0x000000066b200000, 0x00000006dcb50000, 0x00000006dcb50000)
  eden space 1488832K,  86% used [0x000000066b200000, 0x00000006b9a6aec0, 0x00000006c5ff0000)
  from space 186048K,   0% used [0x00000006d15a0000, 0x00000006d15a0000, 0x00000006dcb50000)
  to   space 186048K,   0% used [0x00000006c5ff0000, 0x00000006c5ff0000, 0x00000006d15a0000)
 concurrent mark-sweep generation total 3723968K, used 1597524K [0x00000006dcb50000, 0x00000007c0000000, 0x00000007c0000000)
 Metaspace       used 103385K, capacity 106805K, committed 107392K, reserved 1144832K
  class space    used 12140K, capacity 12802K, committed 12940K, reserved 1048576K
```



重点看这个

```java
2022-09-22T11:19:46.782+0800: 493124.667: [GC (Allocation Failure) 2022-09-22T11:19:46.783+0800: 493124.668: [ParNew (promotion failed): 1637490K->1637490K(1674880K), 120.7397112 secs]2022-09-22T11:21:47.522+0800: 493245.407: [CMS: 2757137K->1597524K(3723968K), 10.8727894 secs] 4394627K->1597524K(5398848K), [Metaspace: 103076K->103076K(1144832K)], 131.6130365 secs] [Times: user=368.07 sys=4.60, real=131.62 secs] 
Heap
```



#### 整体GC逻辑分析

首先 我们设置一个参数

```
-XX:PretenureSizeThreshold=0   
```

这个代表不会存在大对象直接进入老年代的情况， 一般来说是对象会分配到eden 或者 from 区。 如果发现没足够区域进行分配，会进行一次 Youny GC。如果说GC后空间



Youny GC  





问个问题，在CMS收集器的环境下。
eden 区域满了， 我现在需要new 一个对象， 但是没有区域放了，这时候一般会进行 Youny GC， 但是假设 Youny GC 后发现没有能被清理的无引用对象，JVM会进行反复Youny GC， 直到对象晋升进入老年代么？



这个ParNew use 120 secs 有点奇怪
