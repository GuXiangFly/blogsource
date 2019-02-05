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


### Scala数组与Java的List的互转
```scala
// Scala集合和Java集合互相转换
val arr = ArrayBuffer("1", "2", "3")
import scala.collection.JavaConversions.bufferAsJavaList
val javaArr = new ProcessBuilder(arr) //为什么可以这样使用?
val arrList = javaArr.command()
println(arrList) //输出 [1, 2, 3]


import scala.collection.JavaConversions.asScalaBuffer
import scala.collection.mutable
// java.util.List ==> Buffer
val scalaArr: mutable.Buffer[String] = arrList
scalaArr.append("jack")
println(scalaArr)
//案例演示+说明
```

## 元组Tuple
元组也是可以理解为一个容器，可以存放各种相同或不同类型的数据。
说的简单点，就是将多个无关的数据封装为一个整体，称为元组, 最多的特点灵活,对数据没有过多的约束。
注意：元组中最大只能有22个元素


```scala
object TupleDemo01 {
  def main(args: Array[String]): Unit = {
    //创建
    //说明 1. tuple1 就是一个Tuple 类型是Tuple5
    //简单说明: 为了高效的操作元组 ， 编译器根据元素的个数不同，对应不同的元组类型
    // 分别 Tuple1----Tuple22

    val tuple1 = (1, 2, 3, "hello", 4)
    println(tuple1)

    println("==================访问元组=========================")
    //访问元组
    val t1 = (1, "a", "b", true, 2)
    println(t1._1) // 1 //访问元组的第一个元素 ，从1开始
    /*
     override def productElement(n: Int) = n match {
    case 0 => _1
    case 1 => _2
    case 2 => _3
    case 3 => _4
    case 4 => _5
    case _ => throw new IndexOutOfBoundsException(n.toString())
 }
     */
    println(t1.productElement(0)) // 0 // 访问元组的第一个元素，从0开始


    println("==================遍历元组=========================")
    //遍历元组, 元组的遍历需要使用到迭代器
    for (item <- t1.productIterator) {
      println("item=" + item)
    }
  }
}
```


###  List 的 追加元素  
说明:
符号::表示向集合中  新建集合添加元素。
运算时，集合对象一定要放置在最右边，
运算规则，从右向左。
::: 运算符是将集合中的每一个元素加入到空集合中去

```scala

object ListDemo01 {
  def main(args: Array[String]): Unit = {
    //说明
    //1. 在默认情况下 List 是scala.collection.immutable.List,即不可变
    //2. 在scala中,List就是不可变的，如需要使用可变的List,则使用ListBuffer
    //3. List 在 package object scala 做了 val List = scala.collection.immutable.List
    //4. val Nil = scala.collection.immutable.Nil // List()

    val list01 = List(1, 2, 3, "Hello") //创建时，直接分配元素
    println(list01)

    val list02 = Nil  //空集合
    println(list02)

    //访问List的元素
    val value1 = list01(1) // 1是索引，表示取出第2个元素.
    println("value1=" + value1) // 2


    println("-------------list追加元素后的效果-----------------")
    //通过 :+ 和 +: 给list追加元素(本身的集合并没有变化)
    var list1 = List(1, 2, 3, "abc")
    // :+运算符表示在列表的最后增加数据
    val list2 = list1 :+ 4 // (1,2,3,"abc", 4)
    println(list1) //list1没有变化 (1, 2, 3, "abc"),说明list1还是不可变
    println(list2) //新的列表结果是 [1, 2, 3, "abc", 4]

    val list3 = 10 +: list1 // (10,1, 2, 3, "abc")
    println("list3=" + list3)


    //:: 符号的使用

    val list4 = List(1, 2, 3, "abc")
    //说明 val list5 = 4 :: 5 :: 6 :: list4 :: Nil 步骤
    //1. List()
    //2. List(List(1, 2, 3, "abc"))
    //3. List(6,List(1, 2, 3, "abc"))
    //4. List(5,6,List(1, 2, 3, "abc"))
    //5. List(4,5,6,List(1, 2, 3, "abc"))
    val list5 = 4 :: 5 :: 6 :: list4 :: Nil
    println("list5=" + list5)

    //说明 val list6 = 4 :: 5 :: 6 :: list4 ::: Nil 步骤
    //1. List()
    //2. List(1, 2, 3, "abc")
    //3. List(6,1, 2, 3, "abc")
    //4. List(5,6,1, 2, 3, "abc")
    //5. List(4,5,6,1, 2, 3, "abc")
    val list6 = 4 :: 5 :: 6 :: list4 ::: Nil
    println("list6=" + list6)
  }
}
```


