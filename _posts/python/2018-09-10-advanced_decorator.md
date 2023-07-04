---
layout: post
title: 装饰器进阶
category: Python
tags: python
keywords: python
description: 装饰器进阶
---


现在，我们已经明白了装饰器的原理。接下来，我们还有很多事情需要搞清楚。比如：装饰带参数的函数、多个装饰器同时装饰一个函数、带参数的装饰器和类装饰器。

装饰带参数函数
-------

    def foo(func):  # 接收的参数是一个函数名
        def bar(x, y):  # 这里需要定义和被装饰函数相同的参数
            print("这里是新功能...")  # 新功能
            func(x, y)  # 被装饰函数名和参数都有了，就能执行被装饰函数了
        return bar
    
    
    # 定义一个需要两个参数的函数
    @foo
    def f1(x, y):
        print("{}+{}={}".format(x, y, x+y))
    
    
    # 调用被装饰函数
    f1(100, 200)


输出：

    这里是新功能...
    100+200=300


多个装饰器
-----

    def foo1(func):
        print("d1")
    
        def inner1():
            print("inner1")
            return "<i>{}</i>".format(func())
    
        return inner1
    
    
    def foo2(func):
        print("d2")
    
        def inner2():
            print("inner2")
            return "<b>{}</b>".format(func())
    
        return inner2
    
    
    @foo1
    @foo2
    def f1():
        return "Hello Andy"
    
    # f1 = foo2(f1)  ==> print("d2") ==> f1 = inner2
    # f1 = foo1(f1)  ==> print("d1") ==> f1 = foo1(inner2) ==> inner1
    
    ret = f1()  # 调用f1() ==> inner1()  ==> <i>inner2()</i>  ==> <i><b>inner1()</b></i> ==> <i><b>Hello Andy</b></i>
    print(ret)


带参数装饰器
------

> 被装饰的函数可以带参数，装饰器同样也可以带参数。

回头看我们上面写得那些装饰器，它们默认把被装饰的函数当成唯一的参数。但是呢，有时候我们需要为我们的装饰器传递参数，这种情况下应该怎么办呢？

接下来，我们就一步步实现带参数的装饰器：

首先我们来回顾下上面的代码：

    def f1(func):  # f1是我们定义的装饰器函数，func是被装饰的函数
        def f2(*arg, **kwargs):  # *args和**kwargs是被装饰函数的参数
            func(*arg, **kwargs)
        return f2


从上面的代码，我们发现了什么？

我的装饰器如果有参数的话，没地方写了…怎么办呢？

还是要使用闭包函数！

我们需要知道，函数除了可以嵌套两层，还能嵌套更多层：

    # 三层嵌套的函数1
    def f1():    
        def f2():
            name = "Andy"       
            def f3():
                print(name)
            return f3    
        return f2


嵌套三层之后的函数调用：

    f = f1()  # f --> f2
    ff = f()  # ff --> f3
    ff()  # ff()  --> f3()  --> print(name)  --> Andy


注意：在内部函数`f3`中能够访问到它外层函数`f2`中定义的变量，当然也可以访问到它最外层函数`f1`中定义的变量。

    # 三层嵌套的函数2
    def f1():
        name = "Andy"
        def f2():
            def f3():
                print(name)
            return f3
        return f2


调用：

    f = f1()  # f --> f2
    ff = f()  # ff --> f3
    ff()  # ff()  --> f3()  --> print(name)  --> Andy


好了，现在我们就可以实现我们的带参数的装饰器函数了：

    # 带参数的装饰器需要定义一个三层的嵌套函数
    def d(name):  # d是新添加的最外层函数，为我们原来的装饰器传递参数，name就是我们要传递的函数
        def f1(func):  # f1是我们原来的装饰器函数，func是被装饰的函数
            def f2(*arg, **kwargs):  # f2是内部函数，*args和**kwargs是被装饰函数的参数
                print(name)  # 使用装饰器函数的参数
                func(*arg, **kwargs)  # 调用被装饰的函数
            return f2
        return f1


上面就是一个带参装饰器的代码示例，现在我们来写一个完整的应用：

    def d(a=None):  # 定义一个外层函数，给装饰器传参数--role
        def foo(func):  # foo是我们原来的装饰器函数，func是被装饰的函数
            def bar(*args, **kwargs):  # args和kwargs是被装饰器函数的参数
                # 根据装饰器的参数做一些逻辑判断
                if a:
                    print("欢迎来到{}页面。".format(a))
                else:
                    print("欢迎来到首页。")
                # 调用被装饰的函数，接收参数args和kwargs
                func(*args, **kwargs)
            return bar
        return foo
    
    
    @d()  # 不给装饰器传参数，使用默认的'None'参数
    def index(name):
        print("Hello {}.".format(name))
    
    
    @d("电影")  # 给装饰器传一个'电影'参数
    def movie(name):
        print("Hello {}.".format(name))
    
    if __name__ == '__main__':
        index("Andy")
        movie("Andy")


输出：

    欢迎来到首页。
    Hello Andy.
    欢迎来到电影页面。
    Hello Andy.


类装饰器和装饰类
--------

### 类装饰器

除了用函数去装饰函数外，我们还可以使用类去装饰函数。

    class D(object):
        def __init__(self, a=None):
            self.a = a
            self.mode = "装饰"
    
        def __call__(self, *args, **kwargs):
            if self.mode == "装饰":
                self.func = args[0]  # 默认第一个参数是被装饰的函数
                self.mode = "调用"
                return self
            # 当self.mode == "调用"时，执行下面的代码（也就是调用使用类装饰的函数时执行）
            if self.a:
                print("欢迎来到{}页面。".format(self.a))
            else:
                print("欢迎来到首页。")
            self.func(*args, **kwargs)
    
    
    @D()
    def index(name):
        print("Hello {}.".format(name))
    
    
    @D("电影")
    def movie(name):
        print("Hello {}.".format(name))
    
    if __name__ == '__main__':
        index("Andy")
        movie("Andy")


### 装饰类

我们上面所有的例子都是装饰一个函数，返回一个可执行函数。Python中的装饰器除了能装饰函数外，还能装饰类。

可以使用装饰器，来批量修改被装饰类的某些方法：

    # 定义一个类装饰器
    class D(object):
        def __call__(self, cls):
            class Inner(cls):
                # 重写被装饰类的f方法
                def f(self):
                    print("Hello Andy.")
            return Inner
    
    
    @D()
    class C(object):  # 被装饰的类
        # 有一个实例方法
        def f(self):
            print("Hello world.")
    
    
    if __name__ == '__main__':
        c = C()
        c.f()
    
