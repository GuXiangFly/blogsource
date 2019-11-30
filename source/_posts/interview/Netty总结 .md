---
title: Netty ProtoBuf笔记
date: 2018-1-2 20:09:04
tags: [Netty]

---
|protoc类型	|java类型	|c++类型
|:------:    | :-----:    | :----: |
|double	    | double	|double
|float	    | float	    |float
|int32	    | int	    |int32
|int64	    | long	    |int64
|uint32	    | int	    |uint32
|uint64	    | long	    |uint64
|sint32	    | int	    |int32
|sint64	    | long	    |int64
|fixed32	|int	    |uint32
|fixed64	|long	    |uint64
|sfixed32	|int	    |uint32
|sfixed64	|long	    |uint64
|bool	    |boolean	|bool
|string	    |String	    |string
|bytes	    |ByteString	|string


```
option java_package = "cn.guxiangfly.netty5.protobuf";
option java_outer_classname = "PlayerModule";

message PBPlayer{
    required int64 playerId = 1;

    required int32 age = 2;

    required string name = 3;

    repeated int32 skills = 4;
    repeated 对应的是 List
    int32   就对其中List 内部的类型
}

```

对应的java
``` java
class PBPlayer{
    private long playerId;
	
	private int age;
	
	private String name;
	
	private List<Integer> skills = new ArrayList<>();
}
```


### 解释一下 playerId = 1; age = 2; 里面1 2 的含义
```
原来序列化需要这样
{"playerId":"basketball";"age":"18"}
现在只需要这样
{"1":"basketball";"2":"18"}
```