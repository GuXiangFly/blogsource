---
title: Webpack 学习总结
date: 2017-7-27 20:09:04
tags: [webpack,前端]

---



``` ecmascript 6
const path = require('path');
module.exports = {
    entry: './src/entry',
    output: {
        filename: 'bundle.js',
        path: path.resolve(__dirname, 'dist/boudle.js')
    }
}
```

url-loader 将会对小于8kb的图片进行打包处理