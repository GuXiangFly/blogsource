---
title: JavaScript回调函数详解
date: 2017-4-7 21:32:24
tags: [前端]
---

## 介绍 ##
相信很多做后端的特别是java程序员写JavaScript都有点写不惯，其中重要原因之一就是搞不清楚回调函数。   
什么是回调函数呢？  其实回调函数的基本思想就是

> 通过把一个函数的指针，当做另外一个函数的参数，这个函数就叫回调函数。

回调函数有三种实现方式，下面我来一一介绍：

----------


通过指针来调用
--
首先上例子：

这是一段程序，用来比较两个数值的大小。


```JavaScript
<script type="text/javascript">



        function max(num1,num2) {
            if(num1>num2){
                return num1;
            }
            else {
                return num2;
            }
        }

        function  min(num1,num2) {
            if(num1<num2){
                return num1;
            }
            else {
                return num2;
            }
        }


        function math1(num1,num2) {
            return min(num1,num2);
        }
        alert(alert(math1(10,20)));


    </script>
```
这是我们后端程序最先想到的写法，但是JavaScript中能传入指针，这样的坏处就是太死板
如果我们想改为比较 max 的，需要改动原来的方法的源代码来调用。
但是javascript能使用指针调用。于是摇身一变就能变成这样。

```JavaScript
  <script type="text/javascript">
  /**
         *
         * @param num1
         * @param num2
         * @param fun   函数指针
         * @returns {*}
         */
        function math2(num1,num2,fun) {
            return fun(num1,num2);
        }


        function max(num1,num2) {
            if(num1>num2){
                return num1;
            }
            else {
                return num2;
            }
        }

        function  min(num1,num2) {
            if(num1<num2){
                return num1;
            }
            else {
                return num2;
            }
        }
		//比较最大的
        alert(math2(10,20,max));
		//比较较小的
		alert(math2(10,20,min));

        
 </script>
```

这就是通过函数指针来调用。
通过把一个函数的指针，当做另外一个函数的参数，这个函数就叫回调函数

----------
## 通过匿名函数来调用 ##

由于JavaScript中 函数可以这么定义

```JavaScript
var  a1 = func(aa,bb,cc){
   alert("aa+bb+cc");
}
```
我们。
于是我们可以化简上面的写法

```JavaScript
  <script type="text/javascript">
    /**
         *
         * @param num1
         * @param num2
         * @param fun   函数指针
         * @returns {*}
         */
        function math2(num1,num2,fun) {
            return fun(num1,num2);
        }

       alert( math2(10,20,function (num1,num2) {
           if(num1<num2){
               return num1;
           }
           else {
               return num2;
           }
       }))
    </script>
```

类似于我们Java中的 模板设计模式， 里面就有钩子函数。

```JavaScript
  alert(
           
      (function math3(num1,num2,fun) {
           return fun(num1,num2);
       })(10,20,function (num1,num2) {
           if(num1<num2){
               return num1;
           }
           else {
               return num2;
        }
        })
       
       )
```

----------


## 定义和方法同时执行的方式 ##
这种其实换汤不换药，是第二种的改进版

我们完全可以想想成以下的
```JavaScript
	
	var math=function math3(num1,num2,fun) {
           return fun(num1,num2);
       }


alert(
	math(10,20,function (num1,num2) {
           if(num1<num2){
               return num1;
           }
           else {
               return num2;
        }
        })
      )  
```

