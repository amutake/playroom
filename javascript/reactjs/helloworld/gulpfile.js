var gulp = require('gulp');
var uglify = require('gulp-uglify');
var sourcemaps = require('gulp-sourcemaps');
var concat = require('gulp-concat');
var source = require('vinyl-source-stream');
var buffer = require('vinyl-buffer');
var browserify = require('browserify');
var reactify = require('reactify');
var debowerify = require('debowerify');

gulp.task('build', function() {
  var onError = function(err) {
    console.log(err);
    this.emit('end');
  };
  return browserify({entries: './src/main.js', debug: true})
    .transform(reactify)
    .transform(debowerify)
    .bundle()
    .on('error', onError)
    .pipe(source('bundle.js'))
    .pipe(buffer())
    .pipe(gulp.dest('build/'));
});

gulp.task('watch', function() {
  gulp.watch('src/**/*', ['build']);
});

gulp.task('default', ['build']);
