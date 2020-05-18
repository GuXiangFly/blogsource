---
title: Numpy学习
date: 2017-11-1 13:22:54
tags: [MongoDB,java]

---

## ndarray 多维数组(N Dimension Array)

###### NumPy数组是一个多维的数组对象（矩阵），称为`ndarray`，具有矢量算术运算能力和复杂的广播能力，并具有执行速度快和节省空间的特点。

#### **注意：ndarray的下标从0开始，且数组里的所有元素必须是相同类型**

#### ndarray拥有的属性

1. `ndim属性`：维度个数
2. `shape属性`：维度大小
3. `dtype属性`：数据类型

> ## ndarray的随机创建
>
> 通过随机抽样 (numpy.random) 生成随机数据。

示例代码：

```python
# 导入numpy，别名np
import numpy as np

# 生成指定维度大小（3行4列）的随机多维浮点型数据（二维），rand固定区间0.0 ~ 1.0
arr = np.random.rand(3, 4)
print(arr)
print(type(arr))

# 生成指定维度大小（3行4列）的随机多维整型数据（二维），randint()可以指定区间（-1, 5）
arr = np.random.randint(-1, 5, size = (3, 4)) # 'size='可省略
print(arr)
print(type(arr))

# 生成指定维度大小（3行4列）的随机多维浮点型数据（二维），uniform()可以指定区间（-1, 5）
arr = np.random.uniform(-1, 5, size = (3, 4)) # 'size='可省略
print(arr)
print(type(arr))

print('维度个数: ', arr.ndim)
print('维度大小: ', arr.shape)
print('数据类型: ', arr.dtype)
```

运行结果：

```python
[[ 0.09371338  0.06273976  0.22748452  0.49557778]
 [ 0.30840042  0.35659161  0.54995724  0.018144  ]
 [ 0.94551493  0.70916088  0.58877255  0.90435672]]
<class 'numpy.ndarray'>

[[ 1  3  0  1]
 [ 1  4  4  3]
 [ 2  0 -1 -1]]
<class 'numpy.ndarray'>

[[ 2.25275308  1.67484038 -0.03161878 -0.44635706]
 [ 1.35459097  1.66294159  2.47419548 -0.51144655]
 [ 1.43987571  4.71505054  4.33634358  2.48202309]]
<class 'numpy.ndarray'>

维度个数:  2
维度大小:  (3, 4)
数据类型:  float64
```

> ## ndarray的序列创建

#### 1. `np.array(collection)`

> collection 为 序列型对象(list)、嵌套序列对象(list of list)。

示例代码：

```python
# list序列转换为 ndarray
lis = range(10)
arr = np.array(lis)

print(arr)            # ndarray数据
print(arr.ndim)        # 维度个数
print(arr.shape)    # 维度大小

# list of list嵌套序列转换为ndarray
lis_lis = [range(10), range(10)]
arr = np.array(lis_lis)

print(arr)            # ndarray数据
print(arr.ndim)        # 维度个数
print(arr.shape)    # 维度大小
```

运行结果：

```python
# list序列转换为 ndarray
[0 1 2 3 4 5 6 7 8 9]
1
(10,)

# list of list嵌套序列转换为 ndarray
[[0 1 2 3 4 5 6 7 8 9]
 [0 1 2 3 4 5 6 7 8 9]]
2
(2, 10)
```

#### 2. `np.zeros()`

> 指定大小的全0数组。注意：第一个参数是元组，用来指定大小，如(3, 4)。

#### 3. `np.ones()`

> 指定大小的全1数组。注意：第一个参数是元组，用来指定大小，如(3, 4)。

#### 4. `np.empty()`

> 初始化数组，不是总是返回全0，有时返回的是未初始的随机值（内存里的随机值）。

示例代码（2、3、4）：

```python
# np.zeros
zeros_arr = np.zeros((3, 4))

# np.ones
ones_arr = np.ones((2, 3))

# np.empty
empty_arr = np.empty((3, 3))

# np.empty 指定数据类型
empty_int_arr = np.empty((3, 3), int)

print('------zeros_arr-------')
print(zeros_arr)

print('\n------ones_arr-------')
print(ones_arr)

print('\n------empty_arr-------')
print(empty_arr)

print('\n------empty_int_arr-------')
print(empty_int_arr)
```

运行结果：

