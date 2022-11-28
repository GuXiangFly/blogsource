# Android学习





## WSA (windows subsystem Android)





## ADB学习

```
adb shell   #用于进入Android系统
```

```
exit  用于退出
```

```
adb install [apk路径]

adb install D:A.apk    

adb uninstall [安卓系统中应用的包名]
```



ADB 包管理 pm(package manager)

```
adb shell pm list package  #列出所以应用

adb shell pm list package -3  #列出自己安装的第三方


在Android系统中只需要执行  pm list package -3 

```

从Android里面下载东西到电脑

```
adb pull /system/framework/pm.jar   C:/Desptop
```

上传文件

```
adb push Desktop\111.txt  /system/framework
```



## 查看系统日志

```
adb logcat
```

