**Tips**
```bash
# 在 JVM 启动参数里加上，重启前或下次再出现 OOM 时，一定 **dump 堆快照**，便于事后分析
-XX:+HeapDumpOnOutOfMemoryError
-XX:HeapDumpPath=/tmp/heapdump.hprof
```



jmap -dump:format=b,file=/tmp/heap_$(date +%Y%m%d_%H%M%S).hprof 1



文件传输到oss，待整理
curl https://gosspublic.alicdn.com/ossutil/1.7.13/ossutil64?spm=5176.8466032.services.dutil-linux64.19931450VCDPki -o /usr/local/bin/ossutil64
chmod +x /usr/local/bin/ossutil64
cat >/root/.ossutilconfig<<e
[Credentials]
language=CH
endpoint=******
accessKeyID=******
accessKeySecret=******

ossutil64 cp szh oss://filesystem-pet/szh

ossutil64 cp /tmp/heap_20250829_140902.hprof oss://filesystem-pet/heap_20250829_140902.hprof
