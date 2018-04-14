---
title: Vmware的一些设置
date: 2017-7-27 20:09:04
tags: [工具使用]

---
Vmware的一些设置

## move还是Copy

我们一般选择 move

![image.png](http://upload-images.jianshu.io/upload_images/6406935-39e656a52b8f36e9.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

关于这种问题，我们一般选择是move
因为如果选择拷贝过来的，那么Vmware的虚拟网关就会认为我这个电脑上另外还有一个与这台电脑一模一样的linux虚拟机，于是Vmware就会去linux中重新生成一块虚拟网卡给它，那么原来那块就会废掉 ，防止Vmware的网关 连到了两个相同的虚拟机上。  
  如果是 复制的 那么新生成的网卡生效，那就是 eth0网卡过期，eth1网卡生效。
 解压移动过来的虚拟机中就会多一个网卡，一般我们移动过来的就选移动，复制过来的，但是以前的也不想用了也选移动。





## 设置虚拟机IP为固定的

### 首先改为NAT 模式联网

![image.png](http://upload-images.jianshu.io/upload_images/6406935-4db1f1d9ed8f78fe.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)



![image.png](http://upload-images.jianshu.io/upload_images/6406935-38a1b799bf53a3da.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)



![image.png](http://upload-images.jianshu.io/upload_images/6406935-3cf85a0a11204e90.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


## 修改域名的方式
```
sudo hostname guxianghadoop1
```
然后需要重新登录


##  FTP传输
```
FTP 是通过21端口去链接的 需要装FTP服务
SFTP 是通过22端口  SSH去链接的
```