---
title: vue学习笔记(二)
date: 2017-9-20 21:09:04
tags: [前端,vue]

---

vue-loader:
	其他loader ->  css-loader、url-loader、html-loader.....

	后台: nodeJs	->  require  exports
	broserify  模块加载，只能加载js
	webpack   模块加载器， 一切东西都是模块, 最后打包到一块了

	require('style.css');	->   css-loader、style-loader

	
	vue-loader基于webpack



### .vue文件:
		放置的是vue组件代码
``` html

		<template>
			html
		</template>
	
		<style>
			css
		</style>
	
		<script>
			js	（平时代码、ES6）	babel-loader
		</script>
```
-------------------------------------
## 简单的目录结构:

	|-index.html
	|-main.js	入口文件
	|-App.vue	vue文件，官方推荐命名法
	|-package.json	工程文件(项目依赖、名称、配置)
		npm init --yes 生成
	|-webpack.config.js	webpack配置文件

ES6: 模块化开发
	导出模块：
		export default {}
	引入模块:
		import 模块名 from 地址
--------------------------------------------
webpak准备工作:
	cnpm install webpack --save-dev               这个是不带服务器的
	cnpm install webpack-dev-server --save-dev    这个是带服务器的

	App.vue	-> 变成正常代码		vue-loader@8.5.4
	cnpm install vue-loader@8.5.4 --save-dev

	cnpm install vue-html-loader --save-dev
	

### 这几个包是让浏览器能识别 .vue 这种后缀的文件
----- 
	vue-html-loader、css-loader、vue-style-loader、
	vue-hot-reload-api@1.3.2
----

### 下面的模块作用就是使用 支持 ES6语法
	babel-loader
	babel-core
	babel-plugin-transform-runtime
	babel-preset-es2015
	babel-runtime

最最核心：

cnpm install vue@1.0.28 --save



--save-dev  这个参数是将 所下载的依赖 自动放到 package.json 文件 的 "devDependencies": { } 列表中

--save   如果仅仅是--save 不用 -dev 的话 就是将他放到package.json 里面的  "dependencies": { }列表中

	

	

如果 报出node 或者npm版本过低 那么就使用dos安装试试 ，不行就将本地的node_models 里面的东西删了重新下
