---
title: Vue的组件与模板
date: 2017-7-27 20:09:04
tags: [vue,前端]

---


# 第一种方式
vue组件:
	组件: 一个大对象
定义一个组件:
## 全局组件

``` javascript
     var vaa =Vue.extend({
        template:'<h3>我是aaa</h3>'
     });
    Vue.component('aaa',vaa);


    var vm = new Vue({
        el:'#box'
    });

	*组件里面放数据:
		data必须是函数的形式，函数必须返回一个对象(json)
```

``` javascript
<script>
		var Aaa=Vue.extend({
			data(){
				return {
					msg:'我是标题^^'
				};
			},
			template:'<h3>{{msg}}</h3>'
		});

		Vue.component('aaa',Aaa);


		var vm=new Vue({
			el:'#box',
			data:{
				bSign:true
			}
		});

	</script>
```

## 局部组件

放到某个组件内部

其实就是将 
  Vue.component('aaa',vaa);
这个步骤
 替换为在vue对象中的
``` javascript
 components:{ 
		aaa:Aaa
 }
```

``` javascript

 var vaa =Vue.extend({
     template:'<h3>我是aaa</h3>'
 });

var vm=new Vue({
	el:'#box',
	data:{
		bSign:true
	},
	components:{ //局部组件
		aaa:Aaa
	}
});
```

# 第二种方式

## 全局的方式
``` html
<div id="box">
		<my-aaa></my-aaa>
	</div>

	<script>
		Vue.component('my-aaa',{
			template:'<strong>好</strong>'
		});

		var vm=new Vue({
			el:'#box'
		});

	</script>
```

### 分析
``` JavaScript
	Vue.component('my-aaa',{
			template:'<strong>好</strong>'
		}); 

与  上下两种功能一样

   var vaa =Vue.extend({
        template:'<h3>我是aaa</h3>'
     });
    Vue.component('aaa',vaa);

```

## 局部的方式

## 较为常用
``` javascript
	Vue.component('my-aaa',{
		template:'<strong>好</strong>'
	});

	var vm=new Vue({
		el:'#box',

//关键---
		components:{
			'my-aaa':{
				template:'<h2>标题2</h2>'
			}
		}
	});
// ----
```

``` javaScript
<div id="box">
		<my-aaa></my-aaa>
	</div>

	<script>
		var vm=new Vue({
			el:'#box',
			components:{
				'my-aaa':{
					data(){
						return {
							msg:'welcome vue'
						}
					},
					methods:{
						change(){
							this.msg='changed';
						}
					},
					template:'<h2 @click="change">标题2->{{msg}}</h2>'
				}
			}
		});

	</script>
```

# vue中配合模板的写法（推荐的模板写法）

``` javaScript
<body>
	<div id="box">
		<my-aaa></my-aaa>
	</div>

	<template id="aaa">
		<h1>标题1</h1>
		<ul>
			<li v-for="val in arr">
				{{val}}
			</li>
		</ul>
	</template>

	<script>
		var vm=new Vue({
			el:'#box',
			components:{
				'my-aaa':{
					data(){
						return {
							msg:'welcome vue',
							arr:['apple','banana','orange']
						}
					},
					methods:{
						change(){
							this.msg='changed';
						}
					},
					template:'#aaa'
				}
			}
		});

	</script>
</body>

```


# 动态组件