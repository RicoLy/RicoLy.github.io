---
layout: post
title: Python基础之闭包和装饰器
category: Python
tags: python
keywords: python
description:
---

Python中的闭包
----------

讲装饰器之前，先来说一下闭包。

### 闭包的由来

首先我们需要知道，我们是可以在函数中再定义一个函数的（嵌套函数）。

就像这样：

    def foo():
        def bar():
            print("Hello world!")
        return bar


此时我们调用 `foo` 函数，会得到一个其内部定义的 `bar` 函数。我们把 `foo` 函数的返回值赋值给一个变量就可以使用这个变量来调用 `bar` 函数了。

就像这样：

    func = foo()  # func <- bar
    func()  # bar()


输出：

    Hello world!


好了，闭包的故事就发生在上面这样的嵌套函数中。

举个例子：

    def foo():
        name = "Andy"  # 定义了一个foo函数内部的局部变量
        def bar():
            print(name)  # 在bar函数内部引用了其外部函数foo的局部变量name
        return bar



现在，我们来调用一下 `foo` 函数：

    func = foo()
    func()


上面的代码，输出结果是：

    Andy


bar函数不需要传参数，就能获取到外面的变量。

这就是典型的一个闭包现象。

### 闭包的定义

函数内部定义的函数，称为内部函数。如果这个内部函数使用了它外部函数的局部变量，即使外部函数返回了，这个内部函数还可以访问到外部函数的局部变量，这种现象就叫做`闭包`。

注意，即使你在调用 `func` 之前，定义一个全局变量 `name`，它还是会使用原来`foo` 函数内部的 `name` ：

    func = foo()
    name = "Egon"
    func()


输出：

    Andy


此时调用 `func`函数时它会使用自己**定义阶段**引用的外部函数的局部变量 `name` ，而不使用**调用阶段**的全局变量。

### 闭包的实质

闭包是由**函数**和**与它相关的引用环境**组合而成的实体。

Python中可以通过以下命令查看闭包相关信息：

    print(func.__closure__)


输出：

    (<cell at 0x105280408: str object at 0x10544fa78>,)


`__closure__` 属性定义的是一个包含 cell 对象的元组，其中元组中的每一个 cell 对象用来保存作用域中变量的值。可以通过以下命令查看闭包具体包含的变量值：

    print(func.__closure__[0].cell_contents)


输出：

    Andy


像下面的 `func`函数就不能称为闭包，因为它并没有使用包含它的外部函数的局部变量。

    name = "Alex"  # 定义了一个全局变量
    def foo():
        def bar():
            print(name)  # 在bar函数内部引用了全局变量name
        return bar
    
    func = foo()


此时：

    print(func.__closure__)


输出：

    None


闭包的介绍就到这里，接下来我们来说一说Python中的装饰器。

为什么要有装饰器？
---------

在学习装饰器之前，一定要了解一个开放封闭原则。软件开发都应该遵循开放封闭原则。

### 开放封闭原则

*   对扩展是开放的
*   对修改是封闭的

为什么说要对扩展是开放的呢？

因为软件开发过程不可能一次性把所有的功能都考虑完全，肯定会有不同的新功能需要不停添加。也就是说需要我们不断地去扩展已经存在代码的功能，这是非常正常的情况。

那为什么说对修改是封闭的呢？

比如说已经上线运行的源代码，比如某个函数内部的代码是不建议直接修改的。因为函数的使用分为两个阶段：函数的定义阶段和函数的调用阶段。因为你不确定这个函数究竟在什么地方被调用了，你如果粗暴的修改了函数内部的源代码，对整个程序造成的影响是不可控的。

总结一下就是：不修改源代码，不修改调用方式，同时还要加上新功能。

在Python中就可以使用装饰器来实现上面的需求。

**注意：**如果你能够保证自己的每一次修改都是准确无误、万无一失的，那你可以直接修改源代码。

什么是装饰器？
-------

从字面上讲它也是一个工具，装饰其他对象（可调用对象）的工具。

### 装饰器的本质

装饰器本质上可以是任意可调用对象，被装饰的对象也可以是任意可调用对象。

### 装饰器的功能

在不修改被装饰对象源代码以及调用方式的前提下为它添加新功能。

首先我们先来个例子：

    import time
    import random
    
    def index():
        time.sleep(random.randrange(1, 5))  # 随机sleep几秒
        print("欢迎访问首页。")
        
    index()


现在需求来了，我需要统计下 `index` 函数执行耗费的时间。

你可能会很快写出下面的代码：

    import time
    import random
    
    def index():
        start_time = time.time()
    
        time.sleep(random.randrange(1, 5))  # 随机sleep几秒
        print("欢迎访问首页。")
    
        stop_time = time.time()
        print("耗时{}秒。".format(stop_time - start_time))
        
    index()


输出：

    欢迎访问首页。
    耗时2.0009069442749023秒。


需求是实现了，但是修改了原来 `index` 函数的源代码。

那么我们就要想另外的办法去实现了。

我们不能修改函数的源代码，那么我们现在能想到的就是定义一个新的函数来实现这个功能。

