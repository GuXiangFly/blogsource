---
title: JVM参数的优化
date: 2017-3-11 23:09:04
tags: [JVM,java]

---

JVM参数的优化
=============

适当调整Tomcat的运行JVM参数可以提升整体性能。


JVM内存模型
-----------

### Java栈

Java栈是与每一个线程关联的，JVM在创建每一个线程的时候，会分配一定的栈空间给线程。它主要用来存储线程执行过程中的局部变量，方法的返回值，以及方法调用上下文。栈空间随着线程的终止而释放。

### Java堆

Java中堆是由所有的线程共享的一块内存区域，堆用来保存各种JAVA对象，比如数组，线程对象等。

## Java堆的分区

JVM堆一般又可以分为以下三部分：

![这里写图片描述](http://img.blog.csdn.net/20170709233917303?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvbXlfX1N1bl8=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)

◆ **Young 年轻区（代）**

Young区被划分为三部分，Eden区和两个大小严格相同的Survivor区，其中，Survivor区间中，某一时刻只有其中一个是被使用的，另外一个留做垃圾收集时复制对象用，在Eden区间变满的时候，
GC就会将存活的对象移到空闲的Survivor区间中，根据JVM的策略，在经过几次垃圾收集后，任然存活于Survivor的对象将被移动到Tenured区间。

◆ **Tenured 年老区**

Tenured区主要保存生命周期长的对象，一般是一些老的对象，当一些对象在Young复制转移一定的次数以后，对象就会被转移到Tenured区，一般如果系统中用了application级别的缓存，缓存中的对象往往会被转移到这一区间。

◆ **Perm 永久区**

   Perm代主要保存class,method,filed对象，这部份的空间一般不会溢出，除非一次性加载了很多的    类，不过在涉及到热部署的应用服务器的时候，有时候会遇到java.lang.OutOfMemoryErrorPermGen space
的错误，造成这个错误的很大原因就有可能是每次都重新部署，但是重新部署后，类的class没有被卸载掉，这样就造成了大量的class对象保存在了perm中，这种情况下，一般重新启动应用服务器可以解决问题。

**Virtual区：**

最大内存和初始内存的差值，就是Virtual区。

### 设置区大小

JVM提供了相应的参数来对内存大小进行配置。正如上面描述，JVM中堆被分为了3个大的区间，同时JVM也提供了一些选项对Young,Tenured的大小进行控制。

![这里写图片描述](http://img.blog.csdn.net/20170709234254961?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvbXlfX1N1bl8=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)

◆ Total Heap

**\-Xms** ：指定了JVM初始启动以后初始化内存

**\-Xmx**：指定JVM堆得最大内存，在JVM启动以后，会分配-Xmx参数指定大小的内存给JVM，但是不一定全部使用，JVM会根据-Xms参数来调节真正用于JVM的内存

\-Xmx -Xms之差就是三个Virtual空间的大小

◆ **Young Generation**

**\-XX:NewRatio=8**意味着tenured 和 young的比值8：1，这样eden+2\*survivor=1/9

堆内存

**\-XX:SurvivorRatio=32**意味着eden和一个survivor的比值是32：1，这样一个Survivor就占Young区的1/34.

**\-Xmn** 参数设置了年轻代的大小

◆ Perm Generation

**\-XX:PermSize**=16M -XX:MaxPermSize=64M

Thread Stack

**\-XX:Xss**=128K


常用参数
--------

修改文件：bin/catalina.sh

JAVA\_OPTS="-Dfile.encoding=UTF-8 -server -Xms1024m -Xmx1024m -XX:NewSize=512m
-XX:MaxNewSize=512m -XX:PermSize=256m -XX:MaxPermSize=256m -XX:NewRatio=2
-XX:MaxTenuringThreshold=50 -XX:+DisableExplicitGC"

参数说明：

1.  file.encoding 默认文件编码

2.  \-Xmx1024m 设置JVM最大可用内存为1024MB

3.  \-Xms1024m
    设置JVM最小内存为1024m。此值可以设置与-Xmx相同，以避免每次垃圾回收完成后JVM重新分配内存。

4.  \-XX:NewSize 设置年轻代大小

5.  XX:MaxNewSize 设置最大的年轻代大小

6.  \-XX:PermSize 设置永久代大小

7.  \-XX:MaxPermSize 设置最大永久代大小

8.  \-XX:NewRatio=4:设置年轻代（包括Eden和两个Survivor区）与终身代的比值（除去永久代）。设置为4，则年轻代与终身代所占比值为1：4，年轻代占整个堆栈的1/5

9.  \-XX:MaxTenuringThreshold=0：设置垃圾最大年龄，默认为：15。如果设置为0的话，则年轻代对象不经过Survivor区，直接进入年老代。对于年老代比较多的应用，可以提高效率。如果将此值设置为一个较大值，则年轻代对象会在Survivor区进行多次复制，这样可以增加对象再年轻代的存活时间，增加在年轻代即被回收的概论。

10.  \-XX:+DisableExplicitGC这个将会忽略手动调用GC的代码使得
   System.gc()的调用就会变成一个空调用，完全不会触发任何GC


在tomcat中设置JVM参数
---------------------

### windows

修改bin/catalina.bat文件设置参数（第一行）

set JAVA\_OPTS=-Dfile.encoding=UTF-8 -server -Xms1024m -Xmx2048m
-XX:NewSize=512m -XX:MaxNewSize=1024m -XX:PermSize=256m -XX:MaxPermSize=256m
-XX:MaxTenuringThreshold=10 -XX:NewRatio=2 -XX:+DisableExplicitGC

![这里写图片描述](http://img.blog.csdn.net/20170709234838645?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvbXlfX1N1bl8=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)

### linux

修改bin/catalina.sh文件参数（第一行）

JAVA\_OPTS="-Dfile.encoding=UTF-8 -server -Xms1024m -Xmx2048m -XX:NewSize=512m
-XX:MaxNewSize=1024m -XX:PermSize=256m -XX:MaxPermSize=256m
-XX:MaxTenuringThreshold=10 -XX:NewRatio=2 -XX:+DisableExplicitGC"

![这里写图片描述](http://img.blog.csdn.net/20170709234907712?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvbXlfX1N1bl8=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)