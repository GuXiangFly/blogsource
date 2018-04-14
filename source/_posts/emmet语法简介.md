---
title: emmet语法简介
date: 2017-4-14 23:00:04
tags: [前端]

---
##为什么使用emmet
在前端开发中，常常需要打 < 尖括号以及闭合符号 ，并且如果html一写多 会造成大量的层次混乱。但是这些问题大多繁琐重复 会大量 浪费开发者的时间，于是就有了emmet语法的出现。 而前端开发在现今日益重要，无论是前端工程师，还是后端工程师 使用emmet都能提高开发效率。  
现在支持emmet的编辑器据我所知就有

 - **eclipse+aptana** 
 （默认快捷键是 ctrl+alt+enter  在老版本的aptana是不支持   emmet的 需要自己下emmet插件 最新的自带支持）
 - **eclipse+emmet插件** （默认快捷键为 ctrl+e）
 - **sublime text3** （快捷键默认为 tab）
 - **HBuilder**（快捷键默认也为 tab）
 - **等等**。。

##emmet的快速入门
###下面给出几种emmet常用的语法

- **同级命令**   
   **示例 div+p**    （+是同级 (兄弟)命令的标识） 
   结果如下
```html
			<div></div>
			<p></p>
```


- **下级命令**   
   **示例 div>p**    （>是子命令的标识） 
   结果如下
```html
			<div>
		          <p></p>
	       </div>
```

- **上级命令**   
   **示例 div>span>p^a **    （^上升命令的标识） 
   结果如下
```html

		   <div>
			<span>
		<p></p>
			</span>
			<a href=""></a>
		</div 
```
 - **分组命令**    
   **示例 div>（table>ul>li）+div **    （ 用于让括号内的运算 优先） 
   结果如下
```html
<div>
	<table>
		<ul>
			<li></li>
		</ul>
	</table>
	<div></div>
</div>
```
    
   - **乘法符号 **   
   **示例 div*5   **    （^上升命令的标识） 
   结果如下
```html

<div></div>
<div></div>
<div></div>
<div></div>
<div></div>
```


<div class="id"></div>
<div id="id"></div>
   - **ID和类属性 **   
   **示例 div.id    div#id  **    （^上升命令的标识） 
   结果如下
```html
<div class="id"></div>
<div id="id"></div>
```
   - **自定义属性文本 **   
   **input[name="abc"]  **    （^上升命令的标识） 
   结果如下
```html
<input type="text" name="abc" />
```