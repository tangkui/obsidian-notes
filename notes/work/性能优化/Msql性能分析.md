### 导出慢日志分析

- 登录mysql服务器执行
``` bash
pt-query-digest /software/mysqllog/mysql-slow.log --since '2025-08-21 16:21:45'  --until '2025-08-21 16:57:59' >/tmp/20250821003-1.log
``` 


- 远程执行
``` bash
pt-query-digest --processlist h=172.16.107.95,P=3306,u=ctf_aly_appuser,p='password' \ --run-time=30s --iterations=1 --limit=10
``` 

---- 
###  在执行压力测试之前清理所有 SQL 语句相关的统计信息表  
``` sql
-- 清理所有 SQL 语句相关的统计信息表  
TRUNCATE TABLE performance_schema.events_statements_summary_by_digest;  
TRUNCATE TABLE performance_schema.events_statements_summary_by_user_by_event_name;  
TRUNCATE TABLE performance_schema.events_statements_summary_by_host_by_event_name;  
TRUNCATE TABLE performance_schema.events_statements_summary_by_account_by_event_name;  
TRUNCATE TABLE performance_schema.events_statements_summary_by_thread_by_event_name;  
TRUNCATE TABLE performance_schema.events_statements_summary_global_by_event_name;  
  
flush status;
``` 

### 查找锁等待严重的 SQLSELECT  
``` sql 
-- 查找锁等待严重的 SQL
SELECT  
  DIGEST_TEXT,  
  COUNT_STAR,  
  ROUND(SUM_LOCK_TIME / 1000000000, 2) AS total_lock_ms,  
  ROUND(AVG_TIMER_WAIT / 1000000000, 2) AS avg_ms  
FROM performance_schema.events_statements_summary_by_digest  
WHERE DIGEST_TEXT IS NOT NULL  
ORDER BY SUM_LOCK_TIME DESC  
LIMIT 10;

``` 

### 查找扫描行数远大于返回行数的 SQL（可能缺少索引）  
``` sql 
-- 查找扫描行数远大于返回行数的 SQL（可能缺少索引）  
SELECT  
  DIGEST_TEXT,  
  SUM_ROWS_EXAMINED,  
  SUM_ROWS_SENT,  
  ROUND(SUM_ROWS_EXAMINED / SUM_ROWS_SENT, 2) AS exam_sent_ratio  -- 扫描/返回比例  
FROM performance_schema.events_statements_summary_by_digest  
WHERE  
  DIGEST_TEXT IS NOT NULL  
  AND SUM_ROWS_SENT > 0  -- 排除无返回的语句  
  AND SUM_ROWS_EXAMINED > SUM_ROWS_SENT * 10  -- 比例超过10倍（可调整）  
ORDER BY exam_sent_ratio DESC  
LIMIT 10;
``` 

###  查找执行次数最多的 SQLSELECT  
``` sql 
-- 查找执行次数最多的 SQL
SELECT  
  DIGEST_TEXT,  
  COUNT_STAR,  
  ROUND(AVG_TIMER_WAIT / 1000000000, 2) AS avg_ms,  -- 转换为毫秒  
  ROUND(SUM_TIMER_WAIT / 1000000000, 2) AS total_ms  
FROM performance_schema.events_statements_summary_by_digest  
WHERE DIGEST_TEXT IS NOT NULL  
ORDER BY COUNT_STAR DESC  
LIMIT 10;
```  


