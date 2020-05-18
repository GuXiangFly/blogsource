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



#### NIO 同步非阻塞

- 同步非阻塞，服务器实现模式为一个线程处理多个请求(连接)，即客户端发送的连接请求都会注册到多路复用器上，多路复用器轮询到连接有I/O请求就进行处理 

服务器一个线程，处理多个请求连接，客户端的连接请求都会发送到多路复用器selector上，使用 （select  pull  epull）进行处理

![image.png](https://i.loli.net/2020/01/21/fPxcCn15bm4iQvo.png)

详细的如下

<img src="https://i.loli.net/2020/01/21/q9DSgVLWf7Zax5U.png"/>



#### AIO(NIO.2) 异步非阻塞

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
4. 程序切换到哪个channel， 是由Event(事件)决定的
5. Buffer 就是一个内存块 ， 底层是有一个数组
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

