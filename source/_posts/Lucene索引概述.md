---
title: Lucene索引概述
date: 2017-5-1 13:22:54
tags: [Lucene,java]
---
Lucene索引概述
======

lucene
------------

Lucene是apache旗下的顶级项目,是一个全文检索工具包

Lucene就是一个可以创建全文检索引擎系统的一堆jar包.可以使用它来构建全文检索引擎系统,但是它不能独立运，内部使用了倒排索引算法
###  全文检索算法(倒排索引算法):

将文件中的内容提取出来, 将文字拆封成一个一个的词(分词),
将这些词组成索引(字典中的目录),
搜索的时候先搜索索引,通过索引找文档,这个过程就叫做全文检索.

 **分词**: 去掉停用词(a, an, the ,的, 地, 得, 啊, 嗯
,呵呵),因为搜索的时候搜索这些词没有意义,将句子拆分成词,去掉标点符号和空格

 **优点**: 搜索速度快

**缺点:**
因为创建的索引需要占用磁盘空间,所以这个算法会使用掉更多的磁盘空间,这是用空间换时间。


原理:
-----

相当于字典,分为目录和正文两部分,查询的时候通过先查目录,然后通过目录上标注的页数去正文页查找需要的内容

Lucene结构
==========
**比方说我需要为这些文件建立索引**

----------

![这里写图片描述](http://img.blog.csdn.net/20170611151918560?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvbXlfX1N1bl8=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)


----------
**那么可以建立如下的索引存储结构**
![这里写图片描述](http://img.blog.csdn.net/20170611155127526?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvbXlfX1N1bl8=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)

索引（index）:
-----

域名:词 这样的形式,

它里面有指针执行这个词来源的文档

索引库: 放索引的文件夹(这个文件夹可以自己随意创建,在里面放索引就是索引库)

Term词元: 就是一个词, 是lucene中词的最小单位

文档（Document）:
-----

Document对象,一个Document中可以有多个Field域对象,Field域对象中是key
value键值对的形式:有域名和域值,

一个document就是数据库表中的一条记录, 一个Filed域对象就是数据库表中的一行一列

这是一个通用的存储结构.

创建索引和所有时所用的分词器必须一致

域（Field）
------

是否分词:

分词的作用是为了索引

需要分词: 文件名称, 文件内容

不需要分词: 不需要索引的域不需要分词,还有就是分词后无意义的域不需要分词

比如: id, 身份证号

是否索引:

索引的的目的是为了搜索.

需要搜索的域就一定要创建索引,只有创建了索引才能被搜索出来

不需要搜索的域可以不创建索引

需要索引: 文件名称, 文件内容, id, 身份证号等

不需要索引: 比如图片地址不需要创建索引, e:\\\\xxx.jpg

因为根据图片地址搜索无意义

是否存储:

存储的目的是为了显示.

是否存储看个人需要,存储就是将内容放入Document文档对象中保存出来,会额外占用磁盘空间,
如果搜索的时候需要马上显示出来可以放入document中也就是要存储,这样查询显示速度快,
如果不是马上立刻需要显示出来,则不需要存储,因为额外占用磁盘空间不划算.

域的各种类型
------------

| Field类                                                                    | 数据类型               | Analyzed 是否分析 | Indexed 是否索引 | Stored 是否存储 | 说明                                                                                                                                      |
|----------------------------------------------------------------------------|------------------------|-------------------|------------------|-----------------|-------------------------------------------------------------------------------------------------------------------------------------------|
| StringField(FieldName, FieldValue,Store.YES))                              | 字符串                 | N                 | Y                | Y或N            | 这个Field用来构建一个字符串Field，但是不会进行分析，会将整个串存储在索引中，比如(订单号,姓名等) 是否存储在文档中用Store.YES或Store.NO决定 |
| LongField(FieldName, FieldValue,Store.YES)                                 | Long型                 | Y                 | Y                | Y或N            | 这个Field用来构建一个Long数字型Field，进行分析和索引，比如(价格) 是否存储在文档中用Store.YES或Store.NO决定                                |
| StoredField(FieldName, FieldValue)                                         | 重载方法，支持多种类型 | N                 | N                | Y               | 这个Field用来构建不同类型Field 不分析，不索引，但要Field存储在文档中                                                                      |
| TextField(FieldName, FieldValue, Store.NO) 或 TextField(FieldName, reader) | 字符串 或 流           | Y                 | Y                | Y或N            | 如果是一个Reader, lucene猜测内容比较多,会采用Unstored的策略.                                                                              |


## 给出示例代码 ##
首先需要引入以下包：
![这里写图片描述](http://img.blog.csdn.net/20170611160522311?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvbXlfX1N1bl8=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)
----------

```java

package com.guxiang.lucence;

import org.apache.commons.io.FileUtils;
import org.apache.lucene.analysis.Analyzer;
import org.apache.lucene.analysis.standard.StandardAnalyzer;
import org.apache.lucene.document.Document;
import org.apache.lucene.document.Field;
import org.apache.lucene.document.LongField;
import org.apache.lucene.document.TextField;
import org.apache.lucene.index.IndexWriter;
import org.apache.lucene.index.IndexWriterConfig;
import org.apache.lucene.index.Term;
import org.apache.lucene.store.Directory;
import org.apache.lucene.store.FSDirectory;
import org.apache.lucene.util.Version;
import org.testng.annotations.Test;
import org.wltea.analyzer.lucene.IKAnalyzer;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;

/**
 * IndexManagerTest
 *
 * @author guxiang
 * @date 2017/6/8
 */
public class IndexManagerTest {
    @Test
    public void testIndexCreate() throws IOException {
        //采集文件中的文档数据 放入lucene中
        ArrayList<Document> docList = new ArrayList<>();

        //指定文件夹
        File dir = new File("D:\\serversoftware\\JarAndSourceFile\\searchsource");
        //循环取出文件
        for (File file : dir.listFiles()) {
            //文件名称
            String fileName = file.getName();
            //文件内容
            String fileContext = FileUtils.readFileToString(file);
            //文件大小
            Long fileSize = FileUtils.sizeOf(file);

            Document document = new Document();

            //第一个参数:域名
            //第二个参数:域值
            //第三个参数:是否存储,是为yes,不存储为no
            TextField nameFiled = new TextField("fileName", fileName, Field.Store.YES);
			TextField contextFiled = new TextField("fileContext", fileContext, Field.Store.YES);
			TextField sizeFiled = new TextField("fileSize", fileSize.toString(), Field.Store.YES);



            //将所有的域都存放进入文档
            document.add(nameFiled);
            document.add(contextFiled);
            document.add(sizeFiled);

            docList.add(document);
        }


        //创建分词器,StandardAnalyzer标准分词器,标准分词器对英文分词效果很好,对中文是单字分词
        Analyzer analyzer = new IKAnalyzer();

        //指定索引和文档存储的目录
        Directory directory = FSDirectory.open(new File("E:\\dic"));
        IndexWriterConfig indexWriterConfig = new IndexWriterConfig(Version.LUCENE_4_10_3, analyzer);

        //创建写对象的初始化对象
        IndexWriterConfig config = new IndexWriterConfig(Version.LUCENE_4_10_3, analyzer);
        //创建索引和文档写对象
        IndexWriter indexWriter = new IndexWriter(directory, config);

        //将文档加入到索引和文档的写对象中
        for(Document doc : docList){
            indexWriter.addDocument(doc);
        }
        //提交
        indexWriter.commit();
        //关闭流
        indexWriter.close();

    }
}

```