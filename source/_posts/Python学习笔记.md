---
title: Python学习笔记
date: 2017-7-27 20:09:04
tags: [python]
---
##  __name__ 属性

## python中的包
概念
- 包 是一个 包含多个模块 的 特殊目录
- 目录下有一个 特殊的文件 ``__init__.py``
- 包名的 命名方式 和变量名一致，小写字母 + _









### PIP使用逻辑

- pip install <包名>  安装指定的包
- pip uninstall <包名>删除指定的包
- pip list  显示已经安装的包
- pip freeze  显示已经安装的包，并且以指定的格式显示





## pip insta11 包名 -i 国内源地址
示例:
``pip install ipython -i https://pypi.mirrors.ustc.edu.cn/simple/``

就是从中国科技大学(ustc)的服务器上下载requests(基于python的第三方web框架)国内常用的pip下载源列表:
阿里云http://mirrors.aliyun.com/pypi/simple/

- 中国科技大学 https://pypi.mirrors.ustc.edu.cn/simple/
- 豆瓣(douban) http://pypi.douban.com/simple/
- 清华大学 https://pypi.tuna.tsinghua.edu.cn/simple/
- 中国科学技术大学 http://pypi.mirrors.ustc.edu.cn/simple