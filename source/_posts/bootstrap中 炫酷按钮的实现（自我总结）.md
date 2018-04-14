---
title: bootstrap中 炫酷按钮的实现（自我总结）
date: 2017-3-34 21:09:04
tags: [前端,bootstrap]
---
## bootstrap中 炫酷按钮的实现
先上效果图
![这里写图片描述](http://img.blog.csdn.net/20170517231801058?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvbXlfX1N1bl8=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)

```html
     <a href="#" class="btn btn-primary" target="_blank" role="button">
                        加入学习
     </a>
```
我在 使用 role属性 给它加了一个 button 的角色


----------


下面上CSS
```css
#course .btn {
    background: transparent;
    border: 1px solid #40D2B1;
    border-radius: 0px;
    color: #40d;
    margin-top: 20px;
    margin-bottom: 20px;
    padding: 8px 40px;
    transition: all 0.3s;
}
```
transparent ：设置button背景为透明
border: 1px solid #40D2B1;  1px 粗细的线条  颜色为#40D2B1;

border-radius: 是去掉原来的圆角

transition：all 0.3 表示动画有0.3秒

要实现动画 我们还需要加 hover 事件

```
	#course .btn:hover {
    background: #40D2B1;
    color: #fff;
}

```
 hover 代表鼠标悬停的时候 触发的事件