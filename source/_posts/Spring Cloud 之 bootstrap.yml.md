---
title: Spring Cloud 之 bootstrap.yml
date: 2017-6-11 13:19:04
tags: [Spring,springboot,Spring Cloud]

---
# Spring Cloud 之 bootstrap.yml


 首先 在官方文档中有介绍 bootstrap.yml

> The bootstrap context uses a different convention for locating external configuration than the main application context, so instead of application.yml (or .properties) you use bootstrap.yml, keeping the external configuration for bootstrap and main context nicely separate. Example:

bootstrap.yml
```yml
spring:
  application:
    name: foo
  cloud:
    config:
      uri: ${SPRING_CONFIG_URI:http://localhost:8888}
```



我们可以在 bootstrap.yml 中 配置我们启动好后就不想改的内容

里面它会先寻找