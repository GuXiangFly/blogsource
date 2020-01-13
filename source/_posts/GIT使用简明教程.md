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
邮箱信息 :  git config user.email "964999133@qq.com" (用于联系开发者)
配置全局信息

用户名: git config --global user.name "guxiangfly"
邮箱信息: git config --global user.email "964999133@qq.com"

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
git config --global alias.lg "log --color --graph  
--pretty=format:'%Cred%h%Creset   
-%C(yellow)%d%Creset %s %Cgreen(%cr)   
%C(bold blue)<%an>%Creset' --abbrev-commit"
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
master --> 相当于svn的trunk目录, master是git创建的第一个分支
HEAD指针 --> 隐藏看不见的, 默认指向master分支

Git的add和commit原理
add : 添加到暂存区
commit : 添加到本地master分支
push : 将master分支代码提交给服务器

![image.png](http://upload-images.jianshu.io/upload_images/6406935-bf1205e5f941e5a0.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

![](https://i.loli.net/2019/12/05/c9GtCvRVSFXiBYe.png)



## tag 打标记

使用tag，就能够将项目快速切换到某一个中间状态，例如产品开发线上的某一个稳定版本

查看当前标签: git tag
- 在本地代码库给项目打上一个标签:` git tag -a v1.0 -m 'Version 1.0'`  
- 将标签添推送到远程代码库中:` git push origin v1.0`
- 签出v1.0标签: `git checkout v1.0`
- 从签出状态创建v1.0bugfix分支:` git checkout -b bugfix1.0`



## git 撤销改动的方式

- 丢弃工作区中没有git add 的改动

  ```
  git checkout -- code.txt
  ```

- 丢弃工作区中已经git add 的改动

   git reset HEAD file  是将暂存区的修改撤销掉 回到工作区

  ```
  git reset HEAD code.txt
  git checkout -- code.txt
  ```

  

## git 数据diff

```
git diff 版本1 版本2  file
	版本1 这个必须有参数
	版本2 如果不填的话 默认是当前的工作区
	
常用方法
git diff HEAD -- Readme.md

git diff HEAD HEAD^ --Readme.md
```

```
--- 代表是 版本1的数据
+++ 代表是 版本2的数据

举例： git diff HEAD HEAD^ --Readme.md
---代表是 HEAD 的数据
+++代表是 HEAD^ 的数据
```



![](https://i.loli.net/2019/12/05/RIf5WxYXhub6sy7.png)



## git删除文件

-  删除文件后想把删除的文件恢复

  ```bash
  rm -rf Readme.md
  git checkout -- Readme.md
  ```

- 删除文件后 从git中也把文件删除

  ```bash
  rm -rf Readme.md
  git rm Readme.md
  git commit -m 'xxx'
  ```



# git的分支管理

```
当前分支在master 从master分支创建一个 dev分支

git checkout -b dev
```



HEAD 和  分支 和 提交点的关系

HEAD 指向分支  分支指向各个版本

![image-20191205203748399](/Users/mtdp/Library/Application Support/typora-user-images/image-20191205203748399.png)

- 最初的样子 

  一开始master分支是一条线 git 使用 master指向最新的 提交点 再用HEAD指向master 。就确定了当前分支 以及当前分支的提交点了

  ![](https://i.loli.net/2019/12/05/vIcKp7GEBWJ8fLP.png)

- 创建一个新的分支

  

![](https://i.loli.net/2019/12/05/1Nr89mWE26TOCZw.png)



创建一个新的分支 只是创建了一个新的dev指针  然后让HEAD也指向这个指针





- 对dev分支进行开发

  多一个 提交点  就是 dev指针向前移位

![](https://i.loli.net/2019/12/05/1Nr89mWE26TOCZw.png)



- 对假设我对 dev有了修改  并且切换回master 也进行了修改 就会变成这种样子

  ![](https://i.loli.net/2019/12/05/aQiN7W1Strl5hCR.png)

- 现在我们需要合并代码

  - git当前处在master分支上，master需要合并dev的代码

  ```
  git merge dev 
  ```

  - 如果没有冲突的话 git会采用快速合并的方式进行合，并且自动给你创建一个新的提交点

  - 如果有冲突的话   merge dev的时候会修改当前文件，再commit一下 就会新创建一个提交点

  - 总的来说，合并有三种

     - 快速合并    （dev是从master checkout出来   dev分支有新内容  master没有新内容  直接快速合并，不会创建新的提交）

     - 无冲突合并 （会多一次提交记录）

     - 有冲突合并 （会多一次提交记录）

## git 删除分支

```
git branch -d dev    (删除dev分支)
```





## git 代码追踪

```
git branch --set-upstream-to=origin/远程分支名称   本地分支名称


```

