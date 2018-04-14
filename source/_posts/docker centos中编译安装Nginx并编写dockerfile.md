---
title: docker centos中编译安装Nginx并编写dockerfile
date: 2017-9-3 23:00:04
tags: [docker,运维,Nginx]

---

## 首先yum安装一些必要的命令
```
yum install -y wget gcc gcc-c++ make openssl-devel
```

## Nginx需要依赖pcre
[pcre下载地址:ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/](ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/)

[nginx下载地址 http://nginx.org/en/download.html](http://nginx.org/en/download.html)


这个链接可以下载pcre

```

wget ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-8.38.tar.gz

wget http://nginx.org/download/nginx-1.13.5.tar.gz  （下载Nginx）
```

## 都移动到/usr/local/src目录下
```
mv *.gz /usr/local/src
```

```
cd  /usr/local/src/

tar zxf nginx-1.13.5.tar.gz 

tar zxf pcre-8.38.tar.gz
```


```
cd nginx-1.13.5

useradd -s /sbin/nologin -M www

 ./configure --prefix=/usr/local/nginx --user=www --group=www  --with-http_ssl_module  
 --with-http_stub_status_module --with-pcre=/usr/local/src/pcre-8.38

install 

make
```

## 配置Nginx 前台访问
```
 vi /usr/local/nginx/conf/nginx.conf
首行添加
daemon off
```


![image.png](http://upload-images.jianshu.io/upload_images/6406935-792008e984f465e4.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

## 提交
```
 docker commit  -m "v2" 50a  guxiangfly/mycentosnginx:v2 
```
## 启动
```
docker run -d -p 92:80 guxiangfly/mycentosnginx:v2 /usr/local/nginx/sbin/nginx
```



## 编写dockerfile
```

wget ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-8.38.tar.gz

wget http://nginx.org/download/nginx-1.13.5.tar.gz  （下载Nginx）
```

```
# This is my first Dockerfile (注意：文件名Dockerfile 要大写)
# Version 1.0
# Author :guxiang

#Base images
FROM centos

#MAINTAINER
MAINTAINER  guxiang
 
#ADD
 
ADD pcre-8.38.tar.gz  /usr/local/src
ADD nginx-1.13.5.tar.gz  /usr/local/src
 
#RUN
RUN yum install -y wget gcc gcc-c++ make openssl-devel
RUN useradd -s /sbin/nologin -M www
 
#WORKDIR （workdir 功能等价于cd 只是dockerfile中不方便写cd 找的替代）
WORKDIR /usr/local/src/nginx-1.13.5

RUN  ./configure --prefix=/usr/local/nginx --user=www --group=www  --with-http_ssl_module  --with-http_stub_status_module --with-pcre=/usr/local/src/pcre-8.38 && make && make install


RUN echo "daemon.off;" >> /usr/local/nginx/conf/nginx.conf

# ENV命令 添加路径进入环境变量
ENV PATH /usr/local/nginx/sbin:$PATH

#指定内部映射访问的端口
EXPOSE 80

# 执行命令
CMD ["nginx"]
```

```
docker build -t niginx-file:v1 .
```

docker每一步的构建过程 都会将结果提交为镜像
所以docker的构建镜像过程会非常聪明  
他会将之前的镜像构建为缓存
我们再次构建时
会发现有
```
using cache
```
的字样 
这个代表我们使用了缓存构建镜像
```

docker build -t niginx-file:v1 --no-cache .  
```