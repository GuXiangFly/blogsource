---
title: mysql触发器
date: 2017-6-14 22:00:04
tags: [数据库]

---
# 触发器
 **触发器: trigger**, 事先为某张表绑定好一段代码 ,当表中的某些内容发生改变的时候(增删改)系统会自动触发代码,执行.

触发器: 事件类型, 触发时间, 触发对象
- 事件类型: 增删改, 三种类型insert,delete和update
- 触发时间: 前后: before和after
- 触发对象: 表中的每一条记录(行)

一张表中只能拥有一种触发时间的一种类型的触发器: 最多一张表能有6个触发器

创建触发器
在mysql高级结构中: 没有大括号,  都是用对应的字符符号代替

触发器基本语法
```sql
-- 临时修改语句结束符
Delimiter 自定义符号: 后续代码中只有碰到自定义符号才算结束
    
Create trigger 触发器名字 触发时间 事件类型 on 表名 for each row
Begin		-- 代表左大括号: 开始
-- 里面就是触发器的内容: 每行内容都必须使用语句结束符: 分号
End			-- 代表右带括号: 结束
-- 语句结束符
自定义符号
    
-- 将临时修改修正过来
Delimiter  ;
```


```sql
delimiter $$
-- 触发器
CREATE TRIGGER after_order AFTER INSERT on my_order for EACH ROW
BEGIN
	-- 触发器内容开始
		UPDATE my_goods set inv = inv -1  WHERE id = 2;
		
end 
-- 结束触发器
$$

delimiter ;
```

## 查看触发器

查看所有触发器或者模糊匹配
```
Show triggers [like ‘pattern’];
```

可以查看触发器创建语句
```
Show create trigger 触发器名字;
``` 

所有的触发器都会保存一张表中: Information_schema.triggers
 

使用触发器
触发器: 不需要手动调用, 而是当某种情况发生时会自动触发.(订单里面插入记录之后)
 

## 修改触发器&删除触发器
触发器不能修改,只能先删除,后新增.
```
Drop trigger 触发器名字;
``` 

## 触发器记录
触发器记录: 不管触发器是否触发了,只要当某种操作准备执行, 系统就会将当前要操作的记录的当前状态和即将执行之后新的状态给分别保留下来, 供触发器使用: 其中,
-  要操作的当前状态保存到old中
-  操作之后的可能形态保存给new.

Old代表的是旧记录,new代表的是新记录
**删除的时候是没有new的**; **插入的时候是没有old**

Old和new都是代表记录本身: 任何一条记录除了有数据, 还有字段名字.
使用方式: old.字段名 / new.字段名(new代表的是假设发生之后的结果)
 

查看触发器的效果
 

如果触发器内部只有一条要执行的SQL指令, 可以省略大括号(begin和end)
```
Create trigger 触发器名字 触发时间 事件类型 on 表名 for each row
一条SQL指令;
```

触发器: 可以很好的协调表内部的数据处理顺序和关系. 但是从PHP角度出发, 触发器会增加数据库维护的难度, 所以较少使用触发器.
