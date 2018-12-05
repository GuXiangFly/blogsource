而AOP，是通过动态代理实现的。

一、简单来说：

　　JDK动态代理只能对实现了接口的类生成代理，而不能针对类

　　CGLIB是针对类实现代理，主要是对指定的类生成一个子类，覆盖其中的方法（继承）



二、Spring在选择用JDK还是CGLiB的依据：

   (1)当Bean实现接口时，Spring就会用JDK的动态代理

   (2)当Bean没有实现接口时，Spring使用CGlib是实现

　  (3)可以强制使用CGlib（在spring配置中加入<aop:aspectj-autoproxy proxy-target-class="true"/>）

三、CGlib比JDK快？

　 (1)使用CGLib实现动态代理，CGLib底层采用ASM字节码生成框架，使用字节码技术生成代理类，比使用Java反射效率要高。唯一需要注意的是，CGLib不能对声明为final的方法进行代理，因为CGLib原理是动态生成被代理类的子类。

　 (2)在对JDK动态代理与CGlib动态代理的代码实验中看，1W次执行下，JDK7及8的动态代理性能比CGlib要好20%左右。 




## spring事务传播
propagation_request     request（必须）（默认的）
支持当前事务，A如果有事务，B将使用该事务
如果A没有事务，B将创建一个新的事务 

propagation_supports    supports （必须）
支持当前事务，A如果有事务，B将使用该事务
如果A没有事务，B将以非事务执行


PROPAGATION_REQUIRED

如果当前没有事务，就新建一个事务，如果已经存在一个事务中，加入到这个事务中。这是最常见的选择。

PROPAGATION_SUPPORTS

支持当前事务，如果当前没有事务，就以非事务方式执行。

PROPAGATION_MANDATORY

使用当前的事务，如果当前没有事务，就抛出异常。

PROPAGATION_REQUIRES_NEW

新建事务，如果当前存在事务，把当前事务挂起。

PROPAGATION_NOT_SUPPORTED

以非事务方式执行操作，如果当前存在事务，就把当前事务挂起。

PROPAGATION_NEVER

以非事务方式执行，如果当前存在事务，则抛出异常。

PROPAGATION_NESTED

如果当前存在事务，则在嵌套事务内执行。如果当前没有事务，则执行与PROPAGATION_REQUIRED类似的操作。

