---
title: Oracle技术
date: 2017-9-27 20:09:04
tags: [Oralce]

---
Oracle技术


## oracle 用户操作

#### cmd中使用管理员权限运行 链接数据库
``` sql
sqlplus system/oracle@101.132.177.62:1522/XE;
```

#### 修改密码 passw命令
```
passw
旧密码
新密码
```

#### 文件操作命令
```SQL
(1)start和@
说明：运行sql脚本
案例：sq1>@d:\a.sq1 或者 sql>START  d:\a.sql
(3)edit
说明：该命令可以编辑指定的sq[脚本
案例：sql>edit d:\a.sq1
（4）spool
说明：该命令可以将sq恤p№s屏幕上的内容输出到指定
件中去．
案例：sql>spool d:\b.sql并输入sql>spool off

```

#### 用户   角色，口令 来管理权限
``` sql
这是创建用户
create user guxiang IDENTIFIED  by guxiang;

这是将connect角色 分配给 guxiang
grant CONNECT TO guxiang;


## 角色

connect只有链接数据库的权限
resource 表示可有建表的权限

grant CONNECT,resource TO guxiang;


* 希望 xiaoming 用户可以去查询 scott 的 emp 表
     grant select on emp to xiaoming
* 希望 xiaoming 用户可以去修改 scott 的 emp 表
     grant update on emp to xiaoming
* 希望 xiaoming 用户可以去修改/删除，查询，添加 scott 的 emp 表
     grant all on emp to xiaoming
* scott 希望收回 xiaoming 对 emp 表的查询权限
     revoke select on emp from xiaoming
*  希望 xiaoming 用户可以去查询 scott 的 emp 表/还希望 xiaoming 可以把这个 权限继续给别人。  --如果是对象权限，就加入 with grant option
     grant select on emp to xiaoming with grant option


* 希望 xiaoming 用户可以去查询 scott 的 emp 表/还希望 xiaoming 可以把这个 权限继续给别人。

--如果是对象权限，就加入 with grant option
  grant select on emp to xiaoming with grant option

--如果是系统权限。  system 给 xiaoming 权限时：
  grant connect to xiaoming with admin option



## 口令

概述：如果希望用户在修改密码时，不能使用以前使用过的密码，可使用口令历史，
这样 oracle 就会将口令修改的信息存放到数据字典中，这样当用户修改密 码时，
oracle 就会对新旧密码进行比较，当发现新旧密码一样时，就提示用户重新输入密码。

 例子：
 1）建立 profile  SQL>create profile password_history limit
 password_life_time 10 password_grace_time 2 password_reuse_time 10
   password_reuse_time
  //指定口令可重用时间即 10 天后就可以重用

   2）分配给某个用户
alter user tea  profile lock_account;
 删除 profile
概述：当不需要某个 profile 文件时，可以删除该文件。
\SQL> drop profile password_history 【casade】
注意：文件删除后，用这个文件去约束的那些用户通通也都被释放了。。  加了 casade，就会把级联的相关东西也给删除掉
    3) 解锁用户
    alter user  guxiang  account unlock
```

#### 表空间的概念
```
oracle默认划分了很多表空间  作用类似于 windows上的 C盘 D盘 E盘
我们可以将表 存放在不同表空间中
```

#### 增删改 表
```sql
怎样创建表   建表
--学生表  create table student (    ---表名
xh       number(4),   --学号
xm    varchar2(20),   --姓名
sex      char(2),     --性别
birthday date,         --出生日期
sal      number(7,2)   --奖学金
);
--班级表
CREATE TABLE class(
      classId NUMBER(2),
      cName VARCHAR2(40)
);


  修改表   添加一个字段
 SQL>ALTER TABLE student add (classId NUMBER(2));
  修改一个字段的长度
  SQL>ALTER TABLE student MODIFY (xm VARCHAR2(30));

  修改字段的类型/或是名字（不能有数据 有数据就不能做） 不建议做
  SQL>ALTER TABLE student modify (xm CHAR(30));

  删除一个字段  不建议做(删了之后，顺序就变了。加就没问题，应为是加在后 面) SQL>ALTER TABLE student DROP COLUMN sal;

  修改表的名字   很少有这种需求
  SQL>RENAME student TO stu;

  删除表
  SQL>DROP TABLE student;
```

#### 改  数据
``` sql
修改数据
修改一个字段
UPDATE student SET sex = '女' WHERE xh = 'A001';
修改多个字段
```

####