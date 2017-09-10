var gulp = require('gulp');
var del = require('del');
var sass = require('gulp-sass');
var concat = require('gulp-concat');
var cssnano = require('gulp-cssnano');
var rename = require('gulp-rename');
var replace = require('gulp-replace');
var insert = require('gulp-insert');
var makeHash = require('./helpers').makeHash;
var applicationTmpCSS = 'application-tmp';
var applicationDebugCss = 'application-debug';
var applicationCSS;
var debug;

gulp.task('set-css-debug', function (done) {
  debug = true;
  done();
});

gulp.task('set-css-deploy', function (done) {
  debug = false;
  done();
});

gulp.task('clean-css', function (done) {
  del(['/tmp/chaipcr/css/**/*', './web/public/stylesheets/**/*'], {force: true})
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
        })
        .on('error', sass.logError))
        .pipe(insert.transform(function (contents, file) {
          return '/* start of file: ' + file.history[0] + ' */\n' + contents + '\n/* end of file: ' + file.history[0] + ' */\n';
        }))
        .pipe(gulp.dest('/tmp/chaipcr/css'));
});

gulp.task('copy-css-tmp', ['clean-css'], function () {
  return gulp.src('./frontend/stylesheets/**/*.css')
             .pipe(insert.transform(function (contents, file) {
              return '/* start of file: ' + file.history[0] + ' */\n' + contents + '\n/* end of file: ' + file.history[0] + ' */\n';
             }))
             .pipe(gulp.dest('/tmp/chaipcr/css'));
});

gulp.task('concat-css', ['copy-css-tmp', 'sass'], function () {
  return gulp.src(['/tmp/chaipcr/css/**/*'])
         .pipe(concat(applicationTmpCSS+".css"))
         .pipe(gulp.dest('/tmp/chaipcr/css'));
});

gulp.task('hash-css', ['concat-css'], function () {

  var hash = process.env.csshash || makeHash();

  return gulp.src('/tmp/chaipcr/css/'+applicationTmpCSS+'.css')
         .pipe(rename(function (path) {
           path.basename = debug? applicationDebugCss : 'application-' + hash;
           applicationCSS = path.basename;
         }))
         .pipe(gulp.dest('/tmp/chaipcr/css'));
});

gulp.task('minify-css', ['concat-css', 'hash-css'], function () {
  var stream = gulp.src('/tmp/chaipcr/css/'+applicationCSS+'.css');
  if (process.env.debug !== 'true') {
    stream.pipe(cssnano({discardComments: {removeAll: true}}));
  }
  stream.pipe(gulp.dest('/tmp/chaipcr/css'));
  return stream;
});

gulp.task('markup-css-link', ['hash-css'], function () {
  var pattern = /href=\"\/stylesheets\/application(.*)\.css\"/;
  var replacement = 'href="/stylesheets/'+applicationCSS+'.css"';

  return gulp.src('./web/app/views/**/*.html.erb')
         .pipe(replace(pattern, replacement))
         .pipe(gulp.dest('./web/app/views'));
});

gulp.task('css:debug', ['copy-fonts-and-images', 'set-css-debug', 'clean-css', 'concat-css', 'markup-css-link'], function () {
  return gulp.src('/tmp/chaipcr/css/'+applicationCSS+'.css')
         .pipe(gulp.dest('./web/public/stylesheets'));
});

gulp.task('css:deploy', ['copy-fonts-and-images', 'set-css-deploy', 'clean-css', 'concat-css', 'minify-css', 'markup-css-link'], function () {
  return gulp.src('/tmp/chaipcr/css/'+applicationCSS+'.css')
         .pipe(gulp.dest('./web/public/stylesheets'));
});

// NOTE: Make sure VPN is connected and sshpass is installed on your system
// Usage:
//
//       host=10.0.2.199 csshash=fcf0da2a986a77c49089c356075f71 user=root password=chaipcr gulp css:upload
//
// where hash is the remote hash of application-[hash].js file
var shell = require('shelljs');
gulp.task('css:upload', ['minify-css'], function (done) {
  var host = process.env.host || '10.0.2.199';
  var user = process.env.user || 'root';
  var password = process.env.password || 'chaipcr';
  var file = '/tmp/chaipcr/css/'+applicationCSS+'.css';
  var _hash_ = process.env.csshash || '031a8120906bfcf9fa6281587c5be3';
  var remote_file = '/root/chaipcr/web/public/stylesheets/application-'+_hash_+'.css';
  var command = 'sshpass -p \''+password+'\' scp '+file+' '+user+'@'+host+':'+remote_file;
  console.log('Running: \n' + command.replace(password, '*******'));

  shell.exec(command, {async:true, silent: true}, done);

});
