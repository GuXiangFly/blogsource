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
            方法区，也叫永久带 JDK8中被取消
            用于存放虚拟机加载的各种类信息 .class 文件， 静态的变量 和 常量池（常量池在jdk1.7的时候  被移动到了堆区）

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
       - Old 


- 线程独占区
    - JVM虚拟机栈
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
- 与标记-清除算法相比，复制算法是一种相对高效的回收方法
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


有哪些可以作为 GC root
- 根
  - 栈中引用的对象
  - 方法区中静态成员或者常量引用的对象（全局对象） （引出JDK1.7之后JVM常量池不存在方法区，1.8后没有了方法区）
  - JNI方法栈中引用对象
  

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
    一定是
```
 - 读重排序： 初次读一个包含 final 域的对象的引用，与随后初次读这个 final 域，这两个操作之间不能重排序。

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
每个region有一个


## JVM 类加载机制

![](https://raw.githubusercontent.com/GuXiangFly/imagerepo/master/img20181121141121.png)

![](https://raw.githubusercontent.com/GuXiangFly/imagerepo/master/img20181121141042.png)

