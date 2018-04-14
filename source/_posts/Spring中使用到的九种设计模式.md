---
title: Spring中使用到的九种设计模式
date: 2017-4-12 22:31:12
tags: [java,Spring,设计模式]
---
转自：http://ylsun1113.iteye.com/blog/828542

##我对设计模式的理解：

应该说设计模式是我们在写代码时候的一种被承认的较好的模式，就像一种宗教信仰一样，大多数人承认的时候，你就要跟随，如果你想当一个社会存在的话。好的设计模式就像是给代码造了一个很好的骨架，在这个骨架里，你可以知道心在哪里，肺在哪里，因为大多数人都认识这样的骨架，就有了很好的传播性。这是从易读和易传播来感知设计模式的好处。当然设计模式本身更重要的是设计原则的一种实现，比如开闭原则，依赖倒置原则，这些是在代码的修改和扩展上说事。说到底就是人类和代码发生关系的四种场合：阅读，修改，增加，删除。让每一种场合都比较舒服的话，就需要用设计模式。 
但是话说如果你是个毛毛虫，又怎么懂得人的骨骼呢，不了解人的骨骼结构，又怎么知道心肺在哪里呢。让一个不了解设计模式的人去读充斥了设计模式的代码，也是一头雾水，这也是设计模式带来的负面效果。简单有错吗？没有，那为什么？因为我要满足修改和增加的需要，于是我们给自己一个用设计模式的借口。但是如果不修改和增加呢，那不是多此一举。那你又怎么知道不会修改和增加？也许在用设计模式的时候，我们总在问自己这样一个问题，这个玩意以后变化大吗，有增加的可能吗？ 
设计模式其实会带来复杂性的，这是无可争议的，我想我们应该在复杂和简单做一下平衡吧。 

###下面来简单列举spring中的设计模式： 
**1.简单工厂** 
又叫做静态工厂方法（StaticFactory Method）模式，但不属于23种GOF设计模式之一。 
简单工厂模式的实质是由一个工厂类根据传入的参数，动态决定应该创建哪一个产品类。 
spring中的BeanFactory就是简单工厂模式的体现，根据传入一个唯一的标识来获得bean对象，但是否是在传入参数后创建还是传入参数前创建这个要根据具体情况来定。 

**2.工厂方法（Factory Method）** 
定义一个用于创建对象的接口，让子类决定实例化哪一个类。Factory Method使一个类的实例化延迟到其子类。 
spring中的FactoryBean就是典型的工厂方法模式。如下图： 
 

**3.单例（Singleton）** 
保证一个类仅有一个实例，并提供一个访问它的全局访问点。 
spring中的单例模式完成了后半句话，即提供了全局的访问点BeanFactory。但没有从构造器级别去控制单例，这是因为spring管理的是是任意的Java对象。 

**4.适配器（Adapter）** 
将一个类的接口转换成客户希望的另外一个接口。Adapter模式使得原本由于接口不兼容而不能一起工作的那些类可以一起工作。 
spring中在对于aop的处理中有Adapter模式的例子，见如下图： 
 
由于Advisor链需要的是MethodInterceptor对象，所以每一个Advisor中的Advice都要适配成对应的MethodInterceptor对象。 

**5.包装器（Decorator）** 
动态地给一个对象添加一些额外的职责。就增加功能来说，Decorator模式相比生成子类更为灵活。 
 
spring中用到的包装器模式在类名上有两种表现：一种是类名中含有Wrapper，另一种是类名中含有Decorator。基本上都是动态地给一个对象添加一些额外的职责。 

**6.代理（Proxy）** 
为其他对象提供一种代理以控制对这个对象的访问。 
从结构上来看和Decorator模式类似，但Proxy是控制，更像是一种对功能的限制，而Decorator是增加职责。 
 
spring的Proxy模式在aop中有体现，比如JdkDynamicAopProxy和Cglib2AopProxy。 

**7.观察者（Observer）** 
定义对象间的一种一对多的依赖关系，当一个对象的状态发生改变时，所有依赖于它的对象都得到通知并被自动更新。 
 
spring中Observer模式常用的地方是listener的实现。如ApplicationListener。 

**8.策略（Strategy）** 
定义一系列的算法，把它们一个个封装起来，并且使它们可相互替换。本模式使得算法可独立于使用它的客户而变化。 
spring中在实例化对象的时候用到Strategy模式，见如下图： 
 
在SimpleInstantiationStrategy中有如下代码说明了策略模式的使用情况： 
 

**9.模板方法（Template Method）** 
定义一个操作中的算法的骨架，而将一些步骤延迟到子类中。Template Method使得子类可以不改变一个算法的结构即可重定义该算法的某些特定步骤。 
 
Template Method模式一般是需要继承的。这里想要探讨另一种对Template Method的理解。spring中的JdbcTemplate，在用这个类时并不想去继承这个类，因为这个类的方法太多，但是我们还是想用到JdbcTemplate已有的稳定的、公用的数据库连接，那么我们怎么办呢？我们可以把变化的东西抽出来作为一个参数传入JdbcTemplate的方法中。但是变化的东西是一段代码，而且这段代码会用到JdbcTemplate中的变量。怎么办？那我们就用回调对象吧。在这个回调对象中定义一个操纵JdbcTemplate中变量的方法，我们去实现这个方法，就把变化的东西集中到这里了。然后我们再传入这个回调对象到JdbcTemplate，从而完成了调用。这可能是Template Method不需要继承的另一种实现方式吧。 


----------


JdbcTemplate中的execute方法 
 ![这里写图片描述](http://img.blog.csdn.net/20170223210638013?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvbXlfX1N1bl8=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)
 


----------


JdbcTemplate执行execute方法 


![这里写图片描述](http://img.blog.csdn.net/20170223210704045?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvbXlfX1N1bl8=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)