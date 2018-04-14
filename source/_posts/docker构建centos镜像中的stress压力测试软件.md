---
title: docker构建centos镜像中的stress压力测试软件
date: 2017-9-5 23:00:04
tags: [docker,运维]

---


docker构建centos镜像中的stress压力测试软件

## 先拉取一个阿里的docker 源
```
wget  http://mirrors.aliyun.com/repo/epel-6.repo
```

```

ROM centos
ADD epel-6.repo /etc/yum.repos.d/
RUN yum -y install stress && yum clean all
ENTRYPOINT ["stress"]                          
```


新建一个控制台
然后使用
```
docker run -it --rm stress --cpu 1

 (占用一个cpu) 
--rm 代表停止后自动删除这个容器
```
在新的控制台
可以使用top命令查看详情
![image.png](http://upload-images.jianshu.io/upload_images/6406935-f046b892154267e1.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


stress 的使用
```
docker run -it --rm -m 128m stress --vm 1 --vm-bytes 256m --vm-hang 0
```

这个代表 给docker容器分配128m的空间   然后让stress malloc出256m的内存

新版本这样内存溢出就会直接退出