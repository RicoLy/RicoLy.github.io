---
layout: post
title: Go结构体的内存布局
category: Golang
tags: Golang
description: Go结构体的内存布局
---

本文介绍了Go语言结构体的内存对齐现象和对齐策略，并通过一些具体示例介绍了Go语言中结构体内存布局的特殊场景。

结构体的内存布局
--------

### 结构体大小

结构体是占用一块连续的内存，一个结构体变量的大小是由结构体中的字段决定。

    type Foo struct {
    	A int8 // 1
    	B int8 // 1
    	C int8 // 1
    }
    
    var f Foo
    fmt.Println(unsafe.Sizeof(f))  // 3


### 内存对齐

但是结构体的大小又不完全由结构体的字段决定，例如：

    type Bar struct {
    	x int32 // 4
    	y *Foo  // 8
    	z bool  // 1
    }
    
    var b1 Bar
    fmt.Println(unsafe.Sizeof(b1)) // 24


有的同学可能会认为结构体变量`b1`的内存布局如下图所示，那么问题来了，结构体变量`b1`的大小怎么会是24呢？

![memory layout of Bar1](/assets/image/struct01.png)

很显然结构体变量`b1`的内存布局和上图中的并不一致，实际上的布局应该如下图所示，灰色虚线的部分就是内存对齐时的填充（padding）部分。

![memory layout of Bar1](/assets/image/struct02.png)

Go 在编译的时候会按照一定的规则自动进行内存对齐。之所以这么设计是为了减少 CPU 访问内存的次数，加大 CPU 访问内存的吞吐量。如果不进行内存对齐的话，很可能就会增加CPU访问内存的次数。例如下图中CPU想要获取`b1.y`字段的值可能就需要两次总线周期。

![word size](/assets/image/struct03.png)

