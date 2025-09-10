---
title: Java 性能问题排查流程
tags:
  - Java
  - GC
  - CPU
  - OOM
  - 内存泄漏
  - JVM
---
### 场景一：CPU 飙高 / 线程卡死

1. 找到进程 PID
    
    `jps -l`
    
2. 查看线程状态
    
    `jstack -l <pid> > thread.log jcmd <pid> Thread.print > thread.log`
    
3. 排查内容：
    
    - 是否存在死锁 (`Found one Java-level deadlock`)
        
    - 是否有线程长时间 `BLOCKED / WAITING`
        
    - 是否有线程在热点方法中循环消耗 CPU
        

---

### 🟢 场景二：内存泄漏 / OOM

1. 查看堆使用情况
    
    `jmap -heap <pid> jcmd <pid> GC.heap_info`
    
2. 查看对象实例分布
    
    `jmap -histo <pid> | head -20 jcmd <pid> GC.class_histogram | head -20`
    
3. 导出堆文件（离线分析）
    
    `jmap -dump:format=b,file=/tmp/heap_$(date +%Y%m%d_%H%M%S).hprof <pid>`
    
    👉 使用 **Eclipse MAT** 或 **VisualVM** 打开 `heap.bin`，分析泄漏对象。
    

---

### 🟢 场景三：GC 频繁 / 内存回收异常

1. 动态监控 GC
    
    `jstat -gc <pid> 1000 10   # 每秒输出 GC 情况，共 10 次 jcmd <pid> GC.heap_info`
    
2. 查看 GC 日志（需启动参数开启）
    
    `-Xlog:gc*:file=gc.log:time,uptime,level,tags`
    
3. 排查内容：
    
    - Minor GC 是否过于频繁（年轻代太小）
        
    - Full GC 是否频繁（老年代满、内存泄漏）
        

---

### 🟢 场景四：JVM 配置/参数问题

1. 查看 JVM 参数
    
    `jinfo -flags <pid> jcmd <pid> VM.flags`
    
2. 查看系统属性
    
    `jinfo -sysprops <pid>`
    

|命令|输出内容|适用场景|
|---|---|---|
|`jinfo -flags <pid>`|**默认参数 + 手动参数**|全面查看 JVM 当前所有参数配置|
|`jcmd <pid> VM.flags`|**非默认/生效的手动参数**|想快速确认自己到底改了哪些参数|
|`jcmd <pid> VM.command_line`|**完整启动命令行**|想知道应用启动时具体传了哪些参数

---

### 🟢 场景五：方法执行效率 / 线上排查

👉 推荐使用 **Arthas（阿里开源诊断工具）**

`java -jar arthas-boot.jar`

常用命令：

- `thread`：查看热点线程、阻塞线程
    
- `jad`：反编译类
    
- `watch`：观察方法调用入参和返回值
    
- `trace`：跟踪方法调用链路
    
- `heapdump`：导出堆文件
    

---

## 3. 总结 - 常用命令速查表

| 场景        | 常用命令                                                            |
| --------- | --------------------------------------------------------------- |
| 查看进程      | `jps -l`                                                        |
| 线程卡死/CPU高 | `jstack -l <pid>` / `jcmd <pid> Thread.print`                   |
| 内存泄漏/OOM  | `jmap -histo <pid>` / `jmap -dump:format=b,file=heap.bin <pid>` |
| GC 调优     | `jstat -gc <pid>` / `jcmd <pid> GC.heap_info`                   |
| JVM 参数    | `jinfo -flags <pid>` / `jcmd <pid> VM.flags`                    |
| GUI 工具    | `VisualVM`, `MAT`, `Arthas`                                     |

---

📌 建议：

- **CPU 问题** → 先 `top` 找 PID → `jstack` 分析线程
    
- **内存问题** → `jmap` 导出堆 → 用 MAT 分析
    
- **GC 问题** → `jstat` 动态看 → 分析 GC 日志
    
- **不确定问题** → 用 **Arthas** 在线排查