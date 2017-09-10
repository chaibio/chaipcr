var gulp = require('gulp');
var del = require('del');

gulp.task('clean-fonts', function (done) {
  del(['./web/public/fonts/**/*']).then(function () {
    done();
  });
});

gulp.task('copy-fonts', ['clean-fonts'], function () {
  return gulp.src('./frontend/fonts/**/*')
         .pipe(gulp.dest('./web/public/fonts'));
});
