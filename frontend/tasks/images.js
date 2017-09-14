var gulp = require('gulp');
var del = require('del');

gulp.task('clean-images', function (done) {
  del(['./web/public/images/**/*']).then(function () {
    done();
  });
});

gulp.task('copy-images', ['clean-images'], function () {
  return gulp.src('./frontend/images/**/*')
         .pipe(gulp.dest('./web/public/images'));
});
