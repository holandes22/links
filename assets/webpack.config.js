var path = require("path");
var webpack = require("webpack");
var merge = require("webpack-merge");
var CopyWebpackPlugin = require("copy-webpack-plugin");
var ExtractTextPlugin = require("extract-text-webpack-plugin");


var common = {
  module: {
    rules: [
      {
        test: /\.js$/,
        exclude: [/node_modules/],
        use: [
          {
            loader: "babel-loader",
            options: {
              presets: ["babel-preset-env"]

            }
          }
        ]
      },
      {
        test: [/\.scss$/, /\.css$/],
        use: ExtractTextPlugin.extract({
          fallback: "style-loader",
          use: "css-loader!sass-loader"
        })
      },
      {
        test: /\.(png|jpg|gif|svg)$/,
        use: "file-loader?name=/images/[name].[ext]"
      },
      {
        test: /\.(ttf|eot|svg|woff2?)$/,
        use: "file-loader?name=/fonts/[name].[ext]",
      }
    ],
    noParse: [/\.elm$/]
  },
};

module.exports = [
  merge(common, {
    entry: {
      vendor: [
        "normalizecss/normalize.css",
        "font-awesome-loader",
        "semantic-ui-css/semantic.js",
        "semantic-ui-css/semantic.css"
      ],
      app: [
        "./css/app.scss",
        "./js/app.js"
      ]
    },
    output: {
      path: "../priv/static",
      filename: "js/[name].js"
    },
    resolve: {
      modules: [
        "node_modules",
        path.resolve(__dirname, "js"),
        path.resolve(__dirname, "css")
      ]
    },
    plugins: [
      new webpack.ProvidePlugin({
          $: "jquery",
          jQuery: "jquery",
          "window.jQuery": "jquery"
      }),
      new webpack.optimize.CommonsChunkPlugin({
        name: "vendor"
      }),
      new CopyWebpackPlugin([{ from: "./static" }]),
      new ExtractTextPlugin("css/[name].css")
    ]
  })
];
