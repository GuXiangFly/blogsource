---
title: Centos7与Centos6的区别
date: 2017-5-12 20:11:44
tags: [Linux]
---
> > 为了纪念一下我从 centos6 转来 centos7的一脸懵逼的情况。。特地转来一篇 不错的博文，希望小伙伴们不要再像我当初一样的懵逼了
> /(ㄒoㄒ)/~~ 来自：http://www.centoscn.com/CentOS/2014/1031/4035.html
> 
装机
--

首先是装机时，以前的rhel一系的（包括centos，fedora）选包都可以全选的，但现在是只能单选一项了，有子选项重复的；当装到选择分区时，centos7推荐的分区是xfs，而不是之前的ext（2，3，4）一系了；装机其他大致一样。


初次启动
----

装完机后，开机进系统的界面换了，乍一看以为是两个内核，原来有一个是rescue选择，而且按e后，会发现所有的grub.conf的信息全出来了，好不容易找到内核启动的地方，写了个 1（要进单用户模式），然后进了rescue模式。


字符界面
----

进系统后，是图形界面，想进字符界面，结果找到/etc/inittab，发现几乎是个空文件，文件中提示想改runlevel的话，可以把/lib/systemd/system/runlevel*.target  软连到 /etc/systemd/system/default.target下（当然考过来，覆盖也行），试了一下还行，能改到字符界面runlevel3。


配置网络和主机名
--------

然后，想配置网络，进/etc/sysconfig/network-script/一看，我靠，网卡改名了enp1s5，好有趣，配置完网络后改主机名， 到/etc/sysconfig/network去改名字，发现这个文件也是空的，按原6版本的去修改，重启后没效果，man了一下hostname， 发现7中改名要到/etc/hostname去改名字。


本地yum源和挂载
---------

接着，想配置一个本地yum源，配上后要挂光盘，手动挂上了，然后直接echo“mount ......”到rc.local中，毕竟是启动执行脚本，重启之后竟然没挂上，进去rc.local中看了一下，7中竟然要手动的把chmod +x rc.local, 是的，要手动加执行权限，难道我之前装的6以前的系统中这个都要手动加执行权限，我不记得啊！！！！ 当然，加了权限后，开机后启动执行了rc.local的mount命令。


LVM和xfs
-------

后来，想着装一个lvm玩玩，于是啊就分区，格式化（特意格式化为了xfs），pv，vg，lv一步一步，都没问题，然后想着放大，缩小，这时出问题了，执行resize2fs时，怎么一直报superblock什么的出错，这是怎么回事，然后man resize2fs一下，发现这命令只支持ext的文件系统，我艹，那我装系统是怎么是lvm的，这个问题我还没解决，应该有解决方法。


dhcp和服务
-------

接着，想着装一个dhcp玩玩，惊奇的发现所有dhcp的包装上之后，不能service dhcpd start，然后发现/etc/init.d/中竟然没一个dhcp类似的东西，毕竟6之前有dhcpd,dhcpd6,dhcrelay的，然后发现 /sbin/dhcpd有启动文件，难道，难道，以后的服务想service启，都要手动自己编？错了，是在/usr/lib/systemd/system/dhcpd.service,还要修改好多，然后加权限，执行service 服务  restart/stop。。。。。。可以，但是指向了systemctl  restart/start/stop   服务.service


iptables
--------

又发现iptables这次也不是作为一个服务在/etc/init.d/下面了，/sbin下有；

然后，然后，就没有然后了，或许，真的是或许，发现新东西，再在这个日志上更新吧，真的是或许。

对了，我还发现/etc/sysctl.conf也空了，想做个路由转发都要到/proc/sys/net下