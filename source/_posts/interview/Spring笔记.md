---
title: Spring笔记
date: 2018-1-2 20:09:04
tags: [Spring]

---


## Spring 的生命周期

1. 实例Spring容器

2. 扫描类  

    ```
   通过 scan()  
   ```

3. 解析这个扫描类

4. 实例 BeanDefinition

5. 所有的 BeanDefinition 存入 beanDefinitionMap

6. 调用bean工厂后置处理器

7. 验证

8. 推断构造方法

9. 通过反射  new 出对象  

   ```
   nstanceWrapper = createBeanInstance(beanName, mbd, args); 返回的是一个 wrapper
   createBeanInstance 推断构造方法，并且将构造出来的beanName 
   
   ```

10. 缓存注解信息 并且合并

11. 提前暴露自己调用了构造方法的对象 `addSingletonFactory`  

    ```
    addSingletonFactory(beanName, () -> getEarlyBeanReference(beanName, mbd, bean));
    通过这个方法暴露
    ```

12. 判断是否需要属性注入 

13. 完成属性注入`populateBean`

14. 调用 所有的Aware  `initializeBean` 调用 `invokeAwareMethods`

15. 调用生命周期回调方法

16. 完成代理

17. put到 singletonObjects 放入单例池

18. 销毁这个对象



注： AbstractAutowireCapableBeanFactory#doCreateBean 完成了`createBeanInstance` . `addSingletonFactory` . `populateBean`

## Spring源码注册的流程

1. 创建Spring容器的时候 我们一般第一步走

   ```java
   public class IOCTest_Autowired {
   
       public static void test1(){
           AnnotationConfigApplicationContext ctx = new AnnotationConfigApplicationContext(MainConfigAutowired.class);
           BookService bookService = ctx.getBean(BookService.class);
           System.out.println(bookService);
           ctx.close();
       }
   }
   ```

   其中

   ```java
   new AnnotationConfigApplicationContext(MainConfigAutowired.class); 
   ```

   这个的构造函数为

   ```java
   	/**
   	 * Create a new AnnotationConfigApplicationContext, deriving bean definitions
   	 * from the given annotated classes and automatically refreshing the context.
   	 * @param annotatedClasses one or more annotated classes,
   	 * e.g. {@link Configuration @Configuration} classes
   	 */
   	public AnnotationConfigApplicationContext(Class<?>... annotatedClasses) {
   		this();
   		register(annotatedClasses);
   		refresh();
   	}
   
   	/**
   	 * Create a new AnnotationConfigApplicationContext, scanning for bean definitions
   	 * in the given packages and automatically refreshing the context.
   	 * @param basePackages the packages to check for annotated classes
   	 */
   	public AnnotationConfigApplicationContext(String... basePackages) {
   		this();
   		scan(basePackages);
   		refresh();
   	}
   ```

   主要走三步

   ```java
   		this();
   		scan(basePackages); //传入扫描的基础包使用scan   传入类注解的字节码为 register 
   		refresh();
   ```



#### Spring的IOC容器

- spring容器分为基础容器和高级容器
  - BeanFactory结尾的是基础容器
  - applicationcontext结尾的是高级容器

#### BeanFactory基础容器

```
里面主要是获取bean对象的各种方法， 还有就是对bean属性的获取和判定 
```



- **HierarchicalBeanFactory** 

  ```
  HierarchicalBeanFactory 意思为分层的，这个赋予了获取父类BeanFactory的方法getParentBeanFactory()
  ```

- **ListableBeanFactory**

  ```
  ListableBeanFactory   用于bean配置的方法
  类似：
	int getBeanDefinitionCount();  获取bean的个数
  	String[] getBeanDefinitionNames();  获取bean的名称列表
  等方法。
  Listable 意思为 可列举的，对于容器而言，bean的定义和属性是可列举的
  ```
  
  

- **AutowireCapableBeanFactory**

  ```
  AutowireCapableBeanFactory提供了创建bean、自动注入，初始化以及应用bean的后置处理器
  ```

- **ConfigurableBeanFactory**

  ```
  记录被
  ```

  




#### ApplicationContext高级容器
- **ApplicationContext**

  ```
  ApplicationContext 提供了  messageResource 用户实现国际化
  ApplicationContext 提供了 ApplicationEventPublisher的接口  ApplicationEventPublisher用于发布容器。 Bean实现
  ```

- **ConfigurableApplicationContext**

  ```
  ConfigurableApplicationContext 接口继承了 ApplicationContext 接口， 主要添加了 refresh()和Close()方法。 其中 refresh()方法是Spring高级容器的核心方法
  ```

  








#### BeanDefinition 详解

```
BeanDefinition（接口） 是存放的基础bean信息（所有bean都会有的信息， 具体definition描述的bean 并没有信息体现在 BeanDefinition接口中，而是由BeanDefinition的子类来描述）

AbstractBeanDefinition （抽象类，有部分实现） 实现了BeanDefinition接口
GenericBeanDefinition  继承了 AbstractBeanDefinition

AnnotatedGenericBeanDefinition 和 ScannedGenericBeanDefinition 继承了GenericBeanDefinition
它们两个 分别对应了 扫描Bean  

```