类似于这样：

    def wrapper():
        start_time = time.time()
        index()  # 在这个函数内部调用下index
        stop_time = time.time()
        print("耗时{}秒。".format(stop_time - start_time))


这里会有一个问题是，`index()`写死在`wrapper()`里了，让我们先优化一下。通过传参数的方式来实现：

    def wrapper(func):  # 设置一个参数
        start_time = time.time()
        func()  # 在这个函数内部调用下func
        stop_time = time.time()
        print("耗时{}秒。".format(stop_time - start_time))



这样貌似就可以了，在调用`index`的地方直接写`wrapper(index)`就可以了。

但是，这样做会修改原函数的调用方式，原来是`index()`，现在变成了`wrapper(index)`，显然这么做同样还是不能满足我们的要求。

怎么办呢，我们其实可以将 `wrapper` 函数改名为 `index`，这样就实现了既不修改原来的调用方式又扩展了新功能。简直完美。

让我们来写一下：

    def wrapper(func):  # 设置一个参数
        start_time = time.time()
        func()  # 在这个函数内部调用下func
        stop_time = time.time()
        print("耗时{}秒。".format(stop_time - start_time))
        
    index = wrapper
    index()  # 报错了。wrapper函数的func参数怎么办？


我们现在的问题是：

我通过修改函数名之后，原函数本身没有参数，但是我定义的新函数内部又用到外面的变量怎么办？

用闭包啊！把这个变量做成外部函数的局部变量：

    def timer():
        func = index  # 在外部函数定义一个局部变量
        def wrapper():  # 设置一个参数
            start_time = time.time()
            func()  # 在这个函数内部调用下func
            stop_time = time.time()
            print("耗时{}秒。".format(stop_time - start_time))
        return wrapper


上面的写法写死了`func = index`，我们还可以优化下：

    def timer(func):  # 传一个func参数和下面func = index一样都是在my_index函数内部定义了一个局部变量
        # func = index  # 在外部函数定义一个局部变量
        def wrapper():  # 设置一个参数
            start_time = time.time()
            func()  # 在这个函数内部调用下func
            stop_time = time.time()
            print("耗时{}秒。".format(stop_time - start_time))
        return wrapper


好了，我们刚刚就已经写好了一个装饰器。

验证一下，我们的成果：

    index = timer(index)
    index()


输出：

    欢迎访问首页。
    耗时1.0029211044311523秒。


1.  没有修改原函数的源代码。
2.  没有修改原函数的调用方式。(虽然此时的index已不再是原来的index，但是并没有修改调用index的方式。)

现在我们来验证下我们的成果：

    import time
    import random
    
    def index():
        time.sleep(random.randrange(1, 5))  # 随机sleep几秒
        print("欢迎访问首页。")
    
    def home():
        time.sleep(random.randrange(1, 5))  # 随机sleep几秒
        print("欢迎访问个人主页。")
    
    def timer(func):  # 传一个func参数和下面func = index一样都是在my_index函数内部定义了一个局部变量
        def wrapper():  # 设置一个参数
            start_time = time.time()
            func()  # 在这个函数内部调用下func
            stop_time = time.time()
            print("耗时{}秒。".format(stop_time - start_time))
        return wrapper
    
    index = timer(index)
    home = timer(home)
    index()
    home()


输出：

    欢迎访问首页。
    耗时3.0008788108825684秒。
    欢迎访问个人主页。
    耗时3.00280499458313秒。


简直完美，功能实现可以装饰任意函数。就是写起来有点麻烦。Python中支持更简便的写法，往下看。

### 装饰器的语法

在被装饰对象的正上方单独的一行写上`@装饰器名`即可

用装饰器的语法修改一下我们上面的代码：

    def timer(func):  # 传一个func参数和下面func = index一样都是在my_index函数内部定义了一个局部变量
        def wrapper():  # 设置一个参数
            start_time = time.time()
            func()  # 在这个函数内部调用下func
            stop_time = time.time()
            print("耗时{}秒。".format(stop_time - start_time))
        return wrapper
    
    @timer  # 相当于做了 index = timer(index) 操作
    def index():
        time.sleep(random.randrange(1, 5))  # 随机sleep几秒
        print("欢迎访问首页。")


让我们练习写一个装饰器来巩固下上面学习的内容：给 `index` 和 `home` 函数加一个验证功能，用户名和密码正确才打印欢迎信息。否则打印“验证失败”。

先写一个用于验证的装饰器：

    def auth(func):
        def wrapper():
            name = input("用户名：").strip()
            password = input("密码：").strip()
            if name == "Andy" and password == "123":
                print("验证成功！")
                func()
            else:
                print("验证失败！")
        return wrapper


测试一下：

    @auth
    def index():
        time.sleep(random.randrange(1, 5))  # 随机sleep几秒
        print("欢迎访问首页。")
        
    index()


输出：

    用户名：Andy
    密码：123
    验证成功！
    欢迎访问个人主页。


基本的装饰器介绍到这里就结束了。后面还会有多个装饰器及带参数的装饰器。
