var gulp = require('gulp');
var templateCache = require('gulp-angular-templatecache');
var concat = require('gulp-concat');
var coffee = require('gulp-coffee');
var rename = require('gulp-rename');
var replace = require('gulp-replace');
var uglify = require('gulp-uglify');
var gutil = require('gulp-util');
var del = require('del');
var _makeHash = require('./helpers').makeHash;
var hash;

var vendorFiles = [
  'app/libs/jquery-1.10.1.min.js',
  'app/libs/jquery-ui.min.js',
  'app/libs/angular.js',
  'app/libs/angular-resource.js',
  'app/libs/perfect-scrollbar.jquery.min.js',
  'app/libs/angular-perfect-scrollbar.js',
  'app/libs/slider.js',
  'app/libs/angular-ui-switch.js',
  'app/libs/ui-bootstrap-custom-0.13.0.js',
  'app/libs/ui-bootstrap-custom-tpls-0.13.0.js',
  'app/libs/angular-ui-router.js',
  'app/libs/moment.js',
  'app/libs/angular-moment.min.js',
  'app/libs/Chart.js',
  'app/libs/angular-chart.js',
  'app/libs/lodash.min.js',
  'app/libs/fabric.js',
  'app/libs/d3.js',
  'app/libs/n3-line-chart.js',
  'app/libs/ng-focus-on.js',
  'app/libs/http-auth-interceptor.js',
  'app/libs/jstorage.js',
];
var appFiles = [
  'welcome.js',
  'login.js',
  'app/app.js',
  'app/config.js',
  'app/routes.js',
  'app/controllers/**/*.js',
  'app/services/**/*.js',
  'app/directives/**/*.js',
  'app/views/**/*.js',
  'app/canvas/**/*.js',
  'app/filters/**/*.js',
  'templates.js',
];

function _renameJS (path) {
  path.basename = path.basename.replace('.js.coffee.erb', '');
  path.basename = path.basename.replace('.js.coffee', '');
  path.basename = path.basename.replace('.js', '');
  path.extname  = '.js';
}

gulp.task('clean-js', function (done) {
  del(['.tmp/js/**/*', 'web/public/javascripts/**/*']).then(function () {
    done();
  });
});

gulp.task('coffee', ['clean-js'], function () {
  return gulp.src(['frontend/javascripts/**/*.coffee', 'frontend/javascripts/**/*.coffee.erb'])
         .pipe(coffee({bare: true}))
         .pipe(rename(_renameJS))
         .pipe(gulp.dest('.tmp/js'))
         .on('error', gutil.log);
});

gulp.task('templates', function () {
  return gulp.src(['./frontend/javascripts/app/views/**/*.html', './frontend/javascripts/**/*html.erb'])
    .pipe(templateCache({
      module: 'templates',
      standalone: true,
      transformUrl: function(url) {
        return url.replace(/\.html\.erb$/, '.html')
      }
    }))
    .pipe(gulp.dest('./.tmp/js'));
});

gulp.task('copy-js-to-tmp', ['clean-js', 'templates'], function () {
  return gulp.src(['frontend/javascripts/**/*.js.erb', 'frontend/javascripts/**/*.js'])
         .pipe(rename(_renameJS))
         .pipe(gulp.dest('.tmp/js'));
});

gulp.task('concat-js', ['clean-js', 'coffee', 'copy-js-to-tmp', 'templates'], function () {
  var files = vendorFiles.concat(appFiles);

  for (var i = files.length - 1; i >= 0; i--) {
    files[i] = './.tmp/js/' + files[i];
  };

  return gulp.src(files)
         .pipe(concat('application.js'))
         .pipe(gulp.dest('./.tmp/js'));

});

gulp.task('uglify', ['concat-js', 'hash-js'], function () {
  return gulp.src('./.tmp/js/application-'+hash+'.js')
         .pipe(uglify())
         .pipe(gulp.dest('./.tmp/js'));
});

gulp.task('hash-js', ['concat-js'], function () {
  hash = _makeHash();

  return gulp.src('./.tmp/js/application.js')
         .pipe(rename(function (path) {
            path.basename = path.basename + '-' + hash;
         }))
         .pipe(gulp.dest('./.tmp/js'));

});

gulp.task('markup-js-link', ['hash-js'], function () {
  var pattern = /src=\"\/javascripts\/application-(.*)\.js\"/;
  var replacement = 'src="/javascripts/application-'+hash+'.js"';

  return gulp.src('./web/app/views/**/*.html.erb')
         .pipe(replace(pattern, replacement))
         .pipe(gulp.dest('./web/app/views'));
});

gulp.task('js:debug', ['concat-js', 'markup-js-link'], function () {
  return gulp.src('./.tmp/js/application-'+hash+'.js')
         .pipe(gulp.dest('./web/public/javascripts'));
});

gulp.task('js:deploy', ['uglify', 'markup-js-link'], function () {
  return gulp.src('./.tmp/js/application-'+hash+'.js')
         .pipe(gulp.dest('./web/public/javascripts'));
});