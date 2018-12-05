---
title: Spring Cloud Eureka 集群搭建部署
date: 2018-7-28 19:00:04
tags: [Spring Cloud,Spring,springboot]

---
# Spring Cloud Eureka 集群搭建部署

## Maven依赖如下
```xml
<?xml version="1.0"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <parent>
        <groupId>org.springblade</groupId>
        <artifactId>spring-cloud-blade</artifactId>
        <version>1.0</version>
    </parent>

    <artifactId>spring-blade-eureka</artifactId>
    <name>spring-blade-eureka</name>


    <properties>
        <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
        <java.version>1.8</java.version>
    </properties>

    <dependencies>
        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-eureka-server</artifactId>
        </dependency>
       <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-security</artifactId>
        </dependency>
    </dependencies>
</project>

```

## Application类内容如下
```
package org.springblade.eureka;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.netflix.eureka.server.EnableEurekaServer;

@SpringBootApplication
@EnableEurekaServer
public class Application {

	public static void main(String[] args) {
		SpringApplication.run(Application.class, args);
	}
}

```

## application.xml 配置如下
```yml
spring:
  application:
    name: EUREKA-HA
---
server:
  port: 8001                    # 指定该Eureka实例的端口
spring:
  profiles: eurekap1
eureka:
  instance:
    hostname: eurekap1
  client:
    serviceUrl:
      defaultZone: http://user:password123@eurekap2:8002/eureka,http://user:password123@eurekap3:8003/eureka
  #server:
    #enable-self-preservation: false                    # 设为false，关闭自我保护
    #eviction-interval-timer-in-ms: 4000                # 清理间隔（单位毫秒，默认是60*1000）
security:
  basic:
    enabled: true               # 开启基于HTTP basic的认证
  user:
    name: user                  # 配置登录的账号是user
    password: password123       # 配置登录的密码是password123

---
server:
  port: 8002                    # 指定该Eureka实例的端口
spring:
  profiles: eurekap2
eureka:
  instance:
    hostname: eurekap2
  client:
    serviceUrl:
      defaultZone: http://user:password123@eurekap1:8001/eureka,http://user:password123@eurekap3:8003/eureka
  #server:
    #enable-self-preservation: false                    # 设为false，关闭自我保护
    #eviction-interval-timer-in-ms: 4000                # 清理间隔（单位毫秒，默认是60*1000）
security:
  basic:
    enabled: true               # 开启基于HTTP basic的认证
  user:
    name: user                  # 配置登录的账号是user
    password: password123       # 配置登录的密码是password123

---
server:
  port: 8003                    # 指定该Eureka实例的端口
spring:
  profiles: eurekap3
eureka:
  instance:
    hostname: eurekap3
  client:
    serviceUrl:
      defaultZone: http://user:password123@eurekap1:8001/eureka,http://user:password123@eurekap2:8002/eureka
  #server:
    #enable-self-preservation: false                    # 设为false，关闭自我保护
    #eviction-interval-timer-in-ms: 4000                # 清理间隔（单位毫秒，默认是60*1000）
security:
  basic:
    enabled: true               # 开启基于HTTP basic的认证
  user:
    name: user                  # 配置登录的账号是user
    password: password123       # 配置登录的密码是password123

```


## 编写start.bat 进行一键启动
```bat
java -jar -Dspring.profiles.active=eurekap1 spring-blade-eureka-1.0.jar
java -jar -Dspring.profiles.active=eurekap2 spring-blade-eureka-1.0.jar
java -jar -Dspring.profiles.active=eurekap3 spring-blade-eureka-1.0.jar
```