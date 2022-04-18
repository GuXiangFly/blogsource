---
title: Swagger-ui 使用笔记
date: 2018-2-27 20:09:04
tags: [Swagger]
---

### Swagger-ui 简介
首先 Swagger-ui  并不依赖于 springMVC 这一套 使用 jersey JSR 也可以使用 swagger-ui   
Swagger 是一款目前世界最流行的API管理工具。但目前Swagger已经形成一个生态圈，能够管理API的整个生命周期，从设计、文档到  测试与部署。Swagger有几个重要特性：

- 代码侵入式注解
- 遵循YAML文档格式
- 非常适合三端（PC、iOS及Android）的API管理，尤其适合前后端完全分离的架构模式。
- 减少没有必要的文档，符合敏捷开发理念
- 功能强大

Swagger拥有众多不同语言和平台的开源实现与工具，主要有：

- Swagger UI，（这个主要是在） 一套可以展示优美文档的Web应用。
- Swagger Editor，一款以YAML格式编辑与管理API的工具，同时支持JSON格式的文档描述。
- Swagger-Core，Swagger的Java/Scala实现，并已集成 JAX-RS (Jersey, Resteasy, CXF...), Servlets与Play Framework。
- Swagger-JS，Swagger的Javascript版本实现。

### swagger的配置

#### 1. 添加  jar 依赖
```
    compile 'io.springfox:springfox-swagger2:2.8.0'
    compile 'io.springfox:springfox-swagger-ui:2.8.0'
```

####2. 配置 SwaggerConfig
我一般放置在config包下
```java
@Configuration
@EnableSwagger2
// 这个代表只在 test 和  dev 的环境下生效
@Profile({"test","dev"})  
public class SwaggerConfig {

    @Bean
    public Docket createRestApi() {
       
        return new Docket(DocumentationType.SWAGGER_2)
                .apiInfo(apiInfo())
                .select()
                // 这里配置一个扫描package  配置根目录也可以  controller 也可以
                .apis(RequestHandlerSelectors.basePackage("com.youdao.adapmathserver"))
                .paths(PathSelectors.any())
                .build();
    }

    private ApiInfo apiInfo() {
        return new ApiInfoBuilder()
                .title("Adapter Math Server API Document")
                .description("Adapter Math Server APIs")
                .contact("guxiang@rd.netease.com")
                .version("1.0")
                .build();
    }
}
```
![](http://guxiangflyimagebucket.oss-cn-beijing.aliyuncs.com/imagerepo/20190430113732.png)


启动服务器  
如果是在 8080端口启的服务  
输入 http://localhost:8080/swagger-ui.html  
就可以访问
出现类似如下界面
![](http://guxiangflyimagebucket.oss-cn-beijing.aliyuncs.com/imagerepo/20190430115333.png)
**具体有一些简单的操作**   
![](http://guxiangflyimagebucket.oss-cn-beijing.aliyuncs.com/imagerepo/20190430115545.png)

其实做到这一步已经能初步使用 swagger-ui 
但是在 api 上 我们还可以写一些 annotation  

Name | Description
--- | ---
[@ApiOperation](#operation) | 注解来给API增加方法说明。
[@ApiImplicitParams ](#parameter) | 用在方法上包含一组参数说明。
[@ApiImplicitParam](#requestbody) | 用来注解来给方法入参增加说明。
[@ApiResponses](#apiresponse) | 用于表示一组响应
[@ApiResponse](#tag) | 用在@ApiResponses中，一般用于表达一个错误的响应信息

更多注解可以参考  [官方wiki](https://github.com/swagger-api/swagger-core/wiki/Annotations#apimodel)

类似如下
```java
    /**
     * 返回全部可选学习意愿列表
     * @param request
     * @param response
     * @return
     */
    @ApiOperation(value = "返回全部可选学习意愿列表")
    @GetMapping("/aims")
    public Object aims(HttpServletRequest request, HttpServletResponse response) {
        List<Aim> data = infoService.getAllAims();
        return ResultUtil.success(data);
    }
```