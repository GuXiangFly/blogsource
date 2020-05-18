---
title: OpenCV学习
date: 2017-11-1 13:22:54
tags: [OpenCV,python]

---





#####  获取颜色通道

```python
b,g,r=cv2.split(img)
```



##### 只保留某个颜色(opencv 中通道为 BGR)

```python
#%% 
# 只保留R #opencv中颜色
cur_img = img.copy()
cur_img[:,:,0] = 0
cur_img[:,:,1] = 0
cv_show('R',cur_img)
# 只保留G
cur_img = img.copy()
cur_img[:,:,0] = 0
cur_img[:,:,2] = 0
cv_show('G',cur_img)
#%%
# 只保留B
cur_img = img.copy()
cur_img[:,:,1] = 0
cur_img[:,:,2] = 0
cv_show('B',cur_img)

```







##### jupyter教程

按h键打开快捷键模板

- 模式
  - 蓝色为命令模式
    - enter回车    命令->编辑模式
  - 绿色为编辑模式
    - esc      编辑模式->命令模式
- shift + enter   运行当前代码块并且进入到下一个代码块（或者为渲染markdown）
- ctrl + enter  只运行当前代码块不进入下一个代码块
- alt+ enter     运行代码代码块并且在下方新建一个代码块
- 选中单元格
  -  按M 变为markdown
  -  按y 变成代码
  - 按 B （below） 在下方创建代码块
  - 按 A （above） 在上方创建代码块
  -  变为命令模式后按x可以剪切掉当前代码块





PPT 页面