---
title: docker容器的启动与进入
date: 2017-9-2 23:00:04
tags: [docker,运维,Linux]

---

## install docker in Ubuntu
```
1 apt-get update  确保最新的apt-get

2 apt-get install -y docker.io  全局安装docker 这是使用系统自带的docker 安装包

可以手动指定安装包
 curl -s https://get.docker.com|sh

3 docker version 查看版本

4 docker images  查看本机的容器个数

```
## 国内有阿里云的docker hub
## [https://dev.aliyun.com/list.html](https://dev.aliyun.com/list.html "https://dev.aliyun.com/list.html")

```
5. 拉取docker 阿里云的镜像

docker pull registry.cn-beijing.aliyuncs.com/opendcp/nginx

6. 前台启动
docker run -it   c8c29d842c09

7. 后台启动 容器
docker run  -d   c8c29d842c09

8. 进入容器内部

docker exec -it  容器ID  bash   #注意，容器ID 和 镜像ID不一样

```

1、更新epel第三方软件库，否则可能会报错：No package docker available
```
sudo yum install epel-release
```
2、之后我们可以运行
```
sudo yum install -y docker-io
```
完成 docker在 centos上的安装

我们可以通过
```
/etc/init.d/docker start  （centos6使用）
service docker start （centos7使用）

-- centos7 设置开机启动
systemctl start docker.service
systemctl enable docker.service
systemctl grep docker 查看docker进程的状态
```
启动docker

![image.png](http://upload-images.jianshu.io/upload_images/6406935-19ed7f25be221903.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

这个代表docker启动完成

docker有一个类似于maven仓库功能的东西，形式类似于GitHub，里面放了很多的镜像
我们只需要使用命令下载
我们可以通过 
```
docker search  youimagename
```
来看网上的镜像

![image.png](http://upload-images.jianshu.io/upload_images/6406935-496395c531beb737.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

可以通过 
```
docker pull youimagename  
```
这种方式实现下载

可以通过 
```
docker images
```
查看本机所拥有的所有镜像

![image.png](http://upload-images.jianshu.io/upload_images/6406935-3f2c3dbe40fce074.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

这是 通过docker
![image.png](http://upload-images.jianshu.io/upload_images/6406935-e11a0344c19ea07e.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

我们可以通过命令进入docker容器
```
docker run --name guxiangcentos -i -t (也可以写成-it)  centos /bin/bash
```

![image.png](http://upload-images.jianshu.io/upload_images/6406935-b16c85da9b76713c.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

有三个命令常用：

-  -i 代表的意思是 让容器的输入终端保持打开的状态1240)

- -t 代表开启一个伪终端TTY 绑定到容器上1240)

- -d 代表在后天启用

我们来解析一下这句话
首先
这个命令会先检查 当前系统是否含有centos的镜像，如果没有 会自动 docker pull centos 
然后使用这个 centos 镜像 启动一个容器， 并且会自动为这个容器分配一个文件系统，将这个文件系统放在镜像的上一层，让他可写。
并且，会自动分配一个IP地址， centos 这个镜像中没有 ifconfig 命令
使用
```
ip ad li     #注意 centos6 下无用，centos7 可用
```
这个命令 可以查看

之后，docker 会运行一个 用户指定的名利  
这里就是  /bin/bash 
当运行的这个命令退出后，docker容器也就退出了


```
docker ps -a   可以查看所有运行过的容器
```
![image.png](http://upload-images.jianshu.io/upload_images/6406935-d3b2f3da14758eb1.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

我们可以使用 
```
 docker start   06c0c4ff3136    
```
来启动镜像，但是这种方法 启动后就会被关闭

我们可以使用 
```
docker run -d  -P --name  mycentos  centos
```
这个命令来将 docker 在后台开启

我们本来可用通过
```
docker attach CONTAINERID    有bug 不推荐
```
来进入 但是 有bug

我们也可以用
```
docker inspect --format "{{.State.Pid}}"   name或者CONTAINERID  （已经不推荐）

nsenter --target 返回的PID --mount --uts --ipc --net --pid       （已经不推荐）

docker exec -it  name或者CONTAINERID  /bin/bash  （推荐的）

```


![image.png](http://upload-images.jianshu.io/upload_images/6406935-15480445b63d5469.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


