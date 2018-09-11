---
title: GIT使用简明教程
date: 2017-7-27 21:09:04
tags: [git]

---

## 单人开发

- 初始化git本地仓库:git init (.git隐藏文件, 不要轻易乱动)
- 创建文件 : touch Car.h
- 查看文件状态 : git status
- 查看还未add的代码的变化 git diff
- 添加到git版本控制中: git add Car.h
- 添加多个文件到git版本控制中 : git add .
- 提交代码 : git commit -m "注释"

查看代码：git log
红色文件: 文件没有被纳入到git管理中 / 文件被修改了 / 文件发生了冲突
绿色文件: 文件加入到了'暂存区'

## 配置账号信息 (一般来讲只需要配置一次全局的账号即可)
配置局部信息

用户名 : git config user.name "guxiangfly" (区分谁开发的)
邮箱信息 : user.email "964999133@qq.com" (用于联系开发者)
配置全局信息

用户名: git config --global user.name "wukong"
邮箱信息: git config --global user.email "wukong.huaguoshan.com"

注意:

如果没有配置过账号信息, 那么git会有一个默认的账号信息
如果配置的是全局的信息, 那么在finder --> 前往 --> 个人 --> 隐藏文件.gitconfig . 全局信息将会写入到这个文件内
如果没有配置局部信息, 会用默认的全局信息来提交. 局部如果配置过了, 那么将会使用局部配置的信息


著作权归作者所有。商业转载请联系作者获得授权，非商业转载请注明出处。

## 查看日志

查看日志 : git log
版本号 : 40位, 哈希值 . 哈希值是唯一的, 只要服务器看见版本不一样就可以提交到远程服务器
增强版log : 配置带颜色的log别名 提供版本号的前七位
```
$ git config --global alias.lg "log --color --graph  
--pretty=format:'%Cred%h%Creset   
-%C(yellow)%d%Creset %s %Cgreen(%cr)   
%C(bold blue)<%an>%Creset' --abbrev-commit"`
```
粘贴上面那段后:输入 git lg 回车


## 起别名
配置局部命令别名 :

查看状态:` git config alias.st "status"` -->
.后面的字符,代表将来要简写的命令. 双引号内的字符, 代表着原来指令的全称
提交内容:` git config alias.ci "commit -m"`

## 版本回退
### 如果文件已经被commit 可以通过git reset --hard HEAD^回退
- 版本回退: git reset --hard HEAD^ --> 一个^代表一个版本
- 指定版本 : git reset --hard 8308f01 --> 后面拼接7位的版本号
### 如果文件没有commit

- 回退到当前最高版本: git reset --hard HEAD
- 检出当前分支的最高版本: git checkout Car.h (git中 checkout可以做revert的操作, 也就是版本回退)

### 查看修改参考日志
如果git回到了早期的版本, 那么后面的那些版本将不存在.
如果此时有需求, 需要回退到之前的时候, 那么可以通过
```
git reflog
```

 来查看之前
每一次的修改日志版本. 此时就可以通过记录的版本进行回退了.


## GIT的工作原理
Git本地目录分为 **工作区**和**版本库**

版本库包含3个东西:
暂存区 --> 文件只要发生了改动, 就会在暂存区
master --> 相当于svn的trunk目录, master是git创建的第一个分支
HEAD指针 --> 隐藏看不见的, 默认指向master分支

Git的add和commit原理
add : 添加到暂存区
commit : 添加到本地master分支
push : 将master分支代码提交给服务器

![image.png](http://upload-images.jianshu.io/upload_images/6406935-bf1205e5f941e5a0.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

## tag 打标记
使用tag，就能够将项目快速切换到某一个中间状态，例如产品开发线上的某一个稳定版本

查看当前标签: git tag
- 在本地代码库给项目打上一个标签:` git tag -a v1.0 -m 'Version 1.0'`  
- 将标签添推送到远程代码库中:` git push origin v1.0`
- 签出v1.0标签: `git checkout v1.0`
- 从签出状态创建v1.0bugfix分支:` git checkout -b bugfix1.0`

