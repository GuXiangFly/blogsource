---
title: MAC中配置zsh
date: 2019-8-27 20:09:04
tags: [前端]

---

首先，装上v2rayU  配置好机场，防止 github访问失效



## 安装oh-my-zsh

```sh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

安装后，就已经有一些默认效果，如命令行提示符的主题变化。

通过查看 ls ~/.oh-my-zsh  查看是否存在文件

默认会有

```
vim ~/.zshrc 
```

## 变换主题

oh-my-zsh 提供了许多内置主题，可查看 [themes](https://github.com/ohmyzsh/ohmyzsh/wiki/Themes) 获取一系列的主题。

我们可直接通过 ~/.zshrc 配置更新主题配置，将内容修改如下：

```
ZSH_THEME="agnoster"   # 默认为 robbyrussell
```

执行 `source ~/.zshrc` 生效配置，就能看到主题效果。【可能出现乱码情况后续解决】

## 安装插件

 5 个 oh-my-zsh 内置插件，如下所示：

- [git](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/git)，Git 插件，其实就是提供一些常用的 git 命令别名。

- [web-search](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/web-search)，命令行打开搜索引擎，已支持大部分搜索引擎；

- [jsontools](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/jsontools)，用于格式化 json 数据；

- [z](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/z)，基于历史访问目录的快速跳转；

- [vi-mode](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/vi-mode)，使用 vi 模式编辑命令行；

  启用所有插件，打开 `zshrc` 配置，把这些内置插件都打开，如下所示：

  ```sh
  plugins=(git web-search jsontools z vi-mode)
  ```

### 三方插件

我们再来了解 2 个非 oh-my-zsh 内置插件，即 zsh-syntax-highlighting 和 zsh-autosuggestions。这两个插件由 zsh 社区开发。

### 下载

下载命令如下所示：

```sh
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
```

配置到 zshrc

```shell
plugins=(git web-search jsontools z vi-mode zsh-syntax-highlighting zsh-autosuggestions)
```







## 解决字体问题

https://cloud.tencent.com/developer/article/1612798

```sh
# clone
git clone https://github.com/powerline/fonts.git --depth=1
# install
cd fonts
./install.sh
# clean-up a bit
cd ..
rm -rf fonts
```



需要item2配置一下，`Preferences -> Profiles -> Text`

勾选： Use-built-in-powerline-glyphs

font选： Monaco







## 参考

https://www.poloxue.com/posts/2023-10-16-zsh-themes-and-plugins/

https://cloud.tencent.com/developer/article/1612798