因为 CPU 访问内存时，并不是逐个字节访问，而是以字（word）为单位访问。比如 64位CPU的字长（word size）为8bytes，那么CPU访问内存的单位也是8字节，每次加载的内存数据也是固定的若干字长，如8words（64bytes）、16words(128bytes）等。

### 对齐保证

我们上面已经知道了可以通过内置`unsafe`包的`Sizeof`函数来获取一个变量的大小，此外我们还可以通过内置`unsafe`包的`Alignof`函数来获取一个变量的对齐系数，例如：

    // 结构体变量b1的对齐系数
    fmt.Println(unsafe.Alignof(b1))   // 8
    // b1每一个字段的对齐系数
    fmt.Println(unsafe.Alignof(b1.x)) // 4：表示此字段须按4的倍数对齐
    fmt.Println(unsafe.Alignof(b1.y)) // 8：表示此字段须按8的倍数对齐
    fmt.Println(unsafe.Alignof(b1.z)) // 1：表示此字段须按1的倍数对齐


`unsafe.Alignof()`的规则如下：

*   对于任意类型的变量 x ，`unsafe.Alignof(x)` 至少为 1。
*   对于 struct 类型的变量 x，计算 x 每一个字段 f 的 `unsafe.Alignof(x.f)`，`unsafe.Alignof(x)` 等于其中的最大值。
*   对于 array 类型的变量 x，`unsafe.Alignof(x)` 等于构成数组的元素类型的对齐倍数。

在了解了上面的规则之后，我们就可以通过调整结构体 Bar 中字段的顺序来减少其大小：

    type Bar2 struct {
    	x int32 // 4
    	z bool  // 1
    	y *Foo  // 8
    }
    
    var b2 Bar2
    fmt.Println(unsafe.Sizeof(b2)) // 16


此时结构体 Bar2 变量的内存布局示意图如下：

![memory layout of Bar2](/assets/image/struct04.png)

或者将字段顺序调整为以下顺序。

    type Bar3 struct {
    	z bool  // 1
    	x int32 // 4
    	y *Foo  // 8
    }
    
    var b3 Bar3
    fmt.Println(unsafe.Sizeof(b3)) // 16


此时结构体 Bar3 变量的内存布局示意图如下：

![memory layout of Bar3](/assets/image/struct05.png)

总结一下：在了解了Go的内存对齐规则之后，我们在日常的编码过程中，完全可以通过合理地调整结构体的字段顺序，从而优化结构体的大小。

结构体内存布局的特殊场景
------------

除了上述利用内存对齐规则调整字段顺序优化结构体内存布局外，关于Go语言中结构体的内存布局还存在以下几种相对特殊的场景需要注意。

### 空结构体字段对齐

首先我们需要了解的一个前提是：如果结构或数组类型不包含大小大于零的字段（或元素），则其大小为0。两个不同的0大小变量在内存中可能有相同的地址。

由于空结构体`struct{}`的大小为 0，所以当一个结构体中包含空结构体类型的字段时，通常不需要进行内存对齐。例如：

    type Demo1 struct {
    	m struct{} // 0
    	n int8     // 1
    }
    
    var d1 Demo1
    fmt.Println(unsafe.Sizeof(d1))  // 1


但是当空结构体类型作为结构体的最后一个字段时，如果有指向该字段的指针，那么就会返回该结构体之外的地址。为了避免内存泄露会额外进行一次内存对齐。

    type Demo2 struct {
    	n int8     // 1
    	m struct{} // 0
    }
    
    var d2 Demo2
    fmt.Println(unsafe.Sizeof(d2))  // 2


示意图：

![empty struct memory layout](/assets/image/struct06.png)

在实际编程中通过灵活应用空结构体大小为0的特性能够帮助我们节省很多不必要的内存开销。

例如，我们可以使用空结构体作为map的值来实现一个类似 Set 的数据结构。

    var set map[int]struct{} 


我们还可以使用空结构体作为通知类channel的元素，例如Go源码`src/cmd/internal/base/signal.go`中。

    // src/cmd/internal/base/signal.go
    
    // Interrupted is closed when the go command receives an interrupt signal.
    var Interrupted = make(chan struct{})



以及 `src/net/pipe.go`中都有类似的使用示例。

    // src/net/pipe.go
    
    // pipeDeadline is an abstraction for handling timeouts.
    type pipeDeadline struct {
    	mu     sync.Mutex // Guards timer and cancel
    	timer  *time.Timer
    	cancel chan struct{} // Must be non-nil
    }


### 原子操作在32位平台要求强制内存对齐

在 x86 平台上原子操作需要强制内存对齐是因为在 32bit 平台下进行 64bit 原子操作要求必须 8 字节对齐，否则程序会 panic，下面是Go源码`src/atomic/doc.go`中的说明。

    // src/atomic/doc.go
    
    // BUG(rsc): On 386, the 64-bit functions use instructions unavailable before the Pentium MMX.
    //
    // On non-Linux ARM, the 64-bit functions use instructions unavailable before the ARMv6k core.
    //
    // On ARM, 386, and 32-bit MIPS, it is the caller's responsibility
    // to arrange for 64-bit alignment of 64-bit words accessed atomically.
    // The first word in a variable or in an allocated struct, array, or slice can
    // be relied upon to be 64-bit aligned.


这里可以参照[groupcache](https://github.com/golang/groupcache/blob/master/groupcache.go#L170)库中的实际应用，示例代码如下。

    type Group struct {
    	name       string
    	getter     Getter
    	peersOnce  sync.Once
    	peers      PeerPicker
    	cacheBytes int64 // limit for sum of mainCache and hotCache size
    
    	// mainCache is a cache of the keys for which this process
    	// (amongst its peers) is authoritative. That is, this cache
    	// contains keys which consistent hash on to this process's
    	// peer number.
    	mainCache cache
    
    	// hotCache contains keys/values for which this peer is not
    	// authoritative (otherwise they would be in mainCache), but
    	// are popular enough to warrant mirroring in this process to
    	// avoid going over the network to fetch from a peer.  Having
    	// a hotCache avoids network hotspotting, where a peer's
    	// network card could become the bottleneck on a popular key.
    	// This cache is used sparingly to maximize the total number
    	// of key/value pairs that can be stored globally.
    	hotCache cache
    
    	// loadGroup ensures that each key is only fetched once
    	// (either locally or remotely), regardless of the number of
    	// concurrent callers.
    	loadGroup flightGroup
    
    	_ int32 // force Stats to be 8-byte aligned on 32-bit platforms
    
    	// Stats are statistics on the group.
    	Stats Stats
    }
    
    // ...
    
    // Stats are per-group statistics.
    type Stats struct {
    	Gets           AtomicInt // any Get request, including from peers
    	CacheHits      AtomicInt // either cache was good
    	PeerLoads      AtomicInt // either remote load or remote cache hit (not an error)
    	PeerErrors     AtomicInt
    	Loads          AtomicInt // (gets - cacheHits)
    	LoadsDeduped   AtomicInt // after singleflight
    	LocalLoads     AtomicInt // total good local loads
    	LocalLoadErrs  AtomicInt // total bad local loads
    	ServerRequests AtomicInt // gets that came over the network from peers
    }


`Group`结构体中通过添加一个`int32`字段强制让`Stats`字段在32bit平台也是8字节对齐的。

### fasle sharing

结构体内存对齐除了上面的场景外，在一些需要防止CacheLine伪共享的时候，也需要进行特殊的字段对齐。例如`sync.Pool`中就有这种设计：

    type poolLocal struct {
    	poolLocalInternal
    
    	// Prevents false sharing on widespread platforms with
    	// 128 mod (cache line size) = 0 .
    	pad [128 - unsafe.Sizeof(poolLocalInternal{})%128]byte
    }


结构体中的`pad`字段就是为了防止false sharing而设计的。

> 当不同的线程同时读写同一个cache line上不同数据时就可能发生false sharing。false sharing会导致多核处理器上严重的系统性能下降。具体的可以参考 [伪共享(False Sharing)](http://ifeve.com/falsesharing/)。

如注释所说这里之所以使用128字节进行内存对齐是为了兼容更多的平台。

### hot path

hot path 是指执行非常频繁的指令序列。

在访问结构体的第一个字段时，我们可以直接使用结构体的指针来访问第一个字段（结构体变量的内存地址就是其第一个字段的内存地址）。

如果要访问结构体的其他字段，除了结构体指针外，还需要计算与第一个值的偏移(calculate offset)。在机器码中，偏移量是随指令传递的附加值，CPU 需要做一次偏移值与指针的加法运算，才能获取要访问的值的地址。因为访问第一个字段的机器代码更紧凑，速度更快。

下面的代码是标准库`sync.Once`中的使用示例，通过将常用字段放置在结构体的第一个位置上减少CPU要执行的指令数量，从而达到更快的访问效果。

    // src/sync/once.go 
    
    // Once is an object that will perform exactly one action.
    //
    // A Once must not be copied after first use.
    type Once struct {
    	// done indicates whether the action has been performed.
    	// It is first in the struct because it is used in the hot path.
    	// The hot path is inlined at every call site.
    	// Placing done first allows more compact instructions on some architectures (amd64/386),
    	// and fewer instructions (to calculate offset) on other architectures.
    	done uint32
    	m    Mutex
    }


参考链接：[https://stackoverflow.com/questions/59174176/what-does-hot-path-mean-in-the-context-of-sync-once](https://stackoverflow.com/questions/59174176/what-does-hot-path-mean-in-the-context-of-sync-once)
