---
layout: post
title: Go进阶17:深度解密Go语言之channel
category: Golang
tags: Golang
description: Go进阶17:深度解密Go语言之channel
---

![深度解密Go语言之channel](/assets/image/ginbro_coverage.jpg)

##### Referred From [https://segmentfault.com/a/1190000019839546](https://segmentfault.com/a/1190000019839546)

并发与并行
-----

大家都知道著名的摩尔定律.1965 年,时任仙童公司的 Gordon Moore 发表文章,预测在未来十年,半导体芯片上的晶体管和电阻数量将每年增加一倍;1975 年,Moore 再次发表论文,将“每年”修改为“每两年”.这个预测在 2012 年左右基本是正确的.

但随着晶体管电路逐渐接近性能极限,摩尔定律终将走到尽头.靠增加晶体管数量来提高计算机的性能不灵了.于是,人们开始转换思路,用其他方法来提升计算机的性能,这就是多核计算机产生的原因.

这一招看起来还不错,但是人们又遇到了一个另一个定律的限制,那就是 Amdahl’s Law,它提出了一个模型用来衡量在并行模式下程序运行效率的提升.这个定律是说,一个程序能从并行上获得性能提升的上限取决于有多少代码必须写成串行的.

举个例子,对于一个和用户打交道的界面程序,它必须和用户打交道.用户点一个按钮,然后才能继续运行下一步,这必须是串行执行的.这种程序的运行效率就取决于和用户交互的速度,您有多少核都白瞎.用户就是不按下一步,您怎么办？

2000 年左右云计算兴起,人们可以方便地获取计算云上的资源,方便地水平扩展自己的服务,可以轻而易举地就调动多台机器资源甚至将计算任务分发到分布在全球范围的机器.但是也因此带来了很多问题和挑战.例如怎样在机器间进行通信,聚合结果等.最难的一个挑战是如何找到一个模型能用来描述 concurrent.

我们都知道,要想一段并发的代码没有任何 bug,是非常困难的.有些并发 bug 是在系统上线数年后才发现的,原因常常是很诡异的,比如用户数增加到了某个界限.

并发问题一般有下面这几种：

数据竞争.简单来说就是两个或多个线程同时读写某个变量,造成了预料之外的结果.

原子性.在一个定义好的上下文里,原子性操作不可分割.上下文的定义非常重要.有些代码,您在程序里看起来是原子的,如最简单的 i++,但在机器层面看来,这条语句通常需要几条指令来完成（Load,Incr,Store）,不是不可分割的,也就不是原子性的.原子性可以让我们放心地构造并发安全的程序.

内存访问同步.代码中需要控制同时只有一个线程访问的区域称为临界区.Go 语言中一般使用 sync 包里的 Mutex 来完成同步访问控制.锁一般会带来比较大的性能开销,因此一般要考虑加锁的区域是否会频繁进入,锁的粒度如何控制等问题.

死锁.在一个死锁的程序里,每个线程都在等待其他线程,形成了一个首尾相连的尴尬局面,程序无法继续运行下去.

活锁.想象一下,您走在一条小路上,一个人迎面走来.您往左边走,想避开他;他做了相反的事情,他往右边走,结果两个都过不了.之后,两个人又都想从原来自己相反的方向走,还是同样的结果.这就是活锁,看起来都像在工作,但工作进度就是无法前进.

饥饿.并发的线程不能获取它所需要的资源以进行下一步的工作.通常是有一个非常贪婪的线程,长时间占据资源不释放,导致其他线程无法获得资源.

关于并发和并行的区别,引用一个经典的描述：

> 并发是同一时间应对（dealing with）多件事情的能力.
>
> 并行是同一时间动手（doing）做多件事情的能力.

雨痕老师《Go 语言学习笔记》上的解释：

> 并发是指逻辑上具备同时处理多个任务的能力;并行则是物理上同时执行多个任务.

而根据《Concurrency in Go》这本书,计算机的概念都是抽象的结果,并发和并行也不例外.它这样描述并发和并行的区别：

> Concurrency is a property of the code; parallelism is a property of the running program.

并发是代码的特性,并行是正在运行的程序的特性.先忽略我拙劣的翻译.很新奇,不是吗？我也是第一次见到这样的说法,细想一下,还是很有道理的.

我们一直说写的代码是并发的或者是并行的,但是我们能提供什么保证吗？如果在只有一个核的机器上跑并行的代码,它还能并行吗？您就是再天才,也无法写出并行的程序.充其量也就是代码上看起来“并发”的,如此而已.

当然,表面上看起来还是并行的,但那不过 CPU 的障眼法,多个线程在分时共享 CPU 的资源,在一个粗糙的时间隔里看起来就是“并行”.

所以,我们实际上只能编写“并发”的代码,而不能编写“并行”的代码,而且只是希望并发的代码能够并行地执行.并发的代码能否并行,取决于抽象的层级：代码里的并发原语,runtime,操作系统（虚拟机,容器）.层级越来越底层,要求也越来越高.因此,我们谈并发或并行实际上要指定上下文,也就是抽象的层级.

《Concurrency in Go》书里举了一个例子：假如两个人同时打开电脑上的计算器程序,这两个程序肯定不会影响彼此,这就是并行.在这个例子中,上下文就是两个人的机器,而两个计算器进程就是并行的元素.

随着抽象层次的降低,并发模型实际上变得更难也更重要,而越低层次的并发模型对我们也越重要.要想并发程序正确地执行,就要深入研究并发模型.

在 Go 语言发布前,我们写并发代码时,考虑到的最底层抽象是：系统线程.Go 发布之后,在这条抽象链上,又加一个 goroutine.而且 Go 从著名的计算机科学家 Tony Hoare 那借来一个概念：channel.Tony Hoare 就是那篇著名文章《Communicating Sequential Processes》的作者.

看起来事情变得更加复杂,因为 Go 又引入了一个更底层的抽象,但事实并不是这样.因为 goroutine 并不是看起来的那样又抽象了一层,它其实是替代了系统线程.Gopher 在写代码的时候,并不会去关心系统线程,大部分时候只需要考虑到 goroutine 和 channel.当然有时候会用到一些共享内存的概念,一般就是指 sync 包里的东西,比如 sync.Mutex.

什么是 CSP
-------

CSP 经常被认为是 Go 在并发编程上成功的关键因素.CSP 全称是 “Communicating Sequential Processes”,这也是 Tony Hoare 在 1978 年发表在 ACM 的一篇论文.论文里指出一门编程语言应该重视 input 和 output 的原语,尤其是并发编程的代码.

在那篇文章发表的时代,人们正在研究模块化编程的思想,该不该用 goto 语句在当时是最激烈的议题.彼时,面向对象编程的思想正在崛起,几乎没什么人关心并发编程.

在文章中,CSP 也是一门自定义的编程语言,作者定义了输入输出语句,用于 processes 间的通信（communicatiton）.processes 被认为是需要输入驱动,并且产生输出,供其他 processes 消费,processes 可以是进程,线程,甚至是代码块.输入命令是：!,用来向 processes 写入;输出是：?,用来从 processes 读出.这篇文章要讲的 channel 正是借鉴了这一设计.

Hoare 还提出了一个 -> 命令,如果 -> 左边的语句返回 false,那它右边的语句就不会执行.

通过这些输入输出命令,Hoare 证明了如果一门编程语言中把 processes 间的通信看得第一等重要,那么并发编程的问题就会变得简单.

Go 是第一个将 CSP 的这些思想引入,并且发扬光大的语言.仅管内存同步访问控制（原文是 memory access synchronization）在某些情况下大有用处,Go 里也有相应的 sync 包支持,但是这在大型程序很容易出错.

Go 一开始就把 CSP 的思想融入到语言的核心里,所以并发编程成为 Go 的一个独特的优势,而且很容易理解.

大多数的编程语言的并发编程模型是基于线程和内存同步访问控制,Go 的并发编程的模型则用 goroutine 和 channel 来替代.Goroutine 和线程类似,channel 和 mutex (用于内存同步访问控制)类似.

Goroutine 解放了程序员,让我们更能贴近业务去思考问题.而不用考虑各种像线程库,线程开销,线程调度等等这些繁琐的底层问题,goroutine 天生替您解决好了.

Channel 则天生就可以和其他 channel 组合.我们可以把收集各种子系统结果的 channel 输入到同一个 channel.Channel 还可以和 select, cancel, timeout 结合起来.而 mutex 就没有这些功能.

Go 的并发原则非常优秀,目标就是简单：尽量使用 channel;把 goroutine 当作免费的资源,随便用.

说明一下,前面这两部分的内容来自英文开源书《Concurrency In Go》,强烈推荐阅读.

引入结束,我们正式开始今天的主角：channel.

什么是 channel
===========

Goroutine 和 channel 是 Go 语言并发编程的 两大基石.Goroutine 用于执行并发任务,channel 用于 goroutine 之间的同步,通信.

Channel 在 gouroutine 间架起了一条管道,在管道里传输数据,实现 gouroutine 间的通信;由于它是线程安全的,所以用起来非常方便;channel 还提供“先进先出”的特性;它还能影响 goroutine 的阻塞和唤醒.

相信大家一定见过一句话：

> Do not communicate by sharing memory; instead, share memory by communicating.

不要通过共享内存来通信,而要通过通信来实现内存共享.