- **BeanDefinitionRegistry** 

  ```
  BeanDefinitionRegistry 是interface 主要由其实现类实现功能 
  SimpleBeanDefinitionRegistry 主要以 Map实现存储bean
  ```

  

#### Bean的作用域（ScopeMetaData）



#### register()  scan()方法的作用

1.  解析总体的注册类 

     下面代码就是   MainConfigAutowired.class 这个类

   ```java
    AnnotationConfigApplicationContext ctx = new AnnotationConfigApplicationContext(MainConfigAutowired.class);
   ```

2. 调用到 DefaultListableBeanFactory 这个类, 向beanDefinitionMap.put  bean名字和beanDefinition   （但是这个 register只处理spring基础的bean，不放入开发者自定义的 bean）

   ```
   this.beanDefinitionMap.put(beanName, beanDefinition);
   ```



#### refresh() 方法

```java
public void refresh() throws BeansException, IllegalStateException {
   synchronized (this.startupShutdownMonitor) {
      // Prepare this context for refreshing.
      // 1. 准备容器，设置一些初始化信息
      prepareRefresh();

      // 获取 register()  scan() 所使用的 DefaultListableBeanFactory 把它看成 ConfigurableListableBeanFactory
      ConfigurableListableBeanFactory beanFactory = obtainFreshBeanFactory();

      // Prepare the bean factory for use in this context.
      prepareBeanFactory(beanFactory);

      try {
         // Allows post-processing of the bean factory in context subclasses.
         postProcessBeanFactory(beanFactory);

         // Invoke factory processors registered as beans in the context.
         invokeBeanFactoryPostProcessors(beanFactory);

         // Register bean processors that intercept bean creation.
         registerBeanPostProcessors(beanFactory);

         // 初始化消息资源的接口 （主要用于国际化）
         initMessageSource();

         // Initialize event multicaster for this context.
         // 8. 为容器注册一个事件组播器
         initApplicationEventMulticaster();

         // Initialize other special beans in specific context subclasses.
         // 9. 在AbstractApplicationContext 的子类中初始化其他特殊的bean
         onRefresh();

         // Check for listener beans and register them.
         registerListeners();

         // Instantiate all remaining (non-lazy-init) singletons.
         // 这个方法加载了 非spring本身自带的，业务开发工程师写代码自定义的spring bean
         finishBeanFactoryInitialization(beanFactory);

         // Last step: publish corresponding event.
         finishRefresh();
      }

      catch (BeansException ex) {
         if (logger.isWarnEnabled()) {
            logger.warn("Exception encountered during context initialization - " +
                  "cancelling refresh attempt: " + ex);
         }

         // Destroy already created singletons to avoid dangling resources.
         destroyBeans();

         // Reset 'active' flag.
         cancelRefresh(ex);

         // Propagate exception to caller.
         throw ex;
      }

      finally {
         // Reset common introspection caches in Spring's core, since we
         // might not ever need metadata for singleton beans anymore...
         resetCommonCaches();
      }
   }
}
```

1.  

2. **obtainFreshBeanFactory()** : 

   ```java
   ConfigurableListableBeanFactory beanFactory = obtainFreshBeanFactory();
   ```

   这方法用于获取 scan 和 register 里面使用的 DefaultListableBeanFactory

3. **finishBeanFactoryInitialization** : 
   
   `this.finishBeanFactoryInitialization(beanFactory)`这个方法调用了`preInstantiateSingletons`，这方法又调用了 `doGetBean`方法， 这个方法放在下面将
   
4.  

#### doGetBean() 方法

```java
        AnnotationConfigApplicationContext ctx = new AnnotationConfigApplicationContext(MainConfigAutowired.class);
       
       BookService bookService = ctx.getBean(BookService.class);
        
```

上面这个`BookService bookService = ctx.getBean(BookService.class);` 使用的是

`AbstractBeanFactory` 的 `doGetBean` 方法，

doGetBean 方法会传入beanName

`doGetBean` 首先调用了`getSingleton(String beanName, boolean allowEarlyReference)`  这个代码的具体内容如下：

```java
	protected Object getSingleton(String beanName, boolean allowEarlyReference) {
		Object singletonObject = this.singletonObjects.get(beanName);
    
    // 这个isSingletonCurrentlyInCreation 是判断是否有正在创建的，就是是否有循环依赖
		if (singletonObject == null && isSingletonCurrentlyInCreation(beanName)) {
			synchronized (this.singletonObjects) {
				singletonObject = this.earlySingletonObjects.get(beanName);
				if (singletonObject == null && allowEarlyReference) {
					ObjectFactory<?> singletonFactory = this.singletonFactories.get(beanName);
					if (singletonFactory != null) {
						singletonObject = singletonFactory.getObject();
						this.earlySingletonObjects.put(beanName, singletonObject);
						this.singletonFactories.remove(beanName);
					}
				}
			}
		}
		return singletonObject;
	}
```

