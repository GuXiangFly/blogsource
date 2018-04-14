---
title: RESTful API的拦截三种方式比较
date: 2017-6-23 20:09:04
tags: [Spring]

---

RESTful API的拦截三种方式比较

## 过滤器（Filter）
过滤器可以拿到原始的 request 和 response 但是无法知道具体是哪个controller方法执行了

## 拦截器（interceptor）
拦截器既可以拿到原始的request 和 response ，又可以知道具体的是哪个方法的信息，但是无法知道 具体调用的方法 传入的参数的值

## 切片（Aspect）
能拿到具体调用的方法 传入的参数的值，但是无法拿到 原始的 request 和 response信息


## 下面是三种的执行顺序

![image.png](http://upload-images.jianshu.io/upload_images/6406935-30f131e56c3f7a8b.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
