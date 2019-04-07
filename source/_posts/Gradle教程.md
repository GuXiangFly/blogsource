## 常用命令

Gradle 生成的 build文件夹 类似于 Maven的  target 

### wrapper命令的用处
在我们的 gradle-> wrapper ->wrapper.properties 有如下
![](https://raw.githubusercontent.com/GuXiangFly/imagerepo/master/20190313103654.png)
```properties
distributionBase=GRADLE_USER_HOME
distributionPath=wrapper/dists
distributionUrl=https\://services.gradle.org/distributions/gradle-4.6-bin.zip
#可以解释一下 为何 ：之前 要加反斜杠 写成\:  这是因为 properties 配置文件中我们可以不使用= 使用 ： 代表“=”
zipStoreBase=GRADLE_USER_HOME
zipStorePath=wrapper/dists
```
执行命令
```bash
gradle wrapper
```
如果命令检测到我们本地没有gradle ，那么就会去指定的url下拉取 gradle-4.6-bin.zip 进行安装


### 用于测试
```bash
gradle test --tests "com.youdao.adaplearnserver.DbUtil.Mysql2esUtil"
```

### 构建的时候  跳过测试
```bash
 gradle build  -x test 
```
我们可以加入一个参数 --stacktrace 用于打印详细的错误信息，我们一般只需要看最后的那个 caused by 就能定位问题  
```bash
gradle build --stacktrace   -x test 
```

### 用于测试
