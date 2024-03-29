---

title: Linux Shell
date: 2017-11-11 13:09:04
tags: [JVM,java]

---
# 1、Linux Top有哪些重要参数值得关注，这些参数有什么具体含义？

# **参考答案：**

 Linux的top命令详解见http://www.2cto.com/os/201209/157960.html

**解题思路：**不同水平的面试人员有不同层次的理解，面试官应视其回答情况酌情给分

**考察点：**Linux运行情况的查看、top命令的使用熟练程度

**分类：**Linux基本操作{校招，社招都可以用}

**难度分级：**P4

## 2、Linux上用什么命令看在线日志？

**参考答案：**

 Linux 日志都以明文形式存储，所以用户不需要特殊的工具就可以搜索和阅读它们。

还可以编写脚本，来扫描这些日志，并基于它们的内容去自动执行某些功能。

Linux 日志存储在 /var/log 目录中。这里有几个由系统维护的日志文件，但其他服务和程序也可能会把它们的日志放在这里。

大多数日志只有root账户才可以读，不过修改文件的访问权限就可以让其他人可读。

可以用cat、head、tail等查看，用grep搜索过滤，用cut取字段（列数据），更高级的可以用awk和sed重排日志。

**解题思路：**日志文件的格式多是文本文件，从文本文件的处理方式的考虑

**考察点：**日志的存储，Linux查看、搜索文本文件的方式，坑在直接用VI看，如果稍有经验的人这么做，那么基本可以送走了

**分类：**Linux基本操作{校招，社招都可以用}

**难度分级：**P4

## 3、如何输出时间到time.txt文件？

**参考答案：**

date >> time.txt

**解题思路：**重定向的应用

**考察点：** Linux命令输出重定向、简单的Linux命令

**分类：**Linux基本操作{校招，社招都可以用}

**难度分级：**P4

## 4、有一个文本文件source.txt，每行有个字符串，请使用shell命令查找包含“beijing”的行，并将结果保存到文件result.txt中 

**参考答案：** 

grep -i beijing source.txt > result.txt

**解题思路：**用grep来对文本文件搜索，注意-i选项用来忽略大小写

**考察点：** Linux命令输出重定向、grep简单应用

**分类：**Linux基本操作{校招，社招都可以用}

**难度分级：**P4

## 5、查看当前TCP/IP连接的状态和对应的个数？

**参考答案：**

netstat -n | awk '/^tcp/ {++S[$NF]} END {for(a in S) print a, S[a]}'

**解题思路：**用netstat来查看连接和端口，用awk进行统计

**考察点：** netstat和awk的应用

**分类：**Linux组合操作{校招，社招都可以用}

**难度分级：**P5

## 7、分析apache访问日志，找出访问页面的次数排名前100的ip？

**参考答案：**

awk '{print $1}' localhost_access_log.txt | sort | uniq -c | sort -n -k 1 -r | head -n 100

**解题思路：**用awk或者cut来取文本中的第一列，再用sort排序，uniq去重，数字排序，最后输出前100名

**考察点：** awk、sort、head等文本处理工具组合的应用

**分类：**Linux组合操作{社招}

**难度分级：**P5

## 8、符号链接(symbolic link)和硬链接的区别？

**参考答案：** 

硬链接(hard links): 为文件创建了额外的条目。使用时，与文件没有区别；删除时，只会删除链接，不会删除文件；
硬链接的局限性: 1. 不能引用自身文件系统以外的文件，即不能引用其他分区的文件；2. 无法引用目录；
操作: ln file link, 只能link文件；

符号链接(symbolic links): 克服硬链接的局限性，类似于快捷方式，使用与硬链接相同. 
如果先删除文件，则会成为坏链接(broken)，ls会以不同颜色(Ubuntu, 红色)显示;
操作: ln -s item link，可以link文件和目录； 

**解题思路：**hard link和soft link的区别，结合i-node的知识

**考察点：** i-node，文件链接

**分类：**Linux文件系统基本概念{校招，社招}

**难度分级：**P4