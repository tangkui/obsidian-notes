# HashMap源码

## 成员变量
``` java
/**
 * HashMap的底层实现是基于数组 + 链表 + 红黑树
 * 成员变量定义了HashMap的基本运行参数
 */
public class HashMap<K,V> extends AbstractMap<K,V>
    implements Map<K,V>, Cloneable, Serializable {

    // ---------------------- 静态常量部分 ----------------------

    /**
     * 默认初始容量：16
     * 也就是当我们 new HashMap() 时，底层 table 数组的长度
     * 注意：容量必须是 2 的幂次方（原因和位运算优化有关）
     */
    static final int DEFAULT_INITIAL_CAPACITY = 1 << 4; // 16

    /**
     * 最大容量：2^30
     * 超过这个值，容量不再扩容
     */
    static final int MAXIMUM_CAPACITY = 1 << 30;

    /**
     * 默认负载因子：0.75
     * 当 HashMap 的元素数量 > 容量 * 负载因子 时，会触发扩容
     */
    static final float DEFAULT_LOAD_FACTOR = 0.75f;

    /**
     * 当一个桶（链表）中的元素数量 >= 8 时，会将链表转化为红黑树
     * 目的是优化查询效率：链表 O(n) → 红黑树 O(log n)
     */
    static final int TREEIFY_THRESHOLD = 8;

    /**
     * 当红黑树中元素个数 <= 6 时，会退化回链表
     * 避免在小数据量下使用红黑树带来的额外性能开销
     */
    static final int UNTREEIFY_THRESHOLD = 6;

    /**
     * 当 HashMap 容量 < 64 时，即使单个桶的元素数量 >= 8
     * 也不会立刻转为红黑树，而是先进行扩容
     * 目的是避免过早使用红黑树
     */
    static final int MIN_TREEIFY_CAPACITY = 64;

    // ---------------------- 成员变量部分 ----------------------

    /**
     * 存储数据的数组，类型为 Node[]
     * Node 是 HashMap 的基本存储结构，包含 key-value 对
     * 初始为 null，第一次 put 时才真正初始化
     */
    transient Node<K,V>[] table;

    /**
     * 缓存的 entrySet
     * 用于实现 entrySet() 方法时的返回结果（提高效率）
     */
    transient Set<Map.Entry<K,V>> entrySet;

    /**
     * HashMap 当前存储的键值对数量
     */
    transient int size;

    /**
     * HashMap 结构性修改的次数
     * 结构性修改：改变了 HashMap 中元素数量的操作
     * 例如 put/remove/resize 等
     * fail-fast 机制依赖这个值
     */
    transient int modCount;

    /**
     * 阈值：触发扩容的界限
     * threshold = 容量 * 负载因子
     * 当 size 超过 threshold 时，触发扩容
     */
    int threshold;

    /**
     * 负载因子（可自定义，默认 0.75）
     */
    final float loadFactor;

}

``` 

- **核心常量**：DEFAULT_INITIAL_CAPACITY 容量、DEFAULT_LOAD_FACTOR 负载因子、TREEIFY_THRESHOLD 树化阈值。
- **关键变量**：`table`（底层数组）、`size`（元素数量）、`threshold`（扩容阈值）、`modCount`（结构修改次数，支持 fail-fast）。
- **设计思想**：通过参数控制 **性能（查询快）** 与 **内存使用率（扩容时机）** 的平衡。

-------  

