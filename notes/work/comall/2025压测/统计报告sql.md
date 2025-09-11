---
title: 压力测试-统计报告sql
tags:
  - 压测
  - sql
  - 统计
---



## 订单 

``` sql
-- Raw原始单总单量
select count(1) from ctf_order.dc_raw_order where outer_order_id like '20250717%';
``` 

``` sql
-- 拉单总速率
select (select count(1)
        from ctf_order.dc_raw_order
        where outer_order_id like '20250722111%'
          and create_time >= '2025-07-22 15:30:00')        as 原始单总单量,
       min(t.time)                                         as 开始时间,
       max(t.time)                                         as 结束时间,
       (timestampdiff(SECOND, min(t.time), max(t.time)))   as '总耗时(秒)',
       ((select count(1)
         from ctf_order.dc_raw_order
         where outer_order_id like '20250722111%'
           and create_time >= '2025-07-22 15:30:00') /
        (timestampdiff(SECOND, min(t.time), max(t.time)))) as '速率/s'
from (SELECT date_format(create_time, '%Y-%m-%d %H:%i:%s') as time
      FROM ctf_order.dc_raw_order o
      WHERE o.outer_order_id LIKE '20250722111%'
        and create_time >= '2025-07-22 15:30:00') t;
``` 

``` sql
-- 拉单分钟时间分布速率
SELECT
  DATE_FORMAT(create_time, '%Y-%m-%d %H:%i') AS time,
  COUNT(1) AS 单量,
  COUNT(1) / 60.0 AS 速率
FROM
  ctf_order.dc_raw_order
WHERE
  outer_order_id LIKE '20250717%'
GROUP BY
  time
ORDER BY
  time;
``` 

``` sql
-- 常规订单创单总单量
select count(1) from ctf_order.dc_order where outer_order_id like '20250717%';
``` 

``` sql
-- 创单总速率
select (select count(1)
        from ctf_order.dc_order
        where outer_order_id like '20250722111%' and create_time >= '2025-07-22 15:30:00') as 创单总单量,
       min(t.time)                                                                         as 开始时间,
       max(t.time)                                                                         as 结束时间,
       (timestampdiff(SECOND, min(t.time), max(t.time)))                                   as '总耗时(秒)',
       ((select count(1)
         from ctf_order.dc_order
         where outer_order_id like '20250722111%'
           and create_time >= '2025-07-22 15:30:00') /
        (timestampdiff(SECOND, min(t.time), max(t.time))))                                 as '速率/s'
from (SELECT date_format(create_time, '%Y-%m-%d %H:%i:%s') as time
      FROM ctf_order.dc_order o
      WHERE o.outer_order_id LIKE '20250722111%'
        and create_time >= '2025-07-22 15:30:00') t;


``` 

``` sql
-- 创单分钟时间分布速率

SELECT
  DATE_FORMAT(create_time, '%Y-%m-%d %H:%i') AS time,
  COUNT(1) AS 单量,
  COUNT(1) / 60.0 AS 速率
FROM
  ctf_order.dc_order
WHERE
  outer_order_id LIKE '20250717%'
GROUP BY
  time
ORDER BY
  time;

```  

``` sql
-- 库存占用
select count(1) from(
select count(1)
from ctf_warehouse.dc_warehouse_shop_stock_operator_record
where order_id like '20250721001%'
  and type = 'OCCUPY' and create_time >= '2025-07-22 00:00:00' group by order_id) t; 
```

## 出库单 

> PICKING_COMPLETE 拣货
> PACKING_COMPLETE 包装
> DELIVERY_COMPLETE 交收

``` sql
-- 统计某批次出库单拣货、包装、交收的数量  
select count(1)  
from ctf_search_sourcing.dc_outbound_order o  
         left join ctf_search_sourcing.dc_outbound_order_trace t on o.id = t.outbound_order_id  
where o.outer_order_id like '20250828001%' and t.action_type='PROGRESS'  
  -- and t.operate_type in('PICKING_COMPLETE','PACKING_COMPLETE','DELIVERY_COMPLETE')  
and t.operate_type = 'PICKING_COMPLETE' order by operate_time desc;
``` 

``` sql
-- 统计某批次拣货总速率（TPS）
select count(1)                                                                        单量,  
       min(operate_time)                                                               开始时间,  
       max(operate_time)                                                               结束时间,  
       (timestampdiff(SECOND, min(t.operate_time), max(t.operate_time)))            as '总耗时(秒)',  
       count(1) / (timestampdiff(SECOND, min(t.operate_time), max(t.operate_time))) as tps  
from ctf_search_sourcing.dc_outbound_order o  
         left join ctf_search_sourcing.dc_outbound_order_trace t on o.id = t.outbound_order_id  
where o.outer_order_id like '20250828001%'  
  and t.action_type = 'PROGRESS'  
  and t.operate_type = 'PICKING_COMPLETE'  
order by operate_time desc;
``` 


``` sql
-- 统计出库单拣货、包装、交收时间分布及速率
select  
    DATE_FORMAT(t.operate_time, '%Y-%m-%d %H:%i') AS time,  
    COUNT(1) AS 单量,  
    COUNT(1) / 60.0 AS 速率  
from ctf_search_sourcing.dc_outbound_order o  
         left join ctf_search_sourcing.dc_outbound_order_trace t on o.id = t.outbound_order_id  
where o.outer_order_id like '20250828001%' and t.action_type='PROGRESS'  
and t.operate_type = 'PICKING_COMPLETE'  
group by time;
``` 
