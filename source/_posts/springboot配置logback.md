---
title: springboot配置logback
date: 2017-5-24 21:09:04
tags: [springboot,java]

---

## springboot不需要添加jar支持logback

 springboot 默认支持logback 
	在里面的 	
``` xml
		<dependency>
			<groupId>org.springframework.boot</groupId>
			<artifactId>spring-boot-starter-web</artifactId>
		</dependency>
```
这个依赖中拥有
``` xml
<groupId>org.springframework.boot</groupId>
<artifactId>spring-boot-starter-logging</artifactId>

```
这个jar包 
所以**不需要额外手动添加加jar包支持 logback**

## logback配置方式：
spring boot默认会加载

> classpath:logback-spring.xml 或者 classpath:logback-spring.groovy

使用自定义配置文件，配置方式为：
> logging.config=classpath:logback-guxiang.xml

下面给出一段通用的logback配置
``` xml
<?xml version="1.0" encoding="UTF-8"?>
<configuration>

	<!-- 文件输出格式 -->
	<property name="PATTERN" value="%-12(%d{yyyy-MM-dd HH:mm:ss.SSS}) |-%-5level [%thread] %c [%L] -| %msg%n" />
	<!-- test文件路径 -->
	<property name="TEST_FILE_PATH" value="D:/opt/guxiang/logs" />
	<!-- pro文件路径 -->
	<property name="PRO_FILE_PATH" value="/opt/guxiang/logs" />

	<!-- 开发环境 -->
	<springProfile name="dev">
		<appender name="CONSOLE" class="ch.qos.logback.core.ConsoleAppender">
			<encoder>
				<pattern>${PATTERN}</pattern>
			</encoder>
		</appender>
		
		<logger name="com.guxiang" level="debug"/>

		<root level="info">
			<appender-ref ref="CONSOLE" />
		</root>
	</springProfile>

	<!-- 测试环境 -->
	<springProfile name="test">
		<!-- 每天产生一个文件 -->
		<appender name="TEST-FILE" class="ch.qos.logback.core.rolling.RollingFileAppender">
			<!-- 文件路径 -->
			<file>${TEST_FILE_PATH}</file>
			<rollingPolicy class="ch.qos.logback.core.rolling.TimeBasedRollingPolicy">
				<!-- 文件名称 -->
				<fileNamePattern>${TEST_FILE_PATH}/info.%d{yyyy-MM-dd}.log</fileNamePattern>
				<!-- 文件最大保存历史数量 -->
				<MaxHistory>100</MaxHistory>
			</rollingPolicy>
			
			<layout class="ch.qos.logback.classic.PatternLayout">
				<pattern>${PATTERN}</pattern>
			</layout>
		</appender>
		
		<root level="info">
			<appender-ref ref="TEST-FILE" />
		</root>
	</springProfile>

	<!-- 生产环境 -->
	<springProfile name="prod">
		<appender name="PROD_FILE" class="ch.qos.logback.core.rolling.RollingFileAppender">
			<file>${PRO_FILE_PATH}</file>
			<rollingPolicy class="ch.qos.logback.core.rolling.TimeBasedRollingPolicy">
				<fileNamePattern>${PRO_FILE_PATH}/warn.%d{yyyy-MM-dd}.log</fileNamePattern>
				<MaxHistory>100</MaxHistory>
			</rollingPolicy>
			<layout class="ch.qos.logback.classic.PatternLayout">
				<pattern>${PATTERN}</pattern>
			</layout>
		</appender>
		
		<root level="warn">
			<appender-ref ref="PROD_FILE" />
		</root>
	</springProfile>
</configuration>

```