### Map 的构建方式
```scala

object MapDemo01 {
  def main(args: Array[String]): Unit = {

    //方式1-构造不可变映射
    //1.默认Map是 immutable.Map
    //2.key-value 类型支持Any
    //3.在Map的底层，每对key-value是Tuple2
    //4.从输出的结果看到，输出顺序和声明顺序一致
    val map1 = Map("Alice" -> 10, "Bob" -> 20, "Kotlin" -> "北京")
    println(map1)
    //方式2-构造可变映射
    //1.从输出的结果看到，可变的map输出顺序和声明顺序不一致
    val map2 = mutable.Map("Alice" -> 10, "Bob" -> 20, "Kotlin" -> "北京")
    println(map2)
    //方式3-创建空的映射
    val map3 = new scala.collection.mutable.HashMap[String, Int]
    println("map3=" + map3)
    //方式4-对偶元组
    val map4 = mutable.Map(("Alice", 10), ("Bob", 20), ("Kotlin", "北京"))
    println("map4=" + map4)
    
    
    
    
    
    
    //方式1-使用map(key)
    println(map4("Alice")) // 10
    //抛出异常（java.util.NoSuchElementException: key not found:）
    //println(map4("Alice~"))

    //方式2-使用contains方法检查是否存在key
    if (map4.contains("Alice")) {
      println("key存在，值=" + map4("Alice"))
    } else {
      println("key不存在:)")
    }

    //方式3 方式3-使用map.get(key).get取值
    //1. 如果key存在 map.get(key) 就会返回Some(值)  ,然后Some(值).get就可以取出
    //2. 如果key不存在 map.get(key) 就会返回None

    println(map4.get("Alice").get)
    //println(map4.get("Alice~").get)  // 抛出异常

    //方式4-使用map4.getOrElse()取值
    println(map4.getOrElse("Alice~~~", "默认的值 鱼 <・)))><<"))


    val map5 = mutable.Map(("A", 1), ("B", "北京"), ("C", 3))
    map5("A") = 20 //增加
    println("map5=" + map5)

    map5 += ("A" -> 100)
    println("map5=" + map5)

    map5 -= ("A", "B", "AAA") //
    println("map5=" + map5)

    //map的遍历
    val map6 = mutable.Map(("A", 1), ("B", "北京"), ("C", 3))
    println("----(k, v) <- map6--------")
    for ((k, v) <- map6) println(k + " is mapped to " + v)

    println("----v <- map6.keys--------")
    for (v <- map6.keys) println(v)
    println("----v <- map6.values--------")
    for (v <- map6.values) println(v)

    //这样取出方式 v 类型是 Tuple2
    println("----v <- map6--------")
    for (v <- map6) println(v + " key =" + v._1 + " val=" + v._2) //v是Tuple?
  }
}

```

### Map 的遍历
```scala
    //map的遍历
    val map6 = mutable.Map(("A", 1), ("B", "北京"), ("C", 3))
    println("----(k, v) <- map6--------")
    for ((k, v) <- map6) println(k + " is mapped to " + v)

    println("----v <- map6.keys--------")
    for (v <- map6.keys) println(v)
    println("----v <- map6.values--------")
    for (v <- map6.values) println(v)
    
     //这样取出方式 v 类型是 Tuple2
     println("----v <- map6--------")
     
     
     for (v <- map6) println(v + " key =" + v._1 + " val=" + v._2) //v是Tuple?
    
```

### 高阶函数部分
假设有个方法
```scala
  def myPrint(): Unit = {
    println("hello,world!")
  }
  
      //在scala中，可以把一个函数直接赋给一个变量,但是不执行函数
      val f1 = myPrint _    这个不会执行这个函数
      val  f2 = myPrint     这个会执行这个函数
```


### flatmap 操作
```scala
flatmap映射：flat即压扁，压平，扁平化映射
flatmap：flat即压扁，压平，扁平化，效果就是将集合中的每个元素的子元素映射到某个函数并返回新的集合。
看一个案例：

就是 函数中每个元素 如果是个 list  那么将元素中的list 也进行一次遍历
val names = List("Alice", "Bob", "Nick")
def upper( s : String ) : String = {
    s. toUpperCase
}
//注意：每个字符串也是char集合
println(names.flatMap(upper)) 
```

