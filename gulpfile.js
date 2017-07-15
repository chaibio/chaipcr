// var requireDir = require('require-dir');
// var tasks = requireDir('./frontend/tasks');

const gulp = require('gulp')
const { exec } = require('child_process')

gulp.task('ng:build:debug', (done) => {
  process.chdir('./ng2')
  exec('ng build', (err, stdout, stderr) => {
    console.log(err)
    console.log(stdout)
    console.log(stderr)
    process.chdir('..')
    done()
  })
})

gulp.task('ng:build:deploy', (done) => {
  process.chdir('./ng2')
  exec('ng build --target=production', (err, stdout, stderr) => {
    console.log(err)
    console.log(stdout)
    console.log(stderr)
    process.chdir('..')
    done()
  })
})

gulp.task('debug', ['ng:build:debug'], () => {
  return gulp.src('./ng2/dist/**/*')
    .pipe(gulp.dest('./web/public'))
})

gulp.task('deploy', ['ng:build:deploy'], () => {
  return gulp.src('./ng2/dist/**/*')
    .pipe(gulp.dest('./web/public'))
})

gulp.task('default', ['debug'])