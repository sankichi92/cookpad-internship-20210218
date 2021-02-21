export default {
  mode: 'development',
  entry: './ts/index.ts',
  output: {
    path: __dirname,
    filename: 'public/bundle.js',
  },
  module: {
    rules: [
      {
        test: /\.ts$/,
        loader: 'ts-loader',
      },
    ],
  },
  resolve: {
    extensions: ['.ts', '.js'],
  },
};
