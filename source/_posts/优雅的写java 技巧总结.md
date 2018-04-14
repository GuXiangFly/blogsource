---
title: 优雅的写java 技巧总结
date: 2017-7-27 20:09:04
tags: [java]

---

## list方法的

``` java
   List<SellerInfo>  sellerInfoList = new ArrayList<>();
        sellerInfoList.add(new SellerInfo());
        sellerInfoList.add(new SellerInfo());
        sellerInfoList.add(new SellerInfo());
           
```

简化为
``` java
 List<SellerInfo> sellerInfoList2 = Arrays.asList(new SellerInfo(),new SellerInfo(),new SellerInfo());
```