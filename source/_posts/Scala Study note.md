---
title: Scala study Note
date: 2018-8-27 20:09:04
tags: [大数据]

---


### 打印的方法
```scala
object printDemo {
  def main(args: Array[String]): Unit = {
    var str1: String = "hello"
    var str2: String = " world!"
    println(str1 + str2)
    var name:String = "tom"
    var age:Int = 10
    var sal:Float = 10.67f
    var height:Double = 180.15
    //格式化输出
    printf("名字=%s 年龄是%d 薪水%.2f 高%.3f",name,age,sal,height)

    //scala支持使用$输出内容, 编译器会去解析$对应变量
    println(s"\n个人信息如下：\n 名字$name \n年龄$age \n薪水$sal ")
    //如果下字符串中出现了类似${age + 10} 则表示{}是一个表达式
    println(s"\n个人信息如下2：\n 名字${name} \n年龄${age + 10} \n薪水${sal * 100} ")
  }
}
```
## val 和 var
val 不可以改变  通过反编译发现就是加了个 final 
var 可以改变
```scala

    //3.在声明/定义一个变量时，可以使用var 或者 val 来修饰， var 修饰的变量可改变，val 修饰的变量不可改

    var age = 10 //即age 是可以改变的.
    age = 30 // ok

    val num2 = 30
    //num2 = 40 // val 修饰的变量是不可以改变.

    //scala设计者为什么设计  var 和 val
    //(1) 在实际编程，我们更多的需求是获取/创建一个对象后，读取该对象的属性，
    // 或者是修改对象的属性值, 但是我们很少去改变这个对象本身
    //   dog = new Dog()  dog.age = 10  dog = new Dog()
    // 这时，我们就可以使用val
    //(2) 因为val 没有线程安全问题，因此效率高，scala的设计者推荐我们val
    //(3) 如果对象需要改变，则使用var
```
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


## 方法和函数的相互转化

在Scala当中，函数是一等公民，像变量一样，既可以作为函数的参数使用，
也可以将函数赋值给一个变量. ，函数的创建不用依赖于类或者对象，
而在Java当中，函数的创建则要依赖于类、抽象类或者接口. 
```scala
object Method2function {
  def main(args: Array[String]): Unit = {
    val dog = new Dog
    //调用method
    dog.sayHello()
    
    //method  convert to  function
    var fun1 = dog.sayHello _
    fun1()
  }
}

class Dog {
  def sayHello(): Unit ={
    println("hello")
  }
}
    // function
val fun2 = (n1:Int, n2:Int) => {
  n1+n2
}
```

### 函数的定义
基本语法
def 函数名 ([参数名: 参数类型], ...)[[: 返回值类型] =] {
	语句...
	return 返回值
}
函数声明关键字为def  (definition)
[参数名: 参数类型], ...：表示函数的输入(就是参数列表), 可以没有。 如果有，多个参数使用逗号间隔
函数中的语句：表示为了实现某一功能代码块
函数可以有返回值,也可以没有
返回值形式1:    : 返回值类型  =   
返回值形式2:    =  表示返回值类型不确定，使用类型推导完成
返回值形式3:      表示没有返回值，return 不生效
如果没有return ,默认以执行到最后一行的结果作为返回值


函数的形参列表可以是多个, 如果函数没有形参，调用时 可以不带() 
形参列表和返回值列表的数据类型可以是值类型和引用类型。【案例演示】
Scala中的函数可以根据函数体最后一行代码自行推断函数返回值类型。那么在这种情况下，return关键字可以省略

因为Scala可以自行推断，所以在省略return关键字的场合，返回值类型也可以省略
如果函数明确使用return关键字，那么函数返回就不能使用自行推断了,这时要明确写成 : 返回类型 =  ，当然如果你什么都不写，即使有return 

