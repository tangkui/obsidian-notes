## dump日志

**Tips**
```bash
# 在 JVM 启动参数里加上，重启前或下次再出现 OOM 时，一定 **dump 堆快照**，便于事后分析
-XX:+HeapDumpOnOutOfMemoryError
# 以下配置2选一

# 最好是使用这个，不指定具体文件名，自动生成，动态命名：java_pid76932.hprof
-XX:HeapDumpPath=/tmp/log/dumps/

# 指定dum文件具体名称（可能会存在句柄被占用导致某节点不断重启的问题，参考以下[问题点]）
-XX:HeapDumpPath=/tmp/heapdump.hprof

```

### 问题点

1. **文件句柄占用** 
    
    - JVM 在写 heap dump 时，会打开 `/tmp/heapdump.hprof` 文件句柄。
        
    - 如果 dump 文件特别大，写的过程比较长，句柄可能一直被占着。
        
    - 在 Kubernetes/Docker 环境下，如果监控或者探针检测到进程长时间无响应，就可能触发 Pod 重启。
        
2. **文件锁冲突 / 覆盖问题**
    
    - 如果服务频繁 OOM，每次都往同一个 `/tmp/heapdump.hprof` 写，会导致：
        
        - 文件不断被覆盖。
            
        - 某些 JVM 实现会在已有文件句柄被占用时无法重新写入，甚至报错。
            
    - 在集群环境下，如果多个副本都挂载了同一个 `/tmp` 目录，也可能出现多个 JVM 争抢写同一个文件，导致失败或异常。
        
3. **崩溃循环（CrashLoopBackOff）**
    
    - 当 JVM 一直在尝试写 dump → 被卡住 → 探针超时 → Pod 重启 → 再次 OOM → 再次写同一个文件 → 继续卡住。
        
    - 就会出现“不断重启”的现象。

--- 

- **jvm启动参数没有自动dump的情况下，需要手动dump**
- **在OutOfMemoryError报错时，及时执行以下命令**
``` bash 
# 查询java进程pid
jps -l 

# dump 文件
jmap -dump:format=b,file=/tmp/heap_$(date +%Y%m%d_%H%M%S).hprof <PID>

```

- **文件传输到oss（Rancher：微服务所在的docker执行）** 
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


