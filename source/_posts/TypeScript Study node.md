---
title: TypeScript study 
date: 2017-8-27 20:09:04
tags: [前端]

---

### typeScript中的数据类型

typescript中为了使编写的代码更规范，更有利于维护，增加了类型校验，在typescript中主要给我们提供了以下数据类型


        布尔类型（boolean）
        数字类型（number）
        字符串类型(string)
        数组类型（array）
        元组类型（tuple）
        枚举类型（enum）
        
        任意类型（any）
        null 和 undefined
        void类型
        never类型


### typeScript中的函数
    1、函数的定义
    2、可选参数
    3、默认参数
    4、剩余参数
    5、函数重载
    6、箭头函数  es6
   
####  函数的定义
```typescript
    var func = function():number{
        return 123;
    } 
    
    func()  //调用
    
    
    //  形参类型                             返回值类型
    function getInfo(name:string ,age:number):string{
        return `${name} ====${age}`
    }
    
    
    
    //  形参类型               可选参数              返回值类型
    function getInfo(name:string ,age?:number):string{
        return `${name} ====${age}`
    }
    //  形参类型               默认参数              返回值类型
    function getInfo(name:string ,age:number=20):string{
        return `${name} ====${age}`
    }
    
    //  形参类型               剩余参数              返回值类型
    function getInfo(...result:number[]):number{
       let sum:number = 0;
       for(let i = 0; i < result.length; i++) {
         sum+=result[i];
       }
       return sum;
    }
    
    
```


### es5中的class
```javascript
    function Person() {
      this.name = "xianggu";
      this.age = 20;
      function run(){
          console.log("我在跑")
      }
    }
    
    //静态方法不需要通过new 来调用
    Person.getInfo= function(){
        console.log("我是静态方法")
    }
    
    
    
    //原型方法 需要通过new 来调用
    Person.prototype.work = function() {
      console.log("我是原型方法")
    }
    var p = new Person();
    p.work();
    
    
    // es5 中的继承
    
    //对象冒充继承法  : 只能继承构造函数 不能继承原型链上的方法
    function Web(name,age) {
      Person.call(this,name,age)
    }
    
    // 原型链继承法   ：实例化子类的时候 没法给父类传递参数
    Web.prototype = new Person();
    
    var w = new Web('赵四',20);  // 是
    w.work();
    
    
    //原型链+对象冒充
    function Web(name,age) {
          Person.call(this,name,age)
    }
    Web.prototype = new Person();
    var w = new Web('赵四',20);
 
```

###  TypeScript 中的 Class

```typescript
    class Person{
        name : string;
        constructor(n:string){
            this.name=n;
        }
        run():void{
            alert(this.name);
        }
        
        static print():void{
            alert("print 方法")
        }
    }
    
    // TS 中的继承  extend 但是必须有 super  必须写他的构造函数
    
    class Web  extends Person{
      constructor(name:string){
          super(name);  //初始化父类的构造方法
      }
    }
    
    var w = new Web('李四');
    alert(w.run())
    
    
```

### TypeScript 中的接口
```typescript

interface FullName {
  firstName:string;
  secondName?:string;
}

function getName(name:FullName){
    console.log(name)
}

//调用
getName({
    firstName:'GU'
})


```

### Typescript 函数类型接口
```typescript

interface encrypt{
  (key:string,value:string):string
}

var md5:encrypt = function (key, value) {
    //模拟操作
    return key + value;
};
console.log(md5('name', 'zhangsan'));
var sha1:encrypt = function (key, value) {
    //模拟操作
    return key + '----' + value;
};
console.log(sha1('name', 'lisi'));

```

### Typescript  可索引接口
```typescript
interface UserArr{
  [index:number]:string
}

var  arr:UserArr=['123','1231']


```

### Typescript 类类型接口

```typescript
    interface Animal{
      name:string;
      eat(str:string):void;
    }
    
    class Cat implements Animal{
    name:string;
    constructor(name:string) {
        this.name= name;
    }
    
    eat(food:string){
        console.log(this.name + food);
    }
    
    }
```

### TypeScript 中的泛型
```typescript
    function getData<T>(value:T):T {
        return value;      
    }
    
    getData<number>(123);
```