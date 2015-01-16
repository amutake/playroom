module.exports = {
  progress: true,
  color: true,
  watch: true,
  entry: './src/index.js',
  output: {
    filename: 'bundle.js'
  },
  resolve: {
    extensions: ['', '.js']
  },
  module: {
    loaders: [
      { test: /\.js$/, loader: 'jsx?harmony&stripTypes' }
    ]
  }
};
