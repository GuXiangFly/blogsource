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






## MAC 中的软件安装


#### 安装Homebrew
```
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
```

####  安装nvm

```
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.8/install.sh | bash

是zsh用    source ~/.zshrc  

如果非zsh  source ~/.bash_profile

使用nvm 命令 查看是否安装好nvm
```





#### 安装mvn  （ node 和 npm  执行这个 两个都安装好了）

```
nvm ls   (查看已有的node版本)

nvm install 8.17.0  （nvm 安装node版本）

nvm install 

安装完node 后   node和npm都安装好了
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

## 添加npm源
nrm add sankuai  http://npm.sankuai.com

##  切换nrm的镜像
nrm use sankuai


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





# window安全

## 关闭windows安全中心

https://www.bilibili.com/video/BV1aE411o73Z/?spm_id_from=333.337.search-card.all.click&vd_source=73f183da11409d178c0db0c2e3501dd9

1. win+R  输入 regedit

2. 进入路径

   1. ```
      计算机\HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows Defender
      ```

3. 新建一个32位值  value改为1  并且重命名为`DisableAntiSpyware`  

![image-20221030012639660](http://guxiangflyimagebucket.oss-cn-beijing.aliyuncs.com/img/image-20221030012639660.png)







## IDM 下载地址

bilibili教程：

https://www.bilibili.com/video/BV1CK411n7GP/?spm_id_from=333.337.search-card.all.click&vd_source=73f183da11409d178c0db0c2e3501dd9



插件

https://chrome.google.com/webstore/detail/idm-integration-module/ngpampappnmepgilojfohadhhmbhlaek/related

- 建议使用下载包内的软件  百度网盘内搜 IDM破解版



IDM 下载 外网数据，配合 v2ray 需要打开次设置

![image-20221030015609600](http://guxiangflyimagebucket.oss-cn-beijing.aliyuncs.com/img/image-20221030015609600.png)





## 关闭window自动更新

1. win+R   regedit

2. 进入这个目录

   ```
   计算机\HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\UsoSvc
   ```

3. 将start的值改为4

![image-20221101021439305](http://guxiangflyimagebucket.oss-cn-beijing.aliyuncs.com/img/image-20221101021439305.png)

5. 将FailureActions的 10 和 18 两行的第五列由01改为 00

![image-20221101021543650](http://guxiangflyimagebucket.oss-cn-beijing.aliyuncs.com/img/image-20221101021543650.png)
