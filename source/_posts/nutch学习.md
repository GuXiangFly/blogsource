---
title: nutch 学习
date: 2019-9-5 23:00:04
tags: [大数据]

---
首先我们需要对 nutch-site.xml 的添加 agent
```xml
 <property>
  <name>http.agent.name</name>
  <value>blah</value>
 </property>
```

下面是nutch 的架构图
- crawl_generate：待抓取的URL
- crawl_fetch：每个URL的抓取状态
- content：从每个URL抓取到的原始内容
- parse_text：从每个URL解析得到的文本
- parse_data：从每个URL解析得到的外链和元数据
- crawl_parse：包含外链URL，用来更新crawldb
![](https://raw.githubusercontent.com/GuXiangFly/imagerepo/master/20190215101330.png)


###  通过readdb 来查看爬取状态
```
bin/nutch  readdb data/crawldb -stats

CrawlDb statistics start: data/crawldb
Statistics for CrawlDb: data/crawldb
TOTAL urls:	1101     ## 总共有 1101个url
retry 0:	1098
retry 1:	3
min score:	0.0
avg score:	0.0032343324
max score:	1.031
status 1 (db_unfetched):	1004
status 2 (db_fetched):	80
status 4 (db_redir_temp):	2     // 重定向的
status 5 (db_redir_perm):	15
CrawlDb statistics: done
```

###这个 segment 内部有很多文件夹
每完整执行一遍生命周期 就会有一个文件夹产生  就是每执行一次上图的 generate过程 就会有文件夹生成
```bash
[guxiang@hadoop101 segments]$ ls 
20190214063549  20190214063905  20190214174741  20190214174957  20190214190934
20190214063723  20190214174550  20190214174826  20190214185516
```

读取nutch  有三个脚本
```bash
[guxiang@hadoop101 local]$ bin/nutch |grep read
  readdb            read / dump crawl db
  readlinkdb        read / dump link db
  readseg           read / dump segment data
```

### nutch 读取segment中单独的内容
- 单独读取crawl_generate  =>  待抓取的URL
```
bin/nutch readseg -dump /user/dict/webtrans/tiger/nutch/data/segments/20190216212742 /user/dict/webtrans/tiger/nutch/data/segments/20190216212742/crawl_generate_dump -nocontent -nofetch -noparse -noparsedata  –noparsetext
```

- 单独读取 parsedata  => 从每个URL解析得到的外链和元数据
```
bin/nutch readseg -dump /user/dict/webtrans/tiger/nutch/data/segments/20190216212742 /user/dict/webtrans/tiger/nutch/data/segments/20190216212742/parsedata_dump  -nofetch  -nogenerate -nocontent -noparse  –noparsetext
```

- 单独获取 content  => 从每个URL抓取到的原始内容
```
bin/nutch readseg -dump /user/dict/webtrans/tiger/nutch/data/segments/20190216212742 /user/dict/webtrans/tiger/nutch/data/segments/20190216212742/content_dump  -nofetch  -nogenerate -noparse -noparsedata  –noparsetext
```

- 单独获取 crawl_parse   => 包含外链URL，用来更新crawldb
``` 
bin/nutch readseg -dump /user/dict/webtrans/tiger/nutch/data/segments/20190216212742 /user/dict/webtrans/tiger/nutch/data/segments/20190216212742/crawl_parse_dump  --nofetch  -nogenerate -nocontent –noparsedata  –noparsetext
```

- 单独获取 content  => 从每个URL抓取到的原始内容
### nutch 域统计 domainstats

以下是 usage
```bash
[dict@nc066 deploy]$ bin/nutch  domainstats 
Usage: DomainStatistics inputDirs outDir mode [numOfReducer]
	inputDirs	Comma separated list of crawldb input directories
			E.g.: crawl/crawldb/
	outDir		Output directory where results should be dumped
	mode		Set statistics gathering mode
				host	Gather statistics by host
				domain	Gather statistics by domain
				suffix	Gather statistics by suffix
				tld	Gather statistics by top level directory
	[numOfReducers]	Optional number of reduce jobs to use. Defaults to 1.
```

### 在nutch中的文件
nutch中 分有两种文件，一种为map文件，一种为序列文件。  
map文件： 含有两个文件 index  data   这种map文件只是增加了一个索引 方便读取数据
   多数nutch下的文件都是map文件

序列文件： 只有有个不可点开的 part-r-000000 类似的文件 该文件的
这种序列文件  比如是 crawl_generate 和 crawl_parse 的文件

```

```

### parsechecker 命令
通过执行
bin/nutch parsechecker  url
类似
```bash
bin/nutch parsechecker https://ejje.weblio.jp
## 上面的命令 用于查看 https://ejje.weblio.jp  中 解析出了哪些url

bin/nutch parsechecker  -dumpText https://ejje.weblio.jp
## 查看有哪些url的同时  查看出网页内含有的文本
```

### invertlinks
```bash
对crawlerdb 的另一个url 
```

### host等解释
host 是主机，是整体的可以被访问到主机的地址例如  user.qzone.qq.com
domain 是qzone.qq.com
### 


### 域统计命令
```bash
#                      输入目录             输出目录   选项
bin/nutch domainstats data/crawldb/current  host2      host

```

# 使用host2命令 
```bash
more host2/*

615	FETCHED    # 抓取成功的
5522	NOT_FETCHED   # 还没有抓取的
1	art.163.com
17	auto.163.com
1	baby.163.com
1	beihai.home.163.com
1	beihai.house.163.com

```

#  生成 webgraph
```bash
bin/nutch webgraph -segmentDir data/segments -webgraphdb data/webgraphdb
```
webgraph 会输出3个文件夹
inlinks  nodes  outlinks

inlinks  文件夹存储 有哪些网页指向这个 url
outlinks  文件夹存储  这个网页里包含哪些url
nodes   存储每个节点有多少的输入链接 有多少输出链接
```java
public class Node{
    private int numInlinks = 0;
    private int numOutlinks = 0;
    private float inlinkScore= 1.0f;
}
```


##  使用 nodedumper 查看 webgraph 输出的内容
```bash
bin/nutch nodedumper -topn 1 -inlinks -output inlinks_topn_1 -webgraphdb data/webgraphdb
bin/nutch nodedumper -topn 1 -inlinks -output inlinks_topn_1 -webgraphdb data/webgraphdb
```

```bash
bin/nutch 
```
## 百度

> x