01-Java基础面试题

- Java中的异常有哪几类？分别怎么使用？

- 常用的集合类有哪些？比如List如何排序？

- ArrayList和LinkedList内部的实现大致是怎样的？他们之间的区别和优缺点？

- 内存溢出是怎么回事？请举一个例子？

- ==和equals的区别？

- hashCode方法的作用？

- NIO是什么？适用于何种场景？

- HashMap实现原理，如何保证HashMap的线程安全，多线程场景下容易出现上面问题？

- JVM内存结构，为什么需要GC？

- NIO模型，select/epoll的区别，多路复用的原理

- Java中一个字符占多少个字节，扩展再问int, long, double占多少字节

- 创建一个类的实例都有哪些办法？

- final/finally/finalize的区别？

- Session/Cookie的区别？

- String/StringBuffer/StringBuilder的区别，扩展再问他们的实现？

- Servlet的生命周期？

- 如何用Java分配一段连续的1G的内存空间？需要注意些什么？

- Java有自己的内存回收机制，但为什么还存在内存泄露的问题呢？

- 什么是java序列化，如何实现java序列化?(写一个实例)？

- String s = new String("abc");创建了几个 String Object?

- 简述一下你了解的设计模式。

  所谓设计模式，就是一套被反复使用的代码设计经验的总结（情境中一个问题经过证实的一个解决方案）。使用设计模式是为了可重用代码、让代码更容易被他人理解、保证代码可靠性。设计模式使人们可以更加简单方便的复用成功的设计和体系结构。将已证实的技术表述成设计模式也会使新系统开发者更加容易理解其设计思路。 
  在GoF的《Design Patterns: Elements of Reusable Object-Oriented Software》中给出了三类（创建型[对类的实例化过程的抽象化]、结构型[描述如何将类或对象结合在一起形成更大的结构]、行为型[对在不同的对象之间划分责任和算法的抽象化]）共23种设计模式，包括：Abstract Factory（抽象工厂模式），Builder（建造者模式），Factory Method（工厂方法模式），Prototype（原始模型模式），Singleton（单例模式）；Facade（门面模式），Adapter（适配器模式），Bridge（桥梁模式），Composite（合成模式），Decorator（装饰模式），Flyweight（享元模式），Proxy（代理模式）；Command（命令模式），Interpreter（解释器模式），Visitor（访问者模式），Iterator（迭代子模式），Mediator（调停者模式），Memento（备忘录模式），Observer（观察者模式），State（状态模式），Strategy（策略模式），Template Method（模板方法模式）， Chain Of Responsibility（责任链模式）。

  

- 访问修饰符public,private,protected,以及不写（默认）时的区别？

- 解释内存中的栈(stack)、堆(heap)和方法区(method area)的用法。

- 描述一下JVM加载class文件的原理机制？

- 线程的基本状态以及状态之间的关系？

  ![img](https://km.sankuai.com/api/file/561876425/562070530)

- Java序列化与反序列化是什么？为什么需要序列化与反序列化？如何实现Java序列化与反序列化？

  友情链接 ：[Java序列化与反序列化](http://blog.csdn.net/wangloveall/article/details/7992448/)

- Spring AOP 实现原理？

  友情链接 ：[Spring AOP 实现原理](http://blog.csdn.net/moreevan/article/details/11977115/)

- Servlet 工作原理？

  友情链接 ：[Servlet 工作原理解析](http://www.ibm.com/developerworks/cn/java/j-lo-servlet/)

- Java NIO和IO的区别？

  友情链接 ：[Java NIO和IO的区别](http://www.jb51.net/article/50621.htm)

- Java中堆内存和栈内存区别？

  友情链接 ：[Java中堆内存和栈内存详解](http://www.cnblogs.com/whgw/archive/2011/09/29/2194997.html)

- 如何预防Mysql注入？

  友情链接：[MySQL 及 SQL 注入与防范方法](http://www.jb51.net/article/87948.htm)

- Integer缓存？Integer比较大小注意问题。==和equals的区别考察 

   Integer是有缓冲池的，java.lang.Integer.valueOf(int)方法默认情况下如果参数在-128到127之间，则返回缓存中的对象，否则返回new Integer(int)。java使用该机制是为了达到最小化数据输入和输出的目的,这是一种优化措施,提高效率

   其他的包装器:

   Boolean： (全部缓存)

   Byte：  (全部缓存)

   Character (  <=127 缓存)

   Short   (-128~127 缓存)

   Long   (-128~127 缓存)

   Float   (没有缓存)

   Doulbe  (没有缓存)

   可以设置系统属性 java.lang.Integer.IntegerCache.high 修改缓冲区上限，默认为127。参数内容应为大于127的十进制数形式的字符串，否则将被忽略。取值范围为127-Long.MAX_VALUE，但是用时将强转为int。当系统中大量使用Integer时，增大缓存上限可以节省小量内存。 

   区别“==”和equals():“==”是比较两个对象是不是引用自同一个对象。  “equals（）”是比较两个对象的内容。 

- Java HashMap在高并发情况下不当使用，可能会导致什么样极端情况，为什么？

  在并发的多线程使用场景中，在resize扩容的时候，使得HashMap形成环链，造成死循环，CPU飙升至100%。可以举例子说明。

- 如何拷贝数组，怎样效率最高？为什么？
  （1）使用循环结构 这种方法最灵活。唯一不足的地方可能就是代码较多
  （2）使用Object类的clone（）方法， 这种方法最简单，得到原数组的一个副本。灵活形也最差。效率最差，尤其是在数组元素很大或者复制对象数组时。
  （3） 使用Systems的arraycopy这种方法被告之速度最快，并且灵活性也较好，可以指定原数组名称、以及元素的开始位置、复
  制的元素的个数，目标数组名称、目标数组的位置。
  浅拷贝和深拷贝得理解：定义一个数组int[] a={3，1，4，2，5}； int[] b=a； 数组b只是对数组a的又一个引用，即浅拷贝。
  如果改变数组b中元素的值，其实是改变了数组a的元素的值，要实现深度复制，可以用clone或者System.arrayCopy
  clone和System.arrayCopy都是对一维数组的深度复制；因为java中没有二维数组的概念，只有数组的数组。所以二维数组a中存储的实际上是两个一维数组的引用。当调用clone函数时，是对这两个引用进行了复制。