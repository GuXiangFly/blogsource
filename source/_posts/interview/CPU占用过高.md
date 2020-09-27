## CPU占用过高怎么排查

1.  top 找出CPU占用过高的进程 PID

2.  ```
   ps -mp 6902 -o THREAD,tid,time
   ```
通过ps -mp 进程ID  -o THREAD,tid,time  
命令查看进程id

![image-20200726124941985](https://gitee.com/guxiangfly/blogimage/raw/master/img/image-20200726124941985.png)

