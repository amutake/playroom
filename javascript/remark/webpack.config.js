var webpack = require('webpack');

module.exports = {
  devtool: 'source-map',
  entry: {
    app: './index.js',
  },
  output: {
    path: __dirname,
    filename: 'bundle.js',
  },
  module: {
    loaders: [{
      test: /\.js$/,
      exclude: /(node_modules|bower_components)/,
      loader: 'babel-loader'
    }, {
      test: /\.json$/,
      loader: 'json-loader',
    }]
  },
};
