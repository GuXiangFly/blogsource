---
title: Struts2的执行流程解释以及源码分析（以登录 和自动登录实现 为例）
date: 2017-4-16 10:41:48
tags: [struts2,java]
---

## Struts2的执行流程解释以及源码分析（以登录 和自动登录实现 为例） ##

``` xml
<body>
    <form action="${pageContext.request.contextPath}/act1" method="post">
    	用户名：<input type="text" name="username"/><br/>
    	密码：<input type="text" name="password"/><br/>
    	<input type="submit" value="登录"/>
    </form>
  </body>
```
这会提交一个叫act1  的action

----------


**2.服务器端  FilterDispathcher判断是否拦截**
请求被提交到一系列的Filter过滤器，如ActionContextCleanUp和FileterDispather等。
FilterDispatcher是Struts2的控制核心，它通常是过滤器链中的最后一个过滤器。
请求发到FilterDispathcher后，FilterDispatcher询问ActionMapper是否需要调用某个Action来处理这个Request ，需要 那么就拦截 不需要 那就放行。  
如果ActionMapper决定需要调用某个Action，FilterDispatcher就会把action拦截下来，把请求交到ActionProxy,由其进行处理。  
看到 Proxy 则很明显是 **代理的设计模式**， Proxy会找到目标类。

``` xml
<action name="act1" class="com.guxiang.web.action.PersonAction"></action>
```
我们知道 在 代理设计模式中 **无论是动态代理还是静态代理 都需要 new 出 目标类  （实例化目标类）**
那么这个 new 出来的 目标action实例 会被放入 valuestack（值栈）中
![这里写图片描述](http://img.blog.csdn.net/20170315181928184?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvbXlfX1N1bl8=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)

代理设计模式的主要功能就是 增强类  而struts中 则主要是通过 interceptor 进行增强  
 那么就会通过 自定义的拦截器栈增强

**3.通过拦截器增强action**
``` xml
		<interceptors>
			<!-- 声明 -->
			<interceptor name="loginInterceptor"
				class="com.guxiang.crm.web.interceptor.LoginInterceptor"></interceptor>
			<!-- 定义拦截器 -->
			<interceptor-stack name="loginStack">
				<interceptor-ref name="defaultStack"></interceptor-ref>
				<interceptor-ref name="loginInterceptor">
					<param name="excludeMethods">login</param>
				</interceptor-ref>
			</interceptor-stack>
		</interceptors>
		<!-- 声明默认拦截器栈 -->
		<default-interceptor-ref name="loginStack">
		</default-interceptor-ref>
```

首先会执行 defaultStack里面的拦截器
这个defaultStack 可以再 struts-core-xxxx.jar  里面的  **struts-default.xml** 文件里面找到
``` xml
 <interceptor-stack name="defaultStack">
                <interceptor-ref name="exception"/>
                <interceptor-ref name="alias"/>
                <interceptor-ref name="servletConfig"/>
                <interceptor-ref name="i18n"/>
                <interceptor-ref name="prepare"/>
                <interceptor-ref name="chain"/>
                <interceptor-ref name="scopedModelDriven"/>
                <interceptor-ref name="modelDriven"/>
                <interceptor-ref name="fileUpload"/>
                <interceptor-ref name="checkbox"/>
                <interceptor-ref name="multiselect"/>
                <interceptor-ref name="staticParams"/>
                <interceptor-ref name="actionMappingParams"/>
                <interceptor-ref name="params">
                    <param name="excludeParams">dojo\..*,^struts\..*,^session\..*,^request\..*,^application\..*,^servlet(Request|Response)\..*,parameters\...*</param>
                </interceptor-ref>
                <interceptor-ref name="conversionError"/>
                <interceptor-ref name="validation">
                    <param name="excludeMethods">input,back,cancel,browse</param>
                </interceptor-ref>
                <interceptor-ref name="workflow">
                    <param name="excludeMethods">input,back,cancel,browse</param>
                </interceptor-ref>
                <interceptor-ref name="debugging"/>
            </interceptor-stack>
```
**4.里面有个modelDriven 拦截器**

 如果action实现了 modelDriven这个接口，那么 modelDriven这个拦截器就会 调用action里的getModel（）方法， 由此获得 javabean 实例对象，并且，会压入 valuestack的栈顶。    
``` java
	//封装数据
	private User user = new User();
	@Override
	public User getModel() {
		return user;
	}
```
现在值栈状态如下图所示：
 ![这里写图片描述](http://img.blog.csdn.net/20170315200508140?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvbXlfX1N1bl8=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)



----------


**5.还有一个 params拦截器**


我们请求发送的值如图：

![这里写图片描述](http://img.blog.csdn.net/20170315201431426?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvbXlfX1N1bl8=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)

那么 password  和 username 就会在值栈中  从上往下找匹配的
于是找到了 user 里面的  username 和 password 进行 封装上去

![这里写图片描述](http://img.blog.csdn.net/20170315201826285?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvbXlfX1N1bl8=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)

**以及还有一堆拦截器.......= =！**

----------


**之后会执行我们的loginInterceptor 拦截器**  
自定义拦截器   我们从父类来看执行顺序
父类 **MethodFilterInterceptor** 中有一个 **intercept** 方法
```java
    @Override
    public String intercept(ActionInvocation invocation) throws Exception {
        if (applyInterceptor(invocation)) {
            return doIntercept(invocation);
        }
        return invocation.invoke();
    }
```
这个 intercept 方法会判断  是否需要先执行这个拦截器 再  **doIntercept**
**applyInterceptor(invocation)** 这个方法会过滤掉  配置的 login 这个进行登录的拦截器
执行 login 这个action 的时候  不会进入自定义拦截器
那么就可以在login这个拦截器上 直接调用 login方法登录

``` xml
<interceptor-ref name="loginInterceptor">
	<param name="excludeMethods">login</param>
</interceptor-ref>
```
如果 applyInterceptor(invocation)== true
那么就执行  doIntercept


```java
	@Override
	protected String doIntercept(ActionInvocation invocation) throws Exception {
		Object object = ActionContext.getContext().getSession().get("loginUser");
		if (object==null) {
			Object action = invocation.getAction();
			// 2 判断运行时是否是ActionSupport


			if (action instanceof ActionSupport) {
				ActionSupport actionSupport = (ActionSupport) action;
				actionSupport.addFieldError("", "请登录");
			}
			return "login";
		}

		//放行
		return invocation.invoke();

	}
```

------

**最后我们来做一个struts2 的执行流程的完整图解**

![这里写图片描述](http://img.blog.csdn.net/20170315210137057?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvbXlfX1N1bl8=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)
