---
title: Spring Session配置
date: 2017-7-27 20:09:04
tags: [Spring]

---
Spring Session配置



### MAVEN 配置
``` xml
        <!-- redis session依赖 -->
        <dependency>
            <groupId>org.springframework.session</groupId>
            <artifactId>spring-session</artifactId>
        </dependency>

        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-data-redis</artifactId>
        </dependency>
```


### java配置 session会话
``` java
@Configuration
@EnableRedisHttpSession(maxInactiveIntervalInSeconds = 86400)
public class RedisSessionConfig {
    @Bean
    public RedisTemplate<String, String> redisTemplate(RedisConnectionFactory factory) {

        return new StringRedisTemplate(factory);
    }
}

```

### properties文件配置
```
# session会话存储类型
spring.session.store-type=redis

# redis config
spring.redis.database=0
spring.redis.host=127.0.0.1
spring.redis.port=6379
spring.redis.pool.min-idle=1
spring.redis.timeout=3000
```

### YML配置
``` yml

spring.session.store-type: redis

spring:
  redis:
    database: 0
    host: 127.0.0.1
    port: 6379
    pool:
      min-idle: 1
    timeout: 3000
```