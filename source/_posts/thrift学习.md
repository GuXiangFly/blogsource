---
title: 并查集算法的实现与多种优化
date: 2017-7-27 20:09:04
tags: [数据结构与算法]

---
## 不做优化

这个是直接想插入哪个插入哪个



``` java
package com.guxiang.unionFind;

/**
 * UnionFindv2
 *
 * @author guxiang
 */
public class UnionFind{
    private static int[] id;

    private static int count;

    public UnionFind(int n){
        count =n;
        id = new int[n];
        for (int i = 0; i <n ; i++) {
            id[i]=i;
        }
    }

    public static int find(int p){
        return id[p];
    }

    public static boolean isConnected (int p,int q){
        return find(p)==find(q);
    }

    public static void unionElements (int p,int q){
        int pID = find(p);
        int qID = find(q);

        if (pID == qID){
            return;
        }

        /**
         * 如果想 p q 两个元素链接到一起，那么p q本身所链接的元素就要链接到一起
         */
        for (int i = 0; i <count ; i++) {
            if (id[i] ==pID)
                id[i] = qID;
        }
    }

    void testUF1(int n){
        UnionFind uf= new UnionFind(n);

        for (int i = 0; i <n ; i++) {
            int a = (int) Math.random()*n +1;
            int b = (int) Math.random()*n +1;
            uf.unionElements(a,b);
        }
        for (int i = 0; i <n ; i++) {
            int a = (int) Math.random()*n +1;
            int b = (int) Math.random()*n +1;
            uf.isConnected(a,b);
        }
    }

    @Test
    public void testUnionFind(){

    }
}

```

## 基于并查集的对size 的优化
``` java
package com.guxiang.unionFind;

/**
 * UnionFindv2
 *
 * @author guxiang
 */
public class UnionFindv2 {
    private int[] parent;
    private int count;

    /**
     * 构造函数 给并查集的数组赋初值赋初值
     * @param count
     */
    public  UnionFindv2(int count) {
         parent = new int[count];
         this.count = count;
        for (int i = 0; i <count ; i++) {
            parent[i] = i;
        }
    }

    public int find(int p){

        /**
         * 当 p 的值 等于 p的id  p的父元素是自己的时候 那么p就是根
         */
        while (p!=parent[p]){
            p=parent[p];
        }
        return p;
    }

    boolean isConnected(int p, int q){
        return find(p)==find(q);
    }


    /**
     * 合并
     * @param p
     * @param q
     */
    void unionElements(int p,int q){
        int pRoot = find(p);
        int qRoot = find(q);

        if (pRoot==qRoot){
            return;
        }
        parent[pRoot] = qRoot;
    }

    public static void main(String[] args) {

        int n = 10000000;

        UnionFindv2 uf2 = new UnionFindv2(n);


        //用于获取当前时间
        long startTime = System.currentTimeMillis();


        /**
         * 任选两个元素，将他们合并
         */
        for (int i = 0; i <n; i++) {
            int a = (int) Math.random()*n;
            int b = (int) Math.random()*n;
            uf2.unionElements(a,b);
        }

        /**
         * 任选两个元素，看他们是否链接
         */
        for (int i = 0; i <n; i++) {
            int a = (int) Math.random()*n;
            int b = (int) Math.random()*n;
            uf2.isConnected(a,b);
        }

        long endTime = System.currentTimeMillis();
        System.out.println("程序运行时间："+(endTime-startTime)+"ms");
    }
}

```

## 基于 树的高度的优化 rank  将矮的树并给高的树
``` java
package com.guxiang.unionFind;

/**
 * UnionFindv2
 *
 * @author guxiang
 * @date 2017/9/13
 */
public class UnionFindv3 {
    private int[] parent;

    /**
     * 用于记录每一个集合的高度，将高度低的指向高度高的
     */
    private int[] rank;
    private int count;

    /**
     * 构造函数 给并查集的数组赋初值赋初值
     * @param count
     */
    public UnionFindv3(int count) {
         parent = new int[count];
         rank = new int[count];
         this.count = count;
        for (int i = 0; i <count ; i++) {
            parent[i] = i;
            rank[i]=1;
        }
    }

    public int find(int p){

        /**
         * 当 p 的值 等于 p的id  p的父元素是自己的时候 那么p就是根
         */
        while (p!=parent[p]){
            p=parent[p];
        }
        return p;
    }

    boolean isConnected(int p, int q){
        return find(p)==find(q);
    }


    /**
     * 合并
     * @param p
     * @param q
     */
    void unionElements(int p,int q){
        int pRoot = find(p);
        int qRoot = find(q);

        if (pRoot==qRoot){
            return;
        }

        /**
         * 如果pRoot 比 qRoot高 那么 qRoot 移动过来不会增加树的高度
         */
        if (rank[pRoot] < rank[qRoot]){
            parent[pRoot] = qRoot;

            /**
             * 如果pRoot 比 qRoot矮 那么 qRoot 移动过来也不会增加树的高度
             */
        }else if (rank[qRoot] <rank[pRoot]){
            parent[qRoot] = pRoot;
        }
        /**
         * 如果pRoot 与 qRoot一样高  那么 qRoot 移动过来就会增加树的高度
         */
        else {
            parent[qRoot] = pRoot;
            rank[pRoot] +=1;
        }
    }

    public static void main(String[] args) {

        int n = 10000000;

        UnionFindv3 uf3 = new UnionFindv3(n);


        //用于获取当前时间
        long startTime = System.currentTimeMillis();


        /**
         * 任选两个元素，将他们合并
         */
        for (int i = 0; i <n; i++) {
            int a = (int) Math.random()*n;
            int b = (int) Math.random()*n;
            uf3.unionElements(a,b);
        }

        /**
         * 任选两个元素，看他们是否链接
         */
        for (int i = 0; i <n; i++) {
            int a = (int) Math.random()*n;
            int b = (int) Math.random()*n;
            uf3.isConnected(a,b);
        }

        long endTime = System.currentTimeMillis();
        System.out.println("程序运行时间："+(endTime-startTime)+"ms");
    }
}

```