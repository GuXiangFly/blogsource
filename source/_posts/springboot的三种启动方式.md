---
title: springboot的三种启动方式
date: 2017-5-23 12:23:54
tags: [springboot,intellij IDEA]
---
## IDE 运行Application这个类的main方法 ##
![这里写图片描述](http://img.blog.csdn.net/20170605131021244?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvbXlfX1N1bl8=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)


----------


## 在springboot的应用的根目录下运行mvn spring-boot:run ##
![这里写图片描述](http://img.blog.csdn.net/20170605131428546?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvbXlfX1N1bl8=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)


----------
## 使用mvn install 生成jar后运行 ##

```
先到项目根目录
mvn install
cd target
java -jar   xxxx.jar
```


----------


![这里写图片描述](http://img.blog.csdn.net/20170605131919757?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvbXlfX1N1bl8=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)


----------


![这里写图片描述](http://img.blog.csdn.net/20170605131933396?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvbXlfX1N1bl8=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)