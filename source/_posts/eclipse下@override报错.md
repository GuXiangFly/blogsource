---
title: eclipse 环境下 @override 注解 报错
date: 2017-3-16 23:19:04
tags: [工具使用,java]
---


## 在 eclipse 环境下 @override 注解 报错

我们在做项目的时候，写接口，实现类自动生成的方法 注解@override 总是报错，去掉@override 注解就正常了，但是语法上明显可以有注解。  
如同我这样：
![这里写图片描述](http://img.blog.csdn.net/20170314103147318?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvbXlfX1N1bl8=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)


----------


这东西曾经长期困扰我，后来发现 这个原来是 jdk1.5的一个bug，在jdk1.6的时候，已经进行了修复。  
有同学可能会问，我的jdk包 明明已经是 1.6 及其以上了啊 为什么还会报错。 其实我们需要改一下 eclipse 编译的jdk.


----------
**一.在eclipse中修改配置**

在eclipse中修改配置，在 Windows->Preferences-->java->Compiler-->compiler compliance level 中选择 1.6。
![这里写图片描述](http://img.blog.csdn.net/20170314103724291?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvbXlfX1N1bl8=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)

如果还是不行，请看 二

----------
**二.在工程上修改**
鼠标右键选择 Properties-->Java Compiler-->compiler compliance level中选择 1.6。  



![这里写图片描述](http://img.blog.csdn.net/20170314104039416?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvbXlfX1N1bl8=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)
![这里写图片描述](http://img.blog.csdn.net/20170314104117463?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvbXlfX1N1bl8=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)