## 构造函数
``` java 
/**
 * HashMap的底层实现是基于数组 + 链表 + 红黑树
 * 成员变量定义了HashMap的基本运行参数
 */
public class HashMap<K,V> extends AbstractMap<K,V>
    implements Map<K,V>, Cloneable, Serializable {

    // ---------------------- 静态常量部分 ----------------------

    /**
     * 默认初始容量：16
     * 也就是当我们 new HashMap() 时，底层 table 数组的长度
     * 注意：容量必须是 2 的幂次方（原因和位运算优化有关）
     */
    static final int DEFAULT_INITIAL_CAPACITY = 1 << 4; // 16

    /**
     * 最大容量：2^30
     * 超过这个值，容量不再扩容
     */
    static final int MAXIMUM_CAPACITY = 1 << 30;

    /**
     * 默认负载因子：0.75
     * 当 HashMap 的元素数量 > 容量 * 负载因子 时，会触发扩容
     */
    static final float DEFAULT_LOAD_FACTOR = 0.75f;

    /**
     * 当一个桶（链表）中的元素数量 >= 8 时，会将链表转化为红黑树
     * 目的是优化查询效率：链表 O(n) → 红黑树 O(log n)
     */
    static final int TREEIFY_THRESHOLD = 8;

    /**
     * 当红黑树中元素个数 <= 6 时，会退化回链表
     * 避免在小数据量下使用红黑树带来的额外性能开销
     */
    static final int UNTREEIFY_THRESHOLD = 6;

    /**
     * 当 HashMap 容量 < 64 时，即使单个桶的元素数量 >= 8
     * 也不会立刻转为红黑树，而是先进行扩容
     * 目的是避免过早使用红黑树
     */
    static final int MIN_TREEIFY_CAPACITY = 64;

    // ---------------------- 成员变量部分 ----------------------

    /**
     * 存储数据的数组，类型为 Node[]
     * Node 是 HashMap 的基本存储结构，包含 key-value 对
     * 初始为 null，第一次 put 时才真正初始化
     */
    transient Node<K,V>[] table;

    /**
     * 缓存的 entrySet
     * 用于实现 entrySet() 方法时的返回结果（提高效率）
     */
    transient Set<Map.Entry<K,V>> entrySet;

    /**
     * HashMap 当前存储的键值对数量
     */
    transient int size;

    /**
     * HashMap 结构性修改的次数
     * 结构性修改：改变了 HashMap 中元素数量的操作
     * 例如 put/remove/resize 等
     * fail-fast 机制依赖这个值
     */
    transient int modCount;

    /**
     * 阈值：触发扩容的界限
     * threshold = 容量 * 负载因子
     * 当 size 超过 threshold 时，触发扩容
     */
    int threshold;

    /**
     * 负载因子（可自定义，默认 0.75）
     */
    final float loadFactor;

}
``` 

1. **四个构造方法**：
    
    - `HashMap()` → 默认容量 16，默认负载因子 0.75
        
    - `HashMap(int initialCapacity)` → 指定容量，负载因子 0.75
        
    - `HashMap(int initialCapacity, float loadFactor)` → 用户自定义
        
    - `HashMap(Map m)` → 直接用其他 map 构造
        
2. **设计要点**：
    
    - 延迟初始化：**table 并没有立刻分配内存**，而是等到第一次 `put` 时才真正初始化。
        
    - `threshold = tableSizeFor(initialCapacity)`：会把容量调整为 **大于等于传入值的最小 2 的幂次方**，保证位运算效率。

----- 
## Node<K,V>内部类
``` java
/**
 * HashMap 的基本存储结构：节点
 * 本质上是一个“单链表节点”，存储 key-value 键值对
 */
static class Node<K,V> implements Map.Entry<K,V> {
    final int hash;   // key 的哈希值（缓存起来，避免重复计算）
    final K key;      // 键
    V value;          // 值
    Node<K,V> next;   // 指向下一个节点（链表结构）

    /**
     * 构造方法：初始化一个节点
     */
    Node(int hash, K key, V value, Node<K,V> next) {
        this.hash = hash;
        this.key = key;
        this.value = value;
        this.next = next;
    }

    /**
     * 获取 key
     */
    public final K getKey()        { return key; }

    /**
     * 获取 value
     */
    public final V getValue()      { return value; }

    /**
     * 设置新的 value，并返回旧值
     */
    public final V setValue(V newValue) {
        V oldValue = value;
        value = newValue;
        return oldValue;
    }

    /**
     * 判断是否相等：先比较 key，再比较 value
     */
    public final boolean equals(Object o) {
        if (o == this)   // 如果是同一个对象
            return true;
        if (o instanceof Map.Entry) {
            Map.Entry<?,?> e = (Map.Entry<?,?>)o;
            if (Objects.equals(key, e.getKey()) &&
                Objects.equals(value, e.getValue()))
                return true;
        }
        return false;
    }

    /**
     * 计算 hashCode
     * 规则：key 的 hashCode ^ value 的 hashCode
     */
    public final int hashCode() {
        return Objects.hashCode(key) ^ Objects.hashCode(value);
    }

    /**
     * 便于调试时输出 Node 的内容
     * 格式：key=value
     */
    public final String toString() {
        return key + "=" + value;
    }
}

```

- **Node 的结构**：
    
    - `hash`：存放 key 的 hash 值（减少重复计算）。
        
    - `key`：键。
        
    - `value`：值。
        
    - `next`：下一个节点（链表结构）。
        
