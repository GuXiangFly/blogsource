---
title: 极其简单的 使用IDEA 中 实现springboot 热部署 （spring boot devtools版）
date: 2017-5-24 20:42:54
tags: [intellij IDEA,java,springboot]
---
## 添加配置pom.xml配置
第一步：添加springboot的配置文件  

首先我先贴出我的配置

- 添加依赖包

```xml
<!-- spring boot devtools 依赖包. -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-devtools</artifactId>
            <optional>true</optional>
            <scope>true</scope>
        </dependency>
```
- 添加插件

```
<plugin>
	<groupId>org.springframework.boot</groupId>
	<artifactId>spring-boot-maven-plugin</artifactId>
	<configuration>
		<!-- 如果没有该项配置，devtools不会起作用，即应用不会restart -->
		<fork>true</fork>
	</configuration>
</plugin>
```


----------


具体配置文件应该防止的位置为


----------


![这里写图片描述](http://img.blog.csdn.net/20170517131416499?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvbXlfX1N1bl8=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)


----------


需要import的同学记得import 。
![这里写图片描述](http://img.blog.csdn.net/20170517131531976?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvbXlfX1N1bl8=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)


----------


## 任意修改源代码 并且 Ctrl+F9 bulid
但是在eclipse中  项目是会自动编译的  但是在IDEA 中 我们需要 按ctrl+F9 让它再编译一下


----------


## 原理介绍

> spring-boot-devtools 是一个为开发者服务的一个模块，其中最重要的功能就是自动应用代码更改到最新的App上面去。原理是在发现代码有更改之后，重新启动应用，但是速度比手动停止后再启动还要更快，更快指的不是节省出来的手工操作的时间。
>  
其深层原理是：
**使用了两个ClassLoader，一个Classloader加载那些不会改变的类（第三方Jar包），另一个ClassLoader加载会更改的类，称为  restart ClassLoader,这样在有代码更改的时候，原来的restart ClassLoader 被丢弃，重新创建一个restart ClassLoader，由于需要加载的类相比较少，所以实现了较快的重启时间（5秒以内）。**
