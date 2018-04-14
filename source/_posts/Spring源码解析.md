---
title: Spring源码解析
date: 2017-9-24 20:11:44
tags: [Spring,java]
---

之所以能扫描到
``` java
@Controller
@Service
@Component
@Resource
```
这几个注解，是由于他们都是 @Component的父注解或者@Component的本身
为何是父亲就能被扫描到呢？ 
这是由于 这段代码：
``` java
	protected void registerDefaultFilters() {
		this.includeFilters.add(new AnnotationTypeFilter(Component.class));
		ClassLoader cl = ClassPathScanningCandidateComponentProvider.class.getClassLoader();
		try {
			this.includeFilters.add(new AnnotationTypeFilter(
					((Class<? extends Annotation>) ClassUtils.forName("javax.annotation.ManagedBean", cl)), false));
			logger.debug("JSR-250 'javax.annotation.ManagedBean' found and supported for component scanning");
		}
		catch (ClassNotFoundException ex) {
			// JSR-250 1.1 API (as included in Java EE 6) not available - simply skip.
		}
		try {
			this.includeFilters.add(new AnnotationTypeFilter(
					((Class<? extends Annotation>) ClassUtils.forName("javax.inject.Named", cl)), false));
			logger.debug("JSR-330 'javax.inject.Named' annotation found and supported for component scanning");
		}
		catch (ClassNotFoundException ex) {
			// JSR-330 API not available - simply skip.
		}
	}
```

 AnnotationTypeFilter 可以扫描到父注解的子注解





## 包扫描处理代码
``` java
@Override
	public BeanDefinition parse(Element element, ParserContext parserContext) {
		String[] basePackages = StringUtils.tokenizeToStringArray(element.getAttribute(BASE_PACKAGE_ATTRIBUTE),
				ConfigurableApplicationContext.CONFIG_LOCATION_DELIMITERS);

		// Actually scan for bean definitions and register them.
		ClassPathBeanDefinitionScanner scanner = configureScanner(parserContext, element);
		Set<BeanDefinitionHolder> beanDefinitions = scanner.doScan(basePackages);
		registerComponents(parserContext.getReaderContext(), beanDefinitions, element);

		return null;
	}
```