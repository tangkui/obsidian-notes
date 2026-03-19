---
title: CAS
tags:
  - 并发编程
  - 锁机制
  - Java
  - 分布式
---
# CAS（Compare-And-Swap）

## 定义

**CAS** = **Compare-And-Swap**（比较并交换）

一种**原子操作**，属于**乐观锁**实现方式。先比较内存值与预期值，若相等则替换为新值，整个过程不可中断。

---

## 核心语义

```
if (内存值 == 预期值) {
    内存值 = 新值;
    return true;   // 成功
} else {
    return false;  // 失败，值已被其他线程修改
}
```

---

## 三大参数

| 参数 | 说明 | 示例 |
|:---|:---|:---|
| **V** (Value) | 内存位置/变量 | `AtomicInteger` 内部值 |
| **E** (Expected) | 预期值 | 读取时的当前值 |
| **N** (New) | 新值 | 要更新的目标值 |

---

## 代码示例

### JDK实现（AtomicInteger）

```java
AtomicInteger atomicInt = new AtomicInteger(0);

// 自旋CAS
int expected;
do {
    expected = atomicInt.get();           // 1. 读取当前值
} while (!atomicInt.compareAndSet(
            expected,                     // 2. 预期值
            expected + 1                  // 3. 新值
         ));

// 等价于 atomicInt.incrementAndGet()，但展示了CAS本质，无限自旋不切实际，应该添加重试次数
```

### 数据库乐观锁

```sql
-- 更新时校验版本号（CAS思想）
UPDATE account 
SET balance = balance - 100, version = version + 1
WHERE id = 1 
  AND version = 5;   -- 预期版本，即CAS的E
-- 影响行数=1成功，=0失败（需重试）
```

---

## 底层实现

| 层级 | 机制 | 说明 |
|:---|:---|:---|
| **CPU指令** | `LOCK CMPXCHG` (x86) | 硬件保证原子性，总线锁定或缓存锁定 |
| **JVM** | `Unsafe.compareAndSwapInt/Long/Object` | JNI调用本地方法 |
| **语言封装** | `java.util.concurrent.atomic` 包 | `AtomicInteger`, `AtomicReference` 等 |

---

## ABA问题

### 现象
```
线程A读取值：A
线程B修改：A → B → A
线程ACAS成功（值仍是A），但实际已被修改过
```

### 解决方案
| 方案 | 实现 | 适用 |
|:---|:---|:---|
| **版本号** | `AtomicStampedReference` (int stamp) | 需要知道修改次数 |
| **时间戳** | `AtomicMarkableReference` (boolean mark) | 只需知道是否被修改 |

```java
// AtomicStampedReference 使用
AtomicStampedReference<Integer> ref = 
    new AtomicStampedReference<>(100, 0);

int[] stampHolder = new int[1];
Integer value = ref.get(stampHolder);  // 获取值和版本

ref.compareAndSet(value, 200, stampHolder[0], stampHolder[0] + 1);
```

---

## CAS vs 锁机制对比

| 特性 | CAS（乐观锁） | synchronized/Lock（悲观锁） | Redis分布式锁 |
|:---|:---|:---|:---|
| **思想** | 先操作，冲突再重试 | 先加锁，独占访问 | 跨进程互斥 |
| **阻塞** | 非阻塞，CPU自旋 | 阻塞，线程挂起 | 阻塞或自旋轮询 |
| **开销** | 低（无上下文切换） | 高（内核态切换） | 中（网络IO） |
| **适用场景** | 低冲突、短操作 | 高冲突、复杂逻辑 | 分布式系统 |
| **公平性** | 无保证（可能饥饿） | 可公平（ReentrantLock） | 依赖实现 |
| **典型应用** | 计数器、无锁队列 | 事务处理、临界区 | 分布式任务调度 |

---

## 实际应用场景

| 场景 | 实现 | 关键类/语句 |
|:---|:---|:---|
| 原子计数器 | `AtomicInteger` | `incrementAndGet()` |
| 无锁栈/队列 | `AtomicReference` | `compareAndSet()` |
| 数据库乐观锁 | version字段 | `UPDATE ... WHERE version = ?` |
| 分布式配置 | ZooKeeper CAS | `setData(version)` |
| 并发累加 | `LongAdder` | 分段CAS，高并发优化 |

---

## 优缺点

### ✅ 优点
- **无锁化**：无线程阻塞/唤醒开销
- **高吞吐**：低冲突场景性能极佳
- **无死锁**：不存在传统锁的循环等待