```python
------zeros_arr-------
[[ 0.  0.  0.  0.]
 [ 0.  0.  0.  0.]
 [ 0.  0.  0.  0.]]

------ones_arr-------
[[ 1.  1.  1.]
 [ 1.  1.  1.]]

------empty_arr-------
[[ 0.  0.  0.]
 [ 0.  0.  0.]
 [ 0.  0.  0.]]

------empty_int_arr-------
[[0 0 0]
 [0 0 0]
 [0 0 0]]
```

#### 5. `np.arange()` 和 `reshape()`

> arange() 类似 python 的 range() ，创建一个一维 ndarray 数组。
>
> reshape() 将 重新调整数组的维数。

示例代码（5）：

```python
# np.arange()
arr = np.arange(15) # 15个元素的 一维数组
print(arr)
print(arr.reshape(3, 5)) # 3x5个元素的 二维数组
print(arr.reshape(1, 3, 5)) # 1x3x5个元素的 三维数组
```

运行结果：

```python
[ 0  1  2  3  4  5  6  7  8  9 10 11 12 13 14]

[[ 0  1  2  3  4]
 [ 5  6  7  8  9]
 [10 11 12 13 14]]

[[[ 0  1  2  3  4]
  [ 5  6  7  8  9]
  [10 11 12 13 14]]]
```

#### 6. `np.arange()` 和 `random.shuffle()`

> random.shuffle() 将打乱数组序列（类似于洗牌）。

示例代码（6）：

```python
arr = np.arange(15)
print(arr)

np.random.shuffle(arr)
print(arr)
print(arr.reshape(3,5))
```

运行结果：

```python
[ 0  1  2  3  4  5  6  7  8  9 10 11 12 13 14]

[ 5  8  1  7  4  0 12  9 11  2 13 14 10  3  6]

[[ 5  8  1  7  4]
 [ 0 12  9 11  2]
 [13 14 10  3  6]]
```

> ## ndarray的数据类型

#### 1. `dtype`参数

> 指定数组的数据类型，类型名+位数，如float64, int32

#### 2. `astype`方法

> 转换数组的数据类型

示例代码（1、2）：

```python
# 初始化3行4列数组，数据类型为float64
zeros_float_arr = np.zeros((3, 4), dtype=np.float64)
print(zeros_float_arr)
print(zeros_float_arr.dtype)

# astype转换数据类型，将已有的数组的数据类型转换为int32
zeros_int_arr = zeros_float_arr.astype(np.int32)
print(zeros_int_arr)
print(zeros_int_arr.dtype)
```

运行结果：

```python
[[ 0.  0.  0.  0.]
 [ 0.  0.  0.  0.]
 [ 0.  0.  0.  0.]]
float64

[[0 0 0 0]
 [0 0 0 0]
 [0 0 0 0]]
int32
```



## ndarray的矩阵运算
>
> 数组是编程中的概念，矩阵、矢量是数学概念。
>
> 在计算机编程中，矩阵可以用数组形式定义，矢量可以用结构定义!

#### 1. 矢量运算：相同大小的数组间运算应用在元素上

示例代码（1）：

```python
# 矢量与矢量运算
arr = np.array([[1, 2, 3],
                [4, 5, 6]])

print("元素相乘：")
print(arr * arr)

print("矩阵相加：")
print(arr + arr)
```

运行结果：

```python
元素相乘：
[[ 1  4  9]
 [16 25 36]]

矩阵相加：
[[ 2  4  6]
 [ 8 10 12]]
```

#### 2. 矢量和标量运算："广播" - 将标量"广播"到各个元素

- 广播机制

  - 1. 数组的某一维度等长

    2. 或： 其中一个数组的某一长度为1

       ![image-20200417165634819](/Users/mtdp/Library/Application Support/typora-user-images/image-20200417165634819.png)

示例代码（2）：

```python
# 矢量与标量运算
print(1. / arr)
print(2. * arr)
```

运行结果：

```python
[[ 1.          0.5         0.33333333]
 [ 0.25        0.2         0.16666667]]

[[  2.   4.   6.]
 [  8.  10.  12.]]
```



> ## ndarray的索引与切片

#### 1. 一维数组的索引与切片

> 与Python的列表索引功能相似

示例代码（1）：

```python
# 一维数组
arr1 = np.arange(10)
print(arr1)
print(arr1[2:5])
```

运行结果：

```python
[0 1 2 3 4 5 6 7 8 9]
[2 3 4]
```

#### 2. 多维数组的索引与切片：

> arr[r1:r2, c1:c2]
>
> arr[1,1] 等价 arr[1][1]
>
> [:] 代表某个维度的数据

