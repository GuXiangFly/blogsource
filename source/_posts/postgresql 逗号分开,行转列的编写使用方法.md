---
title: postgresql 逗号分开,行转列的编写使用方法
date: 2017-8-2 20:09:04
tags: [数据库,postgreSQL]

---
# postgresql 逗号分开,行转列的编写使用方法


```sql
-- 自定义函数
create or REPLACE FUNCTION CHARINDEX(str VARCHAR(1000) , str2 VARCHAR(1000)) RETURNS INTEGER as
$body$
BEGIN
  RETURN position(str IN str2);
END
$body$
LANGUAGE 'plpgsql' VOLATILE

;with RECURSIVE tmp(id,product_no,product_no_new)   as (
  select id, LEFT(product_no, CHARINDEX(',',product_no||',')-1),
    overlay(product_no PLACING '' FROM 1 FOR CHARINDEX(',',product_no||','))
  from ams_judge_stanard_detail_original_new_view_test
  union all
  select id, LEFT(product_no, CHARINDEX(',',product_no||',')-1),
    overlay(product_no PLACING '' FROM 1 for CHARINDEX(',',product_no||','))
  from tmp
  where product_no > ''
)

select id,product_no_new
from tmp
```