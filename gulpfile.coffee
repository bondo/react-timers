gulp = require 'gulp'
path = require 'path'
touch = require 'touch'
LessPluginCleanCSS = require 'less-plugin-clean-css'
webpack = require 'webpack'
WebpackDevServer = require 'webpack-dev-server'
webpackConfig = require './webpack.config'
webpackProductionConfig = require './webpack.production.config'

$ = require('gulp-load-plugins')()

gulp.task 'css', ->
    gulp.src 'src/styles/**/*.less'
    .pipe $.less plugins: [ new LessPluginCleanCSS advanced: true ]
    .on 'error', (err) -> $.util.log err
    .pipe gulp.dest './public'
    .pipe $.size()

gulp.task 'copy-assets', ->
    gulp.src ['assets/**', '!assets/**/*~']
    .pipe gulp.dest './public'
    .pipe $.size()

gulp.task 'webpack:build', ['css'], (cb) ->
    webpack webpackProductionConfig, (err, stats) ->
        throw new $.util.PluginError('webpack:build', err) if err
        $.util.log '[webpack:build]', stats.toString colors: true
        cb()
        return

devCompiler = webpack webpackConfig
gulp.task 'webpack:build-dev', ['css'], (cb) ->
    devCompiler.run (err, stats) ->
        throw new $.util.PluginError('webpack:build-dev', err) if err?
        $.util.log '[webpack:build-dev]', stats.toString colors: true
        cb()
        return

devServer = {}
gulp.task 'webpack-dev-server', ['css'], (cb) ->
    touch.sync './public/main.css', time: new Date 0
    devServer = new WebpackDevServer devCompiler,
        contentBase: './public/'
        hot: true
        watchDelay: 100
        noInto: true
        quiet: true
    .listen 8080, '0.0.0.0', (err, result) ->
        throw new $.util.PluginError('webpack-dev-server', err) if err?
        $.util.log '[webpack-dev-server]', 'http://localhost:8080'
        cb()
    return

gulp.task 'default', ->
    gulp.start 'build'

gulp.task 'build', ['webpack:build', 'copy-assets']

gulp.task 'watch', ['css', 'copy-assets', 'webpack-dev-server'], ->
    gulp.watch ['src/styles/**'], ['css']
    gulp.watch ['assets/**'], ['copy-assets']
