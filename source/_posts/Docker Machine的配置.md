---
title: Docker Machine的配置
date: 2017-10-5 23:00:04
tags: [docker,运维]

---
### 创建myvm4这个docker-machine
创建myvm3 这个虚拟机用来装很多中间件的，内存尽量大，这里写的是3G
https://8kcum6rp.mirror.aliyuncs.com这个是阿里云加速器的地址，每个人去注册一个，获取加速器地址。码云QA里面有方法的

`docker-machine?create?--virtualbox-memory?"1024"?--engine-registry-mirror="https://8kcum6rp.mirror.aliyuncs.com"?--engine-insecure-registry="0.0.0.0/0"?-d?virtualbox?myvm4
`

### CMD中设置docker 的上下文 
执行下面这个命令，代表当前cmd控制台会使用myvm4中的docker
```
@FOR /f "tokens=*" %i IN ('docker-machine env myvm4') DO @%i
```

### PowerShell中设置docker 的上下文 使用myvm4
```
& "docker-machine.exe" env myvm4 | Invoke-Expression   
```

### 创建一个docker的局域网
```
docker network create guxiang_net
```

### run的方式
-p 端口映射  
-e 环境变量  
--net是加入局域网络  
-d 后台运行  

