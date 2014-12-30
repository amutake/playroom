var webpack = require('webpack');
var deps = Object.keys(require('./package.json').dependencies);

module.exports = {
  entry: {
    app: './src/index.jsx',
    vender: deps
  },
  output: {
    path: __dirname + '/public',
    filename: '[name].js',
    chunkFilename: '[name]-[id].js'
  },
  module: {
    loaders: [
      { test: /\.(js|jsx)$/, loader: 'jsx?harmony' }
    ]
  },
  resolve: {
    extensions: ['', '.js', '.jsx'],
  },
  plugins: [
    new webpack.optimize.CommonsChunkPlugin('vendor', null)
  ],
  watch: true,
  devtool: 'source-map'
}
