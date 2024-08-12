const path = require('path');

module.exports = {
  entry: './app/assets/javascripts/application.js',
  output: {
    filename: 'bundle.js',
    path: path.resolve(__dirname, 'public', 'packs')
  },
  module: {
    rules: [
      {
        test: /\.js$/,
        exclude: /node_modules/,
        use: {
          loader: 'babel-loader',
        },
      },
      {
        test: /\.css$/,
        use: ['style-loader', 'css-loader'],
      },
    ],
  },
  // Adjust the node configuration
  node: {
    __dirname: false,
    __filename: false,
    global: true,
  },
};
