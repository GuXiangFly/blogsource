---
title: springMVC的前端控制器的配置的三种方式
date: 2017-4-22 23:31:12
tags: [springmvc,java]
---

配置springmvc的前端控制器需要在web.xml里面配置拦截的路径名称。

```xml
    <servlet>
		<servlet-name>mvc-dispatcher</servlet-name>
		<servlet-class>org.springframework.web.servlet.DispatcherServlet</servlet-class>
		<!--tomcat启动的时候  就加载这个数字-->
		<load-on-startup>1</load-on-startup>
	</servlet>

	<servlet-mapping>
		<servlet-name>mvc-dispatcher</servlet-name>
		<url-pattern>*.action</url-pattern>
	</servlet-mapping>
```

在这里我使用的是 ***.action 显而易见是 拦截以 .action结尾的路径，但是还有 /  和 /**** 两种方式



----------


 *.action   
--------

```xml
<url-pattern>*.action</url-pattern>
```

----------


**代表是拦截后缀名字为 .action 结尾的url**


/
--------

```xml
<url-pattern>/</url-pattern>
```
**代表 拦截 所有的url 但是不包括 .jsp的url**

----------


/*
--
```xml
<url-pattern>/*</url-pattern>
```
**代表拦截所有的url 同样也包括.jsp为后缀的url**

----------


总结
--
**在我们项目开发中 一般会要求遵守restful   .action 肯定是不可以的，因为restful不让有.action 一般来说 .jsp页面 我们也写在 WEB-INF 目录下，不让人直接访问 也无需配置/*   所有 一般我是使用/ 来拦截**

----------


开发中一般用这种
--------

```xml
<url-pattern>/</url-pattern>
```

---------






额外
------
**（需要注意的是）springMVC 中的拦截器配置方法与web.xml 里面的不一样**
**我们需要使用 “ /** ****”来代表拦截所有**

```xml
 <mvc:interceptors>
        <mvc:interceptor>
            <mvc:mapping path="/**"/>
            <bean class="com.guxiang.interceptor.Interceptor1"></bean>
        </mvc:interceptor>
 </mvc:interceptors>
```
