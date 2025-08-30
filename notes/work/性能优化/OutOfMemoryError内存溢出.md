**Tips**
```bash
# 在 JVM 启动参数里加上，重启前或下次再出现 OOM 时，一定 **dump 堆快照**，便于事后分析
-XX:+HeapDumpOnOutOfMemoryError
-XX:HeapDumpPath=/tmp/heapdump.hprof
```

jmap -dump:format=b,file=/tmp/heap_$(date +%Y%m%d_%H%M%S).hprof 1