### ❌ 缺点
- **CPU空转**：冲突高时自旋浪费CPU（可退化为锁）
- **ABA问题**：需版本号解决
- **只能保证单个变量原子性**：无法像synchronized保证代码块

---

## 与周大福项目关联

| 项目代码 | 机制 | 说明 |
|:---|:---|:---|
| `odoDao.updateStatus` (version) | **CAS** | 数据库乐观锁，无锁更新 |
| `distributedLock.getInterceptLock` | **分布式锁** | 跨系统协调，阻塞等待 |

> 选型原则：**单表操作→CAS，跨系统流程→分布式锁**

---

## 扩展：Java中的原子类体系

```
java.util.concurrent.atomic
├── AtomicBoolean          // 布尔原子操作
├── AtomicInteger          // 整型原子操作
├── AtomicLong             // 长整型原子操作
├── AtomicReference<V>     // 引用类型原子操作
├── AtomicStampedReference<V>  // 带版本号，解决ABA
├── AtomicMarkableReference<V> // 带标记位
├── AtomicIntegerArray     // 数组原子操作
├── AtomicLongArray
├── AtomicReferenceArray
└── 字段更新器（反射操作）
    ├── AtomicIntegerFieldUpdater
    ├── AtomicLongFieldUpdater
    └── AtomicReferenceFieldUpdater
```

---

## 面试高频题

### Q1：CAS能保证线程安全吗？
> 能保证**单个变量**的线程安全，但**不能保证代码块**的原子性。多变量操作需用`synchronized`或`Lock`。

### Q2：为什么`AtomicLong`高并发性能下降？
> 大量线程CAS失败自旋，CPU空转。JDK8引入`LongAdder`，分段累加再合并，减少竞争。

### Q3：CAS和volatile的区别？
| | volatile | CAS |
|:---|:---|:---|
| 作用 | 可见性 + 禁止指令重排 | 原子性 + 可见性 |
| 复合操作 | `i++`非原子 | `compareAndSet`原子 |
| 阻塞 | 不阻塞 | 自旋非阻塞 |

### Q4：如何实现一个简单的自旋锁？
```java
public class SpinLock {
    private AtomicReference<Thread> owner = new AtomicReference<>();
    
    public void lock() {
        Thread current = Thread.currentThread();
        // CAS获取锁，失败则自旋
        while (!owner.compareAndSet(null, current)) {
            // Thread.yield(); // 可选，让出CPU
        }
    }
    
    public void unlock() {
        owner.compareAndSet(Thread.currentThread(), null);
    }
}
```

---

## 参考源码

### Unsafe.class（JDK8）
```java
// 本地方法，HotSpot实现
public final native boolean compareAndSwapInt(
    Object o, long offset, int expected, int x
);

public final native boolean compareAndSwapLong(
    Object o, long offset, long expected, long x
);

public final native boolean compareAndSwapObject(
    Object o, long offset, Object expected, Object x
);
```

### hotspot/src/os_cpu/linux_x86/vm/atomic_linux_x86.inline.hpp
```cpp
// C++层面：内联汇编调用cmpxchg指令
inline jint Atomic::cmpxchg(jint exchange_value, 
                            volatile jint* dest, 
                            jint compare_value) {
    __asm__ volatile ("lock cmpxchgl %1,(%3)"
                      : "=a" (exchange_value)
                      : "r" (exchange_value), "a" (compare_value), "r" (dest)
                      : "cc", "memory");
    return exchange_value;
}
```
 我来解释为什么CAS能保证单个变量的原子性，以及它的底层原理。

---

# CAS如何保证原子性？
## 核心原因：硬件层面的原子指令

CAS不是Java层面的代码逻辑，而是**直接对应CPU的一条原子指令**，硬件保证执行过程中**不可中断、不可拆分**。

---

## 对比：普通操作 vs CAS操作

### 普通`i++`（非原子）

```java
int i = 0;
i++;  // 看似一行，实际3步
```

**字节码层面：**
```asm
ILOAD 0      // 1. 读取i到寄存器
IINC 0 1     // 2. 寄存器+1
ISTORE 0     // 3. 写回内存
```

**问题：线程切换可能发生在任意两步之间**

```
线程A读取i=0 → [切换] → 线程B读取i=0 → B写到1 → [切换] → A写到1
结果：i=1（期望2），丢失一次更新
```

---

### CAS操作（原子）

```java
atomicInt.compareAndSet(0, 1);
```

