var gulp = require('gulp');
var concat = require('gulp-concat');
var coffee = require('gulp-coffee');
var rename = require('gulp-rename');
var gutil = require('gulp-util');
var del = require('del');

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
];

function _renameJS (path) {
  path.basename = path.basename.replace('.js.coffee.erb', '');
  path.basename = path.basename.replace('.js.coffee', '');
  path.basename = path.basename.replace('.js', '');
  path.extname  = '.js';
}

gulp.task('clean-js', function (done) {
  del(['frontend/.tmp/js/**/*', 'web/public/assets/javascripts/**/*']).then(function () {
    done();
  });
});

gulp.task('coffee', ['clean-js'], function () {
  return gulp.src(['frontend/javascripts/**/*.coffee', 'frontend/javascripts/**/*.coffee.erb'])
         .pipe(coffee({bare: true}))
         .pipe(rename(_renameJS))
         .pipe(gulp.dest('frontend/.tmp/js'))
         .on('error', gutil.log);
});

gulp.task('copy-js-to-tmp', ['clean-js'], function () {
  return gulp.src(['frontend/javascripts/**/*.js.erb', 'frontend/javascripts/**/*.js'])
         .pipe(rename(_renameJS))
         .pipe(gulp.dest('frontend/.tmp/js'));
});

gulp.task('concat-js', ['clean-js', 'coffee', 'copy-js-to-tmp'], function () {
  var files = vendorFiles.concat(appFiles);

  for (var i = files.length - 1; i >= 0; i--) {
    files[i] = './frontend/.tmp/js/' + files[i];
  };

  return gulp.src(files)
         .pipe(concat('application.js'))
         .pipe(gulp.dest('./web/public/assets/javascripts'));

});

gulp.task('js', ['concat-js']);