# B-tree (B树)

## 1. 概念

**B-tree** 是一种 **多路平衡搜索树**，专为 **磁盘存储** 设计，所有叶子节点在同一层，保持绝对平衡。

> **B** 代表 **Balanced**（平衡）或 **Bayer**（发明者）

### 核心参数：阶数 m

- 每个节点最多有 **m 个子节点**
- 每个节点最多有 **m-1 个关键字**
- 根节点最少有 **2 个子节点**（除非它是叶子）
- 非根节点最少有 **⌈m/2⌉ 个子节点**

---

## 2. 结构图解

### 3阶B-tree (2-3树) 示例

```mermaid
flowchart TD
    A[20] --> B[10]
    A --> C[30, 40]
    
    B --> D[5]
    B --> E[15]
    
    C --> F[25]
    C --> G[35]
    C --> H[45, 50]
    
    D --> D1[小于5]
    D --> D2[5-10]
    
    E --> E1[10-15]
    E --> E2[15-20]
    
    F --> F1[20-25]
    F --> F2[25-30]
    
    G --> G1[30-35]
    G --> G2[35-40]
    
    H --> H1[40-45]
    H --> H2[45-50]
    H --> H3[大于50]
    
    style A fill:#ff9999,stroke:#333,stroke-width:2px
    style B fill:#99ccff,stroke:#333
    style C fill:#99ccff,stroke:#333
    style D fill:#ccffcc,stroke:#333
    style E fill:#ccffcc,stroke:#333
    style F fill:#ccffcc,stroke:#333
    style G fill:#ccffcc,stroke:#333
    style H fill:#ccffcc,stroke:#333
```

### 节点内部结构

```mermaid
flowchart LR
    P0[指针0] --> K1[Key1]
    K1 --> P1[指针1]
    P1 --> K2[Key2]
    K2 --> P2[指针2]
    P2 --> K3[Key3]
    K3 --> P3[指针3]
    
    style K1 fill:#ff9999
    style K2 fill:#ff9999
    style K3 fill:#ff9999
```

**规则**：`Key[i]` 是 `P[i]` 和 `P[i+1]` 之间的分界值

---

## 3. 查找过程

```mermaid
flowchart TD
    Start[开始查找: Key=35] --> Root[访问根节点<br/>20]
    Root --> Compare1{35 > 20?}
    Compare1 -->|是| NodeC[访问右子节点<br/>30,40]
    Compare1 -->|否| NodeB[访问左子节点]
    NodeC --> Compare2{35 > 30<br/>且 35 < 40?}
    Compare2 -->|是| Found[找到! 在<br/>30和40之间]
    Compare2 -->|否| Next[继续向下]
    
    style Root fill:#ff9999
    style NodeC fill:#99ccff
    style Found fill:#90EE90,stroke:#228B22,stroke-width:3px
```

**查找步骤**：
1. 从根节点开始
2. 在节点内顺序/二分查找关键字
3. 根据比较结果进入对应子树
4. 重复直到找到或到达叶子

---

## 4. 插入与分裂

### 插入流程

```mermaid
flowchart TD
    Insert[插入Key] --> Find[找到合适叶子节点]
    Find --> Check{节点已满?}
    Check -->|否| Add[直接插入]
    Check -->|是| Split[节点分裂]
    Split --> Create[创建新节点<br/>将中间Key提升到父节点]
    Create --> Parent{父节点已满?}
    Parent -->|是| Split
    Parent -->|否| Done[完成]
    
    style Split fill:#ffcc99
    style Create fill:#ff9999
```

### 分裂示意图（3阶B-tree插入25）

```mermaid
flowchart LR
    subgraph Before[插入前]
        A1[10, 20, 30]
    end
    
    subgraph After1[插入25后溢出]
        A2[10, 20, 25, 30]
    end
    
    subgraph After2[分裂后]
        A3[20] --> B3[10]
        A3 --> C3[25, 30]
    end
    
    Before -->|插入25| After1
    After1 -->|分裂| After2
    
    style A2 fill:#ff6b6b,color:#fff
    style A3 fill:#90EE90
```

---

## 5. 删除与合并

### 删除流程

```mermaid
flowchart TD
    Delete[删除Key] --> Locate[定位节点]
    Locate --> IsLeaf{是叶子?}
    IsLeaf -->|否| Replace[用前驱/后继替换<br/>转而在叶子删除]
    IsLeaf -->|是| Check{节点关键字<br/>数量足够?}
    Check -->|是| Remove[直接删除]
    Check -->|否| Borrow{兄弟可借?}
    Borrow -->|是| BorrowKey[向兄弟借一个<br/>通过父节点调整]
    Borrow -->|否| Merge[与兄弟合并<br/>父节点关键字下降]
    Merge --> ParentCheck{父节点<br/>关键字够?}
    ParentCheck -->|否| Merge
    ParentCheck -->|是| Done
    
    style Merge fill:#ffcc99
    style BorrowKey fill:#99ccff
```

---

## 6. 核心特性对比

| 特性 | 二叉树 | B-tree |
|------|--------|--------|
| **子节点数** | ≤2 | ≤m (多路) |
| **节点关键字** | 1个 | 多个 (m-1个) |
| **树高度** | 较高 | 较矮（胖矮） |
| **存储位置** | 内存 | 磁盘/内存 |
| **IO次数** | 多 | 少（一次读一页） |
| **应用场景** | 内存运算 | 文件系统、数据库 |

---

## 7. 应用场景

| 系统/应用 | 使用B-tree原因 |
|----------|--------------|
| **NTFS文件系统** | 存储文件索引，减少磁盘寻道 |
| **HFS+ (Mac)** | 目录索引管理 |
| **MongoDB (旧版)** | 默认存储引擎WiredTiger使用B-tree |
| **SQL Server** | 非聚集索引 |
| **PostgreSQL** | 部分索引实现 |

---

## 8. 为什么适合磁盘？

```mermaid
flowchart LR
    subgraph Memory[内存-二叉树]
        direction TB
        Mem1[节点1] --> Mem2[节点2]
        Mem2 --> Mem3[节点3]
        Mem3 --> Mem4[节点4]
    end
    
    subgraph Disk[磁盘-B-tree]
        direction TB
        Disk1[一页/节点<br/>含多关键字] -->|一次IO| Disk2[一页/节点]
        Disk2 -->|一次IO| Disk3[一页/节点]
    end
    
    style Mem1 fill:#ff9999
    style Mem2 fill:#99ccff
    style Mem3 fill:#ccffcc
    style Disk1 fill:#90EE90
    style Disk2 fill:#90EE90
```

**关键原因**：
1. **局部性原理**：一个节点大小 = 磁盘页大小（4KB），一次IO读入多个关键字
2. **降低高度**：100阶B-tree存1亿数据只需约4层
3. **顺序访问**：节点内关键字有序，支持范围查询

---

## 9. 优缺点

**✅ 优点**
- 磁盘IO次数少（树矮）
- 所有叶子同层，查询稳定 $O(\log n)$
- 支持范围查询
- 自平衡，无需重建

**❌ 缺点**
- 实现复杂（分裂、合并、借用逻辑）
- 空间利用率约50%（非满节点）
- 不适合全遍历（节点间指针不连续）

---

## 10. 与B+tree的关键区别

| 对比项 | B-tree | B+tree |
|--------|--------|--------|
| **数据存储** | 内部节点和叶子都存数据 | 只有叶子存数据 |
| **叶子节点** | 相互独立 | 链表连接 |
| **范围查询** | 需要中序遍历 | 直接顺序扫描叶子 |
| **查询稳定性** | 可能在内部节点命中 | 必查找到叶子 |
| **空间利用率** | 较低 | 更高 |

---

