---
title: 解决spring cloud feign 发送get请求失败的问题
date: 2017-7-20 13:09:04
tags: [前端,springmvc,java]

---

# 解决spring cloud feign 发送get请求失败的问题



Feign在默认情况下使用的是JDK原生的URLConnection发送HTTP请求，没有连接池，但是对每个地址会保持一个长连接，即利用HTTP的persistence connection 。我们可以用Apache的HTTP Client替换Feign原始的http client, 从而获取连接池、超时时间等与性能息息相关的控制能力。Spring Cloud从Brixtion.SR5版本开始支持这种替换，首先在项目中声明Apache HTTP Client和feign-httpclient依赖

```xml
<!-- 使用HttpClient替换Feign原生httpclient -->
<dependency>
    <groupId>org.apache.httpcomponents</groupId>
    <artifactId>httpclient</artifactId>
</dependency>
<dependency>
    <groupId>com.netflix.feign</groupId>
    <artifactId>feign-httpclient</artifactId>
    <version>${feign-httpclient}</version>
</dependency>
```

再添加以下的全局配置  
在application.yml中
```yml
feign:
  httpclient:
    enable: true
```

修改完后我们对它进行请求  
由于feign默认使用的contract契约使用的是springmvc的契约  所以我们能使用springmvc的注解
```java
@RequestMapping(value = "/user", method = RequestMethod.GET)

  public User get0(@RequestBody User user);
```

但是抛出了异常
```
java.lang.IllegalArgumentException: MIME type may not contain reserved characters 
```
只需要使用consumes="application/json"进行指定一下就好
```java
 @RequestMapping(value = "/get-user", method = RequestMethod.GET,consumes="application/json")
  public User getUser(@RequestBody User user);
```
就出json结果了