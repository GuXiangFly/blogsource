---
title: Swagger UI 的使用
date: 2017-8-27 20:09:04
tags: [springboot]

---

为了前后端分离的需要，我们在项目开发中，会使用swagger做前后端交互的文档

我们在springboot中加入 swagger
## 首先 加入maven依赖

``` xml
<dependency>
			<groupId>io.springfox</groupId>
			<artifactId>springfox-swagger2</artifactId>
			<version>2.7.0</version>
</dependency>
<dependency>
		<groupId>io.springfox</groupId>
		<artifactId>springfox-swagger-ui</artifactId>
		<version>2.7.0</version>
</dependency>
```

上面一个 用于提供springboot中使用的时候会用到的 注解 之类的核心

下面一个依赖用于生成html页面 进行文档的可视化

## 在SpringBootApplication类中加注解
``` java
@SpringBootApplication
@EnableSwagger2
public class SecurityDemoApplication {
    public static void main(String[] args) {
        SpringApplication.run(SecurityDemoApplication.class, args);
    }
}
```