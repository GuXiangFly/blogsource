---
title: Scala study Note
date: 2018-8-27 20:09:04
tags: [大数据]

---

## Lazy 懒值

非懒值会在声明的时候 就初始化
懒值在声明时候不会初始化 会在使用到的时候 才初始化

```scala
    
def init(): String = {
  println("call init()")
  return ""
}


def noLazy() {
  val property = init();//没有使用lazy修饰
  println("after init()")
  println(property)
}

def lazyed() {
  lazy val property = init();//没有使用lazy修饰
  println("after init()")
  println(property)
}


noLazy()

lazyed()
```


##  集合
Scala 同时支持可变集合和不可变集合，不可变集合从不可变，可以安全 的并发访问。


两个主要的包:
1) 可变集合:scala.collection.mutable
2) 不可变集合: scala.collection.immutable

Scala 优先采用不可变集合。集合主要分为三大类:序列、集、映射。 所有集合都扩展自 Iterable 特质。对于几乎所有的集合类，Scala 都同时
提供了可变和不可变的版本。


## 集合操作

_代表了集合中的每个元素

当我们元素在函数中 只出现一次的时候 我们可以用 _ 代替
就是这个元素用一次之后就不要用了 这么做可以减少定义的变量个数 
```scala
a.filter(_ % 2 == 0).map(2 * _)
```