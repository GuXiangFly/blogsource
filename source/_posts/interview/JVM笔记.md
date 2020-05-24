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

![image-20200518010403696](https://gitee.com/guxiangfly/blogimage/raw/master/img/image-20200518010403696.png)

- 类从被加载到虚拟机内存中开始，到卸载出内存为止，它的整个生命周期包括：加载（Loading）、验证（Verification）、准备(Preparation)、解析(Resolution)、初始化(Initialization)、使用(Using)和卸载(Unloading)7个阶段。其中准备、验证、解析3个部分统称为连接（Linking）
- 加载、验证、准备、初始化和卸载这5个阶段的顺序是确定的，类的加载过程必须按照这种顺序按部就班地开始，而解析阶段则不一定：它在某些情况下可以在初始化阶段之后再开始，这是为了支持Java语言的运行时绑定（也称为动态绑定或晚期绑定）。以下陈述的内容都已HotSpot为基准。

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

<img src="https://gitee.com/guxiangfly/blogimage/raw/master/img/image-20200518111255286.png" alt="image-20200518111255286" style="zoom: 50%;" />

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


###  JDK 1.6 和 1.7 1.8 有所区别
![](https://raw.githubusercontent.com/GuXiangFly/imagerepo/master/img20181026012129.png)
![](https://raw.githubusercontent.com/GuXiangFly/imagerepo/master/img20181026011620.png)


线程安全的本质
看图 所以有 内存屏障
![](https://raw.githubusercontent.com/GuXiangFly/imagerepo/master/img20181026011844.png)
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
        ```
    - 堆区
       - Eden
       - Survivor*2  
       - Old 


- 线程独占区
    - 虚拟机栈
        ```
           
        ```
        
    - 本地方法栈
        - 本地方法栈和虚拟机栈的不同
         ```
            本地方法栈   为虚拟机执行native方法服务
            JVM虚拟机栈  为虚拟机执行Java方法服务
            （Hotspot 虚拟机中是将他们合二为一的）
         ```
        
    - 程序计数器 （程序执行到哪一行）

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
- 强引用
```
含义是 内存空间不足，宁愿抛出OOM 也不会回收强引用的对象
Object obj = new Object()
通过将对象设置为null 来弱化引用
```
- 弱引用
```
String str= new String("abc")
SoftReference<String> softRef = new SoftReference<String>(str)
```

有哪些可以作为 GC root
- **GC root**
  -  **由系统类加载器(system class loader)加载的对象** （不带有自定义类加载器），这些类是不能够被回收的，他们可以以静态字段的方式保存持有其它对象。我们需要注意的一点就是，通过用户自定义的类加载器加载的类，除非相应的java.lang.Class实例以其它的某种（或多种）方式成为roots，否则它们并不是roots。
  - 栈中引用的对象
  - 方法区中静态成员或者常量引用的对象（全局对象） （引出JDK1.7之后JVM常量池不存在方法区，1.8后没有了方法区）
  - JNI方法栈中引用对象
  - **活的Thread**



#### Minor GC ， Major GC  与 Full GC的区别

> JVM 在进行垃圾回收的时候，并非每次都对三个内存区域（新生代，老年代，方法区）区域一起回收的
>
> 针对Hotspot VM的实现，它的GC按照回收区域分为两大类，一种是 Partial GC （ 部分收集），一种是 Full GC整堆收集
>
> - 部分收集，不完整的收集整个Java堆的垃圾收集。其中又分为：
>   - 新生代收集（Minor GC/ Young GC）： 只是 新生代（eden，s0，s1）的垃圾收集
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
![](https://raw.githubusercontent.com/GuXiangFly/imagerepo/master/img20181112030202.png)
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


​    

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

![image-20200519163443352](https://gitee.com/guxiangfly/blogimage/raw/master/img/image-20200519163443352.png)

<img src="https://gitee.com/guxiangfly/blogimage/raw/master/img/image-20200519163622464.png" alt="image-20200519163622464" style="zoom:50%;" />







### 使用jprofile进行内存分析

###### jprofile打开后如下

![image-20200519164911923](https://gitee.com/guxiangfly/blogimage/raw/master/img/image-20200519164911923.png)

###### 双加最大的对象 char[] 选中 incoming references  （来源引用， 这个incoming reference可以帮助分析来源） 

<img src="https://gitee.com/guxiangfly/blogimage/raw/master/img/image-20200519165055346.png" alt="image-20200519165055346" style="zoom:50%;" />

###### 进入这个页面后点击 show paths to GC root 选择 single Root

<img src="https://gitee.com/guxiangfly/blogimage/raw/master/img/image-20200519165347342.png" alt="image-20200519165347342" style="zoom:50%;" />

<img src="https://gitee.com/guxiangfly/blogimage/raw/master/img/image-20200519165452640.png" alt="image-20200519165452640" style="zoom:50%;" />

###### 下图代表这个char 来自于 控制台 PrintStream

![image-20200519165518802](https://gitee.com/guxiangfly/blogimage/raw/master/img/image-20200519165518802.png)

