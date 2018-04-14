---
title: Oracle 部署与使用
date: 2017-10-5 23:00:04
tags: [docker,Oracle]

---
## 另一篇博客也不差
```
http://blog.csdn.net/zhousenshan/article/details/53072537
```

## 在docker中部署 oracle

我们部署 oracle 中的阿里云docker镜像

我先给出阿里云docker镜像中的[地址](https://dev.aliyun.com/detail.html?spm=5176.1972343.2.2.FQq8yi&repoId=1969)
```
https://dev.aliyun.com/detail.html?spm=5176.1972343.2.2.FQq8yi&repoId=1969
```

### 无需先pull 直接可启动 会自动pull
```
docker run -d -p 1521:1521 --name oracle_11g registry.aliyuncs.com/helowin/oracle_11g
```

### 进入容器
```
docker exec -it 容器ID /bin/bash
```

### 加载环境变量 
```
 source /home/oracle/.bash_profile
```

### 进入系统
``` 

connect /as sysdba 
```

这样可以进入系统进行随意的操作

#### 演示创建一个用户名和密码为 test test 并分配权限的操作

```
create user test identified by test;

grant connect,resource,dba to test;
```

#### 也可更改用户名密码  用户hr 密码为 hr
```sql
alter user hr identified by hr;
````


#### 连接应该如此

```
HOST : 127.0.0.1 就是你的IP 
SID :  helowin
user： test
password： test  #之前分配的用户名密码

```


