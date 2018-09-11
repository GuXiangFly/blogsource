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