​	它首先会调用`singletonObjects`，这是一个`ConcurrentHashMap`，可以认为是 **单例池**，

`private final Map<String, Object> singletonObjects = new ConcurrentHashMap<>(256);`





### 四个Map 一个Set

#### 1.singletonObjects  单例池 

singletonObjects是单例池，里面存放走完生命周期的bean

`private final Map<String, Object> singletonObjects = new ConcurrentHashMap<>(256);`



#### 2. beanDefinitionMap    bean定义信息map

```java
/** Map of bean definition objects, keyed by bean name. */
private final Map<String, BeanDefinition> beanDefinitionMap = new ConcurrentHashMap<>(256);
```

#### 3. singletonsCurrentlyInCreation  Set，正在创建的bean的Set

在 doGetBean 中会调用`createBean` ，doCreateBean会调用`getSingleton` 方法获取当前单例池的springbean， 有两个`getSingleton`方法，其中一个会调用`beforeSingletonCreation(beanName)` 这个方法会将beanName放到`singletonsCurrentlyInCreation `这个set中去

```java
protected void beforeSingletonCreation(String beanName) {
   if (!this.inCreationCheckExclusions.contains(beanName) && !this.singletonsCurrentlyInCreation.add(beanName)) {
      throw new BeanCurrentlyInCreationException(beanName);
   }
}
```

```JAVA
	/** Names of beans that are currently in creation. */
	private final Set<String> singletonsCurrentlyInCreation =
			Collections.newSetFromMap(new ConcurrentHashMap<>(16));
```

#### 4.singletonFactories 单例bean的工厂

```java
	private final Map<String, ObjectFactory<?>> singletonFactories = new HashMap<>(16);
```

#### 5.earlySingletonObjects  是个map ，半成品的bean

```java
private final Map<String, Object> earlySingletonObjects = new HashMap<>(16);
```



####  Spring Bean 和java 对象的区别

Spring Bean 首先是个java对象，但是Spring Bean必须走完Spring 的所有生命周期。类似下面的bean对象，它如果不走完PostConstruct 仅仅走完构造方法，那么它只是个java 对象，不是 Spring Bean

```java
@Component
public class Y {

    public Y(){
        System.out.println("create Y");
    }

    @PostConstruct
    public void postConstructInit(){
        System.out.println("y postConstructInit");
    }
}
```





### Spring循环依赖的解决

> 首先，简单的bean在createbeanInstance 这个方法中会使用反射创建成功，这是没有经过spring生命周期的bean

1. 使用了三级缓存技术，分别为
   - 一级缓存 **singletonObjects**  (是个map)   存放已经创建完成，走完生命周期的bean对象
   - 二级缓存 **singletonFactories**   (是个map)   存放正在创建的bean对象的创建工厂
   - 三级缓存 **earlySingletonObjects**   (是个map)  存放正在创建的bean对象
2. 使用流程为
   1. 假设有两个bean





Spring AOP 和 AspectJ 





### Bean生命周期









## spring事务传播
propagation_request     request（必须）（默认的）
支持当前事务，A如果有事务，B将使用该事务
如果A没有事务，B将创建一个新的事务 

propagation_supports    supports （必须）
支持当前事务，A如果有事务，B将使用该事务
如果A没有事务，B将以非事务执行


PROPAGATION_REQUIRED

如果当前没有事务，就新建一个事务，如果已经存在一个事务中，加入到这个事务中。这是最常见的选择。

PROPAGATION_SUPPORTS

支持当前事务，如果当前没有事务，就以非事务方式执行。

PROPAGATION_MANDATORY

使用当前的事务，如果当前没有事务，就抛出异常。

PROPAGATION_REQUIRES_NEW

新建事务，如果当前存在事务，把当前事务挂起。

PROPAGATION_NOT_SUPPORTED

以非事务方式执行操作，如果当前存在事务，就把当前事务挂起。

PROPAGATION_NEVER

以非事务方式执行，如果当前存在事务，则抛出异常。

PROPAGATION_NESTED

如果当前存在事务，则在嵌套事务内执行。如果当前没有事务，则执行与PROPAGATION_REQUIRED类似的操作。


## Spring事务的传播属性
- required 需要 如果存在一个事务，就支持当前事务。如果没有事务，就开启。
- supports 支持，如果存在就使用当前事务。如果不存在，就开启一个事务。
- mandatory 必须的 ，如果存在事务，就使用当前事务，如果不存在事务，就爆出异常
- required_new 总是开启一个新的事务
- not_support 总是非事务的执行，如果存在一个事务，就挂起
- never 绝不，总是非事务的执行，如果存在一个活动事务，就抛出异常
- nested 嵌套的 如果有就嵌套，如果没有就开启





注：

- classpath用法

  ```
  classpath:config   的意思: 在类路径下寻找config 这个文件夹
  classpath*:config  的意思: 多个工程下的类路径下全都寻找config 这个文件夹
  ```