这就是 Go 的并发哲学,它依赖 CSP 模型,基于 channel 实现.

简直是一头雾水,这两句话难道不是同一个意思？

通过前面两节的内容,我个人这样理解这句话：前面半句说的是通过 sync 包里的一些组件进行并发编程;而后面半句则是说 Go 推荐使用 channel 进行并发编程.两者其实都是必要且有效的.实际上看完本文后面对 channel 的源码分析,您会发现,channel 的底层就是通过 mutex 来控制并发的.只是 channel 是更高一层次的并发编程原语,封装了更多的功能.

关于是选择 sync 包里的底层并发编程原语还是 channel,《Concurrency In Go》这本书的第 2 章 “Go’s Philosophy on Concurrency” 里有一张决策树和详细的论述,再次推荐您去阅读.我把图贴出来：

![tech.ricoly.cn_concurrency code decision tree](/assets/image/c2dtZl8vaW1nL3JlbW90ZS8xNDYwMDAwMDE5ODM5NTU3.jpg)

channel 实现 CSP
--------------

Channel 是 Go 语言中一个非常重要的类型,是 Go 里的第一对象.通过 channel,Go 实现了通过通信来实现内存共享.Channel 是在多个 goroutine 之间传递数据和同步的重要手段.

使用原子函数,读写锁可以保证资源的共享访问安全,但使用 channel 更优雅.

channel 字面意义是“通道”,类似于 Linux 中的管道.声明 channel 的语法如下：

    chan T // 声明一个双向通道
    chan<- T // 声明一个只能用于发送的通道
    <-chan T // 声明一个只能用于接收的通道


单向通道的声明,用 `<-` 来表示,它指明通道的方向.您只要明白,代码的书写顺序是从左到右就马上能掌握通道的方向是怎样的.

因为 channel 是一个引用类型,所以在它被初始化之前,它的值是 nil,channel 使用 make 函数进行初始化.可以向它传递一个 int 值,代表 channel 缓冲区的大小（容量）,构造出来的是一个缓冲型的 channel;不传或传 0 的,构造的就是一个非缓冲型的 channel.

两者有一些差别：非缓冲型 channel 无法缓冲元素,对它的操作一定顺序是“发送-> 接收 -> 发送 -> 接收 -> ……”,如果连续向一个非缓冲 chan 发送 2 个元素,并且没有接收的话,第二次一定会被阻塞;对于缓冲型 channel 的操作,则要“宽松”一些,毕竟是带了“缓冲”光环.

为什么要 channel
============

Go 通过 channel 实现 CSP 通信模型,主要用于 goroutine 之间的消息传递和事件通知.

有了 channel 和 goroutine 之后,Go 的并发编程变得异常容易和安全,得以让程序员把注意力留到业务上去,实现开发效率的提升.

要知道,技术并不是最重要的,它只是实现业务的工具.一门高效的开发语言让您把节省下来的时间,留着去做更有意义的事情,比如写写文章.

channel 实现原理
============

对 chan 的发送和接收操作都会在编译期间转换成为底层的发送接收函数.

Channel 分为两种：带缓冲,不带缓冲.对不带缓冲的 channel 进行的操作实际上可以看作“同步模式”,带缓冲的则称为“异步模式”.

同步模式下,发送方和接收方要同步就绪,只有在两者都 ready 的情况下,数据才能在两者间传输（后面会看到,实际上就是内存拷贝）.否则,任意一方先行进行发送或接收操作,都会被挂起,等待另一方的出现才能被唤醒.

异步模式下,在缓冲槽可用的情况下（有剩余容量）,发送和接收操作都可以顺利进行.否则,操作的一方（如写入）同样会被挂起,直到出现相反操作（如接收）才会被唤醒.

小结一下：同步模式下,必须要使发送方和接收方配对,操作才会成功,否则会被阻塞;异步模式下,缓冲槽要有剩余容量,操作才会成功,否则也会被阻塞.

数据结构
----

直接上源码（版本是 1.9.2）：

    type hchan struct {
        // chan 里元素数量
        qcount   uint
        // chan 底层循环数组的长度
        dataqsiz uint
        // 指向底层循环数组的指针
        // 只针对有缓冲的 channel
        buf      unsafe.Pointer
        // chan 中元素大小
        elemsize uint16
        // chan 是否被关闭的标志
        closed   uint32
        // chan 中元素类型
        elemtype *_type // element type
        // 已发送元素在循环数组中的索引
        sendx    uint   // send index
        // 已接收元素在循环数组中的索引
        recvx    uint   // receive index
        // 等待接收的 goroutine 队列
        recvq    waitq  // list of recv waiters
        // 等待发送的 goroutine 队列
        sendq    waitq  // list of send waiters
    
        // 保护 hchan 中所有字段
        lock mutex
    }


关于字段的含义都写在注释里了,再来重点说几个字段：

`buf` 指向底层循环数组,只有缓冲型的 channel 才有.

`sendx`,`recvx` 均指向底层循环数组,表示当前可以发送和接收的元素位置索引值（相对于底层数组）.

`sendq`,`recvq` 分别表示被阻塞的 goroutine,这些 goroutine 由于尝试读取 channel 或向 channel 发送数据而被阻塞.

`waitq` 是 `sudog` 的一个双向链表,而 `sudog` 实际上是对 goroutine 的一个封装：

    type waitq struct {
        first *sudog
        last  *sudog
    }


`lock` 用来保证每个读 channel 或写 channel 的操作都是原子的.

例如,创建一个容量为 6 的,元素为 int 型的 channel 数据结构如下 ：

![tech.ricoly.cn_chan data structure](/assets/image/c2dtZl8vaW1nL3JlbW90ZS8xNDYwMDAwMDE5ODM5NTU4.jpg)

创建
--

我们知道,通道有两个方向,发送和接收.理论上来说,我们可以创建一个只发送或只接收的通道,但是这种通道创建出来后,怎么使用呢？一个只能发的通道,怎么接收呢？同样,一个只能收的通道,如何向其发送数据呢？

一般而言,使用 `make` 创建一个能收能发的通道：

    // 无缓冲通道
    ch1 := make(chan int)
    // 有缓冲通道
    ch2 := make(chan int, 10)


