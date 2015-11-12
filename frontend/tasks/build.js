var gulp = require('gulp');
var watch = require('gulp-watch');
var batch = require('gulp-batch');

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
  done();
});

gulp.task('default', ['debug']);
