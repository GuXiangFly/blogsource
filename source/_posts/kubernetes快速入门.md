---
title: kubernetes快速入门
date: 2019-8-11 13:09:04
tags: [JVM,java]

---


## k8s 启动命令
```shell script
systemctl start etcd
systemctl start docker
systemctl start kube-apiserver
systemctl start kube-controller-manager
systemctl start kube-scheduler
systemctl start kubelet
systemctl start kube-proxy


systemctl restart etcd
systemctl restart docker
systemctl restart kube-apiserver
systemctl restart kube-controller-manager
systemctl restart kube-scheduler
systemctl restart kubelet
systemctl restart kube-proxy
```

## K8S 常用命令
```shell script
查看各个pod的运行情况
查看容器: 
kubectl get pods
或者 kubectl get po
或者 kubectl get pod 

删除容器1(使用replication controller 批量删除):
kubectl delete -f nginx-rc.yml  

删除容器2(使用 pod name 进行单个删除 不过单个删除后会立即再创建一个pod保持和 rc文件中的数量一致): 
kubectl delete pods/tomcat-pswd

查看容器详情列表: 
kubectl describe pod tomcat-aswd

进入容器内部
kubectl exec -it nginx-swvd /bin/bash

假设一个pod里面有多个container  一个名为 app-main   一个名为 app-help 使用下面命令进入 app-main   进入app-help同理
kubectl exec -it nginx-swvd -c app-main /bin/bash

查看svc的运行
kubectl get svc


查看每个node的运行状态
kubectl get nodes

查看健康状态
kubectl get cs
```


### mytomcat-rc.yml
- 这个rc文件主要是用于创建pod 指定如何创建pod 创建多少个pod
- rc 本质是一个 replication controller 这个controller用于定义pod的个数 pod创建环境
```yaml
apiVersion: v1
kind: ReplicationController
metadata:
  name: mytomcat
spec:
  replicas: 2 
  selector:
    app: mytomcat 
  template:
    metadata:
      labels:
        app: mytomcat 
    spec:
      containers:
        - name: mytomcat 
          image: tomcat:7-jre7 
          ports:
          - containerPort: 8080
```

### mytomcat-svc.yml
- 这个svc文件用于控制对外暴露的端口，以及使用这个 svc对外做负载均衡  
- 这是一个service描述 具体由 kube-proxy 进行流量的分发
```yaml
apiVersion: v1 
kind: Service 
metadata:
  name: mytomcat 
spec:
  type: NodePort 
  ports:
  - port: 8080
    nodePort: 30001
  selector:
    app: mytomcat
```


### nginx-rc.yml
```yaml
apiVersion: v1
kind: ReplicationController
metadata:
  name: nginx
spec:
  replicas: 3
  selector:
    app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx
        ports:
        - containerPort: 80
```
### nginx-svc.yml
```yaml
apiVersion: v1
kind: Service 
metadata: 
  name: nginx 
spec:
  type: NodePort
  ports:
  - port: 80
    nodePort: 30121
  selector:
    app: nginx
```

## 解决问题
- 外部网络无法访问kubernetes
```shell script
## 修改这个文件
vim /etc/sysctl.conf 

加入这么一行
net.ipv4.ip_forward=1
```

- 解决 kubectl get pods 爆出 No resource found
```shell script
vim /etc/kubernetes/apiserver

去除最后一行的 ',serviceaccount'这个值

systemctl restart kube-apiserver
```


解决 kubernetes镜像无法 pull
```shell script

docker pull kubernetes/pause

docker tag docker.io/kubernetes/pause:latest 192.168.25.201:5000/google_containers/pause-amd64.3.0

docker push 192.168.25.201:5000/google_containers/pause-amd64.3.0

vim /etc/kubernetes/kubelet
KUBELET_ARGS="--pod_infra_container_image=192.168.25.201:5000/google_containers/pause-amd64.3.0"

systemctl restart kubelet
```


