
## 后台运行jmeter脚本 
``` bash
nohup jmeter -n -t /root/jmeter_data/andy/jmx/PET_2025_1800X600.jmx \
-l result_$(date +%Y%m%d_%H%M%S).jtl \
-e -o /root/jmeter_data/andy/report_$(date +%Y%m%d_%H%M%S) > jmeter_output.log 2>&1 &
``` 


## 生成html分析报告
``` bash
jmeter -g result_20250901_162520.jtl -o html_$(date +%Y%m%d_%H%M%S)/
```
