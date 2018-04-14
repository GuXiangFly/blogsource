---
title: Java配置Spring Bean
date: 2017-7-14 9:00:04
tags: [springboot,java,Spring]

---
# 简介
spring bean 是使用传统的 XML 方法配置的。在这篇文章中，您将学习使用基于纯 Java 的配置而非 XML 来编写 Spring bean 并配置它们现今流行的springboot就是基于。本文将介绍可用来配置 bean 的多种注释。此外还将演示基于 Java 的配置，将它与基于传统 XML 的方法进行比较。

 

众所周知，Spring 框架是控制反转 (IOC) 或依赖性注入 (DI) 模式的推动因素，而这种推动是通过基于容器的配置实现的。过去，Spring 允许开发人员使用基于 XML 的配置，通过利用应用程序上下文 XML 文件来管理 bean 依赖性。此文件处于应用程序的外部，包含 bean 及其与该应用程序的依赖项的定义。尽管使用 XML 配置较为简单和便捷，但仍有另外一种方法可定义 bean 及其依赖项。这种方法也称为基于 Java 的配置。不同于 XML，基于 Java 的配置使您能够以编程方式管理 bean。这可通过运用多种注释来实现。 这篇文章将演示 Java 配置示例，并将其与传统 XML 配置方法相对比。本文将按照如下步骤演示基于 Java 的配置的基本用法：

理解 @Configuration 和 @Bean 注释
使用 AnnotationConfigApplicationContext 注册配置类
配置 Web 应用程序
实现 bean 生命周期回调和范围
我们将使用一所在线大学的 “创建课程” 用例。在创建课程的过程中，还会创建主题或者模块，而各主题可能又有着不同的作业。因此，我们要创建三个 bean，分别为 Course、Module 和 Assignment。Course bean 将包含一个对 Module bean 的引用，后者包含对 Assignment bean 的引用。

 # 示例

在理想的场景中，您可以在表示应用程序上下文的 XML 中定义 bean。以下代码展示了创建课程 用例中的上下文 XML 及 bean 定义：


## xml的配置
```xml				
<beans>
	<bean id="course" class="demo.Course">
		<property name="module" ref="module"/>
  	</bean>
	
	<bean id="module" class="demo.Module">
		<property name="assignment" ref="assignment"/>
  	</bean>
	
	<bean id="assignment" class="demo.Assignment" />
</beans>
```		

以上 XML 就是您在使用 Spring 配置 bean 时通常会编写的代码。这段 XML 代码定义了 Course bean，它引用 Module bean。Module bean 有一个 Assignment bean 的引用。您现在要删除这段 XML，编写同等效果的 Java 代码。您将使用基于 Java 的配置定义上面指定的 bean。我们会将 XML 替换为 Java 类，这个 Java 类现在将用作 bean 配置的平台。我们将这个类命名为 AppContext.java。以下代码展示了 AppContext 类。

## java的配置
```java		
@Configuration
public class AppContext {
	@Bean
	public Course course() {
		Course course = new Course();
		course.setModule(module());
		return course;
	}

	@Bean
	public Module module() {
		Module module = new Module();
		module.setAssignment(assignment());
		return module;
	}

	@Bean
	public Assignment assignment() {
		return new Assignment();
	}
}
		
```	

正如您通过以上代码所看到的那样，现在可以以编程的方式将 bean 定义为基于 Java 的配置的一部分。AppContext 类现在就像 XML 一样表示配置类。这是通过利用 @Configuration 注释实现的。@Configuration 注释位于类的顶端。它告知 Spring 容器这个类是一个拥有 bean 定义和依赖项的配置类。@Bean 注释用于定义 bean。上述注释位于实例化 bean 并设置依赖项的方法上方。方法名称与 bean id 或默认名称相同。该方法的返回类型是向 Spring 应用程序上下文注册的 bean。您可使用 bean 的 setter 方法来设置依赖项，容器将调用它们来连接相关项。基于 Java 的配置也被视为基于注释的配置。

使用 AnnotationConfigApplicationContext 注册配置类

在传统 XML 方法中，您可使用 ClassPathXmlApplicationContext 类来加载外部 XML 上下文文件。但在使用基于 Java 的配置时，有一个 AnnotationConfigApplicationContext 类。AnnotationConfigApplicationContext 类是 ApplicationContext 接口的一个实现，使您能够注册所注释的配置类。此处的配置类是使用 @Configuration 注释声明的 AppContext。在注册了所述类之后，@Bean 注释的方法返回的所有 bean 类型也会得到注册。以下代码演示了 AnnotationConfigApplicationContext 类的使用：




```java						
public static void main(String[] args) {
  ApplicationContext ctx = new AnnotationConfigApplicationContext(AppContext.class);
  Course course = ctx.getBean(Course.class);
  course.getName();
}

```		

正如以上代码所示，AppContext 配置类的注册方式是将其传递给 AnnotationConfigApplicationContext 构造函数。此外，您还可以使用所述上下文类的 register 方法来注册配置类。以下代码展示了另外一种方法。




```java						
public static void main(String[] args) {
  ApplicationContext ctx = new AnnotationConfigApplicationContext();
  ctx.register(AppContext.class)
}
```			

注册配置类将自动注册 @Bean 注释的方法名称，因而其对应的 bean 就是 Course、Module 和 Assignment。随后您可以使用 getBean 方法来获取相关的 bean，并调用其业务方法。如您所见，编写 Java 的配置类并将其注册到 Spring 上下文非常简单。下一节将讨论如何将基于 Java 的配置与 Web 应用程序配合使用。

 

