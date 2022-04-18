---
title: DDD领域驱动设计
date: 2020-9-27 20:09:04
tags: [编程思想]
---



## DDD的用处是什么的

ddd是什么的缩写(Domain Driven Design)

- DDD是为了解决快速变化、复杂系统的设计问题的







# 模型

### 贫血模型

一般来说我们写一个student类，只有变量属性，和get set。没有具体的方法。

```java
public class Student{
	int id;
	int age;
	String name;
	get...
	set...
}
```

假设学生需要选课，需要写一个

```java
studentService.takeCourse(studentID,courseId)
```

这种包的组件方式是

```
cn.guxiangfly.controller
cn.guxiangfly.service
cn.guxiangfly.dao
```



### 充血模型

```java
class XXController{
	Repository repository;
  CheckService checkService;
  XKService  XKService;
  XKMsg  XKMsg;
  Result xk(String StudentId,String courseId){
    
    //加载数据
    Student s = repository.find(studentId);
    Result r = checkService.check();
    if (r != Success){
      reject();
    }
    xkService.xk(sId,course);
    xkMsg = new XKMsg(student,course);
    msgSender.send(xkMsg);
    return Success;
  }
}
```



抽象了CheckService，对应业务变化（防腐层）

抽象MQ基础设施层，防止第三方组件的变化（rocketMQ->Kafka）







编程思想

- POP
- OOP



POP（面向过程编程） 是一种线性思维

> 比方说造个简陋的小房子，我们先建造门，再造窗户，再造屋顶，再加床，加窗帘等    （这种线性思维可以实现）

OOP （面向对象编程）

> 比如说建个大厦，我们先画个草图搭建一个架构，  电梯是一个对象，卫生间/大厅/客厅/客房/会议室    卧室下有不同型号的客房 都是一个个房间对象.. 将架构搭建完成后，再去填充对象，做装修等 才能更加高效。
>
> 如果从建造第一层开始就先把第一层的房间, 客厅, 装修等弄好后再去建第二层，就不合适。







系统基于领域驱动开发的

> 比如说一个电商分有下面几层
>
> - 支付
>   - 支付对账（领域内的子域）
>   - 支付风控（领域内的子域）
> - 订单
>   - 订单搜索
>   - 订单管理
> - 商品
> - 仓储

## DDD的落地

![image-20201123201613516](http://guxiangflyimagebucket.oss-cn-beijing.aliyuncs.com/img/image-20201123201613516.png)



- User interface  是用户界面
  - 界面展示
- Application  Layer 应用服务层 （主要完成对 Domain的调用）
  - 请求转发
  - 跨领域问题 这里不包含任何领域的逻辑
- Domain Layer  核心-领域层
  - 体系架构基于领域驱动的（领域一旦确认了，就会驱动代码的设计）
  - 内容含有  数据/业务
- infrastructure Layer  基础层   Common-Utility 这些
  - 数据操作
  - 数据存储
  - 常用帮助类
  - 数据验证







领域划分：

- 约束领域
  - 聚合根 aggregateRoot ， 领域根，将领域有一个边界
  -  



<img src="http://guxiangflyimagebucket.oss-cn-beijing.aliyuncs.com/img/image-20201123205429335.png" alt="image-20201123205429335" style="zoom: 50%;" />

- - 实体里不仅包含属性，还包括关系，  类似我们一个用户