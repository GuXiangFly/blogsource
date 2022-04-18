---
title:  CPU占用过高怎么排查
date: 2018-11-1 13:22:54
tags: [java]


---
## CPU占用过高怎么排查


1. top 找出CPU占用过高的进程 PID

   1.  使用 top -c 命令   然后按P
       1.  -c 在 command列显示完整的命令
       2.  按P 对CPU占用率进行排序

   <img src="http://guxiangflyimagebucket.oss-cn-beijing.aliyuncs.com/img/image-20201120192801212.png" alt="image-20201120192801212" style="zoom:67%;" />

2. 第二步：top  -Hp  41469     查看pid 内的具体线程

   <img src="http://guxiangflyimagebucket.oss-cn-beijing.aliyuncs.com/img/image-20201120203158484.png" alt="image-20201120203158484" style="zoom:50%;" />

3. 使用 printf "%x\n"  41604    将**线程id**转换为16进制        //**记得转换线程Id ，不是进程Id**/

   

4. jstack 41604 | grep '0x线程十六进制号'  -C5 --color     此命令查看线程堆栈

![image-20201120210356677](http://guxiangflyimagebucket.oss-cn-beijing.aliyuncs.com/img/image-20201120210356677.png)





jstack 36565 | grep '0x8ed5'  -C5 --color 





另一种方式查看

1. ```
   ps -mp 6902 -o THREAD,tid,time
   ```
   通过ps -mp 进程ID  -o THREAD,tid,time  
   命令查看进程id

![image-20200726124941985](http://guxiangflyimagebucket.oss-cn-beijing.aliyuncs.com/img/image-20200726124941985.png)









https://www.bilibili.com/video/BV1WE411p7yH?p=65







jstack -m 