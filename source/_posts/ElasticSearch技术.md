---

title: ElasticSearch技术
date: 2017-10-27 20:09:04
tags: [ElasticSearch]

---
## ElasticSearch 特性
在实时搜索上优于 solr

ES有两个端口 一个是 Transport 的端口 9300
一个是  RESTful 形式的端口    9200 

```bash
Relational DB -> DataBases -> Tables ->Rows -> Columns
ElasticSearch -> Indices   -> Types  ->Documents -> Fields
```
ES 中的 Indices(指数 index)  对应为  关系型数据库中的  DataBases
Types  对应为  Tables
Documents  对应为  一行记录
Fields  对应   一个字段

## ES 如何使用
### 使用ES创建索引
```json

 //请求为：http://localhost:9200/people  这个可以创建一个名字为 people的 index  类似创建一个people的数据库
curl -put  http://localhost:9200/people 
{
	"setting":{
		"number_of_shards": "5",
		"number_of_replicas": "1"
	},

	"mappings": {   
		"man": {        //一张表（typos） 叫做 man
			"properties": {
				"name": {
					"type": "text",
					"store": true,           // 代表 需要存储
					"index": true,           //代表使用分词器
					"analyzer": "standard"   //使用标准分词器
				},
				"country": {
					"type": "keyword",
					"store": true, 
					 index: false   // 代表不使用分词器
				},
				"age": {
					"type": "integer"
				},
				"date":{
					"type": "date",
					"format": "yyyy-mm-dd HH:mm:ss||yyyy-MM-dd||epoch_millis"
				}
			}
		}
	}
}
```

### 删除索引库（对应数据库中的）
```bash
curl -delete http://localhost:9200/people/man/1
```

### 给typo中添加一条document (给表中insert一条记录)

```bash
curl -post http://localhost:9200/people/man/1
```
```json
{
  "name": "guxiang",
  "country": "国家",
  "age": "25",
  "date": "2019-04-01"
}
```

直接在整个json里面插入 需要这样写
```json
{
  "novel": {
    "properties": {
      "title": {
        "type": "text"
      }
    }
  }
}
```

### 全文查询
``` json
http://localhost:9200/people/_search
{
    "query": {
        "multi_match" : {
            "query" : "guide",
            "fields" : ["_all"]
        }
    }
}

也可以是
http://localhost:9200/people/_search?q=guide
上面是它的完整json包
```

### 固定字段查询
``` json
http://localhost:9200/people/_search
{
	"query": {
		"match": {
			"name": "guxiang"
		}
	}
}
```

### 语法查询

查询包含 guxiang  和  啊 这两个的
``` json
http://localhost:9200/people/_search
{
	"query": {
		"query_string": {
			"query":"guxiang AND 啊"
		}
	}
}
```

### 指定字段 分词查询
查询字段name 里面 有guxiang这个词的   guxiang2 是另一个单词 没有被查出
``` json
http://localhost:9200/people/_search
{
	"query": {
		"term": {
			"name":"guxiang"
		}
	}
}
```

### 比较大小 范围查询

``` json
http://localhost:9200/people/_search
{
	"query": {
		"range": {
			"age": {
				"gt":20,
				"lt":30
			}
		}
	}
}
```

### 比较日期大小查询
``` json
http://localhost:9200/people/_search
{
	"query": {
		"range": {
			"date": {
				"gt":"1997-01-01",
				"lt":"1997-05-01"
			}
		}
	}
}
```

### filter 查询
filter查询 没有匹配的等级  只返回是匹配的  不返回匹配的等级
``` json
http://localhost:9200/people/_search
{
	"query": {
		"bool": {
			"filter": {
				"term": {
					"age": 21
				}
			}
		}
	}
}
```

### 复合条件查询
``` json
http://localhost:9200/people/_search
{
	"query": {
		"bool": {
			"must": [
				{
					"match": {
						 "name": "guxiang"
					}
				},
				{
					"match": {
						 "date": "1997-03-03"
					}
				}
			],
			"filter": {
				"term": {
					"age": 21
				}
			}
		}
	}
}
```

##  如何查看分词器的分词效果
```bash
POST http://127.0.0.1:9200/_analyze
```
```json
{
  "analyzer":"standard",
  "text"    :"我是一个程序员"
}
```

## IK 分词器
IK 分词器有两种算法 ik_smart  和  ik_max_word
ik_smart 为最少切分
ik_max_word 为最细粒度切分


