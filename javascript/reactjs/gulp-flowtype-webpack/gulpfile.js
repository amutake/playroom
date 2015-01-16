var gulp = require('gulp');
var flowtype = require('gulp-flowtype');
var webpack = require('gulp-webpack');
var uglify = require('gulp-uglify');
var config = require('./webpack.config.js');

gulp.task('build', function() {
  return gulp.src('./src/index.js')
    .pipe(webpack(config))
    .pipe(uglify())
    .pipe(gulp.dest('./public/'));
});

gulp.task('server', function() {

});

gulp.task('default', ['build']);
