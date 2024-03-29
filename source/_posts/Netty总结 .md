---

title: Netty学习
date: 2018-1-2 20:09:04
tags: [Netty]

---
## Netty 学习

## IO模型

#### BIO （block IO   同步并阻塞）

- BIO缺点

  - 这种服务端的模型为一个连接一个线程， 对客户端而言没有压力，但是对服务端压力比较大
  - 缺点
    - 如果这个连接不做任何事情，会浪费资源
    - 如果读取没有返回 会阻塞

     

  

![image.png](https://i.loli.net/2020/01/21/bLFolXSvmVNKHQt.png)



#### NIO 同步非阻塞（Reactor  响应器）

- 同步非阻塞，服务器实现模式为一个线程处理多个请求(连接)，即客户端发送的连接请求都会注册到多路复用器上，多路复用器轮询到连接有I/O请求就进行处理 

服务器一个线程，处理多个请求连接，客户端的连接请求都会发送到多路复用器selector上，使用 （select  pull  epull）进行处理

![image.png](https://i.loli.net/2020/01/21/fPxcCn15bm4iQvo.png)

详细的如下

<img src="https://i.loli.net/2020/01/21/q9DSgVLWf7Zax5U.png"/>



#### AIO(NIO.2) 异步非阻塞   （proactor  前置器）

异步非阻塞，AIO 引入异步通道的概念，采用了 Proactor 模式，简化了程序编写，有效的请求才启动线程，它的特点是先由操作系统完成后才通知服务端程序启动线程去处理，一般适用于连接数较多且连接时间较长的应用









## NIO 详解

#### NIO 核心三个组件

- Channel(通道)
- Buffer(缓冲区)
- Selector(选择器) 

如上图所示：

NIO是面向buffer编程的   （也有的叫面向块编程）

数据读取到一个它稍后处理的缓冲区，需要时可在缓冲区中前后移动


#### NIO 的 Selector 、 Channel 和 Buffer 的关系

<img src="https://i.loli.net/2020/01/27/ZzB5MqXa6InNtTL.png" style="zoom:50%;" /> 

1. 一个channel 对应一个buffer
2. Selector 对应一个线程， 一个selector对应多个 channel(连接)
3. 上图有3个 channel注册到了 selector上
4. selector切换到**哪个channel， 是由Event(事件)决定的**
5. Buffer 就是一个内存块， 底层是有一个数组
6. Buffer是双向的，NIO中数据的读取写入是通过Buffer。  BIO中要么是inputstream，要么是outputstream, 不能双向。但是 NIO 的 Buffer 是可以读也可以写, 需要 flip 方法切换 
7. channel 也是双向的, 可以返回底层操作系统的情况, 比如 Linux ， 底层的操作系统通道就是双向的.。
8. channel能提供从网络或则文件读取数据的渠道，但是读写数据必须通过buffer





#### NIO 的 buffer

在 NIO 中，Buffer 是一个顶层父类，它是一个抽象类

常用Buffer子类一览

-  ByteBuffer，存储字节数据到缓冲区  （**ByteBuffer 使用的最多**）
- ShortBuffer，存储字符串数据到缓冲区
- CharBuffer，存储字符数据到缓冲区
- IntBuffer，存储整数数据到缓冲区
- LongBuffer，存储长整型数据到缓冲区
- DoubleBuffer，存储小数到缓冲区
- FloatBuffer，存储小数到缓冲区 

使用方式

```java
    public static void main(String[] args) {

        //举例说明Buffer 的使用 (简单说明)
        //创建一个Buffer, 大小为 5, 即可以存放5个int
        IntBuffer intBuffer = IntBuffer.allocate(5);

        intBuffer.put(1);
        intBuffer.put(2);
        intBuffer.put(3);
        intBuffer.put(4);
        intBuffer.put(5);
				
      	// 这个flip方法很重要
        intBuffer.flip();
        while (intBuffer.hasRemaining()) {
            int i = intBuffer.get();
            System.out.println(i);

        }
    }
```

buffer 用4个变量来操作数据
```
    private int mark = -1;
    private int position = 0;
    private int limit;
    private int capacity;

```
| **属性** | **描述**                                                     |
| -------- | ------------------------------------------------------------ |
| Capacity | 容量，即可以容纳的最大数据量；在缓冲区创建时被设定并且不能改变 |
| Limit    | 表示缓冲区的当前终点，不能对缓冲区超过极限的位置进行读写操作。且极限是可以修改的 |
| Position | 位置，下一个要被读或写的元素的索引，每次读写缓冲区数据时都会改变改值，为下次读写作准备 |
| Mark     | 标记                                                         |





#### NIO中的通道 Channel

NIO中,  Channel 主要有以下的几种

- FileChannel 用于文件的数据读写

- DatagramChannel 用于 UDP 的数据读写
- ServerSocketChannel   这是服务端的channel   （类似BIO中的 ServerSocket）
- SocketChannel  这是客户端的channel  （类似BIO的 Socket）



如下图：

 程序建立连接的流程为

1. 首先一个客户端连接过来，先连接到 Server 的 ServerSocketChannel
2. 这个ServerSocketChannel 会给他创建一个相应的 SocketChannel

<img src="https://i.loli.net/2020/01/21/q9DSgVLWf7Zax5U.png"/>







Selector 开发

![image-20201012143439322](http://guxiangflyimagebucket.oss-cn-beijing.aliyuncs.com/img/image-20201012143439322.png)

```
1.当客户端连接时，会通过ServerSocketChannel 得到 SocketChannel
2.Selector 进行监听  select 方法, 返回有事件发生的通道的个数.
3.将socketChannel注册到Selector上, register(Selector sel, int ops), 一个selector上可以注册多个SocketChannel
4.注册后返回一个 SelectionKey, 会和该Selector 关联(集合)
5.进一步得到各个 SelectionKey (有事件发生)
6.在通过 SelectionKey  反向获取 SocketChannel , 方法 channel()
7.可以通过  得到的 channel  , 完成业务处理
代码撑腰
```









## Reactor 模型理解

考虑一个问题：

> 当有10000个client要连接一个server，并且同时client也会不定时的发请求给server端，server端收到请求后需要及时进行返回，那么我们应该怎么做？

- 方案1

  - 使用一个线程来监听，每一个新的client发起连接的时候，建立并且new一个线程来处理新的连接，处理完成后返回。
  - **缺点**：当client数量非常多的时候，服务端线程过多，server端可能会产生性能问题。

- 方案2

  - 当一个新的client发起连接的时候，建立连接并且使用线程池来处理该连接。
  - **缺点**：1. 服务端处理能力受限于线程池中的线程数，client太多，线程池无法提供足够线程。
    			2. 当client连接较少的时候，也有资源的浪费

- 方案3

  - 通过多路复用技术，我那么将 client和客户端的连接，存放在一个queue或者数组中，

  ![image-20201210015748570](http://guxiangflyimagebucket.oss-cn-beijing.aliyuncs.com/img/image-20201210015748570.png)





#### 传统阻塞I/O服务模型

- 工作原理图

  > 黄色的框表示对象， 蓝色的框表示线程
  > 白色的框表示方法(API)

- 模型特点

  > 采用阻塞IO模式获取输入的数据
  > 每个连接都需要独立的线程完成数据的输入，业务处理,数据返回

- 问题分析

  > 当并发数很大，就会创建大量的线程，占用很大系统资源
  > 连接创建后，如果当前线程暂时没有数据可读，该线程会阻塞在read 操作，造成线程资源浪费

<img src="http://guxiangflyimagebucket.oss-cn-beijing.aliyuncs.com/img/image-20201210011920654.png" alt="image-20201210011920654" style="zoom:67%;" />

#### Reactor 模式

##### I/O 复用结合线程池，就是 Reactor 模式基本设计思想

- Reactor模式明显的特点，就是将请求当成一个event事件，这个事件发给一个 事件分派器，事件分派器监听到事件后通过这个分派器分发给某个线程（或进程，进行处理）



<img src="http://guxiangflyimagebucket.oss-cn-beijing.aliyuncs.com/img/image-20201210012206343.png" alt="image-20201210012206343" style="zoom: 50%;" />









# TCP粘包和拆包