- ik_smart 拆分的结果
```json
{
    "tokens": [
        {
            "token": "我",
            "start_offset": 0,
            "end_offset": 1,
            "type": "CN_CHAR",
            "position": 0
        },
        {
            "token": "是",
            "start_offset": 1,
            "end_offset": 2,
            "type": "CN_CHAR",
            "position": 1
        },
        {
            "token": "一个",
            "start_offset": 2,
            "end_offset": 4,
            "type": "CN_WORD",
            "position": 2
        },
        {
            "token": "程序员",
            "start_offset": 4,
            "end_offset": 7,
            "type": "CN_WORD",
            "position": 3
        }
    ]
}
```

- ik_max_word 拆分的结果
``` json
{
    "tokens": [
        {
            "token": "我",
            "start_offset": 0,
            "end_offset": 1,
            "type": "CN_CHAR",
            "position": 0
        },
        {
            "token": "是",
            "start_offset": 1,
            "end_offset": 2,
            "type": "CN_CHAR",
            "position": 1
        },
        {
            "token": "一个",
            "start_offset": 2,
            "end_offset": 4,
            "type": "CN_WORD",
            "position": 2
        },
        {
            "token": "一",
            "start_offset": 2,
            "end_offset": 3,
            "type": "TYPE_CNUM",
            "position": 3
        },
        {
            "token": "个",
            "start_offset": 3,
            "end_offset": 4,
            "type": "COUNT",
            "position": 4
        },
        {
            "token": "程序员",
            "start_offset": 4,
            "end_offset": 7,
            "type": "CN_WORD",
            "position": 5
        },
        {
            "token": "程序",
            "start_offset": 4,
            "end_offset": 6,
            "type": "CN_WORD",
            "position": 6
        },
        {
            "token": "员",
            "start_offset": 6,
            "end_offset": 7,
            "type": "CN_CHAR",
            "position": 7
        }
    ]
}
```


## ES 中的查询

- 使用SpringData 中的查询 这种有不足之处
    主要在于，这个的缺点在于，他是将分词结果使用 and 来拼接 ，产生结果。
``` java
 articleRepository.findArticlesByContent("maven是一个工程构建工具");
```

- 使用原生的查询
    使用 elasticsearch client 的查询，分词结果是  ||  也就是 or 的关系
``` java
 NativeSearchQuery query = new NativeSearchQueryBuilder()
         .withQuery(QueryBuilders.queryStringQuery("maven是一个工程构建工具").defaultField("content"))
         .build();
 List<Article> articleList = template.queryForList(query, Article.class);
 articleList.forEach(System.out::println);
```





