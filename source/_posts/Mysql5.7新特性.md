---
title: MySQL5.7 新特性
date: 2017-3-11 23:09:04
tags: [数据库,mysql]

---


### MySQL5.7 之前
```
scripts/mysql_install_db\
   --datadir=/data/sql_data \
   --user=mysql --basedir=/home/mysql
```
### mySQL5.7之后
```
bin/mysqld --initialize --user=mysql\
          --basedir =/home/mysql\
		  --datadir = /home/mysql/data
```

mysqld 是mysql的守护进程

初始化生成数据库后 会生成默认的数据库的密码


## mysql5.7 支持json数据类型

mysql5.7之前，我们只能 存入varchar或者 text等字符类型的列中存储json字符串，再在程序中使用json字符串。

5.7后 提供了 json_type(),json_object(),json_merge()

这个里面存储的是一个json数组
```
create table t1(jdoc JSON);

insert into t1(jdoc) VALUES (json_array('guxiang','man'));
```