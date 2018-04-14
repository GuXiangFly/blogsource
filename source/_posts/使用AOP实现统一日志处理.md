---
title: 使用AOP实现统一日志处理
date: 2017-7-27 20:09:04
tags: [Spring]

---

在类上添加 @Aspect 注解 以及 @Component 将类添加到IOC容器中

``` java
@Aspect
@Component
public class HttpAspect {

    @Before("execution(public * cn.guxiangfly.controller.GirlController.*(..))")
    public void  doBefore(){
        System.out.println("111111111");
    }


    @After("execution(public * cn.guxiangfly.controller.GirlController.*(..))")
    public void  doAfter(){
        System.out.println("222222222");
    }
}
```

## 上面与下面的功能与实现相同
``` java
@Aspect
@Component
public class HttpAspect {

    @Pointcut("execution(public * cn.guxiangfly.controller.GirlController.*(..))")
    public void log(){
    }


    @Before("log()")
    public void doBefore2(){
        System.out.println("111111111");
    }


    @After("log()")
    public void doAfter2(){
        System.out.println("222222222");
    }

}

```

## 标准的统一日志处理框架
``` java
@Aspect
@Component
public class HttpAspect {

@Pointcut("execution(public * cn.guxiangfly.controller.GirlController.*(..))")
    public void log(){
    }


    @Before("log()")
    public void doBefore2(JoinPoint joinpoint){
        ServletRequestAttributes requestAttributes = (ServletRequestAttributes) RequestContextHolder.getRequestAttributes();
        HttpServletRequest request = requestAttributes.getRequest();
        logger.info("url={}",request.getRequestURL());
        logger.info("method={}",request.getRequestURL());
        logger.info("ip={}",request.getRemoteAddr());
        logger.info("class_method={}",joinpoint.getSignature().getDeclaringTypeName()+"."+joinpoint.getSignature().getName());
        logger.info("args={}",joinpoint.getArgs());

    }

    @AfterReturning(returning = "object",pointcut = "log()")
    public void doAfterReturning(Object object){
        logger.info("response={}",object.toString());
    }


}
```