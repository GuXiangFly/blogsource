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









## 重学spring

 https://www.bilibili.com/video/BV1iZ4y137CZ?p=5

### 实例化与初始化

![image-20210304211521124](https://gitee.com/guxiangfly/blogimage/raw/master/img/image-20210304211521124.png)

从刚开始准备实例化对象，到最终完成 bean的初始化分为3步

1. 实例化(从堆中开辟一块空间)

2. 填充对象的各个属性 （这个使用set方法完成，不使用init）

3. 执行 init-method (类似下面的xml，有一个init-method)

   ```xml
       <bean id="compInfoChangeMessageProducer" class="com.meituan.lvyou.libra.business.adapter.producer.impl.CompInfoChangeMessageProducer" init-method="init" destroy-method="destroy">
           <property name="topic" value="${lvyou_libra_promotion_compare_comp_deal_change_topic}"/>
           <property name="properties">
               <props>
                   <prop key="mafka.bg.namespace">hotel</prop>
                   <prop key="mafka.client.appkey">com.sankuai.lvyou.libra</prop>
               </props>
           </property>
       </bean>
   ```








spring的生命周期流程



![image-20210309215926865](https://gitee.com/guxiangfly/blogimage/raw/master/img/image-20210309215926865.png)



类似下面这段

```xml
<bean id ="datasource"  class = "com.alibaba.druid.pool.DruidDataSource">
    <property name="username" value="${jdbc.username}"></property>
</bean>
```

${jdbc.username}是通过BeanFactoryPostProcessor来赋值的  源码如下

```java
public class PropertySourcesPlaceholderConfigurer extends PlaceholderConfigurerSupport implements EnvironmentAware {
··············

    public void postProcessBeanFactory(ConfigurableListableBeanFactory beanFactory) throws BeansException {
        if (this.propertySources == null) {
    ······················
            try {
                PropertySource<?> localPropertySource = new PropertiesPropertySource("localProperties", this.mergeProperties());
                if (this.localOverride) {
                    this.propertySources.addFirst(localPropertySource);
                } else {
                    this.propertySources.addLast(localPropertySource);
                }
            } catch (IOException var3) {
                throw new BeanInitializationException("Could not load properties", var3);
            }
        }
················
    }
}
```





自己想实现可以这么实现： 实现postProcessBeanFactory

```java
@Component
public class MyBeanFactoryPostProcessor implements BeanFactoryPostProcessor {

	@Override
	public void postProcessBeanFactory(ConfigurableListableBeanFactory beanFactory) throws BeansException {
		System.out.println("MyBeanFactoryPostProcessor...postProcessBeanFactory...");
		int count = beanFactory.getBeanDefinitionCount();
		String[] names = beanFactory.getBeanDefinitionNames();
		for (String name : names) {
			System.out.println(name);
		}
		System.out.println("当前BeanFactory中有"+count+" 个Bean");
		System.out.println(Arrays.asList(names));
	}

}
```



####  Bean的生命周期

![image-20210309013032829](C:\Users\guxiang\AppData\Roaming\Typora\typora-user-images\image-20210309013032829.png)

前提：首先明确bean分为实例化和初始化两步，bean是通过beandefinition创建出来的

1. 扫描 xml，@bean等注解

2. 通过beandefinitionReader读取出beanDefinition

3. beanDefinition通过 BeanFactoryPostProcessor进行部分操作（类似填充jdbc.username等配置信息）

4. 通过反射，进行实例化。  

5. 实例化后填充属性 populationBean--------------(属于初始化)

6. 执行 aware接口，注入部分属性--------------(属于初始化)

7. beanpostprocesser.before 执行--------------(属于初始化)

8. InitializingBean 与 init-method：--------------(属于初始化)

   如果Bean在Spring配置文件中配置了 init-method 属性，则会自动调用其配置的初始化方法。

9. beanpostprocesser.after 执行 （这里面AbstractAutoProxyCreator继承了beanpostprocesser 在postProcessAfterInitialization方法中实现了 aop的自动代理）--------------(属于初始化)



#### 具体源码的 bean生命； 周期流程


1. 首先 需要创建一个BeanFactory   也就是 DefaultListableBeanFactory

   1. refresh方法中的obtainFreshBeanFactory  进行了   1. 创建beanfactory  2. 加载bean定义信息

      ```java
      obtainFreshBeanFactory调用了refreshBeanFactory
      protected final void refreshBeanFactory() throws BeansException {
      -----
      			DefaultListableBeanFactory beanFactory = createBeanFactory();
      			beanFactory.setSerializationId(getId());
      			customizeBeanFactory(beanFactory);
      			loadBeanDefinitions(beanFactory);
      -----
      	}
      ```

      defaultListableBeanFactory 里面有 beandefinitionmap

      <img src="https://gitee.com/guxiangfly/blogimage/raw/master/img/image-20210309224409378.png" alt="image-20210309224409378" style="zoom:67%;" />

2. 通过BeanFactory读取配置文件 loadBeanDefinitions   (在上面源码处理完成)

3.  执行beanfactorypostprocesser      【refresh 内的 invokeBeanFactoryPostProcessors(beanFactory)】

4. 准备其他东西

   ```java
   				// Register bean processors that intercept bean creation.
   				registerBeanPostProcessors(beanFactory);   
   
   				// Initialize message source for this context.
   				initMessageSource();
   
   				// Initialize event multicaster for this context.
   				initApplicationEventMulticaster();
   
   				// Initialize other special beans in specific context subclasses.
   				onRefresh();
   
   				// Check for listener beans and register them.
   				registerListeners();
   ```

5. 进行实例化 和 初始化

   ```
   // Instantiate all remaining (non-lazy-init) singletons. 翻译：实例化非懒加载的单例对象
   finishBeanFactoryInitialization(beanFactory);
   
   内部调用有
   beanFactory.preInstantiateSingletons();
   
   finishBeanFactoryInitialization 调用 preInstantiateSingletons 调用 getBean 调用 doGetBean 调用 createBean  调用doCreateBean 调用  createBeanInstance  调用到instantiateBean 调用到getInstantiationStrategy().instantiate 看impl  最后调用到 BeanUtils.instantiateClass(constructorToUse) 进行 ctor.newInstance(args) 反射调用
   ```

   1. 属性填充:    doCreateBean 内调用 populateBean 进行 属性填充
   2. 执行Aware填充： doCreateBean 内调用 initializeBean， initializeBean调用invokeAwareMethods，执行 aware的属性填充
   3. 执行BeanPostProcessor的Before：doCreateBean 内调用的initializeBean  调用了 applyBeanPostProcessorsBeforeInitialization
   4. 执行init-method：doCreateBean 内调用的initializeBean  调用了 invokeInitMethods
   5. 执行BeanPostProcessor的After ： doCreateBean 内调用的initializeBean  调用了applyBeanPostProcessorsAfterInitialization
   6. 执行了





### ![image-20210310005642762](C:\Users\guxiang\AppData\Roaming\Typora\typora-user-images\image-20210310005642762.png)

循环依赖的流程







####  如何实现循环依赖

首先我们明确， Bean A的生命周期 包括有 实例化A 和 初始化A

<img src="https://gitee.com/guxiangfly/blogimage/raw/master/img/image-20210310132535166.png" alt="image-20210310132535166" style="zoom:67%;" />

解决办法：三级缓存

```java
 /** Cache of singleton objects: bean name to bean instance. 一级缓存*/
	private final Map<String, Object> singletonObjects = new ConcurrentHashMap<>(256);

	/** Cache of singleton factories: bean name to ObjectFactory. 三级缓存*/
	private final Map<String, ObjectFactory<?>> singletonFactories = new HashMap<>(16);
//ObjectFactory 是一个函数式接口，仅有一个方法，可以用来传入lambda表达式，可以通过调用getObject来执行具体的逻辑


	/** Cache of early singleton objects: bean name to bean instance. 二级缓存*/
	private final Map<String, Object> earlySingletonObjects = new HashMap<>(16);
```



循环依赖主要在实例化和初始化bean阶段完成

主要集中在`finishBeanFactoryInitialization(beanFactory` 内调用的`beanFactory.preInstantiateSingletons()` 方法中



spring实例化bean的流程方法

- getBean -> doGetBean  ->createBean -> doCreateBean



#### 三级缓存流程

getBean -> doGetBean-> `getSingleton(beanName) ` 先从一级缓存中获取，如果获取不到，那么通过beanName看是否bean在创建中。都不在，那么这个getSingleton(beanName) 先出栈。  

然后会调用到 `getSingleton(String beanName, ObjectFactory<?> singletonFactory)`; 这个

getSingleton(beanName, createBean的lambda表达式)    这个 `getSingleton(String beanName, ObjectFactory<?> singletonFactory)` **并没有进入三级缓存**中









#### 三级缓存入栈流程

**进入创建A的过程**

getBean入栈 -> doGetBean入栈->  getSingleton(beanName,ObjectFactory)入栈 ->singletonFactory调用 createBean(入栈) 

-> doCreateBean入栈  

-> 调用createBeanInstance创建BeanA 并且 出栈，此时Bean A 的b属性为null

(此时的bean对象只进行了实例化，没有初始化，只是个半成品)

-> 调用addSingletonFactory(beanName, () -> getEarlyBeanReference(beanName, mbd, bean)); 里面放置 三级缓存和一级缓存

```java
protected void addSingletonFactory(String beanName, ObjectFactory<?> singletonFactory) {
		Assert.notNull(singletonFactory, "Singleton factory must not be null");
		synchronized (this.singletonObjects) {
			if (!this.singletonObjects.containsKey(beanName)) {
				this.singletonFactories.put(beanName, singletonFactory);
				this.earlySingletonObjects.remove(beanName);
				this.registeredSingletons.add(beanName);
			}
		}
	}
```

addSingletonFactory出栈

-> 调用 populateBean 入栈 

​	-> 调用applyPropertyValues 入栈

   内部有

```
String propertyName = pv.getName();
Object originalValue = pv.getValue(); 类型是RuntimeBeanReference
```

​      -> 调用resolveValueIfNecessary 入栈

​      ->  调用 resolveReference 入栈

​      ->  调用 this.beanFactory.getBean(refName) 入栈   

**进入创建B的过程**

   ->  调用  doGetbean -> 调用B doCreateBean  -> 调用 ···· 重复上面的工作

**进入二次创建A的过程**

（此时，三级缓存singletonFactories中已经有了  【a,() -> getEarlyBeanReference(a, mbd, A@1755) 这个ObjectFactory】 和 【b,()->getEarlyBeanReference(b, mbd, B@1876) 这个ObjectFactory】）



 getBean(a)-> createbean(a) -> doCreateBean(a)-> getSingleton(a)

此时 getSingleton（a） 调用到  this.singletonFactories.get(a) 通过调用getEarlyBeanReference 获取到了ObjectFactory， ObjectFactory获取到了bean的半成品



出栈到 B   this.beanFactory.getBean(B) 

......

#### 循环依赖简易版步骤

先进行A的实例化，然后A初始化受阻 将a,lambda放入 singletonFactories，需要赋值B

再进行B的实例化，然后B初始化受阻 将a,lambda放入 singletonFactories，需要赋值A



|                                                              | A                             | B                             |
| :----------------------------------------------------------- | :---------------------------- | :---------------------------- |
| 一级缓存                                                                                                                          Map<String, Object> singletonObjects = new ConcurrentHashMap<>(256); |                               |                               |
| 二级缓存                                                                                                                            Map<String, Object> earlySingletonObjects = new HashMap<>(16); |                               |                               |
| 三级缓存 Map<String, ObjectFactory<?>> singletonFactories = new HashMap<>(16); | k:a, v:ObjectFactory 的lambda | k:b, v:ObjectFactory 的lambda |

 

再进行A的getBean ->doGetBean  ->getSingleton(a)                 ----具体位置（AbstractBeanFactory  搜getSingleton(beanName)）

从此段代码中先得到ObjectFactory，调用getObject 调用lambda 获取bean的半成品(仅仅进行了实例化). 

```java
	protected Object getSingleton(String beanName, boolean allowEarlyReference) {
		Object singletonObject = this.singletonObjects.get(beanName);
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

加入二级缓存，并且从三级缓存中删除

此阶段图示 

|                                                              | A                                                            | B             |
| :----------------------------------------------------------- | :----------------------------------------------------------- | :------------ |
| 一级缓存Map<String, Object> singletonObjects = new ConcurrentHashMap<>(256); |                                                              |               |
| 二级缓存Map<String, Object> earlySingletonObjects = new HashMap<>(16); | k:a, v:A@1755(半成品)（A对象中的b属性为null）                |               |
| 三级缓存 Map<String, ObjectFactory<?>> singletonFactories = new HashMap<>(16); | k:a,                                               v:lambda(删除) | k:b, v:lambda |

 



到这个阶段，其实B的实例化 和初始化都完成了 于是B变成了一个完成品 （虽然B对象 里面的a属性是个半成品，但是B已经是个完成品了）

退回到(DefaultSingletonBeanRegistry这段代码中的getSingleton中的 **addsingleton 下面有具体代码**)

这段代码中将B 添加入一级缓存，并且删除二级缓存和三级缓存

|                                                              | A                    | B                                                       |
| :----------------------------------------------------------- | :------------------- | :------------------------------------------------------ |
| 一级缓存Map<String, Object> singletonObjects = new ConcurrentHashMap<>(256); |                      | k:b,    v:B@2153(完成品)虽然B对象 里面的a属性是个半成品 |
| 二级缓存Map<String, Object> earlySingletonObjects = new HashMap<>(16); | k:a v:A@1755(半成品) |                                                         |
| 三级缓存 Map<String, ObjectFactory<?>> singletonFactories = new HashMap<>(16); | k:a, v:lambda(删除)  | k:b    v:lambda(删除)                                   |

 

给B进行实例化和初始化已经出栈，

进入给A进行 初始化的操作，  退回到A进行 (DefaultSingletonBeanRegistry这段代码中的getSingleton中的 addsingleton)

 添加入一级缓存，并且删除二级缓存和三级缓存

|                                                              | A                               | B                                                     |
| :----------------------------------------------------------- | :------------------------------ | :---------------------------------------------------- |
| 一级缓存Map<String, Object> singletonObjects = new ConcurrentHashMap<>(256); | k:a,     V: A@1755（完成品）    | k:b,  v:B@2153(完成品)虽然B对象 里面的a属性是个半成品 |
| 二级缓存Map<String, Object> earlySingletonObjects = new HashMap<>(16); | k:a,     v:A@1755(半成品)(删除) |                                                       |
| 三级缓存 Map<String, ObjectFactory<?>> singletonFactories = new HashMap<>(16); | k:a,     v:lambda(删除)         | k:b,  v:lambda(删除)                                  |

 



#### 循环依赖深入思考

- 三级缓存解决循环依赖的关键是什么？为什么通过提前暴露对象能解决？
  - 实例化和初始化分开操作。 spring是将半成品的对象赋值给其他对象
- 如果只使用一级缓存能否解决问题？
  - 不能，在整个过程中，缓存中放的是半成品和成品对象，如果只使用一级缓存，那么成品和半成品都会放到一级缓存中，会混淆
- 只使用二级的缓存行不行
  - 三级缓存的singletonFactories的 lambda存放的是   beanName, () -> getEarlyBeanReference(beanName, mbd, bean)
  - 这个getEarlyBeanReference是里面用来实现动态代理的。使用三级缓存主要使用解决aop代理问题。
- 如果某个bean对象需要使用代理对象，会不会创建普通的bean对象
  - 会
- 为什么使用三级缓存能解决这个问题
  - 当一个对象需要被代理的时候，在整个过程中是生成两个对象，一个普通对象，一个代理对象，bean默认是单例的

------------



getEarlyBeanReference的代码

```java
	protected Object getEarlyBeanReference(String beanName, RootBeanDefinition mbd, Object bean) {
		Object exposedObject = bean;
		if (!mbd.isSynthetic() && hasInstantiationAwareBeanPostProcessors()) {
			for (BeanPostProcessor bp : getBeanPostProcessors()) {
				if (bp instanceof SmartInstantiationAwareBeanPostProcessor) {
					SmartInstantiationAwareBeanPostProcessor ibp = (SmartInstantiationAwareBeanPostProcessor) bp;
					exposedObject = ibp.getEarlyBeanReference(exposedObject, beanName);
				}
			}
		}
		return exposedObject;
	}
```



```java
	protected Object getSingleton(String beanName, boolean allowEarlyReference) {
		Object singletonObject = this.singletonObjects.get(beanName);
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



```java
	protected void addSingleton(String beanName, Object singletonObject) {
		synchronized (this.singletonObjects) {
			this.singletonObjects.put(beanName, singletonObject);
			this.singletonFactories.remove(beanName);
			this.earlySingletonObjects.remove(beanName);
			this.registeredSingletons.add(beanName);
		}
	}
```





springMVC流程

![image-20211013144942499](https://gitee.com/guxiangfly/blogimage/raw/master/img/image-20211013144942499.png)

- 客户端通过url发送请求
- 核心控制器Dispatcher Servlet接收到请求，通过系统或自定义的映射器配置找到对应的handler，并将url映射的控制器controller返回给核心控制器。
- 通过核心控制器找到系统或默认的适配器
- 由找到的适配器，调用实现对应接口的处理器，并将结果返回给适配器，结果中包含数据模型和视图对象，再由适配器返回给核心控制器
- 核心控制器将获取的数据和视图结合的对象传递给视图解析器，获取解析得到的结果，并由视图解析器响应给核心控制器
- 核心控制器将结果返回给客户端
