---

title: RocksDB学习
date: 2019-11-11 13:09:04
tags: [java,RocksDB,LSM]

---
如何使用java操作rocksDB

```java
package cn.guxiangfly.rocksdbtest;

import org.rocksdb.Options;
import org.rocksdb.RocksDB;

import javax.annotation.Resource;
import java.net.URL;

/**
 * @Author guxiang02
 * @Date 2021/6/25
 **/
public class RocksDBDemo {
    public static void main(String[] args)throws Exception {
        Options dbOpt = new Options();
        dbOpt.setCreateIfMissing(true);

        URL resource = RocksDBDemo.class.getResource("/myrocksdb");
        RocksDB rocksDB = RocksDB.open(dbOpt,resource.getPath());

        byte[] key= "guxiang".getBytes();

        byte[] value = "222".getBytes();

        rocksDB.put(key,value);

        System.out.println("写入数据到rocksdb中完成");

        System.out.println("从rocksDB中读取到key="+new String(key) +" value是" +new String(rocksDB.get(key)));
    }
}

```



![image-20210628173741518](https://gitee.com/guxiangfly/blogimage/raw/master/img/image-20210628173741518.png)