---
title: postgresql 存储过程
date: 2017-8-3 20:09:04
tags: [数据库]

---
# postgresql 存储过程


```sql 
Create or replace function 过程名(参数名 参数类型,…..) returns 返回值类型 as
 $body$

 //声明变量
 Declare
 变量名变量类型；
 如：
 flag Boolean;

 变量赋值方式（变量名类型 ：=值；）
 如：
 str  text :=值; / str  text;  str :=值；

 Begin
  函数体；

  return 变量名； //存储过程中的返回语句

 End;
 $body$
 Language plpgsql;
```



|子类型|标准名|描述|
| ------------- |:-------------:| ---------:|
|Smalll integer|Smallint|一个2字节的符号型整数，可以存储-32768到32767的数字|
|Integer|Int|一个4字节的符号型整数，可以存储-2147483648到2147473647的数字|
|Serial|--|和integer一样，除了它的值通常是由PostgreSQL自动输入的。

