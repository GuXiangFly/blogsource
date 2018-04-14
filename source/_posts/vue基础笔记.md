
---
title: vue学习笔记
date: 2017-7-27 20:09:04
tags: [前端,vue]

---
vue 学习

每个 Vue 实例都会代理其 data 对象里所有的属性

通过data 可以操作 data里面的属性
通过 vue 也可以操作data里面的属性


## 修饰符
有些指令可以在其名称后面带一个“参数”，中间放一个冒号隔开。 
``` html
    <a v-bind:href="url"></a> 
```
``` html
    <a v-on:click="doSomething"></a> 
```


## 缩写
vue中 有且仅有这两个缩写
``` HTML
<!-- 完整语法 --> <a v-bind:href="url"></a>
 <!-- 缩写 --> <a :href="url"></a> 
```

``` html
<!-- 完整语法 --> <a v-on:click="doSomething"></a>
 <!-- 缩写 --> <a @click="doSomething"></a>
``` 


## 数值绑定

``` html
<div id=“demo"> a = {{ a }}, b = {{ b }} </div> 
```

``` javascript
var vm = new Vue({  
 el: '#demo',  
 data: { a: 1 },  
 computed: { b: function ()
               { return this.a + 1; };
           };
 }); 

结果：a = 1, b = 2
```  

这里我们声明了一个计算属性b。我们提供的函数将用作属性vm.b 的getter。
``` javascript
:function ()
               { return this.a + 1; };
           };

功能类似于

public int getB(){
	return this.a+1;
}
```

这里可以是声明式地创建这种依赖关系——计算属性的 getter 是干 净无副作用的，因此也是易于测试和理解的。 


``` javascript
window.onload = function() {
    var vm = new Vue({
        el: '#demo',
        data: {
            firstName: 'Foo',
            lastName: 'Bar'
        },
        computed: {
            fullName: {
                // getter
                get: function() {
                    return this.firstName + ' ' + this.lastName;
                },
                // setter
                set: function(newValue) {
                    var names = newValue.split(' ');
                    this.firstName = names[0];
                    this.lastName = names[names.length - 1];
                }
            }
        }
    });

    setTimeout(function() {
        vm.fullName = 'Edogawa Conan';
    }, 5000);
};
```
``` html
<div id="demo">{{ fullName }}</div>
```


## Vue.js类与样式绑定 


### 对象语法 绑定 class
``` html
<div class="static" v-bind:class="{ 'class-a': isA, 'class-b': isB }"></div> 

``` 


``` JavaScript
data: {   isA: true,   isB: false } 
```
可以被编译为：
```
<div class="static class-a"></div> 
```

**直接绑定数据里的一个对象： **
``` html
<div v-bind:class="classObject"></div> 
```
``` javascript
data: { 
  classObject: {  
   'class-a': true,   
   'class-b': false  
  }
}
```


### 数组语法 绑定 class
根据条件切换列表中的 class，可以用三元表达式： 
``` html
<div v-bind:class="[classA, isB ? classB : '']"> 

<div v-bind:class="[classA, { classB: isB, classC: isC }]"> 
```

## 对象语法 绑定 style 
v-bind:style对象语法十分直观，看着像 CSS的JavaScript 对象。 CSS 属性名可以用驼峰式或短横分隔命名： 
``` HTML
<div v-bind:style="{ color: activeColor, fontSize: fontSize + 'px' }"></div> 
 
data: {   activeColor: 'red',   fontSize: 30 } 
```

