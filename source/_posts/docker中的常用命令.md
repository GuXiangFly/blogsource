---
title: docker中的常用命令
date: 2017-9-5 23:00:04
tags: [docker,运维]

---
## docker命令大全手册
https://docs.docker.com/engine/reference/commandline/swarm_ca/

centos7中的设置 docker 开机启动
```
--安装
yum -y install docker
--开启
systemctl start docker.service
--查看docker是否开启
docker version

systemctl enable docker.service
systemctl grep docker  (查看docker的进程)
```

## docker加速器（Ubuntu centos通用）
```
sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json <<-'EOF'
{
  "registry-mirrors": ["https://hlef81mt.mirror.aliyuncs.com"]
}
EOF
sudo systemctl daemon-reload
sudo systemctl restart docker
```


## centos7中使用 iptables 
由于在centos7中 使用firewalld会与docker网络出现一些冲突
```
 systemctl  disable firewalld 
 yum -y install iptables-services 
 systemctl enable iptables
 systemctl start iptables
```


```
docker run -it --rm stress --cpu 1 (占用一个cpu) 

--rm 代表停止后自动删除这个容器
```


## docker 安装 mysql 
```
sudo docker run --name first-mysql -p 3306:3306 -e MYSQL\_ROOT\_PASSWORD=root -d mysql
```

## docker 安装 oracle 

oracle 11.0.2 64bit 企业版 实例名: helowin

### 启动容器：
 ```
 docker run -d --name oracle_11g -p 1521:1521 registry.aliyuncs.com/helowin/oracle_11g
```
(plsql navicat等连接要注意端口的映射 )

### 1.进入容器 
```
docker exec -it 容器ID /bin/bash
```

### 2.加载环境变量 
```
source /home/oracle/.bash_profile
```

### 3.登录 
```
sqlplus /nolog
```

```
connect /as sysdba 到这里就可以进行您想要的任何操作了
```

容器系统用户 root：helowin

（如需用plsql工具连接 请设置用户和密码） 举例：
```
create user test identified by test;
grant connect,resource,dba to test;
```
（很多留言问oracle 用户密码，想不明白，你们咋想的 ）

如需映射oracle的数据文件 把容器内对应的文件，拷贝到宿主机，映射即可（如下）

/home/oracle/app/oracle/oradata/

/home/oracle/app/oracle/flash_recovery_area/helowin/