### 构造器
```scala
写法1
class A() {
}
写法2
class A {
}

val a = new A
val a2 = new A()

//构造器的快速入门
//创建Person对象的同时初始化对象的age属性值和name属性值
class Person(inName:String,inAge:Int) {
  var name: String = inName
  var age: Int = inAge
  age += 10
  println("~~~~~~~~~~")

  //重写了toString，便于输出对象的信息
  override def toString: String = {
    "name=" + this.name + "\t age" + this.age
  }

  println("ok~~~~~")
  println("age=" + age)

  def this(name:String) {
    //辅助构造器，必须在第一行显式调用主构造器(可以是直接，也可以是间接)
    this("jack", 10)
    //this
    this.name = name //重新赋值
  }
}
object ConDemo02 {

  def main(args: Array[String]): Unit = {
    val a = new AA("jack")
    //输出的顺序是
    //1. b~~~ 父类
    //2. AA() 主构造器
    //3. A this(name:String) 辅助构造器
  }
}

## 辅助构造器
class BB(){
  println("b~~~")
}

class AA() extends BB() {
  println("AA()")
  def this(name:String) {
    this
    println("A this(name:String)")
  }
}


```

### Scala 的包
scala 会自动引入常用的包

java.lang.*
scala.* 包
Predef 包

### scala 半生对象
当一个文件中出现了 class Clerk 和 object Clerk
1. class Clerk 称为伴生类
2. object Clerk 的伴生对象
3. 因为scala设计者将static拿掉, 他就是设计了 伴生类和伴生对象的概念
4. 伴生类 写非静态的内容 伴生对象 就是静态内容

### apply方法
伴生对象-apply方法.
在伴生对象中定义apply方法，可以实现： 类名(参数) 方式来创建对象实例. 


### 特质 trait
一个类具有某种特质（特征），就意味着这个类满足了这个特质（特征）的所有要素，所以在使用时，也采用了extends关键字，如果有多个特质或存在父类，那么需要采用with关键字连接

没有父类class  类名   extends   特质1   with    特质2   with   特质3 ..

有父类class  类名   extends   父类   with  特质1   with   特质2   with 特质3


### scala 的 implicit
```scala

//小结
//1. 当在程序中，同时有 隐式值，默认值，传值
//2. 编译器的优先级为 传值 > 隐式值 > 默认值
//3. 在隐式值匹配时，不能有二义性
//4. 如果三个 （隐式值，默认值，传值） 一个都没有，就会报错

object ImplicitVal02 {
  def main(args: Array[String]): Unit = {
    // 隐式变量（值）
//    implicit val name: String = "Scala"
    //implicit val name1: String = "World"

    //隐式参数
    def hello(implicit content: String = "jack"): Unit = {
      println("Hello " + content)
    } //调用hello
    hello

    //当同时有implicit 值和默认值，implicit 优先级高
    def hello2(implicit content: String = "jack"): Unit = {
      println("Hello2 " + content)
    } //调用hello
    hello2


    //说明
    //1. 当一个隐式参数匹配不到隐式值，仍然会使用默认值

    implicit val name: Int = 10
    def hello3(implicit content: String = "jack"): Unit = {
      println("Hello3 " + content)
    } //调用hello
    hello3 //  hello3 jack

//    //当没有隐式值，没有默认值，又没有传值，就会报错
//    def hello4(implicit content: String ): Unit = {
//      println("Hello4 " + content)
//    } //调用hello
//    hello4 //  hello3 jack
  }
}
```

### 隐式类
```scala
object ImplicitClassDemo {

  def main(args: Array[String]): Unit = {
    //DB1会对应生成隐式类
    //DB1是一个隐式类, 当我们在该隐式类的作用域范围，创建MySQL1实例
    //该隐式类就会生效, 这个工作仍然编译器完成
    //看底层..
    implicit class DB1(val m: MySQL1) { //ImplicitClassDemo$DB1$2
      def addSuffix(): String = {
        m + " scala"
      }
    }


    //创建一个MySQL1实例
    val mySQL = new MySQL1
    mySQL.sayOk()
    mySQL.addSuffix() //研究 如何关联到 DB1$1(mySQL).addSuffix();

    implicit def f1(d:Double): Int = {
      d.toInt
    }

    def test1(n1:Int): Unit = {
      println("ok")
    }
    test1(10.1)

  }
}
class DB1 {}
class MySQL1 {
  def sayOk(): Unit = {
    println("sayOk")
  }
}
```

### Scala集合类

![](https://raw.githubusercontent.com/GuXiangFly/imagerepo/master/20190128203945.png)


### scala的遍历
三种方式 
```scala

```