示例代码（2）：

```python
# 多维数组
arr2 = np.arange(12).reshape(3,4)
print(arr2)

print(arr2[1])

print(arr2[0:2, 2:])

print(arr2[:, 1:3])
```

运行结果：

```python
[[ 0  1  2  3]
 [ 4  5  6  7]
 [ 8  9 10 11]]

[4 5 6 7]

[[2 3]
 [6 7]]

[[ 1  2]
 [ 5  6]
 [ 9 10]]
```

#### 3. 条件索引

> 布尔值多维数组：arr[condition]，condition也可以是多个条件组合。
>
> 注意，多个条件组合要使用 **& |** 连接，而不是Python的 **and or**。

示例代码（3）：

```python
# 条件索引

# 找出 data_arr 中 2005年后的数据
data_arr = np.random.rand(3,3)
print(data_arr)

year_arr = np.array([[2000, 2001, 2000],
                     [2005, 2002, 2009],
                     [2001, 2003, 2010]])

is_year_after_2005 = year_arr >= 2005
print(is_year_after_2005, is_year_after_2005.dtype)

filtered_arr = data_arr[is_year_after_2005]
print(filtered_arr)

#filtered_arr = data_arr[year_arr >= 2005]
#print(filtered_arr)

# 多个条件
filtered_arr = data_arr[(year_arr <= 2005) & (year_arr % 2 == 0)]
print(filtered_arr)
```

运行结果：

```python
[[ 0.53514038  0.93893429  0.1087513 ]
 [ 0.32076215  0.39820313  0.89765765]
 [ 0.6572177   0.71284822  0.15108756]]

[[False False False]
 [ True False  True]
 [False False  True]] bool

[ 0.32076215  0.89765765  0.15108756]

#[ 0.32076215  0.89765765  0.15108756]

[ 0.53514038  0.1087513   0.39820313]
```

## ndarray的维数转换

> 二维数组直接使用转换函数：transpose()
>
> 高维数组转换要指定维度编号参数 (0, 1, 2, …)，注意参数是元组

示例代码：

```python
arr = np.random.rand(2,3)    # 2x3 数组
print(arr)    
print(arr.transpose()) # 转换为 3x2 数组


arr3d = np.random.rand(2,3,4) # 2x3x4 数组，2对应0，3对应1，4对应3
print(arr3d)
print(arr3d.transpose((1,0,2))) # 根据维度编号，转为为 3x2x4 数组
```

运行结果：

```python
# 二维数组转换
# 转换前：
[[ 0.50020075  0.88897914  0.18656499]
 [ 0.32765696  0.94564495  0.16549632]]

# 转换后：
[[ 0.50020075  0.32765696]
 [ 0.88897914  0.94564495]
 [ 0.18656499  0.16549632]]


# 高维数组转换
# 转换前：
[[[ 0.91281153  0.61213743  0.16214062  0.73380458]
  [ 0.45539155  0.04232412  0.82857746  0.35097793]
  [ 0.70418988  0.78075814  0.70963972  0.63774692]]

 [[ 0.17772347  0.64875514  0.48422954  0.86919646]
  [ 0.92771033  0.51518773  0.82679073  0.18469917]
  [ 0.37260457  0.49041953  0.96221477  0.16300198]]]

# 转换后：
[[[ 0.91281153  0.61213743  0.16214062  0.73380458]
  [ 0.17772347  0.64875514  0.48422954  0.86919646]]

 [[ 0.45539155  0.04232412  0.82857746  0.35097793]
  [ 0.92771033  0.51518773  0.82679073  0.18469917]]

 [[ 0.70418988  0.78075814  0.70963972  0.63774692]
  [ 0.37260457  0.49041953  0.96221477  0.16300198]]]
```



#### 索引切片总结

```python
import numpy as np

arr2 = np.arange(48).reshape(6, 8)
print(arr2)

print("=====取出第2行")

print(arr2[[1], :])
"等于"
print(arr2[[1]])
"约等于：arr2[1]  这种会展示为一维数组 "
print(arr2[1])

print("=====取出第1， 3行")
print(arr2[[0, 2], :])

print("=====取出所有行的 1,3列")
print(arr2[:, [1, 2]])

print("=====取出第2行到第4行 ，第 1到第3列")
print(arr2[1:4, 0:3])

print("=====取出(0,3) ,(1,2) ,(4,4) 这3个点的值")
print(arr2[[0, 1, 4], [3, 2, 4]])

```

