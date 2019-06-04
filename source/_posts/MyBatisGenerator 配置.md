---
title: MyBatis Generator配置
date: 2017-11-1 13:22:54
tags: [java]

---
## MyBatis Generator 是什么
MyBatis Generator是一个可以用来生成Mybatis dao,entity,Mapper文件的一个工具,在项目的过程中可以省去很多重复的工作,我们只要在MyBatis Generator的配置文件中配置好要生成的表名与包名，然后运行一条命令就会生成一堆文件。
## 如何配置依赖
### Gradle 版本
 - 1 在 buildScript 中添加
```groovy
  classpath "gradle.plugin.com.arenagod.gradle:mybatis-generator-plugin:1.4"
```
 - 2 在plugins中加上plugin
```groovy
 id "com.arenagod.gradle.MybatisGenerator" version "1.4"
```
 - 3添加repo 依赖
```groovy
 compile group: 'org.mybatis.generator', name: 'mybatis-generator-core', version:'1.3.2'
``` 
- 4 配置脚本
 ```
   注意 mac 下写相对路径可能有问题，建议写绝对路径
   windows 我也写了绝对路径  相对路径入下 src/main/resources/mybatis-generator.xml
 ```
```groovy
configurations {
    mybatisGenerator
}
// mybatis-generator.xml 配置路径
//这里会遇到个问题：MyBatis Generator 通过xml生成，有日志但是没有生成文件成功的问题， 
//原因：mac下是找不到 ./src 路径的，需要全路径，如下配置。windows则为src/main/resources/mybatis-generator.xml
mybatisGenerator {
    verbose = true
    configFile = 'D:\\IntellijIDEAWorkSpace\\neteaseworkspace\\adapmath-server\\src\\main\\resources\\mybatis-generator.xml'
}

```


#### 简单的 build.gradle 配置Demo
可以参考后面的链接 [点我](https://gitlab.corp.youdao.com/luna-dev/adapmath-server/blob/dev-guxiang/build.gradle)   
或者下面的简单配置
```groovy
buildscript {
    ext {
        springBootVersion = '1.5.6.RELEASE'
    }
    repositories {
        mavenLocal()
        mavenCentral()
    }
    dependencies {
        classpath("org.springframework.boot:spring-boot-gradle-plugin:${springBootVersion}")
        classpath "gradle.plugin.com.arenagod.gradle:mybatis-generator-plugin:1.4"
    }
}
plugins {
     id "com.arenagod.gradle.MybatisGenerator" version "1.4"
 }
apply plugin: 'java'
apply plugin: 'org.springframework.boot'
apply plugin: "com.arenagod.gradle.MybatisGenerator"

dependencies {
    compile group: 'org.mybatis.generator', name: 'mybatis-generator-core', version:'1.3.2'
}


configurations {
    mybatisGenerator
}
// mybatis-generator.xml 配置路径
//这里会遇到个问题：MyBatis Generator 通过xml生成，有日志但是没有生成文件成功的问题， 
//原因：mac下是找不到 ./src 路径的，需要全路径，如下配置。windows则为src/main/resources/generator.xml
mybatisGenerator {
    verbose = true
    configFile = 'D:\\IntellijIDEAWorkSpace\\neteaseworkspace\\adapmath-server\\src\\main\\resources\\mybatis-generator.xml'
}
```
双击此处进行生成  
![](https://raw.githubusercontent.com/GuXiangFly/imagerepo/master/20190429114232.png)

### mybatis-generator.xml 配置详解
可以参考demo [点我](https://gitlab.corp.youdao.com/luna-dev/adapmath-server/blob/dev-guxiang/src/main/resources/mybatis-generator.xml)
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE generatorConfiguration
        PUBLIC "-//mybatis.org//DTD MyBatis Generator Configuration 1.0//EN"
        "http://mybatis.org/dtd/mybatis-generator-config_1_0.dtd">
<generatorConfiguration>
    <context id="runningCoinTables" targetRuntime="MyBatis3">
        <commentGenerator>
            <property name="suppressDate" value="true"/>
            <property name="suppressAllComments" value="true"/>
        </commentGenerator>
        <!--数据库链接地址账号密码-->
        <jdbcConnection driverClass="com.mysql.jdbc.Driver"
                        connectionURL="jdbc:mysql://ns013x.corp.youdao.com:3306/adapmath?useSSL=false"
                        userId="root" password="zhaoweidictop">
        </jdbcConnection>
        
        
        <!-- 
        只有一个属于forceBigDecimals，默认false。
        如果字段精确超过0，生成BigDecimal 如果字段精确是0，总长度10-18生成Long;  
        如果字段精确是0，总长5-9生成Integer;
        如果字段精确是0，总长小于5生成Short; 
        如果forceBigDecimals为true,统一生成BigDecimal 
        -->  
        <javaTypeResolver>
            <property name="forceBigDecimals" value="false"/>
        </javaTypeResolver>
        <!--生成Model类存放位置-->
        <javaModelGenerator targetPackage="com.youdao.adapmathserver.dao.entity" targetProject="src/main/java">
            <property name="enableSubPackages" value="true"/>
            <property name="trimStrings" value="true"/>
        </javaModelGenerator>
        <!--生成映射文件存放位置-->
        <sqlMapGenerator targetPackage="mappings" targetProject="src/main/resources">
            <property name="enableSubPackages" value="true"/>
        </sqlMapGenerator>
        <!--生成Dao类存放位置-->
        <!-- 客户端代码，生成易于使用的针对Model对象和XML配置文件 的代码
                这边的 type 可以切换为其他的  注解可以使用ANNOTATEDMAPPER
                
                type="ANNOTATEDMAPPER",生成Java Model 和基于注解的Mapper对象
                type="MIXEDMAPPER",生成基于注解的Java Model 和相应的Mapper对象
                type="XMLMAPPER",生成SQLMap XML文件和独立的Mapper接口
        -->
        <javaClientGenerator type="XMLMAPPER" targetPackage="com.youdao.adapmathserver.dao.mapper"
                             targetProject="src/main/java">
            <property name="enableSubPackages" value="true"/>
        </javaClientGenerator>

        <!--生成对应表及类名-->
        <!--
            这几项是视自己需求看是否开启， 如果开启 会在 Model类生成 example 代码, mapper也会有相应 example 代码
            enableCountByExample="false"  
            enableUpdateByExample="false"
            enableDeleteByExample="false"
            enableSelectByExample="false"
            selectByExampleQueryId="false"
          -->
        <table tableName="wrong_question" domainObjectName="WrongQuestion" enableCountByExample="false"
               enableUpdateByExample="false" enableDeleteByExample="false" enableSelectByExample="false"
               selectByExampleQueryId="false">
            <property name="useActualColumnNames" value="false"/>
        </table>

        <table tableName="textbook" domainObjectName="Textbook" enableCountByExample="false"
               enableUpdateByExample="false" enableDeleteByExample="false" enableSelectByExample="false"
               selectByExampleQueryId="false">
            <property name="useActualColumnNames" value="false"/>
        </table>
    </context>
</generatorConfiguration>
```