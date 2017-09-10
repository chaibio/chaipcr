var gulp = require('gulp');
var templateCache = require('gulp-angular-templatecache');
var htmlmin = require('gulp-html-minifier');
var concat = require('gulp-concat');
var coffee = require('gulp-coffee');
var jshint = require('gulp-jshint');
var babel = require('gulp-babel');
var rename = require('gulp-rename');
var replace = require('gulp-replace');
var uglify = require('gulp-uglify');
var insert = require('gulp-insert');
var gutil = require('gulp-util');
var stripDebug = require('gulp-strip-debug');
var stripComment = require('gulp-strip-comments');
var del = require('del');
var _makeHash = require('./helpers').makeHash;
var swallowError = require('./helpers').swallowError;
var debug;
var applicationDebugJS = 'application-debug';
var applicationTmpJS = 'application-tmp';
var applicationJS;

var vendorFiles = [
  'libs/jquery-1.10.1.min.js',
  'libs/jquery-ui.min.js',
  'libs/angular.js',
  'libs/angular-animate.js',
  'libs/angular-resource.js',
  'libs/angular-cookies.min.js',
  'libs/perfect-scrollbar.jquery.min.js',
  'libs/angular-perfect-scrollbar.js',
  'libs/slider.js',
  'libs/angular-ui-switch.js',
  'libs/ui-bootstrap-tpls-0.14.3.js',
  'libs/angular-ui-router.js',
  'libs/moment.js',
  'libs/angular-moment.min.js',
  'libs/lodash.min.js',
  'libs/fabric.js',
  'libs/d3.v4.min.js',
  'libs/ng-focus-on.js',
  'libs/http-auth-interceptor.js',
  'libs/http-response-interceptor.js',
  'libs/jstorage.js',
  'libs/spin.min.js',
  'libs/ladda.min.js',
  'libs/angular-ladda.min.js',
  'libs/rainbowvis.js',
  'libs/ellipsis-animated.js',
  'libs/ng-file-upload-shim.js',
  'libs/ng-file-upload.js',
  'libs/ng-webworker.js',
];
var appFiles = [
  'welcome.js',
  'login.js',
  'app/charts/**/*.js',
  'app/canvas-app.js',
  'app/app.js',
  'app/config.js',
  'app/routes.js',
  'app/controllers/**/*.js',
  'app/services/**/*.js',
  'app/directives/**/*.js',
  'app/views/**/*.js',
  'app/canvas/**/*.js',
  'app/filters/**/*.js',
  'dynexp/_libs/**/*.js',
  'dynexp/optical_cal/**/*.js',
  'dynexp/dual_channel_optical_cal_v2/**/*.js',
  'dynexp/optical_test_single_channel/**/*.js',
  'dynexp/optical_test_dual_channel/**/*.js',
  'dynexp/thermal_consistency/**/*.js',
  'dynexp/thermal_performance_diagnostic/**/*.js',
  'dynexp/pika_test/**/*.js',
  'dynexp/dynexp.module.js',
  'templates.js',
];

function _renameJS(path) {
  path.basename = path.basename.replace('.js.coffee', '');
  path.basename = path.basename.replace('.js.es6', '');
  path.basename = path.basename.replace('.js', '');
  path.extname = '.js';
}

gulp.task('set-js-debug', function(done) {
  debug = true;
  done();
});

gulp.task('set-js-deploy', function(done) {
  debug = false;
  done();
});

gulp.task('clean-js', function(done) {
  del([
    '/tmp/chaipcr/js/**/*',
    'web/public/javascripts/**/*'
  ], {force: true}).then(function() {
    done();
  });
});

gulp.task('coffee', ['clean-js'], function() {
  return gulp.src(['frontend/javascripts/**/*.coffee'])
    .pipe(coffee())
    .on('error', swallowError)
    .pipe(rename(_renameJS))
    .pipe(stripComment())
    .pipe(insert.transform(function(contents, file) {
      return '// start of file: ' + file.history[0] + '\n' + contents + '\n// end of file: ' + file.history[0] + '\n';
    }))
    .pipe(gulp.dest('/tmp/chaipcr/js'))
    .on('error', gutil.log);
});

gulp.task('es6', ['clean-js'], function() {
  // console.log("Testing es6");
  return gulp.src(['frontend/javascripts/**/*.es6'])
    .pipe(babel({
      presets: ['es2015']
    }))
    .on('error', swallowError)
    .pipe(rename(_renameJS))
    .pipe(gulp.dest('/tmp/chaipcr/js'))
    .on('error', gutil.log);
});

