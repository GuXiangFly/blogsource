---
title: mysql中的函数
date: 2017-6-19 21:09:04
tags: [数据库]
---
# 函数
#### 函数: 将一段代码块封装到一个结构中, 在需要执行代码块的时候, 调用结构执行即可.(代码复用)

函数分为两类: 系统函数和自定义函数


## 系统函数
系统定义好的函数, 直接调用即可.
**任何函数都有返回值, 因此函数的调用是通过select调用.**

Mysql中,字符串的基本操作单位(最常见的是字符)
Substring: 字符串截取(字符为单位)
 
char_length: 字符长度
Length: 字节长度
 
Instr: 判断字符串是否在某个具体的字符串中存在, 存在返回位置
 
Lpad: 左填充, 将字符串按照某个指定的填充方式,填充到指定长度(字符)
 
Insert: 替换,找到目标位置,指定长度的字符串,替换成目标字符串
 
Strcmp: compare,字符串比较
 

## 自定义函数
函数要素: 
- 函数名
- 参数列表(形参和实参)
- 返回值
- 函数体(作用域)

创建函数

### 创建语法

```sql
Create function  函数名([形参列表]) returns 数据类型 -- 规定要返回的数据类型
Begin
-- 函数体
-- 返回值: return 类型(指定数据类型);
End
```

### 定义函数


自定义函数与系统函数的调用方式是一样: select 函数名([实参列表]);
 

查看函数
查看所有函数: show function status [like ‘pattern’];
 

查看函数的创建语句: show create function 函数名;
 

修改函数&删除函数
函数只能先删除后新增,不能修改.

Drop function 函数名;
 

函数参数

参数分为两种: 定义时的参数叫形参, 调用时的参数叫实参(实参可以是数值也可以是变量)
形参: 要求必须指定数据类型
Function 函数名(形参名字 字段类型) returns 数据类型
 

在函数内部使用@定义的变量在函数外部也可以访问
 

作用域
Mysql中的作用域与js中的作用域完全一样
全局变量可以在任何地方使用; 局部变量只能在函数内部使用.

全局变量: 使用set关键字定义, 使用@符号标志
局部变量: 使用declare关键字声明, 没有@符号: 所有的局部变量的声明,必须在函数体开始之前


```sql
-- 修改语句结束符
delimiter %%

CREATE trigger before_order BEFORE  insert on my_order for EACH ROW
  BEGIN

    -- select 要写的语句  into  @变量名  这种语法 就是让我们不要显示 select 的结果
    SELECT inv
    FROM my_goods where id = new.g_id into @inv;

    IF @inv < new.g_number THEN
      -- 库存不够(暴力报错)
        insert INTO xxx VALUES (xxx);

    END IF ;

  END %%

DELIMITER ;
```

## 查看函数
查看所有函数: show function status [like ‘pattern’];
 

查看函数的创建语句: show create function 函数名;
 

## 修改函数&删除函数

函数只能先删除后新增,不能修改.

Drop function 函数名;


## 作用域
Mysql中的作用域与js中的作用域完全一样
全局变量可以在任何地方使用; 局部变量只能在函数内部使用.

在函数内部使用@定义的变量在函数外部也可以访问

- **全局变量**: **使用set关键字定义, 使用@符号标志**
- **局部变量**: **使用declare关键字声明, 没有@符号: 所有的局部变量的声明,必须在函数体开始之前**
- **任何变量 无论是全局的还是局部 在mysql中修改 都需要加 set 关键字**
```

DELIMITER $$
CREATE FUNCTION display2(int_1 int) RETURNS int
BEGIN
  -- 定义条件变量
  -- int_1 就是一个局部变量
  set @i = 1;
  set @res = 0;

  -- 循环求和
  while @i <= int_1 DO
    -- 求和: 任何变量要修改必须使用set关键字
    -- mysql中没有+=,没有++

    set @res = @res + @i;

    -- 修改循环变量
    set @i = @i + 1;


  END WHILE;

  RETURN @res;
END
$$

select display2(10);

select @res;

```