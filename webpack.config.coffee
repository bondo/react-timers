path = require 'path';
webpack = require 'webpack';

module.exports =
	entry: [
		'webpack-dev-server/client?http://0.0.0.0:8080'
		'webpack/hot/only-dev-server'
		'./src/scripts/main'
	]

	devtool: 'eval'
	debug: true

	output:
		path: path.join(__dirname, 'public')
		filename: 'bundle.js'

	resolveLoader: modulesDirectories: ['node_modules']

	plugins: [
		new webpack.HotModuleReplacementPlugin()
		new webpack.NoErrorsPlugin()
	]

	resolve: extensions: ['', '.js', '.coffee', '.cjsx']

	module:
		loaders: [
			{ test: /\.css$/, loaders: ['style', 'css'] }
			{ test: /\.cjsx$/, loaders: ['react-hot', 'coffee', 'cjsx'] }
			{ test: /\.coffee$/, loader: 'coffee' }
		]
