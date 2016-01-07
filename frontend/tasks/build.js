var gulp = require('gulp');
var watch = require('gulp-watch');
var batch = require('gulp-batch');
var shell = require('shelljs');

gulp.task('watch', function () {

  watch([
    './frontend/**/*',
    '!./frontend/.tmp/**/*',
    '!./frontend/tasks/**/*',
  ], batch(function (events, done) {
      gulp.start('debug', done);
  }));

});

gulp.task('copy-fonts-and-images', ['copy-fonts', 'copy-images']);

gulp.task('debug', ['css:debug', 'js:debug', 'copy-fonts-and-images'], function (done) {
  console.log('\n\t--- DONE DEBUG BUILD ---\n');
  done();
});

gulp.task('deploy', ['css:deploy', 'js:deploy', 'copy-fonts-and-images'], function (done) {
  console.log('\n\t--- DONE DEPLOY BUILD ---\n');

  var host = process.env.host || '10.0.2.180';
  var password = process.env.remote_password || 'chaipcr';
  var command = "remote_password=" + password + " ./deploy.sh " + host;

  console.log('Running command: ' + command.replace(password, '*******'));
  console.log('\nPress Ctrl+C to cancel deploy.sh\n');
  shell.exec(command, {async:true, silent: false}, function () {
    console.info('\n\ngulp deploy options:\n');
    console.info('\tcsshash= hash of existing remote css (will replace remote file)\n');
    console.info('\tjshash= hash of existing remote js (will replace remote file)\n');
    console.info('\tremote_password= password to be passed to ./deploy.sh script, default `chaipcr`\n');
    console.info('\thost= IP address of remote host, default `10.0.2.180`\n');
    console.info('\tstripdebug= true/false whether to remove console.log statements or not, default `true`\n');
    console.info('\tExample: csshash=e4967a23c76ea10339d8f2fc0b57b0 jshash=e4967a23c76ea10339d8f2fc0b57b0 host=10.0.2.180 remote_password=chaipcr gulp deploy\n\n');
    done();
  });
});

gulp.task('default', ['debug']);
