---
title: SQL常用技巧语句汇总
date: 2017-7-8 20:09:04
tags: [数据库]

---
## 查询出表中某个字段重复的语句

** 以查询出ams_judge_standard_method_new表中  method_name字段重复为例子**

```sql
select * from ams_judge_standard_method_new where method_name in   
(select method_name from ams_judge_standard_method_new group by   
 method_name having COUNT(*)>1)
```
## 删除重复的记录 并且只保留 id 最小的一条
```sql
--- 删除重复的记录 并且只保留 id 最小的一条
DELETE from ams_judge_standard_new where standard_no in
                                                (select standard_no from ams_judge_standard_new group by
                                                  standard_no having COUNT(*)>1)
and id not IN (select min(id) from ams_judge_standard_new group by
  standard_no having COUNT(*)>1 );
```

## 三列中的结果 合并到一起
``` sql

SELECT SYSUSER.ID,
      SYSUSER.USERID,
      SYSUSER.USERNAME,
      SYSUSER.GROUPID,
      SYSUSER.SYSID,
      decode(SYSUSER.GROUPID,
      '1',(SELECT mc FROM USERJD WHERE ID = sysuser.SYSID),
      '2',(SELECT mc FROM USERJD WHERE ID = sysuser.SYSID),
      '3',(SELECT mc FROM USERYY WHERE ID = sysuser.SYSID),
      '4',(SELECT mc FROM USERGYS WHERE ID = sysuser.SYSID)
      )  as sysms

FROM SYSUSER


===================================================

SELECT SYSUSER.ID,
      SYSUSER.USERID,
      SYSUSER.USERNAME,
      SYSUSER.GROUPID,
      SYSUSER.SYSID,
      nvl(USERJD.MC, nvl(USERYY.MC,USERGYS.MC)) as sysmc

FROM SYSUSER
LEFT JOIN USERJD
  on SYSUSER.SYSID = USERJD.ID
LEFT JOIN USERYY
  on SYSUSER.SYSID = USERYY.ID
LEFT JOIN USERGYS
  ON SYSUSER.SYSID = USERGYS.ID

```

