---
title: intellij IDEA hql语句检查报错
date: 2017-4-1 15:12:54
tags: [intellij IDEA,java,hibernate]
---

## 在 idea 下写 hql语句报如下错误 ##


----------
This inspection controls whether the Persistence QL Queries are error-checked


----------


![这里写图片描述](http://img.blog.csdn.net/20170322204254420?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvbXlfX1N1bl8=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)


----------
**网上不少网友解释说可以关闭  sql检查就好**
**确实是可以的 但是这种说法其实是比价不负责的，有一种更为正确的方式，那么就是在facets 上添加  hibernate 的支持  这种甚至能在写 hql 语句时候 给你智能提示。**


----------


![这里写图片描述](http://img.blog.csdn.net/20170322204810728?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvbXlfX1N1bl8=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)


----------
另外 如果有同学已经关闭了 sql 的检查 那么可以在这里开启。


----------
![这里写图片描述](http://img.blog.csdn.net/20170322205047853?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvbXlfX1N1bl8=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)
