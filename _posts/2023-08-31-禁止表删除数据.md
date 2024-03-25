---
title: 禁止表删除数据
date: 2023-08-31 12:56:38
tags:
---


```sql
create trigger [Tgr_table] on [table] 
instead of delete 
as 
begin
select '禁止對表進行刪除操作' ---将对表delete全部锁定禁止操作 
return;
end
```