**底层硬件指令（x86）：**
```asm
lock cmpxchg  // 单条指令，lock前缀保证原子性
```

**关键：CPU/内存控制器保证这条指令执行期间：**
- **总线锁定** 或 **缓存锁定**
- 其他CPU核心无法访问该内存地址
- 指令执行不可中断

---

## 硬件如何保证？两种机制

### 1. 总线锁定（早期CPU）

```
CPU0执行lock cmpxchg时：
    ↓
向总线发送 LOCK# 信号
    ↓
其他CPU核心无法访问内存（总线被独占）
    ↓
指令执行完成，释放LOCK#
```

**缺点**：锁定整个总线，影响其他CPU访问任何内存，性能差。

---

### 2. 缓存锁定（现代CPU，MESI协议）

```
CPU0缓存了变量i（状态：Exclusive独占）
    ↓
执行lock cmpxchg
    ↓
锁定缓存行，标记为Modified
    ↓
其他CPU若也想操作i：缓存失效，被迫从CPU0重新读取
```

**优点**：只锁定特定缓存行，不阻塞总线，性能高。

---

## Java层面的"障眼法"

你以为CAS是Java代码，实际是**JNI调用本地方法** → **C++内联汇编** → **CPU指令**

```
java.util.concurrent.atomic.AtomicInteger.compareAndSet()
    ↓
Unsafe.compareAndSwapInt()  // native方法
    ↓
JVM: unsafe.cpp
    ↓
atomic_linux_x86.inline.hpp: cmpxchg()
    ↓
汇编: lock cmpxchgl
    ↓
CPU硬件执行（原子）
```

---

## 为什么只能保证"单个变量"？

### CAS的硬件限制

```asm
lock cmpxchg [内存地址], 寄存器  // 只能操作一个内存位置
```

**无法做到：**
```java
// 想同时原子更新两个变量？硬件不支持！
compareAndSet(a, expectA, newA, b, expectB, newB);  // ❌ 不存在
```

### 代码证明：多变量CAS不安全

```java
class Account {
    private AtomicInteger balance = new AtomicInteger(100);
    private AtomicInteger points = new AtomicInteger(10);
    
    // 转账+积分：两个CAS，中间可能被其他线程打断
    public void transfer(int amount) {
        // 步骤1：扣余额（原子）
        balance.compareAndSet(100, 100 - amount);
        
        // [切换！其他线程修改了points]
        
        // 步骤2：加积分（原子）
        points.compareAndSet(10, 10 + amount);  // 基于错误的预期值！
    }
}
```

**两个独立的CAS ≠ 整体原子**，中间状态对外可见。
```java
public void deduct() {
    // CAS 1：这个操作本身是原子的（不可拆分）
    balance.compareAndSet(100, 90);
    
    // ❌ 但上面和下面是两个独立操作，中间有间隙
    
    // CAS 2：这个操作本身也是原子的（不可拆分）
    points.compareAndSet(10, 11);
}
```

**原子性范围：**

- ✅ `balance.compareAndSet` 这一行：原子
    
- ✅ `points.compareAndSet` 这一行：原子
    
- ❌ `deduct()` 整个方法：**不是原子**

| 场景 | 说明                                      |
| :- | :-------------------------------------- |
| 转账 | 扣A账户（原子）+ 加B账户（原子）≠ 转账整体原子              |
| 结婚 | 男方领证（原子）+ 女方领证（原子）≠ 结婚整体原子（可能一方领了另一方没领） |
需要事务（Transaction）或锁，才能保证**整体原子性**。

---

## 对比：synchronized能保证代码块

```java
synchronized(this) {
    a++;  // 多步操作
    b++;  // 但整体不可见中间状态
}
```

**原理**：Monitor锁，线程互斥进入，其他线程完全阻塞。

| 机制 | 粒度 | 实现 | 适用 |
|:---|:---|:---|:---|
| **CAS** | 单个变量 | 硬件指令 | 简单计数、状态切换 |
| **synchronized** | 代码块 | JVM Monitor | 复杂逻辑、多变量 |

---

## 一句话总结

> **CAS的原子性 = 硬件指令的原子性**
> 
> CPU把"比较+交换"封装成一条不可中断的指令，但只能针对**一个内存地址**。

---

## 关联笔记

- [[CPU缓存一致性协议MESI]]
- [[Unsafe类详解]]
- [[synchronized底层Monitor]]
- [[原子类vs锁性能对比]]