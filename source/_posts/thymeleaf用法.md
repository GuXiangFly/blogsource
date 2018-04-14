---
title: thymeleaf用法
date: 2017-9-13 22:00:04
tags: [thymeleaf,springboot]

---

## thymeleaf配置

### 默认情况下 thymeleaf 需要实现 严谨的html格式 否则会报错，我们可以通过以下配置实现较为轻松的html格式
``` xml
	<properties>
		<thymeleaf.version>3.0.3.RELEASE</thymeleaf.version>
		<thymeleaf-layout-dialect.version>2.2.0</thymeleaf-layout-dialect.version>
	</properties>

<dependency>
	<groupId>org.springframework.boot</groupId>
	<artifactId>spring-boot-starter-thymeleaf</artifactId>
	<exclusions>
		<exclusion>
			<groupId>nz.net.ultraq.thymeleaf</groupId>
			<artifactId>thymeleaf-layout-dialect</artifactId>
		</exclusion>
	</exclusions>
</dependency>
```

### thymeleaf 对 springsecurity也有较好的支持
``` xml
	<dependency>
			<groupId>org.thymeleaf.extras</groupId>
			<artifactId>thymeleaf-extras-springsecurity4</artifactId>
			<version>3.0.2.RELEASE</version>
	</dependency>
```