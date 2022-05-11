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





### 注意
thrift不支持日期



### 一个DEMO
编写thrift代码
```thrift 
namespace java thrift.generated

/*这个define 定义*/
typedef i16 short
typedef i32 int
typedef i64 long
typedef bool boolean
typedef string String

struct Person{
    1: optional String username,
    2: optional int age,
    3: optional boolean married
}


exception DataException{
    1:optional String message,
    2: optional String callStack,
    3: optional String date
}

service PersonService{
    Person getPersonByUserName(1:required String username) throws (1:DataException dataException),

    void savePerson(1:required Person person) throws (1:DataException dataException)
}
```
使用命令
```
thrift --gen java src/main/resources/thrift/data.thrift 
```

使用这个命令后，会在项目的根目录下生成一个gen-java的文件夹 里面有  thrift/generated包下 放置

```
Person.java 
DataException.java
PersonService.java
```



在pom.xml中加入依赖

```XML
        <dependency>
            <groupId>org.apache.thrift</groupId>
            <artifactId>libthrift</artifactId>
            <version>0.13.0</version>
        </dependency>
```

![image-20211205004601785](https://gitee.com/guxiangfly/blogimage/raw/master/img/image-20211205004601785.png)

- TTransport： 传输层

  

  

  ### Thrift的传输格式

  ![image-20211205005109549](https://gitee.com/guxiangfly/blogimage/raw/master/img/image-20211205005109549.png)





### Thrfit传输方式

![image-20211205005350116](https://gitee.com/guxiangfly/blogimage/raw/master/img/image-20211205005350116.png)



### Thrfit的服务模型

![image-20211205005331005](https://gitee.com/guxiangfly/blogimage/raw/master/img/image-20211205005331005.png)

