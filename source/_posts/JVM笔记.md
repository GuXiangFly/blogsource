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
- 线程共享区
    - 老年代 (Tenured Gen)
    - 新生代
       - Eden
       - Survivor*2  
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


- 根
  - 栈中引用的对象
  - 方法区中静态成员或者常量引用的对象（全局对象）
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