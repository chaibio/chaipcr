var gulp = require('gulp');
var del = require('del');
var sass = require('gulp-sass');
var concat = require('gulp-concat');
var minifyCss = require('gulp-minify-css');
var rename = require('gulp-rename');
var replace = require('gulp-replace');
var makeHash = require('./helpers').makeHash;
var hash;

gulp.task('clean-css', function (done) {
  del(['./frontend/.tmp/css/**/*', './web/public/stylesheets/**/*'])
  .then(function () {done();});
});

gulp.task('sass', ['clean-css'], function () {
  return gulp.src('./frontend/stylesheets/**/*.scss')
        .pipe(rename(function (path) {
          path.basename = path.basename.replace('.css.scss', '');
          path.basename = path.basename.replace('.css', '');
        }))
        .pipe(sass({
          includePaths: ['./frontend/stylesheets']
        }).on('error', sass.logError))
        .pipe(gulp.dest('./frontend/.tmp/css'));
});

gulp.task('copy-css-tmp', ['clean-css'], function () {
  return gulp.src('./frontend/stylesheets/**/*.css')
         .pipe(gulp.dest('./frontend/.tmp/css'));
});

gulp.task('concat-css', ['copy-css-tmp', 'sass'], function () {
  return gulp.src(['./frontend/.tmp/css/**/*'])
         .pipe(concat("application.css"))
         .pipe(gulp.dest('./frontend/.tmp/css'));
});

gulp.task('minify-css', ['concat-css', 'hash-css'], function () {
  return gulp.src('./frontend/.tmp/css/application-'+hash+'.css')
         .pipe(minifyCss({keepSpecialComments: 0}))
         .pipe(gulp.dest('./frontend/.tmp/css'))
});

gulp.task('hash-css', ['concat-css'], function () {

  hash = makeHash();

  return gulp.src('./frontend/.tmp/css/application.css')
         .pipe(rename(function (path) {
           path.basename = path.basename + '-' + hash;
         }))
         .pipe(gulp.dest('./frontend/.tmp/css'));
});

gulp.task('markup-css-link', ['hash-css'], function () {
  var pattern = /href=\"\/stylesheets\/application-(.*)\.css\"/;
  var replacement = 'href="/stylesheets/application-'+hash+'.css"';

  return gulp.src('./web/app/views/**/*.html.erb')
         .pipe(replace(pattern, replacement))
         .pipe(gulp.dest('./web/app/views'));
});

gulp.task('css:debug', ['clean-css', 'concat-css', 'markup-css-link'], function () {
  return gulp.src('./frontend/.tmp/css/application-'+hash+'.css')
         .pipe(gulp.dest('./web/public/stylesheets'));
});

gulp.task('css:deploy', ['clean-css', 'concat-css', 'minify-css', 'markup-css-link'], function () {
  return gulp.src('./frontend/.tmp/css/application-'+hash+'.css')
         .pipe(gulp.dest('./web/public/stylesheets'));
});