## 关于POD
pod的定义文件
```yaml
apiVersion: v1        　　          #必选，版本号，例如v1,版本号必须可以用 kubectl api-versions 查询到 .
kind: Pod       　　　　　　         #必选，Pod
metadata:       　　　　　　         #必选，元数据
  name: string        　　          #必选，Pod名称
  namespace: string     　　        #必选，Pod所属的命名空间,默认为"default"
  labels:       　　　　　　          #自定义标签
    - name: string      　          #自定义标签名字
  annotations:        　　                 #自定义注释列表
    - name: string
spec:         　　　　　　　            #必选，Pod中容器的详细定义
  containers:       　　　　            #必选，Pod中容器列表
  - name: string      　　                #必选，容器名称,需符合RFC 1035规范
    image: string     　　                #必选，容器的镜像名称
    imagePullPolicy: [ Always|Never|IfNotPresent ]  #获取镜像的策略 Alawys表示下载镜像 IfnotPresent表示优先使用本地镜像,否则下载镜像，Nerver表示仅使用本地镜像
    command: [string]     　　        #容器的启动命令列表，如不指定，使用打包时使用的启动命令
    args: [string]      　　             #容器的启动命令参数列表
    workingDir: string                     #容器的工作目录
    volumeMounts:     　　　　        #挂载到容器内部的存储卷配置
    - name: string      　　　        #引用pod定义的共享存储卷的名称，需用volumes[]部分定义的的卷名
      mountPath: string                 #存储卷在容器内mount的绝对路径，应少于512字符
      readOnly: boolean                 #是否为只读模式
    ports:        　　　　　　        #需要暴露的端口库号列表
    - name: string      　　　        #端口的名称
      containerPort: int                #容器需要监听的端口号
      hostPort: int     　　             #容器所在主机需要监听的端口号，默认与Container相同
      protocol: string                  #端口协议，支持TCP和UDP，默认TCP
    env:        　　　　　　            #容器运行前需设置的环境变量列表
    - name: string      　　            #环境变量名称
      value: string     　　            #环境变量的值
    resources:        　　                #资源限制和请求的设置
      limits:       　　　　            #资源限制的设置
        cpu: string     　　            #Cpu的限制，单位为core数，将用于docker run --cpu-shares参数
        memory: string                  #内存限制，单位可以为Mib/Gib，将用于docker run --memory参数
      requests:       　　                #资源请求的设置
        cpu: string     　　            #Cpu请求，容器启动的初始可用数量
        memory: string                    #内存请求,容器启动的初始可用数量
    livenessProbe:      　　            #对Pod内各容器健康检查的设置，当探测无响应几次后将自动重启该容器，检查方法有exec、httpGet和tcpSocket，对一个容器只需设置其中一种方法即可
      exec:       　　　　　　        #对Pod容器内检查方式设置为exec方式
        command: [string]               #exec方式需要制定的命令或脚本
      httpGet:        　　　　        #对Pod内个容器健康检查方法设置为HttpGet，需要制定Path、port
        path: string
        port: number
        host: string
        scheme: string
        HttpHeaders:
        - name: string
          value: string
      tcpSocket:      　　　　　　#对Pod内个容器健康检查方式设置为tcpSocket方式
         port: number
       initialDelaySeconds: 0       #容器启动完成后首次探测的时间，单位为秒
       timeoutSeconds: 0    　　    #对容器健康检查探测等待响应的超时时间，单位秒，默认1秒
       periodSeconds: 0     　　    #对容器监控检查的定期探测时间设置，单位秒，默认10秒一次
       successThreshold: 0
       failureThreshold: 0
       securityContext:
         privileged: false
    restartPolicy: [Always | Never | OnFailure] #Pod的重启策略，Always表示一旦不管以何种方式终止运行，kubelet都将重启，OnFailure表示只有Pod以非0退出码退出才重启，Nerver表示不再重启该Pod
    nodeSelector: obeject   　　    #设置NodeSelector表示将该Pod调度到包含这个label的node上，以key：value的格式指定
    imagePullSecrets:     　　　　#Pull镜像时使用的secret名称，以key：secretkey格式指定
    - name: string
    hostNetwork: false      　　    #是否使用主机网络模式，默认为false，如果设置为true，表示使用宿主机网络
    volumes:        　　　　　　    #在该pod上定义共享存储卷列表
    - name: string     　　 　　    #共享存储卷名称 （volumes类型有很多种）
      emptyDir: {}      　　　　    #类型为emtyDir的存储卷，与Pod同生命周期的一个临时目录。为空值
      hostPath: string      　　    #类型为hostPath的存储卷，表示挂载Pod所在宿主机的目录
        path: string      　　        #Pod所在宿主机的目录，将被用于同期中mount的目录
      secret:       　　　　　　    #类型为secret的存储卷，挂载集群与定义的secre对象到容器内部
        scretname: string  
        items:     
        - key: string
          path: string
      configMap:      　　　　            #类型为configMap的存储卷，挂载预定义的configMap对象到容器内部
        name: string
        items:
        - key: string
          path: string
```


## rancher 2.0 的创建
```
docker run -d -p 80:80 -p 433:433 rancher/rancher:v2.0.0
```

- 通过log查看启动详情
```
docker logs -f  05b
```


## rancher 1.0 的创建

``` bash
 docker run -di --name=rancher -p 9000:8080 rancher/server
```

