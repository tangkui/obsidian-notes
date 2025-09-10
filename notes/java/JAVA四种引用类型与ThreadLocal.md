---
title: Java 四种引用与 ThreadLocal 内存管理
tags: [Java, GC, 内存管理, 引用类型, 缓存, ThreadLocal]
---

# Java 四种引用类型详解

Java 中有 **四种引用类型**：**强引用（Strong）、软引用（Soft）、弱引用（Weak）、虚引用（Phantom）**。  
不同引用类型对 GC 行为的影响不同，适用于不同业务场景。

---

## 强引用 (Strong Reference)
- **特点**：只要引用存在，对象不会被 GC 回收。
- **业务场景**：普通对象管理。
- **示例代码**：
```java
Object obj = new Object();
obj = null;
System.gc();
System.out.println(obj); // null
``` 

## 软引用 (Soft Reference)

- **特点**：内存不足时才会被 GC 回收。
    
- **业务场景**：图片缓存、内容缓存，内存敏感缓存。
    
- **示例代码**：
``` java
SoftReference<Object> softRef = new SoftReference<>(new Object());
System.gc();
Object obj = softRef.get();
``` 

## 弱引用 (Weak Reference)

- **特点**：对象在下一次 GC 时就会被回收。
    
- **业务场景**：短期缓存、元数据缓存、ThreadLocal。
    
- **示例代码**：
``` java
ReferenceQueue<Object> queue = new ReferenceQueue<>();
PhantomReference<Object> phantomRef = new PhantomReference<>(new Object(), queue);
System.gc();
queue.poll(); // 回收前清理
``` 

## 虚引用 (Phantom Reference)

- **特点**：总是返回 null，GC 回收前可做额外处理。
    
- **业务场景**：资源释放、DirectByteBuffer 回收。
    
- **示例代码**：
``` java
ReferenceQueue<Object> queue = new ReferenceQueue<>();
PhantomReference<Object> phantomRef = new PhantomReference<>(new Object(), queue);
System.gc();
queue.poll(); // 回收前清理
```
## 四种引用对比表

|引用类型|get() 返回|是否影响GC|业务场景|
|---|---|---|---|
|强引用|可|是|普通对象管理|
|软引用|可|内存不足时回收|内存敏感缓存|
|弱引用|可|下一次GC回收|元数据缓存、ThreadLocal|
|虚引用|不可|无|对象回收前清理操作|
### 不同引用类型的行为

|引用类型|对象仍在引用中时|GC 行为|
|---|---|---|
|强引用|有|永不回收|
|软引用|有|不回收（内存不足时才回收）|
|弱引用|有|不回收（下一次 GC 才回收，前提是弱引用可达对象）|
|虚引用|有|不影响对象生命周期，无法通过 get() 访问，GC 会在对象不可达时回收|

> ⚠️ 注意：
> 
> - **软引用和弱引用对象**只会在 **没有强引用** 时才有可能被回收。
>     
> - 如果引用仍在使用（仍然有强引用链），即使内存紧张，GC 也不会回收。

### 实例演示 

``` java
import java.lang.ref.SoftReference;

public class ReferenceTest {
    public static void main(String[] args) {
        Object obj = new Object();
        SoftReference<Object> softRef = new SoftReference<>(obj);

        // obj 强引用还在
        System.gc();

        // 因为强引用 obj 仍然存在，所以软引用对象不会被回收
        if (softRef.get() != null) {
            System.out.println("对象还在"); // 输出：对象还在
        }
    }
}

``` 

## 生命周期与 GC 行为图
``` mermaid
sequenceDiagram
    participant Code as 代码引用
    participant GC as GC
    participant Obj as 对象

    Code->>Obj: 强引用创建
    Note right of Obj: 不会被GC回收
    GC-->>Obj: 尝试回收
    Obj->>Code: 仍可访问

    Code->>Obj: 软引用创建
    Note right of Obj: 内存不足时回收
    GC-->>Obj: 内存紧张时回收
    Obj->>Code: get() 可访问或 null

    Code->>Obj: 弱引用创建
    Note right of Obj: 下一次GC必回收
    GC-->>Obj: 回收
    Obj->>Code: get() null

    Code->>Obj: 虚引用创建
    Note right of Obj: GC回收前可做清理
    GC-->>Obj: 回收
    Obj->>Code: get() 总是 null 
```  

## 1️⃣ ThreadLocalMap 结构

``` java
ThreadLocalMap.Entry {
    WeakReference<ThreadLocal<?>> key; // ThreadLocal对象
    Object value;                     // 线程私有数据
}
```

