---
title: BigData 学习笔记
date: 2018-2-27 20:09:04
tags: [Activiti]

---


### Scala部分

```scala
class Person 
class Asia extends Person
class Chinese extends Asia

//defined class Group 
这是不变  ji  只能接受自己作为类型传入
class Group[T](t:T)  
val groupAsia:Group[Asia] = new Group(new Asia)  -success
val groupPerson:Group[Person] = groupAsia (这样不行)

这个是 协变 +T Ji 可以接受 定义的类型的 父类型传入
class Group1[+T](t:T)
val group1Asia:Group1[Asia] = new Group1(new Asia)  -success
val group1Person:Group1[Person] = group1Asia (这样可以)
val group1Chinese:Group1[Chinese] = group1Asia (这样不可以)

这个是 逆变 -T Ji 可以接受 定义的类型的 子类型传入
class Group2[-T](t:T)
val group2Asia:Group1[Asia] = new Group2(new Asia)  -success
val group2Person:Group1[Person] = group2Asia (这样不可以)
val group2Chinese:Group1[Chinese] = group2Asia (这样可以)

## 上界   T<:Asia
class Group3[T<:Asia](t: T)  
 -(代表T类型 必须是 Asia 以及 Asia 的子类型)
 val group3Asia:Group3[Asia] = new Group3[Asia](new Asia)
 val group3chinese:Group3[Chinese] = new Group3[Chinese](new Chinese)
 
 
 ## 下界  [T>:Asia
 class Group4[T>:Asia](t: T)
   -(代表T类型 必须是 Asia 以及 Asia 的父类型)
  val group4Asia:Group4[Asia] = new Group4[Asia](new Asia)
  val group4Person:Group4[Person] = new Group4[Person](new Person)
  
  buguo  有个地方值得注意
    val group4Chinese2:Group4[Chinese] = new Group4[Chinese](new Chinese)(这样不行)
   val group4chinese = new Group4(new Chinese)  (这样可以,它会自动将Chinese 转换为 Asia)


协变 中的 上界下界
class Group5[+T](t : T){
	def f1[T](t : T) = {}
	def f2[S <: T](s : S) = {}
	def f3[Z >: T](z : Z) = {}
}

逆变 中的 上界下界 
class Group6[-T](t : T){
	def f1[T](t : T) = {}
	def f2[S <: T](s : S) = {}
	def f3[Z >: T](z : Z) = {}
}


```



