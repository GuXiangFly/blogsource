---
title: ThreadLocal考察点
date: 2017-1-10 13:22:54
tags: [java]


---



# ThreadLocal学习



![test](https://guxiangflyimagebucket.oss-cn-beijing.aliyuncs.com/img/20240716161555.png)

![test2](https://guxiangflyimagebucket.oss-cn-beijing.aliyuncs.com/img/image-20240716132350221.png)







## 线程共享资源-保证事务

![image-20240716143721176](/Users/didi/Library/Application Support/typora-user-images/image-20240716143721176.png)





![image-20220323175047690](http://guxiangflyimagebucket.oss-cn-beijing.aliyuncs.com/img/image-20220323175047690.png)

ThreadLocal 的 set方法

```java
    public void set(T value) {
        Thread t = Thread.currentThread();
        ThreadLocalMap map = getMap(t);
        if (map != null)
            map.set(this, value);
        else
            createMap(t, value);
    }
```

ThreadLocal 的 get方法

```java
    public T get() {
        Thread t = Thread.currentThread();
        ThreadLocalMap map = getMap(t);
        if (map != null) {
            ThreadLocalMap.Entry e = map.getEntry(this);
            if (e != null) {
                @SuppressWarnings("unchecked")
                T result = (T)e.value;
                return result;
            }
        }
        return setInitialValue();
    }
```

**每个线程都有一个重要的类型，是ThreadLocalMap**

线程1和线程2的 ThreadLocalMap不是同一个

每个Thread类都有一个threadLocals的成员变量，这个threadLocals 就是ThreadLocalMap

```java
class Thread implements Runnable {
		.....
    ThreadLocal.ThreadLocalMap threadLocals = null;
    ...
}
```



ThreadLocal的内存泄露过程

```java
ThreadLocal<Person> tl = new ThreadLocal<>();
tl.set(new Person("jack"));
```

这个set的时候，会new 一个 Entry（一个WeakReference）
 Entry 的key 是threadLocal   value是  Person



### weakReference解决了什么问题？

##### 多线程不使用线程池的情况

假设线程退出了，那么CurrentThreadRef 与 ThreadLocalRef  弹栈，引用都为空。那么引用丢失，不会内存泄露。

假设线程未退出，ThreadLocalRef 引用丢失，weakReference 丢失， 但是value不会被清理。会存在内存泄露。（虽然threadLocal的key在set 和 get的时候会将  thread里面 threadlocalmap里面的key为null的数据删除） 不过建议多调用threadlocal.remove();
##### 多线程使用线程池的情况







#### TransmittableThreadLocal使用

1. 



======= 



![image-20201215014711439](http://guxiangflyimagebucket.oss-cn-beijing.aliyuncs.com/img/image-20201215014711439.png)











![image-20201215155455231](http://guxiangflyimagebucket.oss-cn-beijing.aliyuncs.com/img/image-20201215155455231.png)避免内存泄露的方式：

- - 使用完threadLocal 及时调用remove方法删除对应的entry









### 3. ThreadLocal的内部结构

1. 原先的结构：

   如果我们不去看源代码的话，可能会猜测ThreadLocal是这样子设计的：**每个ThreadLocal都创建一个Map，然后用线程作为Map的key，要存储的局部变量作为Map的value**，这样就能达到各个线程的局部变量隔离的效果。这是最简单的设计方法，JDK最早期的ThreadLocal 确实是这样设计的，但现在早已不是了。
   ![image-20240826164907538](https://guxiangflyimagebucket.oss-cn-beijing.aliyuncs.com/img/image-20240826164907538.png)

2. JDK8的结构：

   JDK后面优化了设计方案，在JDK8中 ThreadLocal的设计是：每个Thread维护一个ThreadLocalMap，这个Map的key是ThreadLocal实例本身，value才是真正要存储的值Object。

   具体的过程是这样的：

    （1） 每个Thread线程内部都有一个Map (ThreadLocalMap)
    （2） Map里面存储ThreadLocal对象（key）和线程的变量副本（value）
    （3）Thread内部的Map是由ThreadLocal维护的，由ThreadLocal负责向map获取和设置线程的变量值。
    （4）对于不同的线程，每次获取副本值时，别的线程并不能获取到当前线程的副本值，形成了副本的隔离，互不干扰。
   <img src="https://guxiangflyimagebucket.oss-cn-beijing.aliyuncs.com/img/image-20240826170822759.png" alt="image-20240826170822759" style="zoom:50%;" />

   



## 这样设计的好处
这样设计有如下两个优势：

（1） 每个Map存储的Entry数量就会变少。因为之前的存储数量由Thread的数量决定，现在是由ThreadLocal的数量决定。在实际运用当中，往往ThreadLocal的数量要少于Thread的数量。

（2） 当Thread销毁之后，对应的ThreadLocalMap也会随之销毁，能减少内存的使用。


![](https://guxiangflyimagebucket.oss-cn-beijing.aliyuncs.com/img/image-20240826171057789.png)


在源码中，我们可以看到 Thread类中有  threadLocals 这个成员变量

```JAVA
public class Thread implements Runnable {
  
    /* ThreadLocal values pertaining to this thread. This map is maintained
     * by the ThreadLocal class. */
    ThreadLocal.ThreadLocalMap threadLocals = null;

    /*
     * InheritableThreadLocal values pertaining to this thread. This map is
     * maintained by the InheritableThreadLocal class.
     */
    ThreadLocal.ThreadLocalMap inheritableThreadLocals = null;
}
```







## ThreadLocalMap的内部结构【以及弱引用与内存泄漏】

从源码上看，ThreadLocalMap是ThreadLocal类的一个静态内部类，并且没有实现map接口

：

```java
    public class ThreadLocal<T> {
       static class ThreadLocalMap {}
    }
```





<img src="https://guxiangflyimagebucket.oss-cn-beijing.aliyuncs.com/img/image-20240826173328925.png" style="zoom: 25%;" />

map一般是数组实现的哇，数组里面的每个实体是一个 entry，这个entry是一个 weakReference

```java
    static class Entry extends WeakReference<ThreadLocal<?>> {
            /** The value associated with this ThreadLocal. */
            Object value;

            Entry(ThreadLocal<?> k, Object v) {
                super(k);
                value = v;
            }
        }
```

map的key是一个ThreadLocal 对象  value是值，







 弱引用相关概念

 Java中的引用有4种类型： 强、软、弱、虚。当前这个问题主要涉及到强引用和弱引用：

- 强引用（“Strong” Reference），就是我们最常见的普通对象引用，只要还有强引用指向一个对象，就能表明对象还“活着”，垃圾回收器就不会回收这种对象。

- 弱引用（WeakReference），垃圾回收器一旦发现了只具有弱引用的对象，不管当前内存空间足够与否，都会回收它的内存。   
- **弱引用中的对象， 被其他强引用  引用到， 那么仍然不会被回收**



![](https://guxiangflyimagebucket.oss-cn-beijing.aliyuncs.com/img/image-20240826173852073.png)

![](https://guxiangflyimagebucket.oss-cn-beijing.aliyuncs.com/img/image-20240828174750348.png)









综上，ThreadLocal内存泄漏的根源是：由于ThreadLocalMap的生命周期跟Thread一样长，如果没有手动删除对应key就会导致内存泄漏。

（7） 为什么使用弱引用

根据刚才的分析, 我们知道了： 无论ThreadLocalMap中的key使用哪种类型引用都无法完全避免内存泄漏，跟使用弱引用没有关系。

要避免内存泄漏有两种方式：

1. **使用完ThreadLocal，调用其remove方法删除对应的Entry**
2. **使用完ThreadLocal，当前Thread也随之运行结束[线程池情况下不适用。]**

相对第一种方式，第二种方式显然更不好控制，特别是使用线程池的时候，线程结束是不会销毁的。 也就是说，只要记得在使用完ThreadLocal及时的调用remove，无论key是强引用还是弱引用都不会有问题。那么为什么key要用弱引用呢？

**事实上，在ThreadLocalMap中的set/getEntry方法中，会对key为null（也即是ThreadLocal为null）进行判断，如果为null的话，那么是会对value置为null的。**

```java
  private void set(ThreadLocal<?> key, Object value) {

            // We don't use a fast path as with get() because it is at
            // least as common to use set() to create new entries as
            // it is to replace existing ones, in which case, a fast
            // path would fail more often than not.

            Entry[] tab = table;
            int len = tab.length;
            int i = key.threadLocalHashCode & (len-1);

            for (Entry e = tab[i];
                 e != null;
                 e = tab[i = nextIndex(i, len)]) {
                ThreadLocal<?> k = e.get();

                if (k == key) {
                    e.value = value;
                    return;
                }

                if (k == null) {
                    replaceStaleEntry(key, value, i);
                    return;
                }
            }
```

这就意味着使用完ThreadLocal，CurrentThread依然运行的前提下，就算忘记调用remove方法，弱引用比强引用可以多一层保障：弱引用的ThreadLocal在GC后会被回收，对应的value在下一次ThreadLocalMap调用set,get,remove中的任一方法的时候会被清除，从而避免内存泄漏。

## **如何使用 TransmittableThreadLocal**

```xml
        <dependency>
            <groupId>com.alibaba</groupId>
            <artifactId>transmittable-thread-local</artifactId>
            <version>2.12.2</version>
        </dependency>
```

```java
import com.alibaba.ttl.TransmittableThreadLocal;

public class TrafficCenterTransmittableThreadLocal {

    public  static  final TransmittableThreadLocal<PojoBean> pojoBeanThreadLocal = new TransmittableThreadLocal<PojoBean>();

    public static void setPojoBean(PojoBean pojoBean) {
        pojoBeanThreadLocal.set(pojoBean);
    }

    public static PojoBean getPojoBean() {
        return pojoBeanThreadLocal.get();
    }

}
```

```java
        executorService.execute(Objects.requireNonNull(TtlRunnable.get(() -> {
            try {
                Thread.sleep(3000);
            } catch (InterruptedException e) {
                throw new RuntimeException(e);
            }
            PojoBean pojoBean2 = TrafficCenterTransmittableThreadLocal.getPojoBean();
            System.out.println("ThreadLocal pojoBean in Thread TtlRunnable\\t:" + pojoBean2);

        })));
```


```java
@RestController
public class ThreadLocalTestController {

    ExecutorService   executorService = new ThreadPoolExecutor(10, 20, 1000L, TimeUnit.MILLISECONDS,
            new LinkedBlockingDeque<>(100), new ThreadPoolExecutor.AbortPolicy());

    volatile  int count = 0;

    @GetMapping("/threadlocaltest")
    public String test1(){
        count ++;
        PojoBean pojoBean = new PojoBean();
        pojoBean.setContent("test_count_" +count);
        pojoBean.setFlowType("nowTime:" + DateUtils.formatDate(new Date()));
        TrafficCenterTransmittableThreadLocal.setPojoBean(pojoBean);
        System.out.println("ThreadLocal pojoBean:" + pojoBean);

        executorService.execute(new Runnable(){
            public void run() {
                try {
                    Thread.sleep(3000);
                } catch (InterruptedException e) {
                    throw new RuntimeException(e);
                }
                PojoBean pojoBean = TrafficCenterTransmittableThreadLocal.getPojoBean();
                System.out.println("ThreadLocal pojoBean in Thread  normal\\t\\t:" + pojoBean);
            }
        });

        executorService.execute(Objects.requireNonNull(TtlRunnable.get(() -> {
            try {
                Thread.sleep(3000);
            } catch (InterruptedException e) {
                throw new RuntimeException(e);
            }
            PojoBean pojoBean2 = TrafficCenterTransmittableThreadLocal.getPojoBean();
            System.out.println("ThreadLocal pojoBean in Thread TtlRunnable\\t:" + pojoBean2);

        })));

        return "success";
    }
}
```
