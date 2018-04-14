---
title: Jenkins使用
date: 2017-11-14 9:00:04
tags: [运维]

---

## Jenkins的下载
网上使用的 个版本的服务器安装 都没有 war包好用
``` java
java -jar jenkins.war  启动 
```

启动的时候修改默认端口
```shell
java -jar jenkins.war --ajp13Port=-1 --httpPort=8081
```

启动的时候需要填写秘钥 秘钥在Jenkins启动的时候会有下列信息
```
信息: Pre-instantiating singletons in org.springframework.beans.factory.support.DefaultListableBeanFactory@485ce2d7: defining beans [filter,legacy]; root of factory hierarchy
十二月 20, 2017 4:38:15 下午 jenkins.install.SetupWizard init
信息:

*************************************************************
*************************************************************
*************************************************************

Jenkins initial setup is required. An admin user has been created and a password generated.
Please use the following password to proceed to installation:

7c706474fe504b63b18fa76047ed4480

This may also be found at: C:\Users\guxiang\.jenkins\secrets\initialAdminPassword

*************************************************************
*************************************************************

```