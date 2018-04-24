---
title: Mac / Windows 安装软件
date: 2018-3-27 20:09:04
tags: [前端]

---

win中有类似 Linux 中 yum 的软件
choco  https://chocolatey.org/install

#### 安装 choco  Powershell中执行
```
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
```


#### 升级 Chocolatey
```
choco upgrade chocolatey
```

#### choco 安装 nodeJS
```
choco install nodejs
```

#### choco 安装 python
```
choco install python2
```

#### Java


## MAC 中的软件安装


#### 安装Homebrew
```
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
```

#### 安装node 和 npm  执行这个 两个都安装好了
```
brew install node
```

#### 安装 cnpm
```
 npm install -g cnpm --registry=https://registry.npm.taobao.org
```

#### cnpm 安装 angular CLI
```
cnpm i -g angular-cli
```



## 前端模块

#### 更新 angular
```
npm install -g @angular/cli@latest
```