gulp.task('templates', function() {
  return gulp.src(['./frontend/javascripts/**/*.html'])
    .pipe(htmlmin({
      collapseWhitespace: true,
      removeComments: true,
      removeRedundantAttributes: true
    }))
    .on('error', swallowError)
    .pipe(templateCache({
      module: 'templates',
      standalone: true
    }))
    // .on('error', swallowError)
    .pipe(gulp.dest('/tmp/chaipcr/js'));
});

gulp.task('copy-js-to-tmp', ['clean-js', 'templates'], function() {
  return gulp.src(['frontend/javascripts/**/*.js'])
    .pipe(rename(_renameJS))
    .pipe(stripComment())
    .pipe(insert.transform(function(contents, file) {
      return '// start of file: ' + file.history[0] + '\n' + contents + '\n// end of file: ' + file.history[0] + '\n';
    }))
    .pipe(gulp.dest('/tmp/chaipcr/js'));
});

// gulp.task('jslint', ['clean-js', 'coffee', 'es6', 'copy-js-to-tmp', 'templates'], function() {
gulp.task('jslint', [], function() {

  return gulp.src([
      './frontend/javascripts/app/**/*.js',
      './frontend/javascripts/dynexp/**/*.js',
    ])
    .pipe(jshint())
    .pipe(jshint.reporter('default'));
});

gulp.task('concat-js', ['jslint', 'clean-js', 'es6', 'coffee', 'copy-js-to-tmp', 'templates'], function() {
  var files = vendorFiles.concat(appFiles);

  for (var i = files.length - 1; i >= 0; i--) {
    files[i] = '/tmp/chaipcr/js/' + files[i];
  };

  return gulp.src(files)
    .pipe(concat(applicationTmpJS + '.js'))
    .pipe(gulp.dest('/tmp/chaipcr/js'));

});

gulp.task('hash-js', ['concat-js'], function() {
  var hash = process.env.jshash || _makeHash();

  return gulp.src('/tmp/chaipcr/js/' + applicationTmpJS + '.js')
    .pipe(rename(function(path) {
      path.basename = debug ? applicationDebugJS : 'application-' + hash;
      applicationJS = path.basename;
    }))
    .pipe(gulp.dest('/tmp/chaipcr/js'));

});

gulp.task('uglify', ['concat-js', 'hash-js'], function() {
  var isDebug = process.env.debug === 'true';
  var stream = gulp.src('/tmp/chaipcr/js/' + applicationJS + '.js');

  if (!isDebug) {
    stream.pipe(uglify({
        mangle: {
          except: ['notify', 'complete', '_transferable_']
        }
      }))
      .on('error', swallowError)
      .pipe(stripDebug())
      .on('error', swallowError);
  }

  stream.pipe(gulp.dest('/tmp/chaipcr/js'));

  return stream;

});

gulp.task('markup-js-link', ['hash-js'], function() {
  var pattern = /src=\"\/javascripts\/application((.*)?)\.js\"/;
  var replacement = 'src="/javascripts/' + applicationJS + '.js"';

  return gulp.src('./web/app/views/**/*.html.erb')
    .pipe(replace(pattern, replacement))
    .pipe(gulp.dest('./web/app/views'));
});

gulp.task('js:debug', ['set-js-debug', 'concat-js', 'markup-js-link'], function() {
  return gulp.src('/tmp/chaipcr/js/' + applicationJS + '.js')
    .pipe(gulp.dest('./web/public/javascripts'));
});

gulp.task('js:deploy', ['set-js-deploy', 'uglify', 'markup-js-link'], function() {
  return gulp.src('/tmp/chaipcr/js/' + applicationJS + '.js')
    .pipe(gulp.dest('./web/public/javascripts'));
});


// NOTE: Make sure VPN is connected and sshpass is installed on your system
// Usage:
//
//       host=10.0.2.199 jshash=fcf0da2a986a77c49089c356075f71 user=root password=chaipcr gulp js:upload
//
// where hash is the remote hash of application-[hash].js file
var shell = require('shelljs');
gulp.task('js:upload', ['uglify'], function(done) {
  var host = process.env.host || '10.0.2.175';
  var user = process.env.user || 'root';
  var password = process.env.password || 'chaipcr';
  var file = '/tmp/chaipcr/js/' + applicationJS + '.js';
  var _hash_ = process.env.jshash || '19a06cc94d11d2e154e5d3e4494a80';
  var remote_file = '/root/chaipcr/web/public/javascripts/application-' + _hash_ + '.js';
  var command = 'sshpass -p \'' + password + '\' scp ' + file + ' ' + user + '@' + host + ':' + remote_file;
  console.log('Running: \n' + command.replace(password, '*******'));

  shell.exec(command, { async: true, silent: true }, done);

});
