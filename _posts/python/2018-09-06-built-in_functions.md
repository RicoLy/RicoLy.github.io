---
layout: post
title: Python基础之内置函数
category: Python
tags: python
keywords: python
description: Python基础之内置函数
---

本文介绍了Python中的常用内置函数及用法。

内置函数
----

### 内置函数预览

参考链接：[Python3内置函数官方文档](https://docs.python.org/3/library/functions.html?highlight=built)

Python解释器有很多的内置函数，可以被调用。他们按照字母顺序排列如下：

内置函数

abs()

dict()

help()

min()

setattr()

all()

dir()

hex()

next()

slice()

any()

divmod()

id()

object()

sorted()

ascii()

enumerate()

input()

oct()

staticmethod()

bin()

eval()

int()

open()

str()

bool()

exec()

isinstance()

ord()

sum()

bytearray()

filter()

issubclass()

pow()

super()

bytes()

float()

iter()

print()

tuple()

callable()

format()

len()

property()

type()

chr()

frozenset()

list()

range()

vars()

classmethod()

getattr()

locals()

repr()

zip()

compile()

globals()

map()

reversed()

\_\_import\_\_()

complex()

hasattr()

max()

round()

delattr()

hash()

memoryview()

set()

上表中共列出了Python3目前全部68个内置函数。 接下我们逐一来介绍下这些内置函数。

### 内置函数详解

**abs(_x_)**

返回数字的绝对值。参数可以是整数或浮点数。如果参数是复数，则返回其大小。

    >>> x = 1
    >>> abs(x)
    1
    >>> x = -1
    >>> abs(x)
    1
    >>> x = 1.2
    >>> abs(x)
    1.2
    >>> x = -1.2
    >>> abs(x)
    1.2
    >>> x = 1 + 2j
    >>> abs(x)
    2.23606797749979


**all(_iterable_)** 如果 _iterable_ 的所有元素都为true，则返回True（或者如果 _iterable_ 为空）。相当于：

    def all(iterable):
        for element in iterable:
            if not element:
                return False
        return True


几个典型例子：

    >>> l = [True, 1]
    >>> all(l)
    True
    >>> l = [1+1>2, True or False]
    >>> all(l)
    False
    >>> l = [True, False]
    >>> all(l)
    False
    >>> l = []
    >>> all(l)
    True


**any(_iterable_)**

如果 _iterable_ 的任何元素为true，则返回True。如果 _iterable_ 为空，则返回False。相当于：

    def any(iterable):
        for element in iterable:
            if element:
                return True
        return False


几个典型例子：

    >>> l = [True, 1]
    >>> any(l)
    True
    >>> l = [1+1>2, True and False]
    >>> any(l)
    False
    >>> l = [True, False]
    >>> any(l)
    True
    >>> l = []
    >>> any(l)
    False


**ascii(_object_)**

和repr()一样，返回一个包含对象的可打印表示的字符串，但是使用\\x，\\u或\\U转义由repr()返回的字符串中的非ASCII字符。这样会生成一个类似于Python 2中由repr()返回的字符串。

示例：

    >>> ascii("A")
    "'A'"
    >>> ascii("中国")
    "'\\u4e2d\\u56fd'"
    >>> ascii("Hello world!")
    "'Hello world!'"
    >>> ascii(["a", "b", "c"])
    "['a', 'b', 'c']"


**bin(_x_)**

将整数转换为二进制字符串。结果是一个有效的Python表达式。如果 _x_ 不是Python int对象，则必须定义返回一个整数的\_\_index\_\_()方法。

几个例子：

    >>> bin(1)
    '0b1'
    >>> bin(3)
    '0b11'
    >>> bin(10)
    '0b1010'
    >>> bin(65)
    '0b1000001'


_class_ **bool**(\[_x_\])

返回一个布尔值，即True或False。

几个例子：

    >>> bool()
    False
    >>> bool(1>2)
    False
    >>> bool(0)
    False
    >>> bool(1)
    True
    >>> bool("Andy")
    True


_class_ **bytearray**(\[_source_\[, _encoding_\[, _errors_\]\]\])

返回一个新的字节数组。bytearray类是0 <= x <256范围内的可变整数序列。

    >>> bytearray()
    bytearray(b'')
    >>> bytearray("A", encoding="utf-8")
    bytearray(b'A')
    >>> bytearray("A", encoding="gbk")
    bytearray(b'A')
    >>> "A".encode()
    b'A'


_class_ **bytes**(\[_source_\[, _encoding_\[, _errors_\]\]\])

返回一个新的“bytes”对象，它是一个不可变的整数序列，范围为0 <= x <256。

举个例子：

    >>> bytes()
    b''
    >>> bytes("A", encoding="utf-8")
    b'A'
    >>> bytes("123", encoding="utf-8")
    b'123'


**callable**(_object_)

如果 _object_ 参数可以被调用，则返回True，否则返回False。如果返回true，那么仍然可能调用失败，但如果它返回false，则调用对象将永远不会成功。

**注意**类是可以调用的（调用一个类返回一个新的实例）;如果实例的类有\_\_call\_\_()方法，则实例就可以调用。

**chr**(_i_)

返回Unicode代码为整数 _i_ 的字符的字符串表示。

举个例子：

    >>> chr(65)
    'A'
    >>> chr(98)
    'b'
    >>> chr(165)
    '¥'


**classmethod**(_function_)

返回一个类方法。要声明一个类的方法，可以这样写：

    class C:
        @classmethod
        def f(cls, arg1, arg2, ...): ...


**compile**(_source_, _filename_, _mode_, _flags=0_, _dont_inherit=False_, _optimize=-1_)

将源编译成代码或AST对象。

_class_ **complex**(\[_real_\[, _imag_\]\])

返回一个复数，值为true + imag * 1j，或将字符串或数字转换为复数。

    >>> complex()
    0j
    >>> complex("1+2j")
    (1+2j)
    >>> complex(10)
    (10+0j)


**delattr**(_object_, _name_)

这是setattr()的相关。参数是一个对象和一个字符串。字符串必须是对象属性的一个名称。只要该对象允许，该函数就会删除该命名属性。例如`delattr(x, 'foobar')`等价于`del x.foobar`。

_class_ **dict**(*_*kwarg_)

_class_ **dict**(_mapping_, *_*kwarg_)

_class_ **dict**(_iterable_, *_*kwarg_)

创建一个新的字典。

    >>> dict()
    {}
    >>> dict(a=1, b=2)
    {'a': 1, 'b': 2}
    >>> dict([("a", 1), ("b", 2)])
    {'a': 1, 'b': 2}
    >>> dict({"a": 1, "b": 2})
    {'a': 1, 'b': 2}


**dir**(\[_object_\])

没有参数，返回当前本地作用域中的名称列表。使用参数，尝试返回该对象的有效属性列表。

    >>> dir()
    ['__annotations__', '__builtins__', '__doc__', '__loader__', '__name__', '__package__', '__spec__', 'l', 'num']
    >>> dir("a")
    ['__add__', '__class__', '__contains__', '__delattr__', '__dir__', '__doc__', '__eq__', '__format__', '__ge__', '__getattribute__', '__getitem__', '__getnewargs__', '__gt__', '__hash__', '__init__', '__init_subclass__', '__iter__', '__le__', '__len__', '__lt__', '__mod__', '__mul__', '__ne__', '__new__', '__reduce__', '__reduce_ex__', '__repr__', '__rmod__', '__rmul__', '__setattr__', '__sizeof__', '__str__', '__subclasshook__', 'capitalize', 'casefold', 'center', 'count', 'encode', 'endswith', 'expandtabs', 'find', 'format', 'format_map', 'index', 'isalnum', 'isalpha', 'isdecimal', 'isdigit', 'isidentifier', 'islower', 'isnumeric', 'isprintable', 'isspace', 'istitle', 'isupper', 'join', 'ljust', 'lower', 'lstrip', 'maketrans', 'partition', 'replace', 'rfind', 'rindex', 'rjust', 'rpartition', 'rsplit', 'rstrip', 'split', 'splitlines', 'startswith', 'strip', 'swapcase', 'title', 'translate', 'upper', 'zfill']


**divmod**(_a_, _b_)

以两个（非复数）数字作为参数，使用整数除法返回一个由他们的商和余数组成的数字。

举个例子：

    >>> divmod(2,1)
    (2, 0)
    >>> divmod(5,2)
    (2, 1)
    >>> divmod(7,3)
    (2, 1)


**enumerate**(_iterable_, _start=0_)

直接看例子：

    >>> l = ["Alex", "Rain", "Egon", "Yuan"]
    >>> enumerate(l)
    <enumerate object at 0x10aca9948>
    >>> list(enumerate(l))
    [(0, 'Alex'), (1, 'Rain'), (2, 'Egon'), (3, 'Yuan')]
    >>> for n, v in enumerate(l):
    ...     print(n, v)
    ... 
    0 Alex
    1 Rain
    2 Egon
    3 Yuan
    >>> for n, v in enumerate(l, start=1):
    ...     print(n, v)
    ... 
    1 Alex
    2 Rain
    3 Egon
    4 Yuan


其实它就等价于：

    def enumerate(sequence, start=0):
        n = start
        for elem in sequence:
            yield n, elem
            n += 1


**eval**(_expression_, _globals=None_, _locals=None_)

直接看例子：

    >>> x = 1
    >>> eval("x+1")
    2
    >>> eval("1-2+3*4/5")
    1.4


**exec**(_object_\[, _globals_\[, _locals_\]\])

此函数支持Python代码的动态执行。 _object_ 必须是字符串或代码对象。

简单来说，`exec`和`eval`有两个区别：

1.  `eval`只接受一个表达式，`exec`可以使用具有Python语句的代码块：循环，`try: except:`，类和函数/方法定义等等。
2.  `eval`返回给定表达式的值，而`exec`忽略其代码中的返回值，并始终返回`None`。

举个例子：

    >>> x = 1
    >>> eval("x+1")
    2
    >>> eval("1-2+3*4/5")
    1.4
    >>> exec("x+1")  # 一个表达式
    >>> exec("x=2")  # 一个语句
    >>> eval("x=2")  # eval()不支持传入语句，所以报错了。
    Traceback (most recent call last):
      File "<stdin>", line 1, in <module>
      File "<string>", line 1
        x=2
         ^
    SyntaxError: invalid syntax


**filter**(_function_, _iterable_)

生成一个迭代器，迭代器里面的元素是把 _iterable_ 里面的每一个元素传入 _function_ 后返回True的。

可以把`filter()`理解成过滤函数。返回那些满足条件的元素。

    >>> l = [11, 22, 33, 44, 55]
    >>> filter(lambda x: x>30, l)
    <filter object at 0x10ac9fc88>
    >>> list(filter(lambda x: x>30, l))
    [33, 44, 55]


_class_ **float**(\[_x_\])

返回从数字或字符串x构造的浮点数。

直接看例子：

    >>> float()
    0.0
    >>> float(1.23)
    1.23
    >>> float('+1.23')
    1.23
    >>> float('   -12345\n')
    -12345.0
    >>> float('1e-003')
    0.001
    >>> float('+1E6')
    1000000.0
    >>> float('-Infinity')
    -inf


**format**(_value_\[, _format_spec_\])

将 _value_ 转换为由 _format_spec_ 控制的“格式化”表示。

语法参考：[format_spec](https://docs.python.org/3/library/string.html#formatspec)

举个例子：

    >>> format(11, "b")
    '1011'
    >>> format(1234, "*>+7,d")
    '*+1,234'
    >>> format(123.4567, "^-09.3f")
    '0123.4570'


_class_ **frozenset**(\[_iterable_\])

不可变的集合类型。

    >>> s = set([1, 2, 3])
    >>> s1 = frozenset([4, 5, 6])
    >>> s.pop()
    1
    >>> s1.pop()
    Traceback (most recent call last):
      File "<stdin>", line 1, in <module>
    AttributeError: 'frozenset' object has no attribute 'pop'


**getattr**(_object_, _name_\[, _default_\])

返回对象的命名属性的值。 name必须是一个字符串。如果字符串是对象属性的一个名称，则结果就是该属性的值。例如，`getattr(x, 'foobar')`等价于`x.foobar`。

**globals**()

返回一个表示当前全局符号表的字典。

    >>> a = 1
    >>> b = "Andy"
    >>> globals()
    {'__name__': '__main__', '__doc__': None, '__package__': None, '__loader__': <class '_frozen_importlib.BuiltinImporter'>, '__spec__': None, '__annotations__': {}, '__builtins__': <module 'builtins' (built-in)>, 'a': 1, 'b': 'Andy'}


**hasattr**(_object_, _name_)

参数是一个对象和一个字符串。如果字符串是对象属性的一个名称，则结果为True，如果不是则为False。（这是通过调用getattr(object, name)并查看它是否引发AttributeError来实现的。）

**hash**(_object_)

返回对象的哈希值（如果有的话）。哈希值是整数。

    >>> hash(1)
    1
    >>> hash("a")
    4147589707994996422
    >>> hash([1, 2, 3])  # list不是可哈希的类型
    Traceback (most recent call last):
      File "<stdin>", line 1, in <module>
    TypeError: unhashable type: 'list'


**help**(\[_object_\])

调用内置的帮助系统。 （此功能用于交互式使用。）如果没有给出参数，交互式帮助系统将在解释器控制台上启动。如果参数是字符串，则将字符串作为模块，函数，类，方法，关键字或文档主题的名称进行查找，并在控制台上打印一个帮助页面。如果参数是任何其他类型的对象，则生成对象上的帮助页面。

    >>> help()
    
    Welcome to Python 3.6's help utility!
    
    If this is your first time using Python, you should definitely check out
    the tutorial on the Internet at http://docs.python.org/3.6/tutorial/.
    
    Enter the name of any module, keyword, or topic to get help on writing
    Python programs and using Python modules.  To quit this help utility and
    return to the interpreter, just type "quit".
    
    To get a list of available modules, keywords, symbols, or topics, type
    "modules", "keywords", "symbols", or "topics".  Each module also comes
    with a one-line summary of what it does; to list the modules whose name
    or summary contain a given string such as "spam", type "modules spam".
    
    help> quit
    
    You are now leaving help and returning to the Python interpreter.
    If you want to ask for help on a particular object directly from the
    interpreter, you can type "help(object)".  Executing "help('string')"
    has the same effect as typing a particular string at the help> prompt.
    >>> help("func")
    No Python documentation found for 'func'.
    Use help() to get the interactive help utility.
    Use help(str) for help on the str class.
    
    >>> help(1)
    ...  # 进入交互式帮助页面



**hex**(_x_)

将整数转换为以“0x”为前缀的小写十六进制字符串，例如：

    >>> hex(255)
    '0xff'
    >>> hex(-42)
    '-0x2a'


**id**(_object_)

返回一个对象的“身份”。这是一个整数，在整个生命周期中，该对象被保证是唯一的和不变的。具有非重叠生命周期的两个对象可能具有相同的`id()`值

**input**(\[_prompt_\])

如果提示参数存在，则将其写入标准输出，而结尾不带换行符。该函数然后从输入读取一行，将其转换为字符串（去掉结尾的换行符）并返回。

例如：

    >>> name = input("-->:")
    -->:Andy
    >>> name
    'Andy'


_class_ **int**(_x=0_)

_class_ **int**(_x_, _base=10_)

返回一个由数字或字符串 _x_ 构造的整型对象，如果没有给出参数，则返回0。

    >>> int("1")
    1
    >>> int(1)
    1
    >>> int("11", base=8)
    9
    >>> int("11", base=2)
    3


**isinstance**(_object_, _classinfo_)

如果对象参数是 _classinfo_ 参数的实例，或者（直接，间接或虚拟）子类的实例，则返回True。

    >>> isinstance("a", str)
    True
    >>> isinstance(1, int)
    True
    >>> isinstance([1, 2, 3], list)
    True


**issubclass**(_class_, _classinfo_)

如果 _class_ 是 _classinfo_ 的子类（直接，间接或虚拟），则返回True。

    >>> issubclass(bool, int)
    True


布尔类型是整数类型的子类。

**iter**(_object_\[, _sentinel_\])

返回一个迭代器对象。

**len**(_object_\[, _sentinel_\])

返回一个对象的长度（元素个数）。参数可以是sequence（如字符串，字节，元组，列表或范围）或collection（如字典，集合或冻结集合）。

    >>> len("Andy")
    4
    >>> len([1, 2, 3])
    3
    >>> len({"a": 2, "b": 3})
    2


_class_ **list**(\[_iterable_\])

列表类型。

**locals**()

更新并返回表示当前本地符号表的字典。

    >>> def func():
    ...     a = 1
    ...     print(locals())
    ... 
    >>> func()
    {'a': 1}


**map**(_function_, _iterable_, _…_)

返回一个迭代器，它将函数应用于可迭代的每个元素，从而产生结果。

    >>> l = [11, 22, 33, 44, 55]
    >>> map(lambda x:x+100, l)
    <map object at 0x10aed21d0>
    >>> list(map(lambda x:x+100, l))
    [111, 122, 133, 144, 155]


**max**(_iterable_, ***\[, _key_, _default_\])

**max**(_arg1_, _arg2_, *_args_\[, _key_\])

    >>> l = [11, 22, 33, 44, 55]
    >>> max(l)
    55
    >>> max(11, 22, 33)
    33


**memoryview**(_obj_)

返回从给定的参数创建的“内存视图”对象。

    >>> memoryview(b'Andy')
    <memory at 0x10aef9048>


**min**(_iterable_, ***\[, _key_, _default_\])

**min**(_arg1_, _arg2_, *_args_\[, _key_\])

    >>> l = [11, 22, 33, 44, 55]
    >>> min(l)
    11
    >>> min(11, 22, 33)
    11


**next**(_iterator_\[, _default_\])

通过调用其\_\_next\_\_()方法从迭代器获取下一个元素。

    >>> l = [11, 22, 33, 44, 55]
    >>> i = iter(l)
    >>> next(i)
    11
    >>> next(i)
    22
    >>> next(i)
    33
    >>> next(i)
    44
    >>> next(i)
    55
    >>> next(i)
    Traceback (most recent call last):
      File "<stdin>", line 1, in <module>
    StopIteration


_class_ **object**

返回一个新的无特征对象。`object`是所有类的基类。

**oct**(_x_)

将整数 _x_ 转换为八进制字符串。结果是一个有效的Python表达式。

    >>> oct(11)
    '0o13'
    >>> oct(8)
    '0o10'


**open**(_file_, _mode=‘r’_, _buffering=-1_, _encoding=None_, _errors=None_, _newline=None_, _closefd=True_, _opener=None_)

打开文件并返回相应的文件对象。如果无法打开该文件，则会引发OSError。

**模式字符**

**对应的含义**

`'r'`

只读模式打开（默认）

`'w'`

只写模式打开

`'x'`

创建，如果文件已经存在就失败

`'a'`

写入，如果文件存在就追加写入

`'b'`

二进制模式

`'t'`

txt模式（默认）

`'+'`

打开一个磁盘文件进行更新（读写）

`'U'`

通用换行模式（不推荐使用）

**ord**(_c_)

给定一个Unicode字符的字符串，返回对应的Unicode编码数。

    >>> ord("A")
    65
    >>> ord("1")
    49


**pow**(_x_, _y_\[, _z_\])

返回 _x_ 的 _y_ 次幂。

    >>> pow(2, 2)
    4
    >>> pow(2, 3)
    8


**print**(*_objects_, _sep=’ ‘_, _end=’\\n’_, _file=sys.stdout_, _flush=False_)

将 _object_ 打印到文本流 _file_ 中，以 _sep_ 分隔，以 _end_ 结尾。

    >>> print("Hello world!", end="*")
    Hello world!*>>> 


_class_ **property**(_fget=None_, _fset=None_, _fdel=None_, _doc=None_)

返回属性。

    class C:
        def __init__(self):
            self._x = None
    
        @property
        def x(self):
            """I'm the 'x' property."""
            return self._x
    
        @x.setter
        def x(self, value):
            self._x = value
    
        @x.deleter
        def x(self):
            del self._x


**range**(_stop_)

**range**(_start_, _stop_\[, _step_\])

直接看例子：

    >>> range(5)
    range(0, 5)
    >>> list(range(5))
    [0, 1, 2, 3, 4]
    >>> range(0, 5, 2)
    range(0, 5, 2)
    >>> list(range(0, 5, 2))
    [0, 2, 4]


**repr**(_object_)

返回一个包含对象的可打印表示的字符串。

**reversed**(_seq_)

返回一个反向迭代器。

    >>> l = [11, 22, 33, 44, 55]
    >>> reversed(l)
    <list_reverseiterator object at 0x10aed21d0>
    >>> list(reversed(l))
    [55, 44, 33, 22, 11]


**round**(_number_\[, _ndigits_\])

在小数点后，返回数字四舍五入到 _ndigits_ 精度。如果省略 _ndigits_ ，或者为None，则返回最接近整数的输入。

    >>> round(3.1415926)
    3
    >>> round(3.1415926, 3)
    3.142
    >>> round(3.1415926, 5)
    3.14159


_class_ **set**(\[_iterable_\])

集合对象。

**setattr**(_object_, _name_, _value_)

对应getattr()。

_class_ **slice**(_stop_)

_class_ **slice**(_start_, _stop_\[, _step_\])

返回表示由`range(start, stop, step)`指定的索引集的切片对象。

    >>> slice(3)
    slice(None, 3, None)
    >>> slice(0, 5, 2)
    slice(0, 5, 2)
    >>> s = slice(0, 5, 2)
    >>> s.start
    0
    >>> s.step
    2
    >>> s.stop
    5


**sorted**(_iterable\[, key\]\[, reverse\]_)

返回一个新的排序后的列表。

    >>> l = [11, 2, 4, 66, 3, 55]
    >>> sorted(l)
    [2, 3, 4, 11, 55, 66]
    >>> l = [11, 2, 4, 66, 3, 55]
    >>> sorted(l)
    [2, 3, 4, 11, 55, 66]
    >>> d = {"a": 11, "b": 2, "c": 4, "d": 66, "e": 3, "f": 55}
    >>> sorted(d, key=lambda x:d[x])
    ['b', 'e', 'c', 'a', 'f', 'd']


**staticmethod**(_function_)

返回静态方法的函数。

    class C:
        @staticmethod
        def f(arg1, arg2, ...): ...


_class_ **str**(_object=”_)

_class_ **str**(_object=b”_, _encoding=‘utf-8’_, _errors=‘strict’_)

返回一个对象的`str`版本。

**sum**(_iterable_\[, _start_\])

从左到右依次迭代求和，返回总和。 _start_ 默认是0。 _iterable_ 的元素通常是数字，起始值不允许为字符串。

    >>> l = [11, 22, 33, 44, 55]
    >>> sum(l)
    165
    >>> l = ["11", "22", "33", "44", "55"]
    >>> sum(l)
    Traceback (most recent call last):
      File "<stdin>", line 1, in <module>
    TypeError: unsupported operand type(s) for +: 'int' and 'str'
    >>> l = [11, 22, 33, 44, 55]
    >>> sum(l, 3)
    168


**super**(\[_type_\[, _object-or-type_\]\])

返回一个代理对象，将代理对象调用类型的父类或同级类。

**tuple**(\[_iterable_\])

元祖类型。

    >>> l = [11, 22, 33, 44, 55]
    >>> tuple(l)
    (11, 22, 33, 44, 55)


_class_ **type**(_object_)

_class_ **type**(_name_, _bases_, _dict_)

使用一个参数，返回一个对象的类型。有三个参数，返回一个新的类型对象。

**vars**(\[_object_\])

使用\_\_dict\_\_属性返回模块，类，实例或任何其他对象的\_\_dict\_\_属性。

返回一个可迭代或最大的两个或多个参数中的最大项。

**zip**(*_iterables_)

生成一个迭代器来聚合每个迭代的元素。返回元组的迭代器，其中第 _i_ 个元组包含来自每个参数序列或迭代的第 _i_ 个元素。

相当于：

    def zip(*iterables):
        # zip('ABCD', 'xy') --> Ax By
        sentinel = object()
        iterators = [iter(it) for it in iterables]
        while iterators:
            result = []
            for it in iterators:
                elem = next(it, sentinel)
                if elem is sentinel:
                    return
                result.append(elem)
            yield tuple(result)


举个例子：

    >>> x = [1, 2, 3]
    >>> y = [4, 5, 6]
    >>> z = zip(x, y)
    >>> list(z)
    [(1, 4), (2, 5), (3, 6)]
    >>> z = zip(x, y)  # z是一个迭代器，上一步list(z)已经把z消耗了，所以这里要重新生成一个迭代器。
    >>> x1, y1 = zip(*z)
    >>> x1
    (1, 2, 3)
    >>> y1
    (4, 5, 6)


**\_\_import\_\_**(_name_, _globals=None_, _locals=None_, _fromlist=()_, _level=0_)

**注意：**这是日常Python编程中不需要的高级功能，不像`importlib.import_module()`。

例如，`import spam`语句的字节码结果相当于以下代码：

    spam = __import__('spam', globals(), locals(), [], 0)


`import spam.ham`语句类似于以下代码：

    spam = __import__('spam.ham', globals(), locals(), [], 0)
    
