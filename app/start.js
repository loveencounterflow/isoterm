/**
 * Copyright (c) 2018 The xterm.js authors. All rights reserved.
 * @license MIT
 *
 * This file is the entry point for browserify.
 */


/* ### TAINT use helper module with `require_from_xterm()` method */
const PATH          = require('path');
const xterm_path    = PATH.resolve( PATH.join( __dirname, '../xterm' ) );
const webpack_path  = require.resolve( 'webpack', { paths: [ xterm_path, ], } );
const webpack       = require( webpack_path );
const startServer   = require('./server.js');

startServer();

/**
 * This webpack config builds and watches the demo project. It works by taking the output from tsc
 * (via `yarn watch`) which is put into `out/` and then webpacks it into `demo/dist/`. The aliases
 * are used fix up the absolute paths output by tsc (because of `baseUrl` and `paths` in
 * `tsconfig.json`.
 *
 * For production builds see `webpack.config.js` in the root directory. If that is built the demo
 * can use that by switching out which `Terminal` is imported in `client.ts`, this is useful for
 * validating that the packaged version works correctly.
 */
const clientConfig = {
  entry: PATH.resolve(__dirname, 'client.ts'),
  devtool: 'inline-source-map',
  module: {
    rules: [
      {
        test: /\.tsx?$/,
        use: 'ts-loader',
        exclude: /node_modules/
      },
      {
        test: /\.js$/,
        use: ["source-map-loader"],
        enforce: "pre",
        exclude: /node_modules/
      }
    ]
  },
  resolve: {
    modules: [
      'node_modules',
      PATH.resolve(__dirname, '..'),
      PATH.resolve(__dirname, '../addons')
    ],
    extensions: [ '.tsx', '.ts', '.js' ],
    alias: {
      common: PATH.resolve('./out/common'),
      browser: PATH.resolve('./out/browser')
    },
    fallback: {
      // The ligature modules contains fallbacks for node environments, we never want to browserify them
      stream: false,
      util: false,
      os: false,
      path: false,
      fs: false
    }
  },
  output: {
    filename: 'client-bundle.js',
    path: PATH.resolve(__dirname, 'dist')
  },
  mode: 'development',
  watch: true
};
const compiler = webpack(clientConfig);

compiler.watch({
  // Example watchOptions
  aggregateTimeout: 300,
  poll: undefined
}, (err, stats) => {
  // Print watch/build result here...
  if ( err != null ) { throw err; /* new Error( err ) */ };
  process.send( { $key: '^webpack-ready' } );
  console.log(stats.toString({
    colors: true
  }));
});