通过[汇编](https://mp.weixin.qq.com/s/obnnVkO2EiFnuXk_AIDHWw)分析,我们知道,最终创建 chan 的函数是 `makechan`：

    func makechan(t *chantype, size int64) *hchan


从函数原型来看,创建的 chan 是一个指针.所以我们能在函数间直接传递 channel,而不用传递 channel 的指针.

具体来看下代码：

    const hchanSize = unsafe.Sizeof(hchan{}) + uintptr(-int(unsafe.Sizeof(hchan{}))&(maxAlign-1))
    
    func makechan(t *chantype, size int64) *hchan {
        elem := t.elem
    
        // 省略了检查 channel size,align 的代码
        // ……
    
        var c *hchan
        // 如果元素类型不含指针 或者 size 大小为 0（无缓冲类型）
        // 只进行一次内存分配
        if elem.kind&kindNoPointers != 0 || size == 0 {
            // 如果 hchan 结构体中不含指针,GC 就不会扫描 chan 中的元素
            // 只分配 "hchan 结构体大小 + 元素大小*个数" 的内存
            c = (*hchan)(mallocgc(hchanSize+uintptr(size)*elem.size, nil, true))
            // 如果是缓冲型 channel 且元素大小不等于 0（大小等于 0的元素类型：struct{}）
            if size > 0 && elem.size != 0 {
                c.buf = add(unsafe.Pointer(c), hchanSize)
            } else {
                // race detector uses this location for synchronization
                // Also prevents us from pointing beyond the allocation (see issue 9401).
                // 1. 非缓冲型的,buf 没用,直接指向 chan 起始地址处
                // 2. 缓冲型的,能进入到这里,说明元素无指针且元素类型为 struct{},也无影响
                // 因为只会用到接收和发送游标,不会真正拷贝东西到 c.buf 处（这会覆盖 chan的内容）
                c.buf = unsafe.Pointer(c)
            }
        } else {
            // 进行两次内存分配操作
            c = new(hchan)
            c.buf = newarray(elem, int(size))
        }
        c.elemsize = uint16(elem.size)
        c.elemtype = elem
        // 循环数组长度
        c.dataqsiz = uint(size)
    
        // 返回 hchan 指针
        return c
    }


新建一个 chan 后,内存在堆上分配,大概长这样：

![tech.ricoly.cn_make chan](/assets/image/c2dtZl8vaW1nL3JlbW90ZS8xNDYwMDAwMDE5ODM5NTU5.jpg)

说明一下,这张图来源于 Gopher Con 上的一份 PPT,地址见参考资料.这份材料非常清晰易懂,推荐您去读.

接下来,我们用一个来自参考资料【深入 channel 底层】的例子来理解创建,发送,接收的整个过程.

    func goroutineA(a <-chan int) {
        val := <- a
        fmt.Println("G1 received data: ", val)
        return
    }
    
    func goroutineB(b <-chan int) {
        val := <- b
        fmt.Println("G2 received data: ", val)
        return
    }
    
    func main() {
        ch := make(chan int)
        go goroutineA(ch)
        go goroutineB(ch)
        ch <- 3
        time.Sleep(time.Second)
    }


首先创建了一个无缓冲的 channel,接着启动两个 goroutine,并将前面创建的 channel 传递进去.然后,向这个 channel 中发送数据 3,最后 sleep 1 秒后程序退出.

程序第 14 行创建了一个非缓冲型的 channel,我们只看 chan 结构体中的一些重要字段,来从整体层面看一下 chan 的状态,一开始什么都没有：

![tech.ricoly.cn_unbuffered chan](/assets/image/c2dtZl8vaW1nL3JlbW90ZS8xNDYwMDAwMDE5ODM5NTYwP3c9MzMwJmg9NzM0.jpg)

接收
--

在继续分析前面小节的例子前,我们先来看一下接收相关的源码.在清楚了接收的具体过程之后,也就能轻松理解具体的例子了.

接收操作有两种写法,一种带 “ok”,反应 channel 是否关闭;一种不带 “ok”,这种写法,当接收到相应类型的零值时无法知道是真实的发送者发送过来的值,还是 channel 被关闭后,返回给接收者的默认类型的零值.两种写法,都有各自的应用场景.

经过编译器的处理后,这两种写法最后对应源码里的这两个函数：

    // entry points for <- c from compiled code
    func chanrecv1(c *hchan, elem unsafe.Pointer) {
        chanrecv(c, elem, true)
    }
    
    func chanrecv2(c *hchan, elem unsafe.Pointer) (received bool) {
        _, received = chanrecv(c, elem, true)
        return
    }


`chanrecv1` 函数处理不带 “ok” 的情形,`chanrecv2` 则通过返回 “received” 这个字段来反应 channel 是否被关闭.接收值则比较特殊,会“放到”参数 `elem` 所指向的地址了,这很像 C/C++ 里的写法.如果代码里忽略了接收值,这里的 elem 为 nil.

无论如何,最终转向了 `chanrecv` 函数：

    // 位于 src/runtime/chan.go
    
    // chanrecv 函数接收 channel c 的元素并将其写入 ep 所指向的内存地址.
    // 如果 ep 是 nil,说明忽略了接收值.
    // 如果 block == false,即非阻塞型接收,在没有数据可接收的情况下,返回 (false, false)
    // 否则,如果 c 处于关闭状态,将 ep 指向的地址清零,返回 (true, false)
    // 否则,用返回值填充 ep 指向的内存地址.返回 (true, true)
    // 如果 ep 非空,则应该指向堆或者函数调用者的栈
    
    func chanrecv(c *hchan, ep unsafe.Pointer, block bool) (selected, received bool) {
        // 省略 debug 内容 …………
    
        // 如果是一个 nil 的 channel
        if c == nil {
            // 如果不阻塞,直接返回 (false, false)
            if !block {
                return
            }
            // 否则,接收一个 nil 的 channel,goroutine 挂起
            gopark(nil, nil, "chan receive (nil chan)", traceEvGoStop, 2)
            // 不会执行到这里
            throw("unreachable")
        }
    
        // 在非阻塞模式下,快速检测到失败,不用获取锁,快速返回
        // 当我们观察到 channel 没准备好接收：
        // 1. 非缓冲型,等待发送列队 sendq 里没有 goroutine 在等待
        // 2. 缓冲型,但 buf 里没有元素
        // 之后,又观察到 closed == 0,即 channel 未关闭.
        // 因为 channel 不可能被重复打开,所以前一个观测的时候 channel 也是未关闭的,
        // 因此在这种情况下可以直接宣布接收失败,返回 (false, false)
        if !block && (c.dataqsiz == 0 && c.sendq.first == nil ||
            c.dataqsiz > 0 && atomic.Loaduint(&c.qcount) == 0) &&
            atomic.Load(&c.closed) == 0 {
            return
        }
    
        var t0 int64
        if blockprofilerate > 0 {
            t0 = cputicks()
        }
    
        // 加锁
        lock(&c.lock)
    
        // channel 已关闭,并且循环数组 buf 里没有元素
        // 这里可以处理非缓冲型关闭 和 缓冲型关闭但 buf 无元素的情况
        // 也就是说即使是关闭状态,但在缓冲型的 channel,
        // buf 里有元素的情况下还能接收到元素
        if c.closed != 0 && c.qcount == 0 {
            if raceenabled {
                raceacquire(unsafe.Pointer(c))
            }
            // 解锁
            unlock(&c.lock)
            if ep != nil {
                // 从一个已关闭的 channel 执行接收操作,且未忽略返回值
                // 那么接收的值将是一个该类型的零值
                // typedmemclr 根据类型清理相应地址的内存
                typedmemclr(c.elemtype, ep)
            }
            // 从一个已关闭的 channel 接收,selected 会返回true
            return true, false
        }
    
        // 等待发送队列里有 goroutine 存在,说明 buf 是满的
        // 这有可能是：
        // 1. 非缓冲型的 channel
        // 2. 缓冲型的 channel,但 buf 满了
        // 针对 1,直接进行内存拷贝（从 sender goroutine -> receiver goroutine）
        // 针对 2,接收到循环数组头部的元素,并将发送者的元素放到循环数组尾部
        if sg := c.sendq.dequeue(); sg != nil {
            // Found a waiting sender. If buffer is size 0, receive value
            // directly from sender. Otherwise, receive from head of queue
            // and add sender's value to the tail of the queue (both map to
            // the same buffer slot because the queue is full).
            recv(c, sg, ep, func() { unlock(&c.lock) }, 3)
            return true, true
        }
    
        // 缓冲型,buf 里有元素,可以正常接收
        if c.qcount > 0 {
            // 直接从循环数组里找到要接收的元素
            qp := chanbuf(c, c.recvx)
    
            // …………
    
            // 代码里,没有忽略要接收的值,不是 "<- ch",而是 "val <- ch",ep 指向 val
            if ep != nil {
                typedmemmove(c.elemtype, ep, qp)
            }
            // 清理掉循环数组里相应位置的值
            typedmemclr(c.elemtype, qp)
            // 接收游标向前移动
            c.recvx++
            // 接收游标归零
            if c.recvx == c.dataqsiz {
                c.recvx = 0
            }
            // buf 数组里的元素个数减 1
            c.qcount--
            // 解锁
            unlock(&c.lock)
            return true, true
        }
    
        if !block {
            // 非阻塞接收,解锁.selected 返回 false,因为没有接收到值
            unlock(&c.lock)
            return false, false
        }
    
        // 接下来就是要被阻塞的情况了
        // 构造一个 sudog
        gp := getg()
        mysg := acquireSudog()
        mysg.releasetime = 0
        if t0 != 0 {
            mysg.releasetime = -1
        }
    
        // 待接收数据的地址保存下来
        mysg.elem = ep
        mysg.waitlink = nil
        gp.waiting = mysg
        mysg.g = gp
        mysg.selectdone = nil
        mysg.c = c
        gp.param = nil
        // 进入channel 的等待接收队列
        c.recvq.enqueue(mysg)
        // 将当前 goroutine 挂起
        goparkunlock(&c.lock, "chan receive", traceEvGoBlockRecv, 3)
    
        // 被唤醒了,接着从这里继续执行一些扫尾工作
        if mysg != gp.waiting {
            throw("G waiting list is corrupted")
        }
        gp.waiting = nil
        if mysg.releasetime > 0 {
            blockevent(mysg.releasetime-t0, 2)
        }
        closed := gp.param == nil
        gp.param = nil
        mysg.c = nil
        releaseSudog(mysg)
        return true, !closed
    }


上面的代码注释地比较详细了,您可以对着源码一行行地去看,我们再来详细看一下.

*   如果 channel 是一个空值（nil）,在非阻塞模式下,会直接返回.在阻塞模式下,会调用 gopark 函数挂起 goroutine,这个会一直阻塞下去.因为在 channel 是 nil 的情况下,要想不阻塞,只有关闭它,但关闭一个 nil 的 channel 又会发生 panic,所以没有机会被唤醒了.更详细地可以在 closechan 函数的时候再看.
*   和发送函数一样,接下来搞了一个在非阻塞模式下,不用获取锁,快速检测到失败并且返回的操作.顺带插一句,我们平时在写代码的时候,找到一些边界条件,快速返回,能让代码逻辑更清晰,因为接下来的正常情况就比较少,更聚焦了,看代码的人也更能专注地看核心代码逻辑了.

          // 在非阻塞模式下,快速检测到失败,不用获取锁,快速返回 (false, false)
          if !block && (c.dataqsiz == 0 && c.sendq.first == nil ||
              c.dataqsiz > 0 && atomic.Loaduint(&c.qcount) == 0) &&
              atomic.Load(&c.closed) == 0 {
              return
          }



当我们观察到 channel 没准备好接收：

1.  非缓冲型,等待发送列队里没有 goroutine 在等待
2.  缓冲型,但 buf 里没有元素 之后,又观察到 closed == 0,即 channel 未关闭.

因为 channel 不可能被重复打开,所以前一个观测的时候, channel 也是未关闭的,因此在这种情况下可以直接宣布接收失败,快速返回.因为没被选中,也没接收到数据,所以返回值为 (false, false).

*   接下来的操作,首先会上一把锁,粒度比较大.如果 channel 已关闭,并且循环数组 buf 里没有元素.对应非缓冲型关闭和缓冲型关闭但 buf 无元素的情况,返回对应类型的零值,但 received 标识是 false,告诉调用者此 channel 已关闭,您取出来的值并不是正常由发送者发送过来的数据.但是如果处于 select 语境下,这种情况是被选中了的.很多将 channel 用作通知信号的场景就是命中了这里.
*   接下来,如果有等待发送的队列,说明 channel 已经满了,要么是非缓冲型的 channel,要么是缓冲型的 channel,但 buf 满了.这两种情况下都可以正常接收数据. 于是,调用 recv 函数：

    func recv(c *hchan, sg *sudog, ep unsafe.Pointer, unlockf func(), skip int) {
    // 如果是非缓冲型的 channel
    if c.dataqsiz == 0 {
    if raceenabled {
    racesync(c, sg)
    }
    // 未忽略接收的数据
    if ep != nil {
    // 直接拷贝数据,从 sender goroutine -> receiver goroutine
    recvDirect(c.elemtype, sg, ep)
    }
    } else {
    // 缓冲型的 channel,但 buf 已满.
    // 将循环数组 buf 队首的元素拷贝到接收数据的地址
    // 将发送者的数据入队.实际上这时 revx 和 sendx 值相等
    // 找到接收游标
    qp := chanbuf(c, c.recvx)
    // …………
    // 将接收游标处的数据拷贝给接收者
    if ep != nil {
    typedmemmove(c.elemtype, ep, qp)
    }

            // 将发送者数据拷贝到 buf
            typedmemmove(c.elemtype, qp, sg.elem)
            // 更新游标值
            c.recvx++
            if c.recvx == c.dataqsiz {
                c.recvx = 0
            }
            c.sendx = c.recvx
        }
        sg.elem = nil
        gp := sg.g

        // 解锁
        unlockf()
        gp.param = unsafe.Pointer(sg)
        if sg.releasetime != 0 {
            sg.releasetime = cputicks()
        }

        // 唤醒发送的 goroutine.需要等到调度器的光临
        goready(gp, skip+1)
    }


如果是非缓冲型的,就直接从发送者的栈拷贝到接收者的栈.

    func recvDirect(t *_type, sg *sudog, dst unsafe.Pointer) {
        // dst is on our stack or the heap, src is on another stack.
        src := sg.elem
        typeBitsBulkBarrier(t, uintptr(dst), uintptr(src), t.size)
        memmove(dst, src, t.size)
    }


否则,就是缓冲型 channel,而 buf 又满了的情形.说明发送游标和接收游标重合了,因此需要先找到接收游标：

    // chanbuf(c, i) is pointer to the i'th slot in the buffer.
    func chanbuf(c *hchan, i uint) unsafe.Pointer {
        return add(c.buf, uintptr(i)*uintptr(c.elemsize))
    }


将该处的元素拷贝到接收地址.然后将发送者待发送的数据拷贝到接收游标处.这样就完成了接收数据和发送数据的操作.接着,分别将发送游标和接收游标向前进一,如果发生“环绕”,再从 0 开始.

最后,取出 sudog 里的 goroutine,调用 goready 将其状态改成 “runnable”,待发送者被唤醒,等待调度器的调度.

*   然后,如果 channel 的 buf 里还有数据,说明可以比较正常地接收.注意,这里,即使是在 channel 已经关闭的情况下,也是可以走到这里的.这一步比较简单,正常地将 buf 里接收游标处的数据拷贝到接收数据的地址.
*   到了最后一步,走到这里来的情形是要阻塞的.当然,如果 block 传进来的值是 false,那就不阻塞,直接返回就好了. 先构造一个 sudog,接着就是保存各种值了.注意,这里会将接收数据的地址存储到了 `elem` 字段,当被唤醒时,接收到的数据就会保存到这个字段指向的地址.然后将 sudog 添加到 channel 的 recvq 队列里.调用 goparkunlock 函数将 goroutine 挂起.

接下来的代码就是 goroutine 被唤醒后的各种收尾工作了.

我们继续之前的例子.前面说到第 14 行,创建了一个非缓冲型的 channel,接着,第 15,16 行分别创建了一个 goroutine,各自执行了一个接收操作.通过前面的源码分析,我们知道,这两个 goroutine （后面称为 G1 和 G2 好了）都会被阻塞在接收操作.G1 和 G2 会挂在 channel 的 recq 队列中,形成一个双向循环链表.

在程序的 17 行之前,chan 的整体数据结构如下：

![tech.ricoly.cn_chan struct at the runtime](/assets/image/c2dtZl8vaW1nL3JlbW90ZS8xNDYwMDAwMDE5ODM5NTYx.jpg)

`buf` 指向一个长度为 0 的数组,qcount 为 0,表示 channel 中没有元素.重点关注 `recvq` 和 `sendq`,它们是 waitq 结构体,而 waitq 实际上就是一个双向链表,链表的元素是 sudog,里面包含 `g` 字段,`g` 表示一个 goroutine,所以 sudog 可以看成一个 goroutine.recvq 存储那些尝试读取 channel 但被阻塞的 goroutine,sendq 则存储那些尝试写入 channel,但被阻塞的 goroutine.

此时,我们可以看到,recvq 里挂了两个 goroutine,也就是前面启动的 G1 和 G2.因为没有 goroutine 接收,而 channel 又是无缓冲类型,所以 G1 和 G2 被阻塞.sendq 没有被阻塞的 goroutine.

`recvq` 的数据结构如下.这里直接引用文章中的一幅图,用了三维元素,画得很好：

![tech.ricoly.cn_recvq structure](/assets/image/c2dtZl8vaW1nL3JlbW90ZS8xNDYwMDAwMDE5ODM5NTYy.jpg)

再从整体上来看一下 chan 此时的状态：

![tech.ricoly.cn_chan state](/assets/image/c2dtZl8vaW1nL3JlbW90ZS8xNDYwMDAwMDE5ODM5NTYz.jpg)

G1 和 G2 被挂起了,状态是 `WAITING`.关于 goroutine 调度器这块不是今天的重点,当然后面肯定会写相关的文章.这里先简单说下,goroutine 是用户态的协程,由 Go runtime 进行管理,作为对比,内核线程由 OS 进行管理.Goroutine 更轻量,因此我们可以轻松创建数万 goroutine.

一个内核线程可以管理多个 goroutine,当其中一个 goroutine 阻塞时,内核线程可以调度其他的 goroutine 来运行,内核线程本身不会阻塞.这就是通常我们说的 `M:N` 模型：

![tech.ricoly.cn_M:N scheduling](/assets/image/c2dtZl8vaW1nL3JlbW90ZS8xNDYwMDAwMDE5ODM5NTY0.jpg)

`M:N` 模型通常由三部分构成：M,P,G.M 是内核线程,负责运行 goroutine;P 是 context,保存 goroutine 运行所需要的上下文,它还维护了可运行（runnable）的 goroutine 列表;G 则是待运行的 goroutine.M 和 P 是 G 运行的基础.

![tech.ricoly.cn_MGP](/assets/image/c2dtZl8vaW1nL3JlbW90ZS8xNDYwMDAwMDE5ODM5NTY1.jpg)

继续回到例子.假设我们只有一个 M,当 G1（`go goroutineA(ch)`） 运行到 `val := <- a` 时,它由本来的 running 状态变成了 waiting 状态（调用了 gopark 之后的结果）：

![tech.ricoly.cn_G1 running](/assets/image/c2dtZl8vaW1nL3JlbW90ZS8xNDYwMDAwMDE5ODM5NTY2.jpg)

G1 脱离与 M 的关系,但调度器可不会让 M 闲着,所以会接着调度另一个 goroutine 来运行：

![tech.ricoly.cn_G1 waiting](/assets/image/c2dtZl8vaW1nL3JlbW90ZS8xNDYwMDAwMDE5ODM5NTY3.jpg)

G2 也是同样的遭遇.现在 G1 和 G2 都被挂起了,等待着一个 sender 往 channel 里发送数据,才能得到解救.

发送
--

接着上面的例子,G1 和 G2 现在都在 recvq 队列里了.

    ch <- 3


第 17 行向 channel 发送了一个元素 3.

发送操作最终转化为 `chansend` 函数,直接上源码,同样大部分都注释了,可以看懂主流程：

    // 位于 src/runtime/chan.go
    
    func chansend(c *hchan, ep unsafe.Pointer, block bool, callerpc uintptr) bool {
        // 如果 channel 是 nil
        if c == nil {
            // 不能阻塞,直接返回 false,表示未发送成功
            if !block {
                return false
            }
            // 当前 goroutine 被挂起
            gopark(nil, nil, "chan send (nil chan)", traceEvGoStop, 2)
            throw("unreachable")
        }
    
        // 省略 debug 相关……
    
        // 对于不阻塞的 send,快速检测失败场景
        //
        // 如果 channel 未关闭且 channel 没有多余的缓冲空间.这可能是：
        // 1. channel 是非缓冲型的,且等待接收队列里没有 goroutine
        // 2. channel 是缓冲型的,但循环数组已经装满了元素
        if !block && c.closed == 0 && ((c.dataqsiz == 0 && c.recvq.first == nil) ||
            (c.dataqsiz > 0 && c.qcount == c.dataqsiz)) {
            return false
        }
    
        var t0 int64
        if blockprofilerate > 0 {
            t0 = cputicks()
        }
    
        // 锁住 channel,并发安全
        lock(&c.lock)
    
        // 如果 channel 关闭了
        if c.closed != 0 {
            // 解锁
            unlock(&c.lock)
            // 直接 panic
            panic(plainError("send on closed channel"))
        }
    
        // 如果接收队列里有 goroutine,直接将要发送的数据拷贝到接收 goroutine
        if sg := c.recvq.dequeue(); sg != nil {
            send(c, sg, ep, func() { unlock(&c.lock) }, 3)
            return true
        }
    
        // 对于缓冲型的 channel,如果还有缓冲空间
        if c.qcount < c.dataqsiz {
            // qp 指向 buf 的 sendx 位置
            qp := chanbuf(c, c.sendx)
    
            // ……
    
            // 将数据从 ep 处拷贝到 qp
            typedmemmove(c.elemtype, qp, ep)
            // 发送游标值加 1
            c.sendx++
            // 如果发送游标值等于容量值,游标值归 0
            if c.sendx == c.dataqsiz {
                c.sendx = 0
            }
            // 缓冲区的元素数量加一
            c.qcount++
    
            // 解锁
            unlock(&c.lock)
            return true
        }
    
        // 如果不需要阻塞,则直接返回错误
        if !block {
            unlock(&c.lock)
            return false
        }
    
        // channel 满了,发送方会被阻塞.接下来会构造一个 sudog
    
        // 获取当前 goroutine 的指针
        gp := getg()
        mysg := acquireSudog()
        mysg.releasetime = 0
        if t0 != 0 {
            mysg.releasetime = -1
        }
    
        mysg.elem = ep
        mysg.waitlink = nil
        mysg.g = gp
        mysg.selectdone = nil
        mysg.c = c
        gp.waiting = mysg
        gp.param = nil
    
        // 当前 goroutine 进入发送等待队列
        c.sendq.enqueue(mysg)
    
        // 当前 goroutine 被挂起
        goparkunlock(&c.lock, "chan send", traceEvGoBlockSend, 3)
    
        // 从这里开始被唤醒了（channel 有机会可以发送了）
        if mysg != gp.waiting {
            throw("G waiting list is corrupted")
        }
        gp.waiting = nil
        if gp.param == nil {
            if c.closed == 0 {
                throw("chansend: spurious wakeup")
            }
            // 被唤醒后,channel 关闭了.坑爹啊,panic
            panic(plainError("send on closed channel"))
        }
        gp.param = nil
        if mysg.releasetime > 0 {
            blockevent(mysg.releasetime-t0, 2)
        }
        // 去掉 mysg 上绑定的 channel
        mysg.c = nil
        releaseSudog(mysg)
        return true
    }


上面的代码注释地比较详细了,我们来详细看看.

*   如果检测到 channel 是空的,当前 goroutine 会被挂起.
*   对于不阻塞的发送操作,如果 channel 未关闭并且没有多余的缓冲空间（说明：a. channel 是非缓冲型的,且等待接收队列里没有 goroutine;b. channel 是缓冲型的,但循环数组已经装满了元素） 对于这一点,runtime 源码里注释了很多.这一条判断语句是为了在不阻塞发送的场景下快速检测到发送失败,好快速返回.

    if !block && c.closed == 0 && ((c.dataqsiz == 0 && c.recvq.first == nil) || (c.dataqsiz > 0 && c.qcount == c.dataqsiz)) {
    return false
    }


注释里主要讲为什么这一块可以不加锁,我详细解释一下.`if` 条件里先读了两个变量：block 和 c.closed.block 是函数的参数,不会变;c.closed 可能被其他 goroutine 改变,因为没加锁嘛,这是“与”条件前面两个表达式.

最后一项,涉及到三个变量：c.dataqsiz,c.recvq.first,c.qcount.`c.dataqsiz == 0 && c.recvq.first == nil` 指的是非缓冲型的 channel,并且 recvq 里没有等待接收的 goroutine;`c.dataqsiz > 0 && c.qcount == c.dataqsiz` 指的是缓冲型的 channel,但循环数组已经满了.这里 `c.dataqsiz` 实际上也是不会被修改的,在创建的时候就已经确定了.不加锁真正影响地是 `c.qcount` 和 `c.recvq.first`.

这一部分的条件就是两个 `word-sized read`,就是读两个 word 操作：`c.closed` 和 `c.recvq.first`（非缓冲型） 或者 `c.qcount`（缓冲型）.

当我们发现 `c.closed == 0` 为真,也就是 channel 未被关闭,再去检测第三部分的条件时,观测到 `c.recvq.first == nil` 或者 `c.qcount == c.dataqsiz` 时（这里忽略 `c.dataqsiz`）,就断定要将这次发送操作作失败处理,快速返回 false.

这里涉及到两个观测项：channel 未关闭,channel not ready for sending.这两项都会因为没加锁而出现观测前后不一致的情况.例如我先观测到 channel 未被关闭,再观察到 channel not ready for sending,这时我以为能满足这个 if 条件了,但是如果这时 c.closed 变成 1,这时其实就不满足条件了,谁让您不加锁呢！

但是,因为一个 closed channel 不能将 channel 状态从 ‘ready for sending’ 变成 ‘not ready for sending’,所以当我观测到 ‘not ready for sending’ 时,channel 不是 closed.即使 `c.closed == 1`,即 channel 是在这两个观测中间被关闭的,那也说明在这两个观测中间,channel 满足两个条件：`not closed` 和 `not ready for sending`,这时,我直接返回 false 也是没有问题的.

这部分解释地比较绕,其实这样做的目的就是少获取一次锁,提升性能.

*   如果检测到 channel 已经关闭,直接 panic.
*   如果能从等待接收队列 recvq 里出队一个 sudog（代表一个 goroutine）,说明此时 channel 是空的,没有元素,所以才会有等待接收者.这时会调用 send 函数将元素直接从发送者的栈拷贝到接收者的栈,关键操作由 `sendDirect` 函数完成. ```go // send 函数处理向一个空的 channel 发送操作

// ep 指向被发送的元素,会被直接拷贝到接收的 goroutine // 之后,接收的 goroutine 会被唤醒 // c 必须是空的（因为等待队列里有 goroutine,肯定是空的） // c 必须被上锁,发送操作执行完后,会使用 unlockf 函数解锁 // sg 必须已经从等待队列里取出来了 // ep 必须是非空,并且它指向堆或调用者的栈

func send(c \*hchan, sg \*sudog, ep unsafe.Pointer, unlockf func(), skip int) { // 省略一些用不到的 // ……

    // sg.elem 指向接收到的值存放的位置,如 val <- ch,指的就是 &val
    if sg.elem != nil {
        // 直接拷贝内存（从发送者到接收者）
        sendDirect(c.elemtype, sg, ep)
        sg.elem = nil
    }
    // sudog 上绑定的 goroutine
    gp := sg.g
    // 解锁
    unlockf()
    gp.param = unsafe.Pointer(sg)
    if sg.releasetime != 0 {
        sg.releasetime = cputicks()
    }
    // 唤醒接收的 goroutine. skip 和打印栈相关,暂时不理会
    goready(gp, skip+1) } ```


继续看 `sendDirect` 函数：

    // 向一个非缓冲型的 channel 发送数据,从一个无元素的（非缓冲型或缓冲型但空）的 channel
    // 接收数据,都会导致一个 goroutine 直接操作另一个 goroutine 的栈
    // 由于 GC 假设对栈的写操作只能发生在 goroutine 正在运行中并且由当前 goroutine 来写
    // 所以这里实际上违反了这个假设.可能会造成一些问题,所以需要用到写屏障来规避
    func sendDirect(t *_type, sg *sudog, src unsafe.Pointer) {
        // src 在当前 goroutine 的栈上,dst 是另一个 goroutine 的栈
    
        // 直接进行内存"搬迁"
        // 如果目标地址的栈发生了栈收缩,当我们读出了 sg.elem 后
        // 就不能修改真正的 dst 位置的值了
        // 因此需要在读和写之前加上一个屏障
        dst := sg.elem
        typeBitsBulkBarrier(t, uintptr(dst), uintptr(src), t.size)
        memmove(dst, src, t.size)
    }


这里涉及到一个 goroutine 直接写另一个 goroutine 栈的操作,一般而言,不同 goroutine 的栈是各自独有的.而这也违反了 GC 的一些假设.为了不出问题,写的过程中增加了写屏障,保证正确地完成写操作.这样做的好处是减少了一次内存 copy：不用先拷贝到 channel 的 buf,直接由发送者到接收者,没有中间商赚差价,效率得以提高,完美.

然后,解锁,唤醒接收者,等待调度器的光临,接收者也得以重见天日,可以继续执行接收操作之后的代码了.

*   如果 `c.qcount < c.dataqsiz`,说明缓冲区可用（肯定是缓冲型的 channel）.先通过函数取出待发送元素应该去到的位置： ```go qp := chanbuf(c, c.sendx)

// 返回循环队列里第 i 个元素的地址处 func chanbuf(c _hchan, i uint) unsafe.Pointer { return add(c.buf, uintptr(i)_uintptr(c.elemsize)) }


    `c.sendx` 指向下一个待发送元素在循环数组中的位置,然后调用 `typedmemmove` 函数将其拷贝到循环数组中.之后 `c.sendx` 加 1,元素总量加 1 ：`c.qcount++`,最后,解锁并返回.
    
    * 如果没有命中以上条件的,说明 channel 已经满了.不管这个 channel 是缓冲型的还是非缓冲型的,都要将这个 sender “关起来”（goroutine 被阻塞）.如果 block 为 false,直接解锁,返回 false.
    * 最后就是真的需要被阻塞的情况.先构造一个 sudog,将其入队（channel 的 sendq 字段）.然后调用 `goparkunlock` 将当前 goroutine 挂起,并解锁,等待合适的时机再唤醒.
    唤醒之后,从 `goparkunlock` 下一行代码开始继续往下执行.
    
    这里有一些绑定操作,sudog 通过 g 字段绑定 goroutine,而 goroutine 通过 waiting 绑定 sudog,sudog 还通过 `elem` 字段绑定待发送元素的地址,以及 `c` 字段绑定被“坑”在此处的 channel.
    
    所以,待发送的元素地址其实是存储在 sudog 结构体里,也就是当前 goroutine 里.
    
    好了,看完源码.我们接着来分析例子,相信大家已经把例子忘得差不多了,我再贴一下代码：
    
    ```go
    func goroutineA(a <-chan int) {
        val := <- a
        fmt.Println("goroutine A received data: ", val)
        return
    }
    
    func goroutineB(b <-chan int) {
        val := <- b
        fmt.Println("goroutine B received data: ", val)
        return
    }
    
    func main() {
        ch := make(chan int)
        go goroutineA(ch)
        go goroutineB(ch)
        ch <- 3
        time.Sleep(time.Second)
    
        ch1 := make(chan struct{})
    }


在发送小节里我们说到 G1 和 G2 现在被挂起来了,等待 sender 的解救.在第 17 行,主协程向 ch 发送了一个元素 3,来看下接下来会发生什么.

根据前面源码分析的结果,我们知道,sender 发现 ch 的 recvq 里有 receiver 在等待着接收,就会出队一个 sudog,把 recvq 里 first 指针的 sudo “推举”出来了,并将其加入到 P 的可运行 goroutine 队列中.

然后,sender 把发送元素拷贝到 sudog 的 elem 地址处,最后会调用 goready 将 G1 唤醒,状态变为 runnable.

![tech.ricoly.cn_G1 runnable](/assets/image/c2dtZl8vaW1nL3JlbW90ZS8xNDYwMDAwMDE5ODM5NTY4.jpg)

当调度器光顾 G1 时,将 G1 变成 running 状态,执行 goroutineA 接下来的代码.G 表示其他可能有的 goroutine.

这里其实涉及到一个协程写另一个协程栈的操作.有两个 receiver 在 channel 的一边虎视眈眈地等着,这时 channel 另一边来了一个 sender 准备向 channel 发送数据,为了高效,用不着通过 channel 的 buf “中转”一次,直接从源地址把数据 copy 到目的地址就可以了,效率高啊！

![tech.ricoly.cn_send direct](/assets/image/c2dtZl8vaW1nL3JlbW90ZS8xNDYwMDAwMDE5ODM5NTY5.jpg)

上图是一个示意图,`3` 会被拷贝到 G1 栈上的某个位置,也就是 val 的地址处,保存在 elem 字段.

关闭
--

关闭某个 channel,会执行函数 `closechan`：

    func closechan(c *hchan) {
        // 关闭一个 nil channel,panic
        if c == nil {
            panic(plainError("close of nil channel"))
        }
    
        // 上锁
        lock(&c.lock)
        // 如果 channel 已经关闭
        if c.closed != 0 {
            unlock(&c.lock)
            // panic
            panic(plainError("close of closed channel"))
        }
    
        // …………
    
        // 修改关闭状态
        c.closed = 1
    
        var glist *g
    
        // 将 channel 所有等待接收队列的里 sudog 释放
        for {
            // 从接收队列里出队一个 sudog
            sg := c.recvq.dequeue()
            // 出队完毕,跳出循环
            if sg == nil {
                break
            }
    
            // 如果 elem 不为空,说明此 receiver 未忽略接收数据
            // 给它赋一个相应类型的零值
            if sg.elem != nil {
                typedmemclr(c.elemtype, sg.elem)
                sg.elem = nil
            }
            if sg.releasetime != 0 {
                sg.releasetime = cputicks()
            }
            // 取出 goroutine
            gp := sg.g
            gp.param = nil
            if raceenabled {
                raceacquireg(gp, unsafe.Pointer(c))
            }
            // 相连,形成链表
            gp.schedlink.set(glist)
            glist = gp
        }
    
        // 将 channel 等待发送队列里的 sudog 释放
        // 如果存在,这些 goroutine 将会 panic
        for {
            // 从发送队列里出队一个 sudog
            sg := c.sendq.dequeue()
            if sg == nil {
                break
            }
    
            // 发送者会 panic
            sg.elem = nil
            if sg.releasetime != 0 {
                sg.releasetime = cputicks()
            }
            gp := sg.g
            gp.param = nil
            if raceenabled {
                raceacquireg(gp, unsafe.Pointer(c))
            }
            // 形成链表
            gp.schedlink.set(glist)
            glist = gp
        }
        // 解锁
        unlock(&c.lock)
    
        // Ready all Gs now that we've dropped the channel lock.
        // 遍历链表
        for glist != nil {
            // 取最后一个
            gp := glist
            // 向前走一步,下一个唤醒的 g
            glist = glist.schedlink.ptr()
            gp.schedlink = 0
            // 唤醒相应 goroutine
            goready(gp, 3)
        }
    }


close 逻辑比较简单,对于一个 channel,recvq 和 sendq 中分别保存了阻塞的发送者和接收者.关闭 channel 后,对于等待接收者而言,会收到一个相应类型的零值.对于等待发送者,会直接 panic.所以,在不了解 channel 还有没有接收者的情况下,不能贸然关闭 channel.

close 函数先上一把大锁,接着把所有挂在这个 channel 上的 sender 和 receiver 全都连成一个 sudog 链表,再解锁.最后,再将所有的 sudog 全都唤醒.

唤醒之后,该干嘛干嘛.sender 会继续执行 chansend 函数里 goparkunlock 函数之后的代码,很不幸,检测到 channel 已经关闭了,panic.receiver 则比较幸运,进行一些扫尾工作后,返回.这里,selected 返回 true,而返回值 received 则要根据 channel 是否关闭,返回不同的值.如果 channel 关闭,received 为 false,否则为 true.这我们分析的这种情况下,received 返回 false.

channel 进阶
==========

总结一下操作 channel 的结果：

|  close  | panic |  panic  | 正常关闭 |
| :----: | :----: | :----: | :----: |
|读 <\-ch|阻塞|读到对应类型的零值|阻塞或正常读取数据.缓冲型 channel 为空或非缓冲型 channel 没有等待发送者时会阻塞|
|写 ch <\-|阻塞|panic|阻塞或正常写入数据.非缓冲型 channel 没有等待接收者或缓冲型 channel buf 满时会被阻塞|

总结一下,发生 panic 的情况有三种：向一个关闭的 channel 进行写操作;关闭一个 nil 的 channel;重复关闭一个 channel.

读,写一个 nil channel 都会被阻塞.

发送和接收元素的本质
----------

Channel 发送和接收元素的本质是什么？参考资料【深入 channel 底层】里是这样回答的：

> Remember all transfer of value on the go channels happens with the copy of value.

就是说 channel 的发送和接收操作本质上都是 “值的拷贝”,无论是从 sender goroutine 的栈到 chan buf,还是从 chan buf 到 receiver goroutine,或者是直接从 sender goroutine 到 receiver goroutine.

这里再引用文中的一个例子,我会加上更加详细地解释.顺带说一下,这是一篇英文的博客,写得很好,没有像我们这篇文章那样大段的源码分析,它是将代码里情况拆开来各自描述的,各有利弊吧.推荐去读下原文,阅读体验比较好.

    type user struct {
        name string
        age int8
    }
    
    var u = user{name: "Ankur", age: 25}
    var g = &u
    
    func modifyUser(pu *user) {
        fmt.Println("modifyUser Received Vaule", pu)
        pu.name = "Anand"
    }
    
    func printUser(u <-chan *user) {
        time.Sleep(2 * time.Second)
        fmt.Println("printUser goRoutine called", <-u)
    }
    
    func main() {
        c := make(chan *user, 5)
        c <- g
        fmt.Println(g)
        // modify g
        g = &user{name: "Ankur Anand", age: 100}
        go printUser(c)
        go modifyUser(g)
        time.Sleep(5 * time.Second)
        fmt.Println(g)
    }


运行结果：

    &{Ankur 25}
    modifyUser Received Value &{Ankur Anand 100}
    printUser goRoutine called &{Ankur 25}
    &{Anand 100}


这里就是一个很好的 `share memory by communicating` 的例子.

![tech.ricoly.cn_output](/assets/image/c2dtZl8vaW1nL3JlbW90ZS8xNDYwMDAwMDE5ODM5NTcw.jpg)

一开始构造一个结构体 u,地址是 0x56420,图中地址上方就是它的内容.接着把 `&u` 赋值给指针 `g`,g 的地址是 0x565bb0,它的内容就是一个地址,指向 u.

main 程序里,先把 g 发送到 c,根据 `copy value` 的本质,进入到 chan buf 里的就是 `0x56420`,它是指针 g 的值（不是它指向的内容）,所以打印从 channel 接收到的元素时,它就是 `&{Ankur 25}`.因此,这里并不是将指针 g “发送” 到了 channel 里,只是拷贝它的值而已.

再强调一次：

> Remember all transfer of value on the go channels happens with the copy of value.

资源泄漏
----

Channel 可能会引发 goroutine 泄漏.

泄漏的原因是 goroutine 操作 channel 后,处于发送或接收阻塞状态,而 channel 处于满或空的状态,一直得不到改变.同时,垃圾回收器也不会回收此类资源,进而导致 gouroutine 会一直处于等待队列中,不见天日.

雨痕老师的《Go 语言学习笔记》第 8 章通道的“资源泄露”一节举了个例子,大家可以自己去看.

happened before
---------------

维基百科上给的定义：

> In computer science, the happened-before relation (denoted: ->) is a relation between the result of two events, such that if one event should happen before another event, the result must reflect that, even if those events are in reality executed out of order (usually to optimize program flow).

简单来说就是如果事件 a 和事件 b 存在 happened-before 关系,即 a -> b,那么 a,b 完成后的结果一定要体现这种关系.由于现代编译器,CPU 会做各种优化,包括编译器重排,内存重排等等,在并发代码里,happened-before 限制就非常重要了.

根据晃岳攀老师在 Gopher China 2019 上的并发编程分享,关于 channel 的发送（send）,发送完成（send finished）,接收（receive）,接收完成（receive finished）的 happened-before 关系如下：

1.  第 n 个 `send` 一定 `happened before` 第 n 个 `receive finished`,无论是缓冲型还是非缓冲型的 channel.
2.  对于容量为 m 的缓冲型 channel,第 n 个 `receive` 一定 `happened before` 第 n+m 个 `send finished`.
3.  对于非缓冲型的 channel,第 n 个 `receive` 一定 `happened before` 第 n 个 `send finished`.
4.  channel close 一定 `happened before` receiver 得到通知. 我们来逐条解释一下.

第一条,我们从源码的角度看也是对的,send 不一定是 `happened before` receive,因为有时候是先 receive,然后 goroutine 被挂起,之后被 sender 唤醒,send happened after receive.但不管怎样,要想完成接收,一定是要先有发送.

第二条,缓冲型的 channel,当第 n+m 个 send 发生后,有下面两种情况：

若第 n 个 receive 没发生.这时,channel 被填满了,send 就会被阻塞.那当第 n 个 receive 发生时,sender goroutine 会被唤醒,之后再继续发送过程.这样,第 n 个 `receive` 一定 `happened before` 第 n+m 个 `send finished`.

若第 n 个 receive 已经发生过了,这直接就符合了要求.

第三条,也是比较好理解的.第 n 个 send 如果被阻塞,sender goroutine 挂起,第 n 个 receive 这时到来,先于第 n 个 send finished.如果第 n 个 send 未被阻塞,说明第 n 个 receive 早就在那等着了,它不仅 happened before send finished,它还 happened before send.

第四条,回忆一下源码,先设置完 closed = 1,再唤醒等待的 receiver,并将零值拷贝给 receiver.

参考资料【鸟窝 并发编程分享】这篇博文的评论区有 PPT 的下载链接,这是晁老师在 Gopher 2019 大会上的演讲.

关于 happened before,这里再介绍一个柴大和曹大的新书《Go 语言高级编程》里面提到的一个例子.

书中 1.5 节先讲了顺序一致性的内存模型,这是并发编程的基础.

我们直接来看例子：

    var done = make(chan bool)
    var msg string
    
    func aGoroutine() {
        msg = "hello, world"
        done <- true
    }
    
    func main() {
        go aGoroutine()
        <-done
        println(msg)
    }


先定义了一个 done channel 和一个待打印的字符串.在 main 函数里,启动一个 goroutine,等待从 done 里接收到一个值后,执行打印 msg 的操作.如果 main 函数中没有 `<-done` 这行代码,打印出来的 msg 为空,因为 aGoroutine 来不及被调度,还来不及给 msg 赋值,主程序就会退出.而在 Go 语言里,主协程退出时不会等待其他协程.

加了 `<-done` 这行代码后,就会阻塞在此.等 aGoroutine 里向 done 发送了一个值之后,才会被唤醒,继续执行打印 msg 的操作.而这在之前,msg 已经被赋值过了,所以会打印出 `hello, world`.

这里依赖的 happened before 就是前面讲的第一条.第一个 send 一定 happened before 第一个 receive finished,即 `done <- true` 先于 `<-done` 发生,这意味着 main 函数里执行完 `<-done` 后接着执行 `println(msg)` 这一行代码时,msg 已经被赋过值了,所以会打印出想要的结果.

书中,又进一步利用前面提到的第 3 条 happened before 规则,修改了一下代码：

    var done = make(chan bool)
    var msg string
    
    func aGoroutine() {
        msg = "hello, world"
        <-done
    }
    
    func main() {
        go aGoroutine()
        done <- true
        println(msg)
    }


同样可以得到相同的结果,为什么？根据第三条规则,对于非缓冲型的 channel,第一个 receive 一定 happened before 第一个 send finished.也就是说,

在 `done <- true` 完成之前,`<-done` 就已经发生了,也就意味着 msg 已经被赋上值了,最终也会打印出 `hello, world`.

如何优雅地关闭 channel
---------------

这部分内容主要来自 Go 101 上的一篇英文文章,参考资料【如何优雅地关闭 channel】可以直达原文.

文章先“吐槽”了下 Go channel 在设计上的一些问题,接着给出了几种不同情况下如何优雅地关闭 channel 的例子.按照惯例,我会在原作者内容的基础上给出自己的解读,看完这一节您可以再回头看一下英文原文,会觉得很有意思.

关于 channel 的使用,有几点不方便的地方：

1.  在不改变 channel 自身状态的情况下,无法获知一个 channel 是否关闭.
2.  关闭一个 closed channel 会导致 panic.所以,如果关闭 channel 的一方在不知道 channel 是否处于关闭状态时就去贸然关闭 channel 是很危险的事情.
3.  向一个 closed channel 发送数据会导致 panic.所以,如果向 channel 发送数据的一方不知道 channel 是否处于关闭状态时就去贸然向 channel 发送数据是很危险的事情. 文中还真的就给出了一个检查 channel 是否关闭的函数：

    func IsClosed(ch <-chan T) bool {
    select {
    case <-ch:
    return true
    default:
    }

        return false
    }

    func main() {
    c := make(chan T)
    fmt.Println(IsClosed(c)) // false
    close(c)
    fmt.Println(IsClosed(c)) // true
    }


看一下代码,其实存在很多问题.首先,IsClosed 函数是一个有副作用的函数.每调用一次,都会读出 channel 里的一个元素,改变了 channel 的状态.这不是一个好的函数,干活就干活,还顺手牵羊！

其次,IsClosed 函数返回的结果仅代表调用那个瞬间,并不能保证调用之后会不会有其他 goroutine 对它进行了一些操作,改变了它的这种状态.例如,IsClosed 函数返回 true,但这时有另一个 goroutine 关闭了 channel,而您还拿着这个过时的 “channel 未关闭”的信息,向其发送数据,就会导致 panic 的发生.当然,一个 channel 不会被重复关闭两次,如果 IsClosed 函数返回的结果是 true,说明 channel 是真的关闭了.

有一条广泛流传的关闭 channel 的原则：

> don’t close a channel from the receiver side and don’t close a channel if the channel has multiple concurrent senders.

不要从一个 receiver 侧关闭 channel,也不要在有多个 sender 时,关闭 channel.

比较好理解,向 channel 发送元素的就是 sender,因此 sender 可以决定何时不发送数据,并且关闭 channel.但是如果有多个 sender,某个 sender 同样没法确定其他 sender 的情况,这时也不能贸然关闭 channel.

但是上面所说的并不是最本质的,最本质的原则就只有一条：

> don’t close (or send values to) closed channels.

有两个不那么优雅地关闭 channel 的方法：

1.  使用 defer-recover 机制,放心大胆地关闭 channel 或者向 channel 发送数据.即使发生了 panic,有 defer-recover 在兜底.
2.  使用 sync.Once 来保证只关闭一次. 代码我就不贴上来了,直接去看原文.

这一节的重头戏来了,那应该如何优雅地关闭 channel？

根据 sender 和 receiver 的个数,分下面几种情况：

1.  一个 sender,一个 receiver
2.  一个 sender, M 个 receiver
3.  N 个 sender,一个 reciver
4.  N 个 sender, M 个 receiver 对于 1,2,只有一个 sender 的情况就不用说了,直接从 sender 端关闭就好了,没有问题.重点关注第 3,4 种情况.

第 3 种情形下,优雅关闭 channel 的方法是：the only receiver says “please stop sending more” by closing an additional signal channel.

解决方案就是增加一个传递关闭信号的 channel,receiver 通过信号 channel 下达关闭数据 channel 指令.senders 监听到关闭信号后,停止发送数据.我把代码修改地更简洁了：

    func main() {
        rand.Seed(time.Now().UnixNano())
    
        const Max = 100000
        const NumSenders = 1000
    
        dataCh := make(chan int, 100)
        stopCh := make(chan struct{})
    
        // senders
        for i := 0; i < NumSenders; i++ {
            go func() {
                for {
                    select {
                    case <- stopCh:
                        return
                    case dataCh <- rand.Intn(Max):
                    }
                }
            }()
        }
    
        // the receiver
        go func() {
            for value := range dataCh {
                if value == Max-1 {
                    fmt.Println("send stop signal to senders.")
                    close(stopCh)
                    return
                }
    
                fmt.Println(value)
            }
        }()
    
        select {
        case <- time.After(time.Hour):
        }
    }


这里的 stopCh 就是信号 channel,它本身只有一个 sender,因此可以直接关闭它.senders 收到了关闭信号后,select 分支 “case <- stopCh” 被选中,退出函数,不再发送数据.

需要说明的是,上面的代码并没有明确关闭 dataCh.在 Go 语言中,对于一个 channel,如果最终没有任何 goroutine 引用它,不管 channel 有没有被关闭,最终都会被 gc 回收.所以,在这种情形下,所谓的优雅地关闭 channel 就是不关闭 channel,让 gc 代劳.

最后一种情况,优雅关闭 channel 的方法是：any one of them says “let’s end the game” by notifying a moderator to close an additional signal channel.

和第 3 种情况不同,这里有 M 个 receiver,如果直接还是采取第 3 种解决方案,由 receiver 直接关闭 stopCh 的话,就会重复关闭一个 channel,导致 panic.因此需要增加一个中间人,M 个 receiver 都向它发送关闭 dataCh 的“请求”,中间人收到第一个请求后,就会直接下达关闭 dataCh 的指令（通过关闭 stopCh,这时就不会发生重复关闭的情况,因为 stopCh 的发送方只有中间人一个）.另外,这里的 N 个 sender 也可以向中间人发送关闭 dataCh 的请求.

    func main() {
        rand.Seed(time.Now().UnixNano())
    
        const Max = 100000
        const NumReceivers = 10
        const NumSenders = 1000
    
        dataCh := make(chan int, 100)
        stopCh := make(chan struct{})
    
        // It must be a buffered channel.
        toStop := make(chan string, 1)
    
        var stoppedBy string
    
        // moderator
        go func() {
            stoppedBy = <-toStop
            close(stopCh)
        }()
    
        // senders
        for i := 0; i < NumSenders; i++ {
            go func(id string) {
                for {
                    value := rand.Intn(Max)
                    if value == 0 {
                        select {
                        case toStop <- "sender#" + id:
                        default:
                        }
                        return
                    }
    
                    select {
                    case <- stopCh:
                        return
                    case dataCh <- value:
                    }
                }
            }(strconv.Itoa(i))
        }
    
        // receivers
        for i := 0; i < NumReceivers; i++ {
            go func(id string) {
                for {
                    select {
                    case <- stopCh:
                        return
                    case value := <-dataCh:
                        if value == Max-1 {
                            select {
                            case toStop <- "receiver#" + id:
                            default:
                            }
                            return
                        }
    
                        fmt.Println(value)
                    }
                }
            }(strconv.Itoa(i))
        }
    
        select {
        case <- time.After(time.Hour):
        }
    
    }


代码里 toStop 就是中间人的角色,使用它来接收 senders 和 receivers 发送过来的关闭 dataCh 请求.

这里将 toStop 声明成了一个 缓冲型的 channel.假设 toStop 声明的是一个非缓冲型的 channel,那么第一个发送的关闭 dataCh 请求可能会丢失.因为无论是 sender 还是 receiver 都是通过 select 语句来发送请求,如果中间人所在的 goroutine 没有准备好,那 select 语句就不会选中,直接走 default 选项,什么也不做.这样,第一个关闭 dataCh 的请求就会丢失.

如果,我们把 toStop 的容量声明成 Num(senders) + Num(receivers),那发送 dataCh 请求的部分可以改成更简洁的形式：

    ...
    toStop := make(chan string, NumReceivers + NumSenders)
    ...
                value := rand.Intn(Max)
                if value == 0 {
                    toStop <- "sender#" + id
                    return
                }
    ...
                    if value == Max-1 {
                        toStop <- "receiver#" + id
                        return
                    }
    ...


直接向 toStop 发送请求,因为 toStop 容量足够大,所以不用担心阻塞,自然也就不用 select 语句再加一个 default case 来避免阻塞.

可以看到,这里同样没有真正关闭 dataCh,原样同第 3 种情况.

以上,就是最基本的一些情形,但已经能覆盖几乎所有的情况及其变种了.只要记住：

> don’t close a channel from the receiver side and don’t close a channel if the channel has multiple concurrent senders.

以及更本质的原则：

> don’t close (or send values to) closed channels.

关闭的 channel 仍能读出数据
------------------

从一个有缓冲的 channel 里读数据,当 channel 被关闭,依然能读出有效值.只有当返回的 ok 为 false 时,读出的数据才是无效的.

    func main() {
        ch := make(chan int, 5)
        ch <- 18
        close(ch)
        x, ok := <-ch
        if ok {
            fmt.Println("received: ", x)
        }
    
        x, ok = <-ch
        if !ok {
            fmt.Println("channel closed, data invalid.")
        }
    }


运行结果：

    received:  18
    channel closed, data invalid.


先创建了一个有缓冲的 channel,向其发送一个元素,然后关闭此 channel.之后两次尝试从 channel 中读取数据,第一次仍然能正常读出值.第二次返回的 ok 为 false,说明 channel 已关闭,且通道里没有数据.

channel 应用
==========

Channel 和 goroutine 的结合是 Go 并发编程的大杀器.而 Channel 的实际应用也经常让人眼前一亮,通过与 select,cancel,timer 等结合,它能实现各种各样的功能.接下来,我们就要梳理一下 channel 的应用.

停止信号
----

前面一节如何优雅关闭 channel 那一节已经讲得很多了,这块就略过了.

channel 用于停止信号的场景还是挺多的,经常是关闭某个 channel 或者向 channel 发送一个元素,使得接收 channel 的那一方获知道此信息,进而做一些其他的操作.

任务定时
----

与 timer 结合,一般有两种玩法：实现超时控制,实现定期执行某个任务.

有时候,需要执行某项操作,但又不想它耗费太长时间,上一个定时器就可以搞定：

    select {
        case <-time.After(100 * time.Millisecond):
        case <-s.stopc:
            return false
    }


等待 100 ms 后,如果 s.stopc 还没有读出数据或者被关闭,就直接结束.这是来自 etcd 源码里的一个例子,这样的写法随处可见.

定时执行某个任务,也比较简单：

    func worker() {
        ticker := time.Tick(1 * time.Second)
        for {
            select {
            case <- ticker:
                // 执行定时任务
                fmt.Println("执行 1s 定时任务")
            }
        }
    }


每隔 1 秒种,执行一次定时任务.

解耦生产方和消费方
---------

服务启动时,启动 n 个 worker,作为工作协程池,这些协程工作在一个 `for {}` 无限循环里,从某个 channel 消费工作任务并执行：

    func main() {
        taskCh := make(chan int, 100)
        go worker(taskCh)
    
        // 塞任务
        for i := 0; i < 10; i++ {
            taskCh <- i
        }
    
        // 等待 1 小时 
        select {
        case <-time.After(time.Hour):
        }
    }
    
    func worker(taskCh <-chan int) {
        const N = 5
        // 启动 5 个工作协程
        for i := 0; i < N; i++ {
            go func(id int) {
                for {
                    task := <- taskCh
                    fmt.Printf("finish task: %d by worker %d\n", task, id)
                    time.Sleep(time.Second)
                }
            }(i)
        }
    }


5 个工作协程在不断地从工作队列里取任务,生产方只管往 channel 发送任务即可,解耦生产方和消费方.

程序输出：

    finish task: 1 by worker 4
    finish task: 2 by worker 2
    finish task: 4 by worker 3
    finish task: 3 by worker 1
    finish task: 0 by worker 0
    finish task: 6 by worker 0
    finish task: 8 by worker 3
    finish task: 9 by worker 1
    finish task: 7 by worker 4
    finish task: 5 by worker 2


控制并发数
-----

有时需要定时执行几百个任务,例如每天定时按城市来执行一些离线计算的任务.但是并发数又不能太高,因为任务执行过程依赖第三方的一些资源,对请求的速率有限制.这时就可以通过 channel 来控制并发数.

下面的例子来自《Go 语言高级编程》：

    var limit = make(chan int, 3)
    
    func main() {
        // …………
        for _, w := range work {
            go func() {
                limit <- 1
                w()
                <-limit
            }()
        }
        // …………
    }


构建一个缓冲型的 channel,容量为 3.接着遍历任务列表,每个任务启动一个 goroutine 去完成.真正执行任务,访问第三方的动作在 w() 中完成,在执行 w() 之前,先要从 limit 中拿“许可证”,拿到许可证之后,才能执行 w(),并且在执行完任务,要将“许可证”归还.这样就可以控制同时运行的 goroutine 数.

这里,`limit <- 1` 放在 func 内部而不是外部,书籍作者柴大在读者群里的解释是：

> 如果在外层,就是控制系统 goroutine 的数量,可能会阻塞 for 循环,影响业务逻辑. limit 其实和逻辑无关,只是性能调优,放在内层和外层的语义不太一样.

还有一点要注意的是,如果 w() 发生 panic,那“许可证”可能就还不回去了,因此需要使用 defer 来保证.

