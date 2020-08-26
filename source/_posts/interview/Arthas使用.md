---
title: arthas使用
date: 2020-04-11 13:09:04
tags: [java]
---

####  arthas 官方教程

https://alibaba.github.io/arthas/quick-start.html



#### 启动方式

```bash
wget https://alibaba.github.io/arthas/arthas-boot.jar
java -jar arthas-boot.jar
```





#### 基础命令

- pwd  查看路径 （arthas命令中没有 ls，可以通过pwd看到路径后，通过linux查看路径）
- cat    查看文件内容

- grep      

  ```
  sysprop | grep java  -n   #-n 显示行号
  ```

  

- cls   清除屏幕
- reset  重置类的增强，但是在arthas服务器关闭的时候，会自动重置所有的类
- session  查看单签的session

<img src="https://gitee.com/guxiangfly/blogimage/raw/master/img/image-20200624162639157.png" alt="image-20200624162639157" style="zoom:50%;" />

- quit   退出当前的arthas的session
- stop  将整个arthas服务关闭，退出全部session



- keymap   查看arthas快捷键

![image-20200624165223733](https://gitee.com/guxiangfly/blogimage/raw/master/img/image-20200624165223733.png)





- dashboard使用

![image-20200624193235914](https://gitee.com/guxiangfly/blogimage/raw/master/img/image-20200624193235914.png)

```

```



参数说明

- ID: Java级别的线程ID，注意这个ID不能跟jstack中的nativeID一一对应
- NAME: 线程名
- GROUP: 线程组名
- PRIORITY: 线程优先级, 1~10之间的数字，越大表示优先级越高
- STATE: 线程的状态
- CPU%: 线程消耗的cpu占比，采样100ms，将所有线程在这100ms内的cpu使用量求和，再算出每个线程的cpu使用占比。
- TIME: 线程运行总时间，数据格式为`分：秒`
- INTERRUPTED: 线程当前的中断位状态
- DAEMON: 是否是daemon线程

- Thread

##### 参数说明

| 参数名称 | 参数说明                              |
| -------- | ------------------------------------- |
| *id*     | 线程id                                |
| [n:]     | 指定最忙的前N个线程并打印堆栈         |
| [b]      | 找出当前阻塞其他线程的线程            |
| [i ``]   | 指定cpu占比统计的采样间隔，单位为毫秒 |





