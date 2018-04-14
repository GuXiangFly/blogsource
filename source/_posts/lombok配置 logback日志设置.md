---
title: lombok配置 logback日志设置
date: 2017-7-27 20:09:04
tags: [日志处理]

---
日志设置

 我们选用 slf4j 来输出我们的日志
 logback 来处理我们的日志

传统我们可以使用 java生成 
```
private final Logger logger = LoggerFactory.getLogger(LoggerTest.class);
```

也可以使用lombok 插件

依赖一下以下maven
```xml
		<dependency>
			<groupId>org.projectlombok</groupId>
			<artifactId>lombok</artifactId>
			<version>1.16.18</version>
		</dependency>
```


``` java
@RunWith(SpringRunner.class)
@SpringBootTest
@Slf4j
public class LoggerTest {
    //private final Logger logger = LoggerFactory.getLogger(LoggerTest.class);

    @Test
    public void test1() {
        log.debug("debug");
		
    }
}
```


实际上 lombok 不仅仅支持 logback ， 还支持 jbosslog，log4j,log4j2

详情可见于 lombok 中的一段源码
``` java
	
		// private static final org.apache.log4j.Logger log = org.apache.log4j.Logger.getLogger(TargetType.class);
		LOG4J(lombok.extern.log4j.Log4j.class, "org.apache.log4j.Logger", "org.apache.log4j.Logger.getLogger"),
		
		// private static final org.apache.logging.log4j.Logger log = org.apache.logging.log4j.LogManager.getLogger(TargetType.class);
		LOG4J2(lombok.extern.log4j.Log4j2.class, "org.apache.logging.log4j.Logger", "org.apache.logging.log4j.LogManager.getLogger"),
		
		// private static final org.slf4j.Logger log = org.slf4j.LoggerFactory.getLogger(TargetType.class);
		SLF4J(lombok.extern.slf4j.Slf4j.class, "org.slf4j.Logger", "org.slf4j.LoggerFactory.getLogger"),
		
		// private static final org.slf4j.ext.XLogger log = org.slf4j.ext.XLoggerFactory.getXLogger(TargetType.class);
		XSLF4J(lombok.extern.slf4j.XSlf4j.class, "org.slf4j.ext.XLogger", "org.slf4j.ext.XLoggerFactory.getXLogger"),
		
		// private static final org.jboss.logging.Logger log = org.jboss.logging.Logger.getLogger(TargetType.class);
		JBOSSLOG(lombok.extern.jbosslog.JBossLog.class, "org.jboss.logging.Logger", "org.jboss.logging.Logger.getLogger")
		;
		
		private final Class<? extends Annotation> annotationClass;
		private final String loggerTypeName;
```