---
title: java8的方法引用
date: 2017-7-27 20:09:04
tags: [java8]

---
java8的方法引用

一、方法引用：若 Lambda 体中的功能，已经有方法提供了实现，可以使用方法引用
			  **（可以将方法引用理解为 Lambda 表达式的另外一种表现形式）**
1. 对象的引用 :: 实例方法名
2. 类名 :: 静态方法名
3. 类名 :: 实例方法名
注意：
	 ①方法引用所引用的方法的参数列表与返回值类型，需要与函数式接口中抽象方法的参数列表和返回值类型保持一致！
	 ②若Lambda 的参数列表的第一个参数，是实例方法的调用者，第二个参数(或无参)是实例方法的参数时，格式： ClassName::MethodName


我们来看 println的源码
``` java
   public void println(String x) {
        synchronized (this) {
            print(x);
            newLine();
        }
    }
```

它 接收的是一个 string 类型的参数，返回的是void

``` java
Consumer<String> con3 传入了泛型后


public interface Consumer<T> {

    /**
     * Performs this operation on the given argument.
     *
     * @param t the input argument
     */
    void accept(T t);
}
```
里面也有 accept接口是  void accept（string t）参数类型一样


于是就可以这么写
``` java
Consumer<String> consumer = System.out::println;

consumer.accept("Hello Java8！");
```

方法引用是一种特殊的lambda 
既然accept的是一个string，那么 
这个 string 注定是 system.out.println(string)
引用方法把不把println后面的参数写出来 都一样

Consumer 中的接口  accept的参数列表与 println的参数列表一样，所以写了accept 就没必要将println的参数列表写出来了

常见方法引用的地方
``` java
Stream<Integer> stream2 = Stream.of(1,2,3,4,5,6);
stream2.forEach(System.out::println);
```


forEach方法内部其实应该是一个 消费型接口 ，
Consumer<String> consumer = System.out::println;
它们相等 于是可以这么写
``` java
void forEach(Consumer<? super T> action);
```