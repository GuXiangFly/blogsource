---
title: Angular 笔记
date: 2018-3-11 23:09:04
tags: [Angular,前端]

---
#### 什么是双向数据绑定

``` html
 <input  [(ngModel)]="username">
 {{username}}
```
意思就是 初始时 username 的值赋给 文本输入框
文本输入框 如果有改变，那么就会将 文本输入框 的值赋给 username

注意需要在 app.module.ts 里面import
并且需要在 imports 数组里添加 FormsModule
``` javascript
import { FormsModule } from '@angular/forms'


@NgModule({
  declarations: [
    AppComponent,
    HeaderComponent,     FooterComponent,
    NewsComponent
  ],
  imports: [
    BrowserModule,     FormsModule
  ],
  providers: [],
  bootstrap: [AppComponent]
})
export class AppModule { }


<input type="text" [(ngModel)]='username'>

<button (click)='addData()'>增加</button>
```