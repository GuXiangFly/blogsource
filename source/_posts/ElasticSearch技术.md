---
title: ElasticSearch技术
date: 2017-10-27 20:09:04
tags: [ElasticSearch]

---

使用ES创建索引
``` json

请求为：http://localhost:9200/people  这个可以创建一个名字为 people的类

{
	"setting":{
		"number_of_shards": "5",
		"number_of_replicas": "1"
	},

	"mappings": {
		"man": {
			"properties": {
				"name": {
					"type": "text"
				},
				"country": {
					"type": "keyword"
				},
				"age": {
					"type": "integer"
				},
				"date":{
					"type": "date",
					"format": "yyyy-mm-dd HH:mm:ss||yyyy-MM-dd||epoch_millis"
				}
			}
		},
		"woman":{

		}
	}
}
```

直接在整个json里面插入 需要这样写
``` json
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