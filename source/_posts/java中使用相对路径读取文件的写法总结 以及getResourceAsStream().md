---
title: java中使用相对路径读取文件的写法总结 以及getResourceAsStream()
date: 2017-5-11 11:31:12
tags: [java,javaweb]
---
##  读取文件的写法，相对路径

**在当前的目录结构中读取test.txt的有四种写法**

 -  简单粗暴的  File file = new File("src/test.txt")
 - 使用类的相对路径
 - 使用当前线程的类加载器
 - 读取web工程下的文件 使用getRealPath()读取

----------


![这里写图片描述](http://img.blog.csdn.net/20170705133500787?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvbXlfX1N1bl8=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)


----------

``` java
 File file = new File("src/test.txt");
 File file = new File(TestRelativePath.class.getResource("/test.txt").getFile());
  File file = new File(Thread.currentThread().getContextClassLoader().getResource("test.txt").getFile());
   File file = new File(getServletContext().getRealPath("/WEB-INF/classes/test.txt"));
```

**下面我来一一介绍：**

### 简单粗暴的  File file = new File("src/test.txt");

``` java
  @Test
    /**
     * 这种方法 “” 空代表的是 这个Java项目 TestSomeTechnology  由于实际项目在打包后没有src目录 所以这种方法不常用
     */
    public  void  testMethod1() throws IOException{
        File file = new File("src/test.txt");
        BufferedReader br = new BufferedReader(new FileReader(file));
        String len = null;
        while ((len=br.readLine())!=null){
            System.out.println(len);
        }
    }
```


----------
### 使用类的相对路径
TestRelativePath.class.getResource("/test.txt").getFile()

``` java
 @Test
    /**
     * 使用类的相对路径
     * 这种方法 “/” 代表的是bin  src文件夹和resources 文件夹下的的东西都会被加载到bin下面 因为这两个文件被配置为了source
     */
    public  void  testMethod2() throws IOException{

        File file = new File(TestRelativePath.class.getResource("/test.txt").getFile());
        BufferedReader br = new BufferedReader(new FileReader(file));
        String len = null;
        while ((len=br.readLine())!=null){
            System.out.println(len);
        }
    }
```


----------
### 使用当前线程的类加载器
Thread.currentThread().getContextClassLoader().getResource("test.txt").getFile()

``` java
 @Test
    /**
     * 这种是通过当前线程的类加载器
     * 这种方法 “ ” 空代表的是bin  于是就直接填写test 文件夹下的的东西都会被加载到bin下面 因为这两个文件被配置为了source
     */
    public  void  testMethod3() throws IOException{

        File file = new File(Thread.currentThread().getContextClassLoader().getResource("test.txt").getFile());
        BufferedReader br = new BufferedReader(new FileReader(file));
        String len = null;
        if ((len=br.readLine())!=null){
            System.out.println(len);
        }
    }
```

### 读取web工程下的文件 使用getRealPath()读取
目录如下
![这里写图片描述](http://img.blog.csdn.net/20170705155324205?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvbXlfX1N1bl8=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)

--------
**读取 index.jsp**

``` java
@WebServlet(name = "TestServlet",urlPatterns = "/TestServlet")
public class TestServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
doGet(request,response);
    }

    /**
     *  web工程的根目录是 webRoot 使用 “/” 代表webroot webroot下面有index.jsp文件
     */
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        File file = new File(getServletContext().getRealPath("/index.jsp"));
        BufferedReader br = new BufferedReader(new FileReader(file));
        String len = null;
        while ((len=br.readLine())!=null){
            System.out.println(len);
        }
    }
}
```
**读取 test.txt文件**
不过如果想读取test.txt 的话  我们可用用上面的方式

``` java
 File file = new File(Thread.currentThread().getContextClassLoader().getResource("test.txt").getFile());
```

也可以使用 getRealPath()
不过由于是以 webroot为根目录 我们需要从classes里面读
``` java
 File file = new File(getServletContext().getRealPath("/WEB-INF/classes/test.txt"));
```

----------


## getResourceAsStream()方法详解
getResourceAsStream()用法与getResouce()方法一样的，用getResource()取得File文件后，再new FileInputStream(file)  与 getResourceAsStream() 的效果一样。。


----------


给出示例
**两个代码效果一样**
``` java
        InputStream inputStream1 = new FileInputStream(new File(Thread.currentThread().getContextClassLoader().getResource("test.txt").getFile()));
//=============================
        InputStream inputStream2 = Thread.currentThread().getContextClassLoader().getResourceAsStream("test.txt");
```