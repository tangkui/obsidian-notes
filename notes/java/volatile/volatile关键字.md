---
title: volatitle
tags:
  - volatitle
  - 内存屏障
---
volatile关键字在 Java 中的作用是**保证变量的可见性**和**防止指令重排**，但是**不保证原子性**。 

_原子操作是不可分割的,执行过程中不会被中断。单处理器系统中单条指令完成的操作具有原子性_;多处理器系统中需通过总线锁定(如x86的LOCK指令前缀)保证原子性。

要理解 volatile 的底层原理，首先要搞懂 Java 内存模型（JMM）的设计思想。JMM 是一种抽象的内存模型，它定义了线程和主内存之间的交互规则，目的是屏蔽不同硬件和操作系统的内存访问差异，保证 Java 程序在多线程环境下的正确性。

1. JMM 的内存划分
JMM 将内存划分为两个部分：

主内存：所有线程共享的内存区域，存储所有的共享变量。

工作内存：每个线程独有的内存区域，存储线程私有的数据，以及从主内存拷贝的共享变量副本。

2. JMM 的核心交互规则
线程对共享变量的所有操作，都必须在工作内存中进行，不能直接操作主内存，且不同线程之间无法直接访问对方的工作内存。JMM 定义了 8 种原子操作来完成线程与主内存的交互，核心操作包括：

read：从主内存读取共享变量到工作内存；

load：将 read 读取的值加载到工作内存的变量副本中；

use：将工作内存中的变量值传递给线程的执行引擎；

assign：将执行引擎的计算结果赋值给工作内存的变量；

store：将工作内存的变量值写入主内存；

write：将 store 传递的值刷新到主内存的共享变量中。

        对于普通共享变量，线程执行 assign 操作后，不会立即执行 store 和 write 操作，这就导致了主内存的变量值与工作内存的副本值不一致，进而引发可见性问题。而 volatile 变量的特殊之处，就在于它对这些交互规则做了强制约束。

 

三、可见性的底层实现：强制刷新主内存
volatile 保证可见性的核心，是通过强制线程的工作内存与主内存同步，具体体现在两个特殊规则上：

1. volatile 写规则：立即刷新主内存
当线程对 volatile 变量执行 assign 操作（赋值）后，必须立即执行 store 和 write 操作，将修改后的变量值同步到主内存中，不能缓存 到工作内存中。

简单来说： volatile 变量的修改，对所有线程立即可见 。

2. volatile 读规则：强制从主内存读取
当线程对 volatile 变量执行 use 操作（使用）前，必须先执行 read 和 load 操作，从主内存中读取最新的变量值，覆盖工作内存中的旧副本。

简单来说： 线程每次读取 volatile 变量，拿到的都是主内存的最新值 。

这两个规则就像给变量加上了 “实时同步” 的开关，彻底解决了普通变量的缓存不一致问题。我们可以用一张流程图来理解这个过程：
![[Pasted image 20260311151603.png]]
四、有序性的底层实现：内存屏障的魔法
如果说可见性的实现是对 JMM 交互规则的强化，那么有序性的实现则依赖于 volatile 的核心武器 —— 内存屏障（Memory Barrier）。

1. 指令重排序的坑：多线程下的逻辑混乱
在讲解内存屏障之前，我们先回顾一下指令重排序。JVM 为了优化程序执行效率，会在不影响单线程执行结果的前提下，调整指令的执行顺序。这种优化在单线程下没问题，但在多线程下可能会导致严重的逻辑错误。

比如我们之前提到的 DCL 单例模式， instance = new Singleton() 这行代码实际上会被拆分为 3 个指令：

分配内存：为 Singleton 对象分配一块内存空间；

初始化对象：调用构造函数初始化 Singleton 的成员变量；

赋值引用：将 instance 指向分配好的内存地址。

JVM 可能会对指令 2 和 3 进行重排序，执行顺序变为 1→3→2 。这会导致一个严重的问题：线程 A 执行完 1→3 后，instance 已经不为 null，但对象还未初始化；此时线程 B 读取 instance 时，会误以为对象已经创建完成，直接返回一个未初始化的实例，引发空指针异常。

2. 内存屏障的定义与分类
内存屏障是一种 CPU 指令，它的作用是禁止指令重排序，同时强制刷新内存数据。JMM 为 volatile 变量定义了 4 种内存屏障，分别对应不同的约束规则：


| 内存屏障类型        | 作用                                |
| ------------- | --------------------------------- |
| LoadLoad 屏障   | 禁止在屏障后的读操作与屏障前的读操作重排序             |
| StoreStore 屏障 | 禁止在屏障后的写操作与屏障前的写操作重排序             |
| LoadStore 屏障  | 禁止在屏障后的写操作与屏障前的读操作重排序             |
| StoreLoad 屏障  | 禁止在屏障后的读 / 写操作与屏障前的写操作重排序（最强大的屏障） |


3. volatile 变量的内存屏障插入规则
JMM 会在 volatile 变量的读写操作前后，插入特定的内存屏障，以此来禁止指令重排序。具体规则如下：

（1）volatile 写操作后的屏障插入

当线程执行 volatile 变量的写操作时，JVM 会在写操作之后插入StoreStore 屏障和StoreLoad 屏障：

StoreStore 屏障：确保 volatile 写操作的指令，会在屏障后的所有普通写操作指令之前执行；

StoreLoad 屏障：确保 volatile 写操作的指令，会在屏障后的所有普通读 / 写操作指令之前执行，同时强制刷新主内存。

（2）volatile 读操作后的屏障插入

