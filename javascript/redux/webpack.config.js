var webpack = require('webpack');

module.exports = {
  progress: true,
  color: true,
  devtool: 'source-map',
  entry: {
    app: './src/client.js'
    // without babel-core, express
  },
  output: {
    path: __dirname + '/assets/js',
    filename: 'bundle.js'
  },
  module: {
    loaders: [{
      test: /\.js$/,
      exclude: /node_modules/,
      loaders: ['babel-loader']
    }]
  }
}
