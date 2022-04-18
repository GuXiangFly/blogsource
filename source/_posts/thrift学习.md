---
title: thrift学习
date: 2019-7-27 20:09:04
tags: [数据结构与算法]

---
## 

Thrift

![image-20211202193109771](http://guxiangflyimagebucket.oss-cn-beijing.aliyuncs.com/img/image-20211202193109771.png)





thrift 支持的类型 



![image-20211202193955217](http://guxiangflyimagebucket.oss-cn-beijing.aliyuncs.com/img/image-20211202193955217.png)





thrift主要支持的有三大组件：

- struct： 编译完成后是类

- service： 服务端和客户端通信用到的接口

- exception： service所可能抛出的exception





namespace java   com.test.thrfit.demo

代表如果生成java代码的话，这个java代码会在 com.test.thrfit.demo 这个包下

![image-20211202200023451](http://guxiangflyimagebucket.oss-cn-beijing.aliyuncs.com/img/image-20211202200023451.png)







### 枚举的定义

![image-20211202200452829](http://guxiangflyimagebucket.oss-cn-beijing.aliyuncs.com/img/image-20211202200452829.png)





### 异常定义

![image-20211202200513182](http://guxiangflyimagebucket.oss-cn-beijing.aliyuncs.com/img/image-20211202200513182.png)





### 类型定义

![image-20211202200628290](http://guxiangflyimagebucket.oss-cn-beijing.aliyuncs.com/img/image-20211202200628290.png)







### 常量(const)

![image-20211202200705656](http://guxiangflyimagebucket.oss-cn-beijing.aliyuncs.com/img/image-20211202200705656.png)





![image-20211202200759315](http://guxiangflyimagebucket.oss-cn-beijing.aliyuncs.com/img/image-20211202200759315.png)



### 命名空间

代表生成的java代码会

![image-20211202200823331](http://guxiangflyimagebucket.oss-cn-beijing.aliyuncs.com/img/image-20211202200823331.png)







### 可选与必选

![image-20211202200924137](http://guxiangflyimagebucket.oss-cn-beijing.aliyuncs.com/img/image-20211202200924137.png)