### Reduce 化简  流程
化简：将二元函数引用于集合中的函数,。
reduceLeft 就是从左边开始 每次讲前一次的返回结果 作为后一次的 第一个输入结果
//说明
1. def reduceLeft[B >: A](@deprecatedName('f) op: (B, A) => B): B
2. reduceLeft(f) 接收的函数需要的形式为 op: (B, A) => B): B
3. reduceleft(f) 的运行规则是 从左边开始执行将得到的结果返回给第一个参数
4. 然后继续和下一个元素运行，将得到的结果继续返回给第一个参数，继续..
5. 即: //((((1 + 2)  + 3) + 4) + 5) = 15

### Flod 折叠
fold函数将上一步返回的值作为函数的第一个参数继续传递参与运算，直到list中的所有元素被遍历。
如何理解:def reduceLeft[B >: A](@deprecatedName('f) op: (B, A) => B): B =  if (isEmpty) throw new UnsupportedOperationException("empty.reduceLeft")  else tail.foldLeft[B](head)(op)大家可以看到. reduceLeft就是调用的foldLeft[B](head)，并且是默认从集合的head元素开始操作的。
相关函数：fold，foldLeft，foldRight，可以参考reduce的相关方法理解

```scala

object FoldDemo01 {
  def main(args: Array[String]): Unit = {

    val list = List(1, 2, 3, 4)
    def minus( num1 : Int, num2 : Int ): Int = {
      num1 - num2
    }

    //说明
    //1. 折叠的理解和化简的运行机制几乎一样.
    //理解 list.foldLeft(5)(minus) 理解成 list(5,1, 2, 3, 4) list.reduceLeft(minus)
    //步骤  (5-1)
    //步骤  ((5-1) - 2)
    //步骤  (((5-1) - 2) - 3)
    //步骤  ((((5-1) - 2) - 3)) - 4 = - 5
    println(list.foldLeft(5)(minus)) // 函数的柯里化
    ////理解 list.foldRight(5)(minus) 理解成 list(1, 2, 3, 4, 5) list.reduceRight(minus)
    // 步骤 (4 - 5)
    // 步骤 (3- (4 - 5))
    // 步骤 (2 -(3- (4 - 5)))
    // 步骤 1- (2 -(3- (4 - 5))) = 3
    println(list.foldRight(5)(minus)) //
  }
}
```
折叠的简写方法 /:
/: 左折叠
：\ 右折叠
var i6 = (1 /: list4) (minus) // =等价=> list4.foldLeft(1)(minus)
```scala
val list4 = List(1, 9, 2, 8)
def minus(num1: Int, num2: Int): Int = {
num1 - num2
}
var i6 = (1 /: list4) (minus) // =等价=> list4.foldLeft(1)(minus)
println(i6) // 输出?
i6 = (100 /: list4) (minus)
println(i6) // 输出?
i6 = (list4 :\ 10) (minus) // list4.foldRight(10)(minus)
println(i6) // 输出?
```


###  scala 中 _ 的含义
1. 将方法转为函数  fun1() 方法 可以  val f1 = fun1 _ 通过这个来转为函数
2. 将元素赋值 int a =_   表示给 a 赋值一个默认值
3. match case _ 如果有守卫表示忽略传入的 ch
4. match case _ 如果没有守卫表示 默认的匹配
5. 集合遍历的每个元素
### scala 的Match
match的细节和注意事项

如果所有case都不匹配，那么会执行case _ 分支，类似于Java中default语句
如果所有case都不匹配，又没有写case _ 分支，那么会抛出MatchError
每个case中，不用break语句，自动中断case
可以在match中使用其它类型，而不仅仅是字符

=> 等价于 java swtich 的 :
=> 后面的代码块到下一个 case， 是作为一个整体执行，可以使用{} 扩起来，也可以不扩。 

```scala
val oper = '#'
val n1 = 20
val n2 = 10
var res = 0
oper match {
case '+' => res = n1 + n2
case '-' => res = n1 - n2
case '*' => res = n1 * n2
case '/' => res = n1 / n2
case _ => println("oper error")
}
println("res=" + res)
```

模式匹配范围
```scala
for (ch <- "+-3!") {
var sign = 0
var digit = 0
ch match {
case '+' => sign = 1
case '-' => sign = -1
// 说明..
case _ if ch.toString.equals("3") => digit = 3
case _ => sign = 2
}
println(ch + " " + sign + " " + digit)
}

```

### match case 的 表达式和 返回值
```scala
object MatchVar {
  def main(args: Array[String]): Unit = {
    val ch = 'U'
    ch match {
      case '+' => println("ok~")
      // 下面 case mychar 含义是 mychar = ch
      case mychar => println("ok~" + mychar)
      case _ => println ("ok~~")
    }

    val ch1 = '+'
    //match是一个表达式，因此可以有返回值
    //返回值就是匹配到的代码块的最后一句话的值
    val res = ch1 match {
      case '+' => ch1 + " hello "
      // 下面 case mychar 含义是 mychar = ch
      case _ => println ("ok~~")
    }
    println("res=" + res)
  }
}
```


### 偏函数的简写
```scala
object PartialFun03 {
  def main(args: Array[String]): Unit = {

    //可以将前面的案例的偏函数简写
    def partialFun2: PartialFunction[Any,Int] = {
      //简写成case 语句
      case i:Int => i + 1
      case j:Double => (j * 2).toInt
    }

    val list = List(1, 2, 3, 4, 1.2, 2.4, 1.9f, "hello")
    val list2 = list.collect(partialFun2)
    println("list2=" + list2)

    //第二种简写形式
    val list3 = list.collect{
      case i:Int => i + 1
      case j:Double => (j * 2).toInt
      case k:Float => (k * 3).toInt
    }
    println("list3=" + list3) // (2,3,4,5)
  }
}
```

### 高阶函数
能够接受函数作为参数的函数，叫做高阶函数 (higher-order function)。可使应用程序更加健壮。
```scala
//test 就是一个高阶函数，它可以接收f: Double => Double 
def test(f: Double => Double, n1: Double) = {
f(n1)
}
//sum 是接收一个Double,返回一个Double
def sum(d: Double): Double = {
d + d
}
val res = test(sum, 6.0)
println("res=" + res)
```

```scala
说明: def minusxy(x: Int) = (y: Int) => x - y
函数名为 minusxy
该函数返回一个匿名函数
        (y: Int) = > x -y
     
说明val result3 = minusxy(3)(5)

minusxy(3)执行minusxy(x: Int)得到 (y: Int) => 3 - y 这个匿名函
minusxy(3)(5)执行 (y: Int) => x - y 这个匿名函数
也可以分步执行: val f1 = minusxy(3);   val res = f1(90)

```

### 参数类型推断
- 参数类型是可以推断时，可以省略参数类型
- 当传入的函数，只有单个参数时，可以省去括号
- 如果变量只在=>右边只出现一次，可以用_来代替
```scala
//分别说明
val list = List(1, 2, 3, 4)
println(list.map((x:Int)=>x + 1)) //(2,3,4,5)
println(list.map((x)=>x + 1))
println(list.map(x=>x + 1))
println(list.map(_ + 1))
val res = list.reduce(_+_)

map是一个高阶函数，因此也可以直接传入一个匿名函数，完成map
当遍历list时，参数类型是可以推断出来的，可以省略数据类型
Int println(list.map((x)=>x + 1))
当传入的函数，只有单个参数时，可以省去括号
println(list.map(x=>x + 1))
如果变量只在=>右边只出现一次，可以用_来代替
println(list.map(_ + 1))
```

### scala 的闭包
闭包就是通过一个函数
```scala
object ClosureDemo {
  def main(args: Array[String]): Unit = {

    /*
    请编写一个程序，具体要求如下
    1.编写一个函数 makeSuffix(suffix: String)  可以接收一个文件后缀名(比如.jpg)，     并返回一个闭包
     2.调用闭包，可以传入一个文件名，如果该文件名没有指定的后缀(比如.jpg) ,则返回 文件名.jpg , 如果已经有.jpg后缀，则返回原文件名。
     比如 文件名 是 dog =>dog.jpg
     比如  文件名 是 cat.jpg => cat.jpg
    3.要求使用闭包的方式完成
      提示：String.endsWith(xx)

     */
    //使用并测试
    val f = makeSuffix(".jpg")
    println(f("dog.jpg")) // dog.jpg
    println(f("cat")) // cat.jpg

  }
  def makeSuffix(suffix: String) = {
    //返回一个匿名函数，回使用到suffix
    (filename:String) => {
      if (filename.endsWith(suffix)) {
        filename
      } else {
        filename + suffix
      }
    }
  }
}

```
