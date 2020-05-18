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



#### 计算属性

> 计算属性，就是一旦发现data里面数值有变化，然后就会对之进行重新计算
>
> 如下代码： 一旦发现 msg发生变化，或里面触发函数重新计算reverseString 的值，并且将reverseString的值进行缓存

```vue
  <div id="app">
    <div>{{msg}}</div>
    <div>{{reverseString}}</div>
  </div>
  <script type="text/javascript" src="js/vue.js"></script>
  <script type="text/javascript">
    /*
      计算属性
    */
    var vm = new Vue({
      el: '#app',
      data: {
        msg: 'Nihao'
      },
      computed: {
        reverseString: function(){
          return this.msg.split('').reverse().join('');
        }
      }
    });
  </script>
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

#### scoped 的用处

scoped 修饰这个css，会让这个css只作用于这个 component内部

```css
<style lang="less" scoped>

</style>
```



#### ref 的作用

ref 是方便用于拿到 这个组件的实例

```html
 <el-form ref="loginFormRef" :model="loginForm" :rules="loginFormRules" label-width="0px" class="login_form">
 </el-form>
```

调用方法如下

```javascript
<script>
export default {
	......
  methods: {
    resetLoginForm() { //这是一个 @click方法
      this.$refs.loginFormRef.resetFields()
    },
		.....
  }
}
```



#### “ : ”  这个符号代表属性绑定

```html
<el-menu  unique-opened >
</el-menu>
```
或者 

> 注： 使用了 :后   里面的“ ” 内就可以使用表达式了，类似 :unique-opened="isNeedOpen"

```html
<el-menu  :unique-opened="true" >
</el-menu>
```



#### 控制台操作vue中的data

> vm.msg = "xxxx"





### VueX学习细节

#### State:   数据存储

#### mutation:    数据变更处理   

> 注意：只有mutation中定义的函数，才有权利修改state中的数据

#### Action:     异步数据的处理

#### Getter:  用于对Store的数据进行包装处理

> 1. getter用于对Store的数据进行包装处理，它不会影响store的原数据，类似Vue的计算属性
> 2. Store中的数据变化，Getter的数据也会随之变化，类似Vue的计算属性



两种使用store值的方式

```javascript
this.$store.state.count   // 获取 store中 count 的值
```

```javascript
this.$store.commit('addN',3)   //调用 mutation 里面的 addN方法，并且传递3这个函数
```

```javascript
this.$store.dispatch('addAsync')  //调用 Action 中的addAsync方法
```