当线程执行 volatile 变量的读操作时，JVM 会在读操作之后插入LoadLoad 屏障和LoadStore 屏障：

LoadLoad 屏障：确保 volatile 读操作的指令，会在屏障后的所有普通读操作指令之前执行；

LoadStore 屏障：确保 volatile 读操作的指令，会在屏障后的所有普通写操作指令之前执行。

4. 内存屏障如何解决指令重排序问题
回到 DCL 单例模式的例子，当 instance 被 volatile 修饰后，JVM 会禁止 instance = new Singleton() 中的指令重排序。具体来说：

指令 3（赋值引用）不能在指令 2（初始化对象）之前执行；

只有当指令 2 执行完成后，指令 3 才能执行。

这样一来，线程 B 读取 instance 时，要么看到的是 null ，要么看到的是完全初始化完成的对象，不会再出现 “半初始化” 的问题。

 

五、volatile 与普通变量的对比
为了更直观地看到 volatile 变量的底层差异，我们可以通过 javap 命令反编译 字节码文件，对比普通变量和 volatile 变量的指令区别。

1. 编写测试代码
```java 
public class VolatileBytecodeDemo {
    private static int normalVar = 0;
    private static volatile int volatileVar = 0;
    public static void main(String[] args) {
        normalVar = 1;
        volatileVar = 1;
        int a = normalVar;
        int b = volatileVar;
    }
}
```

2. 反编译字节码

执行命令 javac VolatileBytecodeDemo.java 编译代码，再执行 javap -v VolatileBytecodeDemo.class 反编译，重点关注变量的读写指令：

普通变量写指令： putstatic #2 （仅执行赋值操作，无额外指令）；

volatile 变量写指令： putstatic #3 + lock addl $0x0,(%rsp) （ lock 前缀指令会触发内存屏障，强制刷新主内存）；

普通变量读指令： getstatic #2 （仅执行读取操作，无额外指令）；

volatile 变量读指令： getstatic #3 （读取后会触发内存屏障，强制从主内存加载）。

从字节码层面可以看出， volatile 变量的读写操作比普通变量多了 lock 前缀指令，这正是内存屏障的底层体现。

 

六、结尾思考
通过本文的学习，我们知道 volatile 是通过强化JMM 交互规则保证可见性，通过插入内存屏障保证有序性。那么问题来了：

在 DCL 单例模式中，去掉 volatile 关键字会导致什么具体问题？如何复现这个问题？

内存屏障的插入会不会带来性能开销？ volatile 的性能和 synchronized 相比有什么差异？


----  

# 扩展

对 volatile long 和 volatile double 的读写是原子操作。 为什么？不是说volatile只保证可见性和防止指令重新排序吗？不保证其原子性吗

---

## 澄清：volatile 在 Java 中的实际语义

表格

|特性|volatile 保证？|说明|
|:--|:--|:--|
|**可见性**|✅ 保证|一个线程修改，其他线程立即可见|
|**有序性**|✅ 保证|禁止指令重排序（happens-before）|
|**原子性**|⚠️ **部分保证**|仅保证**单次读/写**的原子性，不保证复合操作|

---

## 关键区分：单次操作 vs 复合操作

### 1. 单次读/写是原子的（针对 long/double）

java

复制

```java
volatile double balance;

// ✅ 这两个操作各自是原子的
balance = 100.5;    // 单次写：原子
double x = balance; // 单次读：原子
```

**为什么单次操作是原子的？**

> JLS 17.7 明确规定：  
> _"Writes to and reads of references are always atomic, regardless of whether they are implemented as 32-bit or 64-bit values. Writes to and reads of `long` and `double` values are atomic if they are declared `volatile`."_

**实现层面**：

- 32位 JVM：对 `volatile long/double` 使用**锁总线**或**特殊指令**（如 x86 的 `CMPXCHG8B`）保证64位操作原子性
    
- 64位 JVM：单条指令即可完成，天然原子
    

### 2. 复合操作**不是**原子的

java

复制

```java
volatile double balance;

// ❌ 以下都不是原子操作！
balance++;           // 读 → 加 → 写
balance += 100;      // 读 → 加 → 写  
balance = balance * 2; // 读 → 乘 → 写
```

即使加了 `volatile`，这三步之间仍可能被其他线程打断。

---

## 修正后的准确表述

表格

|类型|非 volatile|volatile|
|:--|:--|:--|
|`int`/`float` (32位)|单次读写原子 ✅|单次读写原子 ✅ + 可见性/有序性|
|`long`/`double` (64位)|单次读写**可能非原子** ❌|单次读写原子 ✅ + 可见性/有序性|

**核心区别**：

- **非 volatile long/double**：32位 JVM 上可能分两次读写（高32位+低32位），导致"字撕裂"
    
- **volatile long/double**：JVM 强制使用原子指令完成64位操作，避免撕裂
    

---

## 对比：volatile vs AtomicLong

java

复制

```java
// volatile：单次操作原子，复合操作不原子
volatile long counter;
counter++;  // 非线程安全！

// AtomicLong：提供 CAS 复合操作
AtomicLong atomicCounter = new AtomicLong();
atomicCounter.incrementAndGet();  // 线程安全（内部 CAS 循环）
```

---

## 一句话总结


> 1、**`volatile` 对 long/double 的特殊之处在于：它把"原本可能非原子的64位操作"变成了"原子操作"**，但这仅限于**单次读或写**。复合操作仍需 `Atomic` 类或锁；
> 2、在使用 volatile 之前，我们必须牢记一个核心原则：**volatile 仅适用于「单一赋值、多线程读取」的场景，不适合用于需要原子性的复合操作场景。**