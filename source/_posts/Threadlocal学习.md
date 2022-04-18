---
title: ThreadLocal考察点
date: 2017-1-10 13:22:54
tags: [java]


---



# ThreadLocal学习

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

<img src="/Users/didi/Library/Application Support/typora-user-images/image-20220323181452974.png" alt="image-20220323181452974" style="zoom:50%;" />

##### 多线程不使用线程池的情况

假设线程退出了，那么CurrentThreadRef 与 ThreadLocalRef  弹栈，引用都为空。那么引用丢失，不会内存泄露。

假设线程未退出，ThreadLocalRef 引用丢失，weakReference 丢失， 但是value不会被清理。会存在内存泄露。（虽然threadLocal的key在set 和 get的时候会将  thread里面 threadlocalmap里面的key为null的数据删除） 不过建议多调用threadlocal.remove();
##### 多线程使用线程池的情况







#### TransmittableThreadLocal使用

1. 



======= 



![image-20201215014711439](https://gitee.com/guxiangfly/blogimage/raw/master/img/image-20201215014711439.png)











![image-20201215155455231](https://gitee.com/guxiangfly/blogimage/raw/master/img/image-20201215155455231.png)避免内存泄露的方式：

- - 使用完threadLocal 及时调用remove方法删除对应的entry









