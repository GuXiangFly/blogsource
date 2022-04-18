---
title: Linux 常用命令
date: 2017-6-11 13:19:04
tags: [Linux]

---



####  查询磁盘空间

 **df**    (display free disk space) 

```
df -lh  
```

#### 查询文件以及文件

**du**   (display disk usage statistics)

```
du -h
```

#### 查询磁盘IO性能

**iostat -xdk 2 3** 

```
iostat -xdk 2 3     iostat 每2秒刷新一次，刷新3次
```

- r/s   w/s 越大，代表读写比较高

- %util   越大代表读写高 

![](https://i.loli.net/2020/03/01/8QX4mOHfecVvMiK.png)

一般来说如果磁盘IO比较高， 多数是SQL需要调优了。



#### CPU性能

**top**



**pidstat**

```
pidstat -u 1 -p 进程号 （这个一般配合 ps -ef|grep java  来查看进程号来使用）
```







#### Top 使用

- **CPU查看**    

  - 按1   （看CPU 具体哪个比较慢）

  - 看 id  (idle)   空闲率  CPU 的id越高，性能越好
  - 查看 load average （分别代表系统，1分钟，5分钟，15分钟 的系统平均负载率）
    - （0.04 + 0.08 + 0.03）/3 * 100%      如果 大于60% 代表负载过高，  如果大于80% 代表系统快挂了
  - top 退出 q
  - uptime (低配版 top命令)

  ![](https://i.loli.net/2020/03/01/Djz5KhxnguqaLCe.png)

- **交互命令**
  
  - P    - 按cpu使用的效率来排序
  - M   - 以内存使用率排序
  - N   - 按PID排序
  - q    - 退出top

##### load average 的含义

>  平均负载(load average)是指**系统的运行队列的平均利用率**，也可以认为是可运行**进程**的平均数。

如果loadavg  = 1 ，代表是现在系统上有一颗CPU满负荷运行

-------

以路况为例， **单核CPU、单车道** 情况如下：

<img src="/Users/didi/Library/Application Support/typora-user-images/image-20220112113820956.png" alt="image-20220112113820956" style="zoom:50%;" />

- 0.00-1.00 之间的数字表示此时路况非常良好，没有拥堵，车辆可以毫无阻碍地通过。
  - (1代表虽然车间距较小，但是没有车排队，没有任务需要排队等待)
- 1.00 表示道路还算正常，但有可能会恶化并造成拥堵。此时系统已经没有多余的资源了，管理员需要进行优化。
- 1.00-*** 表示路况不太好了，如果到达2.00表示有桥上车辆一倍数目的车辆正在等待。这种情况你必须进行检查了。

----------

多核CPU - 多车道 情况如下：

<img src="/Users/didi/Library/Application Support/typora-user-images/image-20220112114204492.png" alt="image-20220112114204492" style="zoom:50%;" />

多核CPU的话，满负荷状态的数字为 "1.00 * CPU核数"，即双核CPU为2.00，四核CPU为4.00。 

----------------------

一般的进程需要消耗CPU、内存、磁盘I/O、网络I/O等资源，在这种情况下，平均负载就不是单独指的CPU使用情况。即内存、磁盘、网络等因素也可以影响系统的平均负载值。  在单核处理器中，平均负载值为1或者小于1的时候，系统处理进程会非常轻松，即负载很低。**当达到3的时候，就会显得很忙**，达到5或者8的时候就不能很好的处理进程了（其中5和8目前还是个争议的阈值，为了保守起见，建议选择低的）。

#### free使用

查看内存信息使用free 

- free -m （较好的使用方式）
- 





#### vmstat -n 2 3

>  一般vmstat工具的使用是通过两个数字参数来完成，第一个参数是采样的时间间隔，单位为秒， 第二个参数是采样的次数

![image-20211215152621037](https://gitee.com/guxiangfly/blogimage/raw/master/img/image-20211215152621037.png)

- Procs

  - r: 运行和等待CPU时间片的进程数，原则是1和的cpu运行进程数不要超过2，整个系统的运行队列不要超过总核数的2倍
  - b: 等待资源的进程数，比如正在等待磁盘I/O、网络I/O

- cpu

  - us:用户进程消耗CPU时间的百分比

  ![image-20211215153100937](https://gitee.com/guxiangfly/blogimage/raw/master/img/image-20211215153100937.png)

如何查看整机性能：

首行会有机器cpu和内存的百分比占用率。







sort
sort 命令对 File 参数指定的文件中的行排序，并将结果写到标准输出。如果 File 参数指定多个文件，那么 sort 命令将这些文件连接起来，并当作一个文件进行排序。

sort语法

 ```
[root@www ~]# sort [-fbMnrtuk] [file or stdin]
选项与参数：
-f  ：忽略大小写的差异，例如 A 与 a 视为编码相同；
-b  ：忽略最前面的空格符部分；
-M  ：以月份的名字来排序，例如 JAN, DEC 等等的排序方法；
-n  ：使用『纯数字』进行排序(默认是以文字型态来排序的)；
-r  ：反向排序；
-u  ：就是 uniq ，相同的数据中，仅出现一行代表；
-t  ：分隔符，默认是用 [tab] 键来分隔；
-k  ：以那个区间 (field) 来进行排序的意思


对/etc/passwd 的账号进行排序
[root@www ~]# cat /etc/passwd | sort
adm:x:3:4:adm:/var/adm:/sbin/nologin
apache:x:48:48:Apache:/var/www:/sbin/nologin
bin:x:1:1:bin:/bin:/sbin/nologin
daemon:x:2:2:daemon:/sbin:/sbin/nologin
sort 是默认以第一个数据来排序，而且默认是以字符串形式来排序,所以由字母 a 开始升序排序。



/etc/passwd 内容是以 : 来分隔的，我想以第三栏来排序，该如何

[root@www ~]# cat /etc/passwd | sort -t ':' -k 3
root:x:0:0:root:/root:/bin/bash
uucp:x:10:14:uucp:/var/spool/uucp:/sbin/nologin
operator:x:11:0:operator:/root:/sbin/nologin
bin:x:1:1:bin:/bin:/sbin/nologin
games:x:12:100:games:/usr/games:/sbin/nologin
默认是以字符串来排序的，如果想要使用数字排序：

cat /etc/passwd | sort -t ':' -k 3n
root:x:0:0:root:/root:/bin/bash
daemon:x:1:1:daemon:/usr/sbin:/bin/sh
bin:x:2:2:bin:/bin:/bin/sh
默认是升序排序，如果要倒序排序，如下

cat /etc/passwd | sort -t ':' -k 3nr
nobody:x:65534:65534:nobody:/nonexistent:/bin/sh
ntp:x:106:113::/home/ntp:/bin/false
messagebus:x:105:109::/var/run/dbus:/bin/false
sshd:x:104:65534::/var/run/sshd:/usr/sbin/nologin


如果要对/etc/passwd,先以第六个域的第2个字符到第4个字符进行正向排序，再基于第一个域进行反向排序。

cat /etc/passwd |  sort -t':' -k 6.2,6.4 -k 1r
sync:x:4:65534:sync:/bin:/bin/sync
proxy:x:13:13:proxy:/bin:/bin/sh
bin:x:2:2:bin:/bin:/bin/sh
sys:x:3:3:sys:/dev:/bin/sh


查看/etc/passwd有多少个shell:对/etc/passwd的第七个域进行排序，然后去重:

cat /etc/passwd |  sort -t':' -k 7 -u
root:x:0:0:root:/root:/bin/bash
syslog:x:101:102::/home/syslog:/bin/false
daemon:x:1:1:daemon:/usr/sbin:/bin/sh
sync:x:4:65534:sync:/bin:/bin/sync
sshd:x:104:65534::/var/run/sshd:/usr/sbin/nologin


uniq
 uniq命令可以去除排序过的文件中的重复行，因此uniq经常和sort合用。也就是说，为了使uniq起作用，所有的重复行必须是相邻的。

uniq语法

[root@www ~]# uniq [-icu]
选项与参数：
-i   ：忽略大小写字符的不同；
-c  ：进行计数
-u  ：只显示唯一的行


testfile的内容如下


cat testfile
hello
world
friend
hello
world
hello



直接删除未经排序的文件，将会发现没有任何行被删除


#uniq testfile
hello
world
friend
hello
world
hello



排序文件，默认是去重

#cat testfile | sort |uniq
friend
hello
world


排序之后删除了重复行，同时在行首位置输出该行重复的次数

#sort testfile | uniq -c
1 friend
3 hello
2 world


仅显示存在重复的行，并在行首显示该行重复的次数

#sort testfile | uniq -dc
3 hello
2 world


仅显示不重复的行

sort testfile | uniq -u
friend


cut
cut命令可以从一个文本文件或者文本流中提取文本列。

cut语法

[root@www ~]# cut -d'分隔字符' -f fields <==用于有特定分隔字符
[root@www ~]# cut -c 字符区间            <==用于排列整齐的信息
选项与参数：
-d  ：后面接分隔字符。与 -f 一起使用；
-f  ：依据 -d 的分隔字符将一段信息分割成为数段，用 -f 取出第几段的意思；
-c  ：以字符 (characters) 的单位取出固定字符区间；


PATH 变量如下

[root@www ~]# echo $PATH
/bin:/usr/bin:/sbin:/usr/sbin:/usr/local/bin:/usr/X11R6/bin:/usr/games
# 1 | 2       | 3   | 4       | 5            | 6            | 7


将 PATH 变量取出，我要找出第五个路径。

#echo $PATH | cut -d ':' -f 5
/usr/local/bin


将 PATH 变量取出，我要找出第三和第五个路径。

#echo $PATH | cut -d ':' -f 3,5
/sbin:/usr/local/bin


将 PATH 变量取出，我要找出第三到最后一个路径。

echo $PATH | cut -d ':' -f 3-
/sbin:/usr/sbin:/usr/local/bin:/usr/X11R6/bin:/usr/games


将 PATH 变量取出，我要找出第一到第三个路径。

#echo $PATH | cut -d ':' -f 1-3
/bin:/usr/bin:/sbin:



将 PATH 变量取出，我要找出第一到第三，还有第五个路径。

echo $PATH | cut -d ':' -f 1-3,5
/bin:/usr/bin:/sbin:/usr/local/bin


实用例子:只显示/etc/passwd的用户和shell

#cat /etc/passwd | cut -d ':' -f 1,7
root:/bin/bash
daemon:/bin/sh
bin:/bin/sh


 wc
统计文件里面有多少单词，多少行，多少字符。

wc语法

[root@www ~]# wc [-lwm]
选项与参数：
-l  ：仅列出行；
-w  ：仅列出多少字(英文单字)；
-m  ：多少字符；


默认使用wc统计/etc/passwd

#wc /etc/passwd
40   45 1719 /etc/passwd
40是行数，45是单词数，1719是字节数



wc的命令比较简单使用，每个参数使用如下：


#wc -l /etc/passwd   #统计行数，在对记录数时，很常用
40 /etc/passwd       #表示系统有40个账户

#wc -w /etc/passwd  #统计单词出现次数
45 /etc/passwd

#wc -m /etc/passwd  #统计文件的字符数
1719



参考 http://vbird.dic.ksu.edu.tw/linux_basic/0320bash_6.php#pipe_2

      http://www.cnblogs.com/stephen-liu74/archive/2011/11/10/2240461.html
 ```