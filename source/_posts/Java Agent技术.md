---
旋转数组的最小数字旋转数组的最小数字title: Java-Agent技术
date: 2019-7-8 13:22:54
tags: [分布式]

---

## Java agent是什么？

Java agent是java命令的一个参数。参数 javaagent 可以用于指定一个 jar 包。

	 1.	 这个 jar 包的 MANIFEST.MF 文件必须指定 Premain-Class 项。
  	 2.	 Premain-Class 指定的那个类必须实现 premain() 方法。

当Java 虚拟机启动时，在执行 main 函数之前，JVM 会先运行 -javaagent 所指定 jar 包内 Premain

Class 这个类的 premain 方法 。



## 如何使用Java agent

使用 java agent 需要几个步骤：

1. 定义一个 MANIFEST.MF 文件，必须包含 Premain-Class 选项，通常也会加入Can-Redefifine

Classes 和 Can-Retransform-Classes 选项。

2. 创建一个Premain-Class 指定的类，类中包含 premain 方法，方法逻辑由用户自己确定。

3. 将 premain 的类和 MANIFEST.MF 文件打成 jar 包。

4. 使用参数 -javaagent: jar包路径 启动要代理的方法。



