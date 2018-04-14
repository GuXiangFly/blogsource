---
title: 通过自定义注解编配置maysql驱动
date: 2017-7-27 20:09:04
tags: [注解]

---


``` java
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;

/**
 * DbInfo
 *
 * 注解信息默认是 (RetentionPolicy.class  在编译的时候存在 运行的时候不存在，
 * 要想让它在编译的时候存在，那么我需要将它指定为 RetentionPolicy.RUNTIME
 * RetentionPolicy.RUNTIME
 * @author guxiang
 * @date 2017/11/4
 */
@Retention(RetentionPolicy.RUNTIME)
public @interface DbInfo {

    String driverClass();

    String username();

    String password();

    String url();
}
```

``` java
public class AnnotationJdbcUtil {


    /**
     * 读取这里的注解信息，然后用这些注解信息去链接数据库
     *
     * @return
     * @throws Exception
     */
    @DbInfo(driverClass = "com.mysql.jdbc.Driver", username = "root", password = "root", url = "jdbc:mysql:///test")
    public Connection getConnection() throws Exception {

        Class<?> clazz = Class.forName("cn.guxiangfly.annotation.AnnotationJdbcUtil");

        Method getConnectionMethod = clazz.getMethod("getConnection", null);

        //判断方法是否在getconnection方法上
        boolean isPresent = getConnectionMethod.isAnnotationPresent(DbInfo.class);

        if (!isPresent){
            return null;
        }
        //如果进来，表明注解在当前方法上
        DbInfo annotation = getConnectionMethod.getAnnotation(DbInfo.class);
        String driverClass = annotation.driverClass();
        String username = annotation.username();
        String password = annotation.password();
        String url = annotation.url();
        Class.forName(driverClass);

        return DriverManager.getConnection(url,username,password);
    }
}

```