- **key 弱引用** → 外部不再持有 ThreadLocal 对象时，可被 GC 回收
    
- **value 强引用** → 保证线程访问期间数据稳定
    

---

## 2️⃣ WeakReference 与 ThreadLocal 的关系

- ThreadLocal 内部用弱引用存储 key
    
- value 是线程私有数据
    
- **问题**：如果线程长期存在且 key 被回收，value 会残留 → 内存泄漏
    

**ThreadLocal 内存泄漏示意图**：
``` mermaid
graph LR
    ThreadLocalObj[ThreadLocal对象] -->|弱引用key| ThreadLocalMapEntry[ThreadLocalMap Entry]
    ThreadLocalMapEntry -->|value| Thread[线程私有数据]
    ThreadMapNote["注: 如果ThreadLocalObj被GC回收，key=null但value仍存在，造成内存泄漏"]
    Thread --> ThreadMapNote

```  

---

## 3️⃣ 为什么 value 不能用弱引用

1. **保证线程访问一致性**
    
    - ThreadLocal.get() 依赖 value
        
    - value 若为弱引用 → GC 可能随时回收 → get() 返回 null → 数据丢失
        
2. **key 和 value 生命周期可能不同步**
    
    - key 可达，但 value 不可达 → 不存在，因为 value 强引用保证可达
        
    - key 不可达，value 可达 → “僵尸数据”，内部清理或 remove() 解决
        

---

## 4️⃣ 生命周期分离示意图

``` mermaid
graph LR
    key_reachable[Key可达] -->|value强引用| value_reachable[Value可达]
    key_unreachable[Key不可达] -->|value仍存在| value_zombie[Value僵尸数据]
    value_zombie -->|内部扫描/下一次put-get/remove| value_collected[Value清理]

``` 



## 5️⃣ 对象仍在使用时 GC 行为

- **原则**：只要对象有可达引用，GC 不会回收
    
- 示例：
    
``` java 
Object obj = new Object();
SoftReference<Object> softRef = new SoftReference<>(obj);

System.gc();
System.out.println(softRef.get()); // 输出对象，未回收
```
- 强引用、软引用、弱引用、虚引用都遵循这一原则
    
---

## 6️⃣ ThreadLocal 使用建议

1. 使用完 ThreadLocal 后调用 `threadLocal.remove()`
    
2. 避免在线程池中长期持有未清理的 ThreadLocal
    
3. 结合业务选择合适引用类型：
    
    - **强引用**：普通对象管理
        
    - **软引用**：缓存（图片、文件内容）
        
    - **弱引用**：ThreadLocal key / 元数据缓存
        
    - **虚引用**：回收前资源释放
        

---

## 7️⃣ ThreadLocalMap key/value 生命周期完整流程

``` mermaid
graph TD
    A["ThreadLocal对象可达"] --> B["ThreadLocal get 或 set"]
    B --> C["value 强引用可用"]

    subgraph GC事件
        D["ThreadLocal对象不可达"] --> E["key 变为 null"]
        E --> F["value 仍存在 → 僵尸数据"]
        F --> G["内部扫描 / 下一次 put-get / remove"]
        G --> H["value 清理"]
    end

    subgraph 正常访问
        A --> C
    end

    subgraph 垃圾回收流程
        D --> E --> F --> G --> H
    end

    Fnote["注: value 仍在内存，但无法通过 ThreadLocal 访问"] 
    Hnote["注: 清理完成，防止内存泄漏"]

    F --> Fnote
    H --> Hnote
``` 


### 说明：

1. **正常访问阶段**
    
    - key 可达，value 强引用 → 线程访问稳定
        
2. **GC事件阶段**
    
    - ThreadLocal对象不可达 → key 弱引用被回收 → entry.key = null
        
    - value 仍然存在 → 僵尸数据
        
    - 内部扫描/下一次 put-get/remove 清理 value → 防止内存泄漏
        
3. **核心设计理念**
    
    - key 弱引用保证 ThreadLocal 对象回收
        
    - value 强引用保证线程访问期间数据可用
        
    - 内部清理机制解决 key 被回收后的僵尸 value
        

---

✅ **总结**

- **ThreadLocalMap 关键设计原则**：
    
    1. key 弱引用 → 避免 ThreadLocal 对象长期占用内存
        
    2. value 强引用 → 保证线程访问期间数据可靠
        
    3. key/value 生命周期可能分离 → 弱引用 key + 强引用 value + 内部扫描/清理
        
- **GC 只回收不可达对象**，有可达引用的对象不会被回收
    
- 四种引用类型结合业务场景使用，可优化缓存、内存和资源管理