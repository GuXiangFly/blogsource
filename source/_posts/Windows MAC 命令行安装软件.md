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

#### 安装 nrm   （管理npm使用的源）
```
##  安装 nrm
sudo  npm  install -g nrm

##  查看nrm 的版本
nrm ls 

##  切换nrm的镜像
nrm use taobao


```

#### 安装webpack
```
npm install webpack -g // 全局安装

npm install webpack --save-dev  //局部项目内安装
```

#### 安装 n   （管理npm的版本）
```
sudo npm install -g n

## 安装npm v8 的最新版
n 8 latest
```

#### 安装 yarn 
```
npm install -g yarn 
```


## 安装 yo
yarn global add yo
```