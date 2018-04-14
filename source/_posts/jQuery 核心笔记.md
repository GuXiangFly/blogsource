---
title: jQuery 核心笔记
date: 2017-3-34 21:09:04
tags: [前端]

---
## jQuery 核心笔记
``` javascript
  1:在js 里面可以使用window.onload= 当页面上面所有的元素加载完毕之后执行触发


  2:$(document).ready(function(){
	});

  3:$(function(){})  ==  window.jQuery(document).ready(function());
   
   执行时机：window.onload 它需要等待页面上面所有的元素都加载完毕，包括图片，src=""
	$(function(){})  只需要页面上面的dom 元素绘制完毕之后就执行，不包含图片或第三方的连接地址...
```

## 两种each的用法 ，效果是一样的
``` javascript
$("input:hidden").each(function(){
			alert( $(this).val() );
 });
```
遍历每个元素的时候，都会执行这个函数。

``` javaScript
			// $.each 全局函数
			// * 回调函数
			// ** 参数1：index 遍历索引
			// ** 参数2：domEle 当前遍历的对象，及==this
			//
			$.each($("input:hidden"),function(index, domEle){
				alert(index + " @ " +  $(domEle).val() );
			});
```

##	层级选择器
 

A  B ， 获得A元素内部所有的B后代元素。（爷孙）
A > B ，获得A元素内部所有的B子元素。（父子）
A + B ，获得A元素后面的第一个兄弟B。（兄弟）
A ~ B ，获得A元素后面的所有的兄弟B。（兄弟）
