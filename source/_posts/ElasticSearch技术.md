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
```json5

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
					"index": true,   //代表使用分词器
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