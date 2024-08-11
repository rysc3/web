const { environment } = require('@rails/webpacker')
const path = require('path');

environment.toWebpackConfig().merge({
  entry: './app/javascript/packs/application.js',
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
});

module.exports = environment.toWebpackConfig();
