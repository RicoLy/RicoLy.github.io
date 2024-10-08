---
layout: post
title: Go教程:03-数据类型
category: Tutorial
tags: Golang Tutorial
description: Go教程:03-数据类型
---


![Go教程:03-数据类型](/assets/image/golang_variable.png#pic_center)

Go 语言数据类型包含基础类型和复合类型两大类. 基础数据类型包括：布尔型,整型,浮点型,复数型,字符型,字符串型,错误类型. 复合数据类型包括：指针,数组,切片,字典,通道,结构体,接口.

变量声明语法
------

    var a int //声明一个int类型的变量
    
    var b struct { //声明一个结构体
        Name string
    }
    
    var a = 8 //声明变量的同时赋值,编译器自动推导其数据类型
    
    var a int = 8 //声明变量的同时赋值
    
    var { //批量声明变量,简洁
        a int
        b string
    }


go可使用var关键字声明全局变量,但是:=这种方式是不能用在全局变量中的.:=只能用在函数体内部.

    var (
        a int
        b bool
        xx,yy,dd string="xx","yy","dd"
        //这里省略变量类型也是可以的.
        zz,aa="zz","aa"
    )


还需要注意的是,go的变量是如果被声明了,那么必须使用,不然会报错,如果不想使用可以加上_=varName,表示为已抛弃的变量.

    //已声明,但未使用
    var a=1
    //标识为已抛弃的变量.
    _=a


变量初始化
-----

**Go 语言在声明变量时会默认给变量赋个当前类型的`空值`/`零值`**

变量的初始化工作可以在声明变量时进行初始化,也可以先声明后初始化.此时var关键字不再是必须的.

初始化变量有多种方式,每种方式有不同的使用场景：

在方法中声明一个临时变量并赋初值

    var tmpStr = ""
    var tmpStr string = ""
    tmpStr :=""


我们看到有此两种方式：

var name \[type\] = value

如果不书写 type ,则在编译时会根据value自动推导其类型.

name := value

这里省略了关键字var,我很喜欢这种方式（可以少写代码,而没有任何坏处）. 但这有需要注意的是”:=” 是在声明和初始化变量,因此该变量必须是第一次出现,如下初始化是错误的. 但是要注意赋值时要确定您想要的类型,在Go中不支持隐式转换的. 如果是定义个float64类型的变量,请写为 v1 :=8.0 而不是v1 :=8 .

Go语言`零值`/`空值`
-------------

当一个变量或者新值被创建时, 如果没有为其明确指定初始值,go语言会自动初始化其值为此类型对应的零值, 各类型零值如下： 对于复合类型, go语言会自动递归地将每一个元素初始化为其类型对应的零值. 比如：数组, 结构体 .

|  类型   | 零值  |
|  :----:  | :----:  |
| 数值类型  | 0 |
| 布尔类型  | false |
| 字符串  | 0 |
| 布尔类型  | ”“（空字符串） |
| slice  | nil |
| map  | nil |
| 指针  | nil |
| 函数  | nil |
| 接口  | nil |
| 信道  | nil |


