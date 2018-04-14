
---
title: JsonView的使用
date: 2017-8-29 20:09:04
tags: [java]

---
JsonView的使用

@JsonView是jackson json中的一个注解，用于控制 方法返回的数据 的可见性


为了显示数据的安全性
我们有以下需求
 - 在访问 ListUser()  方法的时候， 不显示password
 - 在访问 queryUser(String username)  方法的时候 显示password 

我将以下的代码定为一个DTO
``` java
public class User {

    public interface UserSimpleView{};
    public interface UserDetailView extends UserSimpleView{};

    private String username;

    private String password;

    @JsonView(UserSimpleView.class)
    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    @JsonView(UserDetailView.class)
    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }
}

```
以上代码中

我定义了两个接口 UserSimpleView 和 UserDetailView

UserDetailView 继承了UserSimpleView 所以适用于UserSimpleView的get方法同样适用于 UserDetailView


下面来看我的controller方法

``` java
/**
 * UserController
 *
 * @author guxiang
 * @date 2017/10/3
 */
@RestController
public class UserController {

    User user = new User("root","abc");

    @GetMapping("/user")
    @JsonView(User.UserSimpleView.class)
    public User listUser(){
        return user;
    }

    @GetMapping("/user/{username}")
    @JsonView(User.UserDetailView.class)
    public User queryUser(String username){
        return user;
    }

}

```

访问localhost:8080/user后 返回
``` javascript
{
"username": "root"
}
```
它被定义为UserSimpleView  getPassword方法上没有@JsonView(UserSimpleView.class) 这个注解 所以它 不显示 password


访问localhost:8080/user/root后 返回
``` javascript
{
"username": "root",
"password": "abc"
}
```
它controller中方法被定义为UserDetailView 

getUsername方法上有@JsonView(UserSimpleView.class)
getPassword方法上有 @JsonView(UserDetailView.class)
而UserDetailView 继承了 UserSimpleView
 所以返回显示定义的全部数据