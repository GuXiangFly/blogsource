---
title: linux中的进程
date: 2017-2-23 20:09:04
tags: [Linux]

---

linux中如果想再后台打开一个程序 那么命令后面加一个 &
例如
```
firefox &
```

查看后台的程序的命令
```
jobs
```


```
kill -9 %1
```


## 脱机管理
nohup 即使关掉窗口，程序在后台还是正常运行
```
nohup ping localhost &
```

## ps aux 的意义

```
ps aux
```
a --all 显示所有的进程
u --user  显示用户
x -- 显示详细信息

```
ps aux
可以替换为  ps -ex
```

查看 进程名字 PID，cpu使用率，内存大小 
```
ps -ex -o comm,pid,%cpu,%mem
```


## 杀死进程的几种方法

### 方法一
```
ps aux |grep ping     找到ping命令他的pid

kill -9 进程PID   通过pid杀死进程
```
### 方法二
```
pidof ping 直接能查出pid

再 kill -9 进程PID
```

### 方法三
```
killall -9 ping   只需要填写进程的名字
```

## top命令

资源信息实时刷新，默认3秒刷新一次

![image.png](http://upload-images.jianshu.io/upload_images/6406935-4529f0aa722f2131.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)