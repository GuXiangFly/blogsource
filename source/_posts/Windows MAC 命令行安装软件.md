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

#### 使用 nvm-windows
首先 在这个地址中下载 nvm-setup版 https://github.com/coreybutler/nvm-windows/releases

很多参考以下链接 [https://segmentfault.com/a/1190000009442289](https://segmentfault.com/a/1190000009442289)   
使用 setup版安装 会让你选两个路径 
-  通过 nvm 安装 nodejs



继续输入命令：`nvm install latest` 如果网络畅通，我们会看到正在下载的提示，下载完成后 会让你use那个最新的node版本。

用nvm install node版本号来安装node，如 
```
nvm install 8.0.0
```
安装完后 8.0.0版本会放在你 nvm 目录下

再次执行以下命令 node会放到 NVM_SYSLINK 目录下
```bash
nvm use 8.0.0
```
由于所有环境都在`D:\developwork\softwareworkspace\nodeENV `
重装系统我只需要将
```bash
NPM_HOME : D:\developwork\softwareworkspace\nodeENV\npm
NVM_HOME : D:\developwork\softwareworkspace\nodeENV\nvm
NVM_SYMLINK : D:\developwork\softwareworkspace\nodeENV\nodejs

Path配置进  
%NPM_HOME%   # 注意 npm 需要配置在最前面  这是由于每个版本node自带NPM  切换 node 会导致 npm切换 
%NVM_HOME%
%NVM_SYMLINK%
这些加入环境变量中
```
在 windows home 目录下 也创建 .npmrc 文件
```bash
prefix=D:\developwork\softwareworkspace\nodeENV\npm
home=https://npm.taobao.org
registry=https://registry.npm.taobao.org/
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
```
yarn global add yo
```
