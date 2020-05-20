---
title: MAC OS 开机启动项设置
date: 2017-8-27 20:09:04
tags: [前端]

---

Mac开机启动的配置与其他类Unix系统相比较麻烦，Linux配置rc.local文件即可。
 macOS系统上开机启动这个叫法不准确，应该叫“自启动”或者“登录时启动”。macOS上启动项可分为登陆项（Login Items）和启动项（Startup Items）。Login items在用户登录后立即启动并一直运行，直到用户退出登录或者手动终止才会停止运行。Startup items苹果官方不推荐再使用，Startup items在系统装载的最后阶段启动。详见[官方文档](https://link.jianshu.com?t=https%3A%2F%2Fdeveloper.apple.com%2Flibrary%2Fcontent%2Fdocumentation%2FMacOSX%2FConceptual%2FBPSystemStartup%2FChapters%2FIntroduction.html%23%2F%2Fapple_ref%2Fdoc%2Fuid%2F10000172i-SW1-SW1)。

下面简要介绍如何配置自启动项。

#### 使用登录项添加自启动项

这种方式支持有用户界面的程序。
 进入`设置`->`用户与群组`->`登录项`，点击+号找到想自动启动的软件，选择后按确定即可。

删除自启动项，重新进入`登录项`，选中目标项点击减号后确定即可。

### 使用launchctl工具添加启动项

从OS X 10.4 Tiger开始，Apple要求开发者使用[launch daemons and agents](https://link.jianshu.com?t=https%3A%2F%2Fdeveloper.apple.com%2Flibrary%2Fmac%2Fdocumentation%2FMacOSX%2FConceptual%2FBPSystemStartup%2FChapters%2FCreatingLaunchdJobs.html)配置自启动项，launch daemons和launch agents由launchd进程管理。launchd是macOS下用于初始化系统环境的关键进程，它是内核装载成功之后在OS环境下启动的第一个进程。采用这种方式来配置自启动项只需要一个plist文件，该plist文件存在于以下目录，各目录决定了其启动的先后和拥有的权限：
 `~/Library/LaunchAgents //特定用户登录后以当前用户启动，第三方程序一般都放这里`
 `/Library/LaunchAgents //任一用户登录后以当前用户启动，管理员使用`
 `/System/Library/LaunchAgents //系统组件，任一用户登录后以当前用户启动`
 `/Library/LaunchDaemons //系统装载时以root用户启动，管理员使用`
 `/System/Library/LaunchDaemons //系统组件，系统装载时以root用户启动`

目录区别：
 `/System/Library //存放Apple开发的系统组件。`
 `/Library //存放系统管理员安装的程序。`
 `~/Library //存放普通用户安装的程序。`

launch daemon和launch agents区别：
 它们本质上都是守护进程，launch daemons在系统装载时启动，属于所有用户；launch agents是某个用户拥有的程序，在这个用户登录后启动。

创建plist文件



```jsx
vi ~/Library/LaunchAgents/aria2.plist
```

写入以下xml



```xml
<?xml version="1.0"encoding="utf-8"?>
<!DOCTYPE plist PUBLIC"-//Apple//DTD PLIST 1.0//EN"
"http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
    <dict>
        <key>KeepAlive</key>
        <true/>
        <key>RunAtLoad</key>
        <true/>
        <key>Label</key>
        <string>aria2</string>
        <key>ProgramArguments</key>
        <array>
            <string>/usr/local/bin/aria2c</string>
            <string>-D</string>
        </array>
        <key>WorkingDirectory</key>
        <string>/Users/Roy/Downloads</string>
    </dict>
</plist>
```

键值说明见[launchd.plist(5)](https://link.jianshu.com/?t=https://developer.apple.com/legacy/library/documentation/Darwin/Reference/ManPages/man5/launchd.plist.5.html#//apple_ref/doc/man/5/launchd.plist)。

检查plist语法是否正确



```jsx
plutil ~/Library/LaunchAgents/aria2.plist 
```

修改[文件权限](https://link.jianshu.com?t=https%3A%2F%2Fss64.com%2Fbash%2Fchmod.html)



```jsx
chmod 644 ~/Library/LaunchAgents/aria2.plist
```

添加自启动项



```jsx
//launchctl工具提供了一系列接口方便使用launchd程序
launchctl load ~/Library/LaunchAgents/aria2.plist
```

启动自启动项



```undefined
launchctl start aria2
```

删除自启动项



```jsx
launchctl unload ~/Library/LaunchAgents/aria2.plist
```

查看当前所有自启动项



```cpp
launchctl list
```

#### Homebrew安装的程序可使用[Homebrew Services](https://link.jianshu.com?t=https%3A%2F%2Fgithub.com%2FHomebrew%2Fhomebrew-services)设置开机启动

设置开机启动



```cpp
brew services start mysql //如果用Homebrew安装了mysq：
```

只运行不开机启动



```undefined
brew services run mysql
```

停止运行不再开机启动(存疑，未验证）



```undefined
brew services stop mysql
```

注意Homebrew安装的程序不全都支持这种方式，如果命令执行失败，请手动配置plist文件，使用launchctl工具添加启动项。



作者：仰海的黑板报
链接：https://www.jianshu.com/p/eee8a7de179c
来源：简书
著作权归作者所有。商业转载请联系作者获得授权，非商业转载请注明出处。