- **特点**：
    
    - Node 继承自 `Map.Entry`，所以可以作为 `entrySet` 的元素直接返回。
        
    - HashMap 底层就是一个 **数组 + 链表（或红黑树）**，数组存放的是 **Node 引用**。
        
- **扩展**：
    
    - 当链表太长（≥8 且容量 ≥64），Node 会被替换成 `TreeNode`（红黑树节点）。
        
    - `TreeNode` 继承自 Node，但有更多字段（父节点、左右子树等）。

---- 
## put方法
``` java
/**
 * 向 HashMap 中放入一个键值对 (key, value)
 *
 * @param key   要存储的键
 * @param value 要存储的值
 * @return 如果 key 已经存在，返回旧值；否则返回 null
 */
public V put(K key, V value) {
    // 调用核心方法 putVal
    return putVal(hash(key), key, value, false, true);
}

/**
 * HashMap 的核心插入方法
 *
 * @param hash key 的哈希值
 * @param key 键
 * @param value 值
 * @param onlyIfAbsent 如果为 true，则不覆盖旧值
 * @param evict 主要用于 LinkedHashMap，这里 HashMap 忽略
 */
final V putVal(int hash, K key, V value, boolean onlyIfAbsent,
               boolean evict) {
    Node<K,V>[] tab; Node<K,V> p; int n, i;

    // 1. 如果 table 还未初始化，则调用 resize 初始化
    if ((tab = table) == null || (n = tab.length) == 0)
        n = (tab = resize()).length;

    // 2. 计算桶下标：(n - 1) & hash
    // 如果该桶为空，则直接放入新节点
    if ((p = tab[i = (n - 1) & hash]) == null)
        tab[i] = newNode(hash, key, value, null);

    else {
        Node<K,V> e; K k;
        // 3. 如果桶里第一个节点的 key 与传入的 key 相同 → 覆盖
        if (p.hash == hash &&
            ((k = p.key) == key || (key != null && key.equals(k))))
            e = p;

        // 4. 如果是红黑树节点，则调用红黑树的 putTreeVal 方法
        else if (p instanceof TreeNode)
            e = ((TreeNode<K,V>)p).putTreeVal(this, tab, hash, key, value);

        // 5. 否则就是链表：遍历链表，找到相同 key 或在末尾插入
        else {
            for (int binCount = 0; ; ++binCount) {
                if ((e = p.next) == null) {
                    // 插入到链表末尾
                    p.next = newNode(hash, key, value, null);
                    // 如果链表长度 >= 8，则转化为红黑树
                    if (binCount >= TREEIFY_THRESHOLD - 1)
                        treeifyBin(tab, hash);
                    break;
                }
                // 找到相同 key，退出循环，后续覆盖 value
                if (e.hash == hash &&
                    ((k = e.key) == key || (key != null && key.equals(k))))
                    break;
                p = e;
            }
        }

        // 6. 如果找到了相同 key 的节点，则覆盖旧值
        if (e != null) {
            V oldValue = e.value;
            if (!onlyIfAbsent || oldValue == null)
                e.value = value;
            afterNodeAccess(e); // 钩子方法，LinkedHashMap 会用
            return oldValue;
        }
    }

    // 7. 成功插入新节点后，结构性修改次数 +1
    ++modCount;

    // 8. 如果 size 超过 threshold，则扩容
    if (++size > threshold)
        resize();

    afterNodeInsertion(evict); // 钩子方法，LinkedHashMap 会用
    return null;
}
``` 

- **懒加载 table**：如果还没初始化，先 `resize()`。
    
- **定位桶下标**：通过 `(n - 1) & hash`，效率比取模高。
    
- **三种插入情况**：
    
    - 桶为空 → 直接放入。
        
    - 桶非空 → 分三类：
        
        - key 相同 → 覆盖 value。
            
        - 桶为红黑树 → 调用红黑树插入。
            
        - 桶为链表 → 遍历，找到相同 key 覆盖，否则插入末尾。
            
- **链表树化**：当链表长度 ≥ 8 且容量 ≥ 64 → 转换为红黑树。
    
- **扩容检查**：插入完成后，若 `size > threshold` → 扩容。