![image-20200628235211995](https://gitee.com/guxiangfly/blogimage/raw/master/img/image-20200628235211995.png)



小tips 一般   “_” 开头的，都是elasticsearch事先定义好的关键字

####  创建索引，以及查看索引的设置

```json
PUT /lib    ##创建索引lib，指定分片为3  副本为0
{
    "number_of_shards" : "3",  ## 
    "number_of_replicas" : "0"
}

PUT lib2  ##创建索引lib2

GET /lib2/_settings   ## 查看索引设置
-------
{
  "lib2" : {
    "settings" : {
      "index" : {
        "creation_date" : "1611041413908",
        "number_of_shards" : "5",
        "number_of_replicas" : "1",
        "uuid" : "X3aWwW34RB-jI014M6MK-A",
        "version" : {
          "created" : "6050499"
        },
        "provided_name" : "lib2"
      }
    }
  }
}
```

##### 



# 二次elasticsearch回顾



## 倒排索引

搜索引擎中：

- 正排索引：文档ID到文档内容和单词的关联
- 倒排索引：单词到文档id的关系

假设文档集中包含5个文档

<img src="https://gitee.com/guxiangfly/blogimage/raw/master/img/image-20210119180506932.png" alt="image-20210119180506932" style="zoom: 67%;" />



将这5个文档进行倒排索引后

<img src="https://gitee.com/guxiangfly/blogimage/raw/master/img/image-20210119190756683.png" alt="image-20210119190756683" style="zoom: 67%;" />

##### 其他能支持的功能

1. 倒排索引还能支持存储每个单词在某个文档中出现的频率

<img src="https://gitee.com/guxiangfly/blogimage/raw/master/img/image-20210119191010437.png" alt="image-20210119191010437" style="zoom:67%;" />

2. 倒排索引还可以记录单词在某个文档出现的位置信息

   (1,<11>,1), (2,<7>,1)  (3,<3,9>,2)

   - (1,<11>,1)代表单词在文档1中，出现1次，在11这个位置
   - (3,<3,9>,2)  代表单词在文档3中，出现2此，在3和9这个位置

#### ES中记录倒排索引的方式

如果我们**不建立标准化规则**，文档倒排索引后的结果如下

<img src="https://gitee.com/guxiangfly/blogimage/raw/master/img/image-20210119191529361.png" alt="image-20210119191529361" style="zoom:67%;" />



##### 使用标准化规则（normalization）：

建立倒排索引的时候，会对拆分出的各个单词进行相应的处理，以提升后面搜索的时候能搜索到相关联的文档的概率

- 不区分大小写
- 不区分单复数
- 意思相近的也能能直接进行索引

<img src="https://gitee.com/guxiangfly/blogimage/raw/master/img/image-20210119192244699.png" alt="image-20210119192244699" style="zoom:67%;" />





对上面**不使用标准化规则**的倒排索引进行搜索：  quick  brown

<img src="https://gitee.com/guxiangfly/blogimage/raw/master/img/image-20210119191600042.png" alt="image-20210119191600042" style="zoom:67%;" />

在搜索中有个相关度分数， doc_1 的搜索分数比 Doc_2 的分数高



<img src="https://gitee.com/guxiangfly/blogimage/raw/master/img/image-20210119203351419.png" alt="image-20210119203351419" style="zoom:67%;" />



### 分词器 

## 2.2 分词器

分词器:从一串文本中切分出一个一个的词条，并对每个词条进行标准化
包括三部分:

1. character filter：分词之前的预处理，过滤掉HTML标签，特殊符号转换等
2. tokenizer:分词
3. token filter:标准化（大小写转换，单复数转换，同义词转换）

内置分词器：

1. standard分词器：默认的，它会将词汇单元转换成小写形式，并去除停用词和标点符号，支持重温采用的方法为单字切分
2. simple分词器：首选会通过非字母字符来分隔文本信息，然后将词汇单元统一为小写形式，该分词器会去杜鳌数字类型的字符
3. whitespace分词器：仅仅是去除空格，对字符没有转换成小写形式，不支持中文，并且不对生成的词汇单元进行其他的标准化处理
4. language分词器：特定语言的分词器，不支持中文



#### 向索引中添加文档 （指定id使用PUT，不指定id使用POST）

```json
PUT  /lib/user/1
{
	"first_name":"jane26",
	"age":35,
	"interests":["forestry","history2"]
}

---------
POST  /lib/user/
{
	"first_name":"jane25",
	"age":35,
	"interests":["forestry","history"]
}
```

#### elasticsearch中的修改

##### 1.通过PUT整个文档覆盖的方式进行修改

```json
PUT  /lib/user/1
{
	"first_name":"jane27",
	"age":35,
	"interests":["forestry","history2"]
}
```

<img src="https://gitee.com/guxiangfly/blogimage/raw/master/img/image-20210119154423816.png" alt="image-20210119154423816" style="zoom:50%;" />

##### 2.通过POST 指定字段方式进行修改

```json
POST  /lib/user/1/_update
{
	"doc": {
	  "first_name":"jane28"
	}
}
```

<img src="https://gitee.com/guxiangfly/blogimage/raw/master/img/image-20210119154948562.png" alt="image-20210119154948562" style="zoom:50%;" />



#### 3.删除指定id的文档

```
DELETE  /lib/user/1
```



#### 4.查询指定id的文档

```json
GET  /lib/user/1
```





#### 5. mget 批量获取

```json
GET /_mget
{
  "docs":[
    {
      "_index":"lib",   ##索引名称
      "_type":"user",   ##索引type
      "_id":1,  ##文档id
      "_source":"interests" ##指定具体的字段
    },
    {
      "_index":"lib",
      "_type":"user",
      "_id":2,
      "_source":["interests","age"]  ##指定具体的字段
    }
    ]
}

----简写----
GET /lib/user/_mget
{
  "docs":[
    {
      "_id":1,
      "_source":"interests"
    },
    {
      "_id":2,
      "_source":["interests","age"]
    }
   ]
}


----更加简写---
GET /lib/user/_mget
{
  "ids":[1,2]
}
```



#### 6. 批量增删改 bulk

Bulk的格式

```json
{action:{metadata}}  
{requestbody}
```

action 有 

- create 文档不存在时创建，
- update 更新文档，
- index 创建新文档或替换已有文档，
- delete：删除一个文档（注意delete不需要有requestbody）
- create 和index 的区别是，create在已有相应文档的时候继续创建会报错

```json
POST _bulk
{ "index" : { "_index" : "test", "_type" : "_doc", "_id" : "1" } }  ##创建一个索引为index，type为_doc,id为1
{ "field1" : "value1" }   ## 内容为 field1：value1

{ "delete" : { "_index" : "test", "_type" : "_doc", "_id" : "2" } } 

{ "create" : { "_index" : "test", "_type" : "_doc", "_id" : "3" } }
{ "field1" : "value3" }

{ "update" : {"_id" : "1", "_type" : "_doc", "_index" : "test"} }
{ "doc" : {"field2" : "value2"} }
```



bulk会将处理的数据载入到内存中，所以是有数据量的限制的

一般建议是1000-5000个文档，建议大小5-15MB，默认数据量不超过100MB





### Elasticsearch的版本控制



#### 1. 内部版本控制

elasticsearch的版本控制是通过乐观锁实现的。

通过put覆盖更新后，文档会产生一个version，当前的version是3

<img src="https://gitee.com/guxiangfly/blogimage/raw/master/img/image-20210119170434763.png" alt="image-20210119170434763" style="zoom: 33%;" />



使用`PUT  /lib/user/3?version=2 `进行修改，version=2 与当前版本3不符合，不能修改。

改为`PUT  /lib/user/3?version=3` 就能修改成功

![image-20210119170559505](https://gitee.com/guxiangfly/blogimage/raw/master/img/image-20210119170559505.png)



#### 2. 外部版本控制

version_type=external 为指定外部版本控制，

version=内容就不是=当前文档版本了，  请求中version字段值需要大于 当前文档version的值，并且值会赋值给当前的文档

```json
PUT  /lib/user/3?version=3&version_type=external
{
	"first_name":"jane2",
	"age":35,
	"interests":["forestry","history23"]
}
```

![image-20210119171357818](https://gitee.com/guxiangfly/blogimage/raw/master/img/image-20210119171357818.png)

<img src="https://gitee.com/guxiangfly/blogimage/raw/master/img/image-20210119171629914.png" alt="image-20210119171629914" style="zoom: 33%;" />

使用外部版本控制，需要将



## Mapping信息

当我们为index索引，未创建mapping，添加第一个文档的时候，elasticsearch会自动创建一个mapping。下面我们看看默认赋值的mapping信息

```json
PUT /myindex/article/1
{
  "post_date":"2018-05-19",
  "title":"java",
  "content":"java is the best",
  "author_id":100
}
-----------
GET /myindex/article/_mapping
{
  "myindex" : {
    "mappings" : {
      "article" : {
        "properties" : {
          "author_id" : {
            "type" : "long"
          },
          "content" : {
            "type" : "text",
            "fields" : {
              "keyword" : {
                "type" : "keyword",
                "ignore_above" : 256
              }
            }
          },
          "post_date" : {
            "type" : "date"
          },
          "title" : {
            "type" : "text",
            "fields" : {
              "keyword" : {
                "type" : "keyword",
                "ignore_above" : 256
              }
            }
          }
        }
      }
    }
  }
}
```

##### 关于自动检测类型的推断

- true，false --- boolean
- 119  --- long
- 123.34  ---double
- 1990-11-11  --- date
- "sssddd"  ---  text



##### mapping 核心数据类型

- 字符型：
  - string类型包括  text 和 keyword
  - 区别：text会进行分词，keyword不会进行分词

## 2.7 mapping

es自动创建了index，type，以及type对应的mapping(dynamic mapping)
mapping定义了type中的每个字段的数据类型以及这些字段如何分词等相关属性

创建索引的时候，可以预先定义字段的类型及相关属性，这样就能够把日期字段处理成日期，把数字字段处理成数字，把字符串字段处理成字符串值等

支持的数据类型：

##### (1)核心数据类型(core datatype)

- 字符型:string,包括text和keyword
  text类型被用来索引长文本，在建立索引前会将这些文本进行分词，转化为词的组合，建立索引，允许es来检索这些词语。text类型不能用来排序和聚合。
  keyword类型不需要进行分词，可以被用来检索过滤，排序和聚合，keyword类型字段只能用本身来进行检索
- 数字型：long,integer,short,btype,dobule,float (默认没有分词)
- 日期型：date (默认没有分词)
- 布尔型：boolean
- 二进制型：binary

##### (2)复杂数据类型

- 数组类型：数组类型不需要专门制定数组元素的type,比如：
  字符型数组：["one","two"]
  整型数组：[1,2]
  数组型数组：[1,[2,3]],等价于[1,2,3]
  对象数组：[{"name":"Mary","age":12},{"name":"Tom","age":20}]
- 对象类型：`_object_`用于单个json对象
- 嵌套类型：`_nested_`用于json数组

##### (3)地理位置类型

- 地理坐标类型：`_geo_point_`用于经纬度坐标
- 地理形状类型：`_geo_shape_`用于类似于多边形的复杂形状

##### (4)特定类型

- IPv4类型：`_ip_`用于IPv4地址
- Completion:`_completion_`提供自动补全建议
- Token count类型：`_token_count_`用于统计做了标记的字段的index数目，该值会一致增加，不会因为过滤条件而减少
- mapper-murmur3类型：通过插件，可以通过`_murmur3_`来计算index的hash值
- 附加类型：采用mapper-attachments插件，可支持`_attachments_`索引，例如Microsoft Office格式，Open Document格式，ePub，HTML等

支持的属性：

- "store":false // 是否单独设置此字段的是否存储而从_source字段中分离，默认是false,只能搜索，不能获取值
- "index":true // 分词，不分词是false,设置成false字段将不会被索引
- "analyzer":"ik" // 指定分词器，默认分词器是standard analyzer
- "boost":1.23 // 字段级别的分数加权，默认是1.0
- "doc_values":false // 对not_analyzed字段，默认都是开启，分词字段不能使用，对哦排序和聚合能提升较大性能，节约内存
- "fielddata":{"format":"disabled"} // 针对分词字段，参与排序或聚合时能提高性能，不分词字段统一建议使用doc_value
- "fields":{"raw":{"type":"string","index":"not_analyzed"}} // 可以对一个字段提供多种索引模式，同一个字段的值，一个分词，一个不分词
- "ignore_above":100 // 超过100个字符的文本，将会被忽略，不被索引
- "include_in_all":true // 设置是否此参数字段包含在_all字段中，默认是true,除非index设置成no选项
- "index_options":"docs" // 4个可选参数docs(索引文档号)，freqs(文档号+词频),positions(文档号+词频+位置，通常用来距离查询),offsets(文档号+词频+位置+偏移量，通常被使用在高亮字段)，分词字段默认是positions,其他的默认是docs
- "norms":{"enable":true,"loading":lazy} // 分词字段默认配置，不分词字段：默认{"enable":false},存储长度因子和索引时boost,建议对需要参与评分字段使用，会额外增加内存消耗量
- "null_value":NULL // 设置一些缺失字段的初始化值，只有string可以使用，分词字段的null值也会被分词
- "position_increment_gap":0 // 影响距离查询或近似查询，可以设置在多值字段的数据上或分词字段上，查询时可以指定slop间隔，默认是100
- "search_analyzer":"ik" // 设置搜索时的分词器，默认跟analyzer是一致的，比如index时用standard+ngram，搜索时用standard来完成自动提示功能
- "similarity":"BM25" // 默认是TF/IDF算法，指定一个字段评分策略，仅仅对字符串型和分词类型有效
- "term_vector":"no" // 默认不存储向量信息，支持参数yes(tern存储),with_positions(term+位置),with_offsets(term+偏移量),with_positions_offsets(term+位置+偏移量),对快速高亮fast vector highlighter能提升性能，但开启又会加大索引体积，不适合大数据量用





#### Object数据类型及手动创建mapping

```json
# 添加一个文档
PUT /lib5/person/1
{
  "name":"tom",
  "age":30,
  "birthday":"1985-12-12",
  "address":{
    "country":"china",
    "province":"guangdong",
    "city":"shenzhen"
  }
}

# 查看该文档
GET /lib5/person/1

# 查看文档mapping
GET /lib5/_mapping
```

结果如下

```json
{
  "lib5" : {
    "mappings" : {
      "person" : {
        "properties" : {
          "address" : {
            "properties" : {
              "city" : {
                "type" : "text",
                "fields" : {
                  "keyword" : {
                    "type" : "keyword",
                    "ignore_above" : 256
                  }
                }
              },
              "country" : {
                "type" : "text",
                "fields" : {
                  "keyword" : {
                    "type" : "keyword",
                    "ignore_above" : 256
                  }
                }
              },
              "province" : {
                "type" : "text",
                "fields" : {
                  "keyword" : {
                    "type" : "keyword",
                    "ignore_above" : 256
                  }
                }
              }
            }
          },
          "age" : {
            "type" : "long"
          },
          "birthday" : {
            "type" : "date"
          },
          "name" : {
            "type" : "text",
            "fields" : {
              "keyword" : {
                "type" : "keyword",
                "ignore_above" : 256
              }
            }
          }
        }
      }
    }
  }
}
```



##### object类型 底层存储格式

```json
{
  "name":"tom",
  "age":30,
  "birthday":"1985-12-12",
  "address":{
    "country":"china",
    "province":"guangdong",
    "city":"shenzhen"
  }
}
----对应底层存储格式----
{
  "name":["tom"],
  "age":[30],
  "birthday":["1985-12-12"],
  "address.country":["china"],
  "address.province":["guangdong"],
  "address.city":["shenzhen"]
}
```

更复杂一些
```json
{
    "person":[
        {"name":"lisi","age":25},
        {"name":"waqngwu","age":26},
        {"name":"zhangsan","age":30}
    ]
}
# 底层存储格式
{
    "person.name":["lisi","waqngwu","zhangsan"],
    "person.age":[25,26,30]
}
```





##### object 和 nested 对象的区别(es7 下测试)

- 在我们的document中，如果包含了一个数据对象的时候， 使用查询会出错， 我们可以使用nested对象解决这种问题。

es7中  type  固定是 _doc

- object 数据

```json
# 电影的Mapping信息
PUT my_movies
{
      "mappings" : {
      "properties" : {
        "actors" : {
          "properties" : {
            "first_name" : {
              "type" : "keyword"
            },
            "last_name" : {
              "type" : "keyword"
            }
          }
        },
        "title" : {
          "type" : "text",
          "fields" : {
            "keyword" : {
              "type" : "keyword",
              "ignore_above" : 256
            }
          }
        }
      }
    }
}


# 写入一条电影信息   电影名字叫 speed，  电影有n个演员， 
# 一个是 Keanu Reeves  一个是 Dennis Hopper
POST my_movies/_doc/1
{
  "title":"Speed",
  "actors":[
    {
      "first_name":"Keanu",
      "last_name":"Reeves"
    },
    {
      "first_name":"Dennis",
      "last_name":"Hopper"
    }
  ]
}

# 对它进行相应的查询
POST my_movies/_search
{
  "query": {
    "bool": {
      "must": [
        {"match": {"actors.first_name": "Keanu"}},
        {"match": {"actors.last_name": "Hopper"}}
      ]
    }
  }
}
## 结果
结果能搜到相应的数据
```

对于上面的演员，**其实没有 keanu hopper这个人**，但是我们也搜索到了相应的document 

<img src="https://gitee.com/guxiangfly/blogimage/raw/master/img/image-20210128174228387.png" alt="image-20210128174228387" style="zoom:50%;" />

- 为什么我们会搜到不需要的结果？

  - 存储时，对文档内部的对象数组，是没有设置查询边界的，对于list的json格式被设置为 key:[“value1”,“value2”] 的结构
  - 当对内部对象为list的多个字段查询时会导致问题
  - 使用 Nested Data  Type 能解决这个问题
  - <img src="https://gitee.com/guxiangfly/blogimage/raw/master/img/image-20210128175549949.png" alt="image-20210128175549949" style="zoom:50%;" />

  

  ###### 如何使用 Nested 来解决对象存储问题

  ![image-20210128175738106](https://gitee.com/guxiangfly/blogimage/raw/master/img/image-20210128175738106.png)

- nested 数据类型是允许对象数组中的对象被单独索引的。不用放在一起变成数组
- 使用 properties 和  nested 关键字，将所有的 actors 索引到多个分隔的文档中

创建nested类型的 对象数组

```json
DELETE my_movies
## 创建 Nested 对象 Mapping
PUT my_movies
{
      "mappings" : {
      "properties" : {
        "actors" : {
          "type": "nested",
          "properties" : {
            "first_name" : {"type" : "keyword"},
            "last_name" : {"type" : "keyword"}
          }},
        "title" : {
          "type" : "text",
          "fields" : {"keyword":{"type":"keyword","ignore_above":256}}
        }
      }
    }
}

POST my_movies/_doc/1
{
  "title":"Speed",
  "actors":[
    {
      "first_name":"Keanu",
      "last_name":"Reeves"
    },

    {
      "first_name":"Dennis",
      "last_name":"Hopper"
    }
  ]
}
```









注意：ElasticSearch 7.x 默认不再支持指定索引类型,默认索引类型是_doc，如果想改变，则配置include_type_name: true 即可
(这个没有测试，官方文档说的，无论是否可行，建议不要这么做，因为elasticsearch8后就不在提供该字段)

如下手动创建mapping，在6.x可以顺利执行，但是在7.x则会报错：`Root mapping definition has unsupported parameters`

Elasticsearch6 手动创建mapping

```json
PUT /lib6
{
  "settings": {
    "number_of_shards": 3,
    "number_of_replicas": 0
  },
  "mappings": {
    "books":{
      "properties":{
        "title":{"type":"text"},
        "name":{"type":"text","analyzer":"standard"},
        "publish_date":{"type":"date","index":false}, ##默认es会对每个字段进行倒排索引， index:false，表示不要对这个字段进行倒排索引
        "price":{"type":"dobule"},
        "number":{"type":"integer"}
      }
    }
  }
}
```



###  基本查询(Query查询)

1. 数据准备

   ```json
   PUT /lib3/user/1
   {
     "name":"zhaoliu",
     "address":"hei long jiang sheng tie ling shi",
     "age":50,
     "birthday":"1970-12-12",
     "interests":"xi huan he jiu,duan lian,lvyou"
   }
   
   PUT /lib3/user/2
   {
     "name":"lisi",
     "address":"bei jing hai dian qu qing he zhen",
     "age":20,
     "birthday":"1998-12-12",
     "interests":"xi huan he jiu,duan lian,changge"
   }
   
   PUT /lib3/user/3
   {
     "name":"zhaoming",
     "address":"bei jing hai dian qu qing he zhen",
     "age":23,
     "birthday":"1970-12-12",
     "interests":"xi huan he jiu,duan lian,lvyou,youyong"
   }
   
   # _score:和当前搜索相关度的匹配分数
   ```

#### 简单查询
   ```json
   GET /lib3/_search?q=name:zhaoming ##查询name = zhaoming 
   GET /lib3/_search?q=interests:he jiu&sort=age:desc 查询interests含有he jiu，并且按age 倒序排列
   ```

```json
   GET /lib3/_search?q=name:zhaoming
   {
     "took" : 42,  ##查询使用了42毫秒
     "timed_out" : false,  ##是否超时，未超时
     "_shards" : {
       "total" : 5,   
       "successful" : 5,
       "skipped" : 0,
       "failed" : 0
     },
     "hits" : {
       "total" : 1,  ##查询出的文档个数
       "max_score" : 0.2876821,  ##最高的相关度分数
       "hits" : [
         {
           "_index" : "lib3",
           "_type" : "user",
           "_id" : "3",
           "_score" : 0.2876821,  ##相关度分数  如果未
           "_source" : {
             "name" : "zhaoming",
             "address" : "bei jing hai dian qu qing he zhen",
             "age" : 23,
             "birthday" : "1970-12-12",
             "interests" : "xi huan he jiu,duan lian,lvyou,youyong"
           }
         }
       ]
     }
   }
```





#### query_string查询
把查询的词句先分词，然后再查询

```json
GET /lib3/user/3/_search
{
    "query":{
        "query_string":{
            "default_field":"name",
            "query":"zhangsan"
        }
    }
}
```

#### term查询和terms查询

1. term query会去倒排索引中寻找确切的term,这种查询的使用的关键词是keyword，numeric，date

- term:查询某个字段里含有某个关键词的文档
- terms:查询某个字段里含有多个关键词的文档
- 一般来说 term查询的 sorce 都是1

```json
GET /lib3/user/_search
{
  "query": {
    "term": {
      "name":"zhaoliu"
    }
  }
}

GET /lib3/user/_search
{
  "query": {
    "terms": {
      "interests": [
        "hejiu",
        "changge"
      ]
    }
  }
}
```



term 和 terms 查询，不会对 zhaoliu ，hejiu这个词语进行分词

match  查询 会对 zhaoliu进行分词



#### match查询 （term和match的区别）

```json
GET /lib3/user/_search
{
  "query": {
    "match": {
      "name":"zhaoliu zhaoming"
    }
  }
}
有结果 ： match会吧 "zhaoliu zhaoming" 进行分词后再查询倒排数据


如果这个时候我们使用term查询
GET /lib3/user/_search
{
  "query": {
    "term": {
      "name":"zhaoliu zhaoming"
    }
  }
}
结果为空： 因为term把"zhaoliu zhaoming" 当成一个词， 并且在倒排索引中没有这个词
```





#### match_phrase 

```json
GET /lib3/user/_search
{
  "query": {
    "match_phrase": {
      "interests":"lvyou youyong"
    }
  }
}
```

将短语进行分词， 组成短语，然后来查询。

<img src="https://gitee.com/guxiangfly/blogimage/raw/master/img/image-20210119223256152.png" alt="image-20210119223256152" style="zoom:67%;" />

















查询使用

```json
PUT lib
{
          "number_of_shards" : "3",
        "number_of_replicas" : "0"
}

GET /lib/_settings


POST  /lib/user/
{
	"first_name":"jane25",
	"age":35,
	"interests":["forestry","history"]
}


PUT  /lib/user/3?version=5&version_type=external
{
	"first_name":"jane2",
	"age":35,
	"interests":["forestry","history23"]
}


POST  /lib/user/3/_update?version=4
{
	"doc": {
	  "first_name":"jane28"
	}
}

DELETE  /lib/user/1



GET /_mget
{
  "docs":[
    {
      "_index":"lib",
      "_type":"user",
      "_id":1,
      "_source":"interests"
    },
    {
      "_index":"lib",
      "_type":"user",
      "_id":2,
      "_source":["interests","age"]
    }
    ]
}



GET /lib/user/_mget
{
  "docs":[
    {
      "_id":1,
      "_source":"interests"
    },
    {
      "_id":2,
      "_source":["interests","age"]
    }
    ]
}

GET /lib/user/_mget
{
  "ids":[1,2]
}


POST _bulk
{ "index" : { "_index" : "test", "_type" : "_doc", "_id" : "1" } }
{ "field1" : "value1" }
{ "delete" : { "_index" : "test", "_type" : "_doc", "_id" : "2" } }
{ "create" : { "_index" : "test", "_type" : "_doc", "_id" : "3" } }
{ "field1" : "value3" }
{ "update" : {"_id" : "1", "_type" : "_doc", "_index" : "test"} }
{ "doc" : {"field2" : "value2"} }




PUT /myindex/article/1
{
  "post_date":"2018-05-19",
  "title":"java",
  "content":"java is the best",
  "author_id":100
}

PUT /myindex/article/2
{
  "post_date":"2018-05-29",
  "title":"java",
  "content":"java is the best111",
  "author_id":12
}

GET /myindex/article/_mapping


GET /myindex/article/_search?q=2018-05-19



# 添加一个文档
PUT /lib5/person/1
{
  "name":"tom",
  "age":30,
  "birthday":"1985-12-12",
  "address":{
    "country":"china",
    "province":"guangdong",
    "city":"shenzhen"
  }
}

# 查看该文档
GET /lib5/person/1

# 查看文档mapping
GET /lib5/_mapping



PUT /lib3/user/1
{
  "name":"zhaoliu",
  "address":"hei long jiang sheng tie ling shi",
  "age":50,
  "birthday":"1970-12-12",
  "interests":"xi huan he jiu,duan lian,lvyou"
}

PUT /lib3/user/2
{
  "name":"lisi",
  "address":"bei jing hai dian qu qing he zhen",
  "age":20,
  "birthday":"1998-12-12",
  "interests":"xi huan he jiu,duan lian,changge"
}

PUT /lib3/user/3
{
  "name":"zhaoming",
  "address":"bei jing hai dian qu qing he zhen",
  "age":23,
  "birthday":"1970-12-12",
  "interests":"xi huan he jiu,duan lian,lvyou,youyong"
}

GET /lib3/user/_search?q=name:zhaoming

GET /lib3/user/_search?q=interests:he jiu&sort=age:desc


GET /lib3/user/_search
{
  "query": {
    "term": {
      "name":"zhaoliu"
    }
  }
}

GET /lib3/user/_search
{
  "query": {
    "terms": {
      "interests": [
        "hejiu",
        "changge"
      ]
    }
  }
}
```





#### 复合查询

##### 1.使用bool查询

must: 文档必须匹配这些条件才能被包含进来

must_not：文档必须不匹配这些条件才能被包含。

should 







## 解析 elasticsearch 的架构

#### 1.1.分布式架构的透明隐藏特性

ElasticSearch是一个分布式系统,隐藏了复杂的处理机制
 分片机制:我们不用关心数据是按照什么机制分片的、最后放入到哪个分片中
 分片的副本:
 集群发现机制(cluster discovery):比如当前我们启动了一个es进程,当启动第二个es进程时,这个进程作为一个node自动就发现了集群,并且加入了进去
 shard负载均衡:比如现在有10shard,集群中有3个节点,es会进行均衡的进行分配,以保证每个节点均衡的负载请求
 请求路由

#### 1.2.扩容机制

垂直扩容:购置新的机器,替换已有的机器
 水平扩容:直接增加机器

#### 1.3.rebalance

增加或减少节点时会自动均衡。， ，

#### 1.4.master节点

主节点的主要职责是和集群操作相关的内容,如创建或删除索引,跟踪哪些节点是群集的一部分,并决定哪些分片分配给相关的节点.稳定的主节点对集群的健康是非常重要的.

#### 1.5.节点对等

每个节点都能接收请求,每个节点接收到请求后都能把该请求路由到有相关数据的其它节点上接收原始请求的节点负责采集数据并返回给客户端







## 分片和副本机制

1. index包含多个shard

2. 每个shard都是一个最小工作单元,承载部分数据;每个shard都是一个Lucene实例,有完整的建立索引和处理请求的能力

3. 增减节点时,shard会自动在nodes中负载均衡

4. primary shard和replica shard,每个document肯定只存在于某一个primary shard以及其对应的replica shard,不可能存在于多个primary shard

5. replica shard是primary shard的副本,负责容错,以及承担读请求负载

6. primary shard的数量在创建索引的时候就固定了,replica shard的数量可以随时修改

7. primary shard的默认数量是5,replica默认是1,默认有10个shard,5个primary shard,5个replica shard

8. primary shard不能和自己的replica shard放在同一个节点上(否则节点宕机,primary shard和副本都丢失了,起不到容错的作用),但是可以和其他primary shard的replica shard放在同一个节点上





## PUT  和 POST两种修改文档方式的区别

#### PUT （类比mysql的 replace）

- 1. 先将







### 写一致性原理和quorum机制

1. 任意一个增删改