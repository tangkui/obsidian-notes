## dump日志

**Tips**
```bash
# 在 JVM 启动参数里加上，重启前或下次再出现 OOM 时，一定 **dump 堆快照**，便于事后分析
-XX:+HeapDumpOnOutOfMemoryError
-XX:HeapDumpPath=/tmp/heapdump.hprof
```


- **jvm启动参数没有自动dump的情况下，需要手动dump**
- **在OutOfMemoryError报错时，及时执行以下命令**
``` bash 
# 查询java进程pid
jps -l 

# dump 文件
jmap -dump:format=b,file=/tmp/heap_$(date +%Y%m%d_%H%M%S).hprof <PID>

```

- **文件传输到oss**
``` bash
# 下载传输工具
curl https://gosspublic.alicdn.com/ossutil/1.7.13/ossutil64?spm=5176.8466032.services.dutil-linux64.19931450VCDPki -o /usr/local/bin/ossutil64
``` 

``` bash 
# 添加执行权限
chmod +x /usr/local/bin/ossutil64
``` 

``` bash 
##  替换授权信息
cat >/root/.ossutilconfig<<e
[Credentials]
language=CH
endpoint=******
accessKeyID=******
accessKeySecret=******
``` 

``` bash
# 上传到OSS的filesystem-pet目录
ossutil64 cp /tmp/heapdump.hprof oss://filesystem-pet/heapdump.hprof
``` 


## 分析日志


