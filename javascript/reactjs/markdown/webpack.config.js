var webpack = require('webpack');
var deps = Object.keys(require('./package.json').dependencies);

module.exports = {
  entry: {
    app: './src/index.jsx',
    vendor: deps.concat(['bootstrap'])
  },
  output: {
    path: __dirname + '/public',
    filename: '[name].js',
    chunkFilename: '[name]-[id].js'
  },
  module: {
    loaders: [
      { test: /\.(js|jsx)$/, loader: 'jsx?harmony' },
      { test: /\.css$/, loader: 'style!css' },
      { test: /\.(woff|svg|ttf|eot)([\?]?.*)$/, loader: "file?name=[name].[ext]" }
    ]
  },
  resolve: {
    extensions: ['', '.js', '.jsx', '.css'],
    root: [__dirname + "/bower_components"]
  },
  plugins: [
    new webpack.optimize.CommonsChunkPlugin('vendor', null),
    new webpack.ResolverPlugin(
      new webpack.ResolverPlugin.DirectoryDescriptionFilePlugin("bower.json", ["main"])
    )
  ],
  watch: true,
  devtool: 'source-map'
}
