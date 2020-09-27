---
title: Springboot源码分析
date: 2018-3-11 23:09:04
tags: [SpringBoot,前端]

---


启动流程

1. 从 run方法进入

![image-20200709110209295](https://gitee.com/guxiangfly/blogimage/raw/master/img/image-20200709110209295.png)



2. 点进去后能发现 先是创建一个 SpringApplication 对象，然后再run

![image-20200709111457847](https://gitee.com/guxiangfly/blogimage/raw/master/img/image-20200709111457847.png)

----

#### 创建 SpringApplication 对象

构造方法进行 initialize

```java
	public SpringApplication(Object... sources) {
		initialize(sources);
	}
```

```java
	private void initialize(Object[] sources) {
		if (sources != null && sources.length > 0) {
      // 保存主配置类
			this.sources.addAll(Arrays.asList(sources));
		}
    
    //判断当前应用是否一个web应用
		this.webEnvironment = deduceWebEnvironment();
    
    // 这个是从 META-INF/spring.factories 文件上读取 ApplicationContextInitializer
		setInitializers((Collection) getSpringFactoriesInstances(
				ApplicationContextInitializer.class));
    
     // 这个是从 META-INF/spring.factories 文件上读取 ApplicationListener
		setListeners((Collection) getSpringFactoriesInstances(ApplicationListener.class));
    // 从多个配置类中 找到有main方法的主配置类
		this.mainApplicationClass = deduceMainApplicationClass();
	}
```



![image-20200709112237201](https://gitee.com/guxiangfly/blogimage/raw/master/img/image-20200709112237201.png)

这个是被加载的 ApplicationContextInitializer

![image-20200709113006534](https://gitee.com/guxiangfly/blogimage/raw/master/img/image-20200709113006534.png)



这个是被加载的 ApplicationListener

![image-20200709113423428](https://gitee.com/guxiangfly/blogimage/raw/master/img/image-20200709113423428.png)





#### run 方法调用

```java
	/**
	 * Run the Spring application, creating and refreshing a new
	 * {@link ApplicationContext}.
	 * @param args the application arguments (usually passed from a Java main method)
	 * @return a running {@link ApplicationContext}
	 */
	public ConfigurableApplicationContext run(String... args) {
		StopWatch stopWatch = new StopWatch();
		stopWatch.start();
		ConfigurableApplicationContext context = null;
		FailureAnalyzers analyzers = null;
		configureHeadlessProperty();
    
     //获取之前从 META-INF/spring.factories 文件上读取 ApplicationListener
		SpringApplicationRunListeners listeners = getRunListeners(args);
    // 回调所有的 ApplicationListener的starting
		listeners.starting();
		try {
			ApplicationArguments applicationArguments = new DefaultApplicationArguments(
					args);
			ConfigurableEnvironment environment = prepareEnvironment(listeners,
					applicationArguments);
			Banner printedBanner = printBanner(environment);
			context = createApplicationContext();
			analyzers = new FailureAnalyzers(context);
      
      //prepareContext 下面有详细解释
       // 1.初始化 之前的Initializers
       // 2.回调所有的 listener的contextPrepared的方法
       // 3. 回调所有的 listener的contextLoaded的方法
			prepareContext(context, environment, listeners, applicationArguments,
					printedBanner);
      
      // IOC容器的初始化过程， spring 的 refresh
      // 扫描，创建，加载 所有容器的地方
			refreshContext(context);
      
      // 从ioc容器中获取所有的ApplicationRunner 和 CommandLineRunner
      // 先回调 ApplicationRunner 再回调 CommandLineRunner
			afterRefresh(context, applicationArguments);
      
      // 所有的listeners 回调 finished方法
			listeners.finished(context, null);
      
      // 这个代表启动完成
			stopWatch.stop();
			if (this.logStartupInfo) {
				new StartupInfoLogger(this.mainApplicationClass)
						.logStarted(getApplicationLog(), stopWatch);
			}
      // 启动完成后  返回IOC容器
			return context;
		}
		catch (Throwable ex) {
			handleRunFailure(context, listeners, analyzers, ex);
			throw new IllegalStateException(ex);
		}
	}
```





#### 介绍 beanPostConstruct 

Spring内部有非常多的beanpostconstruct，整个bean的生命周期都非常依赖beanpostconstruct去完成。  



<img src="https://gitee.com/guxiangfly/blogimage/raw/master/img/image-20200925200833269.png" alt="image-20200925200833269" style="zoom:33%;" />

![image-20200925201436402](https://gitee.com/guxiangfly/blogimage/raw/master/img/image-20200925201436402.png)







##### 介绍prepareContext

```java
	private void prepareContext(ConfigurableApplicationContext context,
			ConfigurableEnvironment environment, SpringApplicationRunListeners listeners,
			ApplicationArguments applicationArguments, Banner printedBanner) {
		context.setEnvironment(environment);
		postProcessApplicationContext(context);
    // 初始化 之前的Initializers
		applyInitializers(context);
    
    // 回调所有的 listener的contextPrepared的方法
		listeners.contextPrepared(context);
		if (this.logStartupInfo) {
			logStartupInfo(context.getParent() == null);
			logStartupProfileInfo(context);
		}

		// Add boot specific singleton beans
		context.getBeanFactory().registerSingleton("springApplicationArguments",
				applicationArguments);
		if (printedBanner != null) {
			context.getBeanFactory().registerSingleton("springBootBanner", printedBanner);
		}

		// Load the sources
		Set<Object> sources = getSources();
		Assert.notEmpty(sources, "Sources must not be empty");
		load(context, sources.toArray(new Object[sources.size()]));
    
   // 回调所有的 listener的contextLoaded的方法
		listeners.contextLoaded(context);
	}
```



##### 介绍Call Runner

```java
	protected void afterRefresh(ConfigurableApplicationContext context,
			ApplicationArguments args) {
		callRunners(context, args);
	}

	private void callRunners(ApplicationContext context, ApplicationArguments args) {
		List<Object> runners = new ArrayList<Object>();
		runners.addAll(context.getBeansOfType(ApplicationRunner.class).values());
		runners.addAll(context.getBeansOfType(CommandLineRunner.class).values());
		AnnotationAwareOrderComparator.sort(runners);
		for (Object runner : new LinkedHashSet<Object>(runners)) {
			if (runner instanceof ApplicationRunner) {
				callRunner((ApplicationRunner) runner, args);
			}
			if (runner instanceof CommandLineRunner) {
				callRunner((CommandLineRunner) runner, args);
			}
		}
	}
```







##### 自定义starter









## Spring AOP

 假设我有一个注解

```java
@Documented
@Retention(value = RetentionPolicy.RUNTIME)
@Target(value = {ElementType.METHOD})
public @interface CatTransaction {
    String type() default "";
    String name() default "";
    boolean isThrowOut() default true;
}
```



切面

```java
@Aspect
@Component
public class CatTransactionAspect {

    @Pointcut("@annotation(cn.guxiangfly.aop.CatTransaction)")
    public void pointCut() {

    }

    @Around(value="pointCut()&& @annotation(catTransaction)")
    public void logAround(ProceedingJoinPoint joinPoint, CatTransaction catTransaction){

        String name = joinPoint.getSignature().getName();
        System.out.println("=ProceedingJoinPoint==start:" +name);
        try {
            joinPoint.proceed();
        }catch (Throwable e){
            throw new RuntimeException(e);
        }
        System.out.println("=ProceedingJoinPoint==end:" +name);
    }
}

```



下面此类使用了

```java
public class PlusCalculator {

    @CatTransaction
    public void test_aop_01() {
        System.out.println("test_aop_01");
        test_aop_02();
    }

    @CatTransaction
    public void test_aop_02() {
        System.out.println("test_aop_02");
    }
}
```

<img src="https://gitee.com/guxiangfly/blogimage/raw/master/img/image-20200925184532725.png" alt="image-20200925184532725" style="zoom:50%;" />

Spring AOP的代理对象，是在spring初始化的时候，就创建出来了，如果springBean的AOP代理对象被创建出来并且放到singletonObjects（单例对象池）里面，那么未被代理的对象，就不会放到 singletonobjects里面了。



Spring使用AOP的步骤

1. spring 初始化的时候，调用了无参构造方法，无参构造方法会首先调用父类无参构造方法

   ![image-20200925193304041](https://gitee.com/guxiangfly/blogimage/raw/master/img/image-20200925193304041.png)

   ![image-20200925193418027](https://gitee.com/guxiangfly/blogimage/raw/master/img/image-20200925193418027.png)

```


```









后置处理bean  AbstractAdvisorAutoProxyCreator是个 beanPostConstruct。

它会调用到ProxyCreatorSupport整个类，整个类的createAopProxy选择代理模式



```java
	@Override
	public AopProxy createAopProxy(AdvisedSupport config) throws AopConfigException {
		if (config.isOptimize() || config.isProxyTargetClass() || hasNoUserSuppliedProxyInterfaces(config)) {
			Class<?> targetClass = config.getTargetClass();
			if (targetClass == null) {
				throw new AopConfigException("TargetSource cannot determine target class: " +
						"Either an interface or a target is required for proxy creation.");
			}
			if (targetClass.isInterface() || Proxy.isProxyClass(targetClass)) {
				return new JdkDynamicAopProxy(config);
			}
			return new ObjenesisCglibAopProxy(config);
		}
		else {
			return new JdkDynamicAopProxy(config);
		}
	}

```



```

```

