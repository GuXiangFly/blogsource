---
title: java中的语法较好写法集锦
date: 2017-7-27 20:09:04
tags: [java]

---

## list的语法糖 省去了各种add
``` java
List<Employee> emps = Arrays.asList(
			new Employee(101, "张三", 18, 9999.99),
			new Employee(102, "李四", 59, 6666.66),
			new Employee(103, "王五", 28, 3333.33),
			new Employee(104, "赵六", 8, 7777.77),
			new Employee(105, "田七", 38, 5555.55)
	);
```