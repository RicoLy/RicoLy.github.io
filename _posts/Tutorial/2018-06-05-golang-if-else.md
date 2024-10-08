---
layout: post
title: Go教程:05-控制结构if-else
category: Tutorial
tags: Golang Tutorial
description: Go教程:05-控制结构if-else
---

![Go教程:05-控制结构if-else](/assets/image/golang_if_else.jpg#pic_center)

1.if语法样式
--------

if 是用于测试某个条件（布尔型或逻辑型）的语句,如果该条件成立,则会执行 if 后由大括号括起来的代码块,否则就忽略该代码块继续执行后续的代码.

    if condition {
    	// do something	
    }


2.if-else语言样式
-------------

如果存在第二个分支,则可以在上面代码的基础上添加 else 关键字以及另一代码块,这个代码块中的代码只有在条件不满足时才会执行. if 和 else 后的两个代码块是相互独立的分支,只可能执行其中一个.

    if condition {
    	// do something	
    } else {
    	// do something	
    }


3.if-else更多分支
-------------

如果存在第三个分支,则可以使用下面这种三个独立分支的形式：

    if condition1 {
    	// do something	
    } else if condition2 {
    	// do something else	
    } else {
    	// catch-all or default
    }


else-if 分支的数量是没有限制的,但是为了代码的可读性,还是不要在 if 后面加入太多的 else-if 结构.如果您必须使用这种形式,则把尽可能先满足的条件放在前面.

4.if-else注意事项
-------------

即使当代码块之间只有一条语句时,大括号也不可被省略(尽管有些人并不赞成,但这还是符合了软件工程原则的主流做法).

关键字 if 和 else 之后的左大括号 `{` 必须和关键字在同一行,如果您使用了 else-if 结构,则前段代码块的右大括号 `}` 必须和 else-if 关键字在同一行.这两条规则都是被编译器强制规定的.

非法的 Go 代码:

    if x{
    }
    else {	// 无效的
    }


要注意的是,在您使用 `gofmt` 格式化代码之后,每个分支内的代码都会缩进 4 个或 8 个空格,或者是 1 个 tab,并且右大括号与对应的 if 关键字垂直对齐.

在有些情况下,条件语句两侧的括号是可以被省略的;当条件比较复杂时,则可以使用括号让代码更易读.条件允许是符合条件,需使用 &&,

 

或 !,您可以使用括号来提升某个表达式的运算优先级,并提高代码的可读性.

一种可能用到条件语句的场景是测试变量的值,在不同的情况执行不同的语句,不过将在第 5.3 节讲到的 switch 结构会更适合这种情况.

5.if-else示例
-----------

    package main
    import "fmt"
    func main() {
    	bool1 := true
    	if bool1 {
    		fmt.Printf("The value is true\n")
    	} else {
    		fmt.Printf("The value is false\n")
    	}
    }


输出：

    The value is true


**注意事项** 这里不需要使用 `if bool1 == true` 来判断,因为 `bool1` 本身已经是一个布尔类型的值.

这种做法一般都用在测试 `true` 或者有利条件时,但您也可以使用取反 `!` 来判断值的相反结果,如：`if !bool1` 或者 `if !(condition)`.后者的括号大多数情况下是必须的,如这种情况：`if !(var1 == var2)`.

当 if 结构内有 break,continue,goto 或者 return 语句时,Go 代码的常见写法是省略 else 部分（另见第 5.2 节）.无论满足哪个条件都会返回 x 或者 y 时,一般使用以下写法：

    if condition {
    	return x
    }
    return y


**注意事项** 不要同时在 if-else 结构的两个分支里都使用 return 语句,这将导致编译报错 `function ends without a return statement`（您可以认为这是一个编译器的 Bug 或者特性）.（ **译者注：该问题已经在 Go 1.1 中被修复或者说改进** ）

这里举一些有用的例子：

1.  判断一个字符串是否为空：
    *   `if str == "" { ... }`
    *   `if len(str) == 0 {...}`
2.  判断运行 Go 程序的操作系统类型,这可以通过常量 `runtime.GOOS` 来判断.

         if runtime.GOOS == "windows"	 {
             .	..
         } else { // Unix-like
             .	..
         }


    这段代码一般被放在 init() 函数中执行.这儿还有一段示例来演示如何根据操作系统来决定输入结束的提示：
    
         var prompt = "Enter a digit, e.g. 3 "+ "or %s to quit."
        	
         func init() {
             if runtime.GOOS == "windows" {
                 prompt = fmt.Sprintf(prompt, "Ctrl+Z, Enter")		
             } else { //Unix-like
                 prompt = fmt.Sprintf(prompt, "Ctrl+D")
             }
         }


3.  函数 `Abs()` 用于返回一个整型数字的绝对值:

         func Abs(x int) int {
             if x < 0 {
                 return -x
             }
             return x	
         }


4.  `isGreater` 用于比较两个整型数字的大小:

         func isGreater(x, y int) bool {
             if x > y {
                 return true	
             }
             return false
         }



6.if-else包含一个初始化语句
------------------

在第四种情况中,if 可以包含一个初始化语句（如：给一个变量赋值）.这种写法具有固定的格式（在初始化语句后方必须加上分号）：

    if initialization; condition {
    	// do something
    }


例如:

    val := 10
    if val > max {
    	// do something
    }


您也可以这样写:

    if val := 10; val > max {
    	// do something
    }


但要注意的是,**_使用简短方式 `:=` 声明的变量的作用域只存在于 if 结构中_**（在 if 结构的大括号之间,如果使用 if-else 结构则在 else 代码块中变量也会存在）. 如果变量在 if 结构之前就已经存在,那么在 if 结构中,该变量原来的值会被隐藏.最简单的解决方案就是不要在初始化语句中声明变量.

    package main
    
    import "fmt"
    
    func main() {
    	var first int = 10
    	var cond int
    
    	if first <= 0 {
    		fmt.Printf("first is less than or equal to 0\n")
    	} else if first > 0 && first < 5 {
    		fmt.Printf("first is between 0 and 5\n")
    	} else {
    		fmt.Printf("first is 5 or greater\n")
    	}
    	if cond = 5; cond > 10 {
    		fmt.Printf("cond is greater than 10\n")
    	} else {
    		fmt.Printf("cond is not greater than 10\n")
    	}
    }


输出：

    first is 5 or greater
    cond is not greater than 10


下面的代码片段展示了如何通过在初始化语句中获取函数 `process()` 的返回值,并在条件语句中作为判定条件来决定是否执行 if 结构中的代码：

    if value := process(data); value > max {
    	...
    }
    