过去，您通常要利用 XmlWebApplicationContext 上下文来配置 Spring Web 应用程序，即在 Web 部署描述符文件 web.xml 中指定外部 XML 上下文文件的路径。XMLWebApplicationContext 是 Web 应用程序使用的默认上下文类。以下代码描述了 web.xml 中指向将由 ContextLoaderListener 监听器类载入的外部 XML 上下文文件的元素。



```java		
				
<web-app>
	<context-param>
		<param-name>contextConfigLocation</param-name>
		<param-value>/WEB-INF/applicationContext.xml</param-value>
	</context-param>
	<listener>
		<listener-class>
			org.springframework.web.context.ContextLoaderListener
		</listener-class>
	</listener>
	<servlet>
	<servlet-name>sampleServlet</servlet-name>
	<servlet-class>
		org.springframework.web.servlet.DispatcherServlet
	</servlet-class>
	</servlet>

...
</web-app>
```			

现在，您要将 web.xml 中的上述代码更改为使用 AnnotationConfigApplicationContext 类。切记，XmlWebApplicationContext 是 Spring 为 Web 应用程序使用的默认上下文实现，因此您永远不必在您的 web.xml 文件中显式指定这个上下文类。现在，您将使用基于 Java 的配置，因此在配置 Web 应用程序时，需要在 web.xml 文件中指定 AnnotationConfigApplicationContext 类。上述代码将修改如下：




```xml						
<web-app>
	<context-param>
		<param-name>contextClass</param-name>
		<param-value>
			org.springframework.web.context.
			support.AnnotationConfigWebApplicationContext
		</param-value>
	</context-param>
	<context-param>
		<param-name>contextConfigLocation</param-name>
		<param-value>
			demo.AppContext
		</param-value>
	</context-param>
	<listener>
		<listener-class>
			org.springframework.web.context.ContextLoaderListener
		</listener-class>
	</listener>
	<servlet>
	<servlet-name>sampleServlet</servlet-name>
	<servlet-class>
		org.springframework.web.servlet.DispatcherServlet
	</servlet-class>
	<init-param>
		<param-name>contextClass</param-name>
		<param-value>
			org.springframework.web.context.
			support.AnnotationConfigWebApplicationContext
		</param-value>
	</init-param>
	</servlet>

...
</web-app>
```			

以上修改后的 web.xml 现在定义了 AnnotationConfigWebApplicationContext 上下文类，并将其作为上下文参数和 servlet 元素的一部分。上下文配置位置现在指向 AppContext 配置类。这非常简单。下一节将演示 bean 的生命周期回调和范围的实现。

 

 

您还可以使用基于 Java 的配置来管理 bean 的生命周期。@Bean 支持两种属性，即 initMethod 和 destroyMethod，这些属性可用于定义生命周期方法。在实例化 bean 或即将销毁它时，容器便可调用生命周期方法。生命周期方法也称为回调方法，因为它将由容器调用。使用 @Bean 注释注册的 bean 也支持 JSR-250 规定的标准 @PostConstruct 和 @PreDestroy 注释。如果您正在使用 XML 方法来定义 bean，那么就应该使用 bean 元素来定义生命周期回调方法。以下代码显示了在 XML 配置中通常使用 bean 元素定义回调的方法。



				
<bean id="course" class="demo.Course" init-method="setup" destroy-method="cleanup" >
	<property name="module" ref="module"/>
</bean>
			

以下代码演示了使用 Java 配置的生命周期方法


```java			
@Configuration
public class AppContext {
	@Bean(initMethod = "setup", destroyMethod = "cleanup")
	public Course course() {
		Course course = new Course();
		course.setModule(module());
		return course;
	}

	@Bean(initMethod = "setup", destroyMethod = "cleanup")
	public Module module() {
		Module module = new Module();
		module.setAssignment(assignment());
		return module;
	}
	
	
}		
public class Course {

	private Module module;
	private String name;
	
	public Course() {
	}
	
	public void setup() {
		this.name = "M100 Pythagoras Theorems"
	}
	
	public void setModule(Module module) {
		this.module = module;
	}
	
	public void cleanup() {
		module = null;
	}
}
		
```	

上面的代码重新访问了 AppContext 配置类。@Bean 注释现在有两个额外的属性，即 initMethod 和 destroyMethod。它们定义了生命周期方法的设置和清除。这些方法是在已经注册的 bean 中实现的，最终由容器在 bean 初始化及其销毁之前调用它。这里以 Course bean 为例，提供了生命周期方法实现。所实现的方法是 setup 和 cleanup。同样，您还可以在 Module 和 Assignment bean 中实现这些方法。

 

bean 的方法是使用 @Scope 注释定义的。XML 中实现这一目标的方法是指定 bean 元素中的 scope 属性。




```xml						
<bean id="course" class="demo.Course" scope="prototype" >
	<property name="module" ref="module"/>
</bean>
```		

以下代码展示了使用 Java 配置的 bean 范围定义：




```java						
@Configuration
public class AppContext {
	@Bean(initMethod = "setup", destroyMethod = "cleanup")
	@Scope("prototype")
	public Course course() {
		Course course = new Course();
		course.setModule(module());
		return course;
	}
	...
}

```			

正如您在上面的代码中所看到的那样，在 Java 配置类中定义 bean 的范围非常简单。上面的 AppContext 配置类使用 @Scope 注释为 Course bean 定义了一个 prototype 范围。默认范围是 singleton。

利用 Java 配置可以做许多事情。本文只触及了一些基础内容。使用 Java 配置并无显著优势，它仅仅是 Spring 提供的 XML 配置的替代方法。对于不喜欢在框架中使用 XML 的人来说，这是实现配置的一种出色方法。但缺点也是显而易见的，如果您对 Java 类中的配置做出了任何更改，就必须重新编译应用程序。
>http://www.ibm.com/developerworks/cn/webservices/ws-springjava/