## resize（扩容方法）
- **resize** 是 HashMap 的性能关键点之一
- 
``` java
/**
 * 扩容 & 初始化方法
 * 1. 如果 table 为 null，就进行第一次初始化
 * 2. 如果 size > threshold，就扩容为原来的 2 倍
 *
 * @return 扩容后的新 table
 */
final Node<K,V>[] resize() {
    Node<K,V>[] oldTab = table;   // 保存旧的 table
    int oldCap = (oldTab == null) ? 0 : oldTab.length; // 旧容量
    int oldThr = threshold;       // 旧阈值（扩容临界点）
    int newCap, newThr = 0;       // 新容量、新阈值

    // 1. 如果旧容量大于 0
    if (oldCap > 0) {
        // 如果旧容量已经达到最大值（2^30）
        if (oldCap >= MAXIMUM_CAPACITY) {
            threshold = Integer.MAX_VALUE; // 不再扩容
            return oldTab;
        }
        // 否则容量翻倍，阈值也翻倍
        else if ((newCap = oldCap << 1) < MAXIMUM_CAPACITY &&
                 oldCap >= DEFAULT_INITIAL_CAPACITY)
            newThr = oldThr << 1; // 阈值翻倍
    }
    // 2. 如果旧容量 == 0，但旧阈值 > 0
    // 说明是调用了带初始容量的构造方法，还未分配数组
    else if (oldThr > 0)
        newCap = oldThr; // 容量 = 阈值（这里阈值是 tableSizeFor 算出来的）

    // 3. 否则是第一次初始化（调用无参构造）
    else {
        newCap = DEFAULT_INITIAL_CAPACITY;       // 容量 = 16
        newThr = (int)(DEFAULT_LOAD_FACTOR * DEFAULT_INITIAL_CAPACITY); // 阈值 = 12
    }

    // 4. 如果新阈值为 0，则根据负载因子计算
    if (newThr == 0) {
        float ft = (float)newCap * loadFactor;
        newThr = (newCap < MAXIMUM_CAPACITY && ft < (float)MAXIMUM_CAPACITY ?
                  (int)ft : Integer.MAX_VALUE);
    }
    threshold = newThr; // 更新阈值

    // 5. 分配新的数组（容量 newCap）
    @SuppressWarnings({"rawtypes","unchecked"})
    Node<K,V>[] newTab = (Node<K,V>[])new Node[newCap];
    table = newTab;

    // 6. 如果旧数组不为空，把元素搬迁过来
    if (oldTab != null) {
        for (int j = 0; j < oldCap; ++j) {
            Node<K,V> e;
            if ((e = oldTab[j]) != null) {
                oldTab[j] = null; // 释放引用，方便 GC
                // 如果桶里只有一个节点，直接放到新表中
                if (e.next == null)
                    newTab[e.hash & (newCap - 1)] = e;
                // 如果是红黑树，拆分到新桶
                else if (e instanceof TreeNode)
                    ((TreeNode<K,V>)e).split(this, newTab, j, oldCap);
                // 否则是链表，进行“低位/高位”拆分
                else {
                    Node<K,V> loHead = null, loTail = null;
                    Node<K,V> hiHead = null, hiTail = null;
                    Node<K,V> next;
                    do {
                        next = e.next;
                        // 判断节点在新表中的位置：低位桶 or 高位桶
                        if ((e.hash & oldCap) == 0) {
                            if (loTail == null)
                                loHead = e;
                            else
                                loTail.next = e;
                            loTail = e;
                        }
                        else {
                            if (hiTail == null)
                                hiHead = e;
                            else
                                hiTail.next = e;
                            hiTail = e;
                        }
                    } while ((e = next) != null);

                    // 低位桶放在原索引位置
                    if (loTail != null) {
                        loTail.next = null;
                        newTab[j] = loHead;
                    }
                    // 高位桶放在原索引 + oldCap 的位置
                    if (hiTail != null) {
                        hiTail.next = null;
                        newTab[j + oldCap] = hiHead;
                    }
                }
            }
        }
    }
    return newTab;
}

``` 
- **什么时候扩容？**
    
    - 第一次 `put` 时初始化。
        
    - `size > threshold` 时扩容。
        
- **容量 & 阈值变化**：
    
    - 容量翻倍，阈值也翻倍。
        
    - 最大容量限制：2^30。
        
- **搬迁规则**：
    
    - 单节点：直接放到新桶。
        
    - 红黑树：调用 `split()`，重新分布到新桶。
        
    - 链表：利用 `(e.hash & oldCap)` 判断分到 **低位桶（原索引 j）** 或 **高位桶（j+oldCap）**，不需要重新计算 hash。
        
    
    👉 这是 JDK 8 对比 JDK 7 的重大优化：避免了重新计算 hash，提高了性能。