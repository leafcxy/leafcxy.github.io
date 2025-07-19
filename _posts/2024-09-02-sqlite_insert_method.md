---
title: sqlite.获取插入id的几种方式
date: 2024-09-02 02:05:33
tags: [sqlite]
---

1. sqlite_sequence

```sql
insert into TbTest(Name, Age) values('usr', 20);
select seq from sqlite_sequence where name='TbTest';
```

<!-- more -->

2. rowid

```sql
--表设置了自增列，会生成 rowid 的隐藏列，需要显式查询语句才可以查询出
select rowid from TbTest;
--但是，表没有设置自增列，上面的语句无法查出任何值
--特殊的，表无论是否设置了自增列，但都可以使用聚合函数查询出 rowid
insert into TbTest(Name, Age) values('usr', 20);
select max(rowid) from TbTest;
```

3. ID 列

```sql
insert into TbTest(Name, Age) values('usr', 20);
select max(ID) from TbTest;
```

4. last_insert_rowid

```sql
insert into TbTest(Name, Age) values('usr', 20);
--注意！若此行处有插入临时表的操作，下面的语句获取到的是插入临时表的 rowid
select last_insert_rowid() from TbTest LIMIT 1;
```
