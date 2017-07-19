// var requireDir = require('require-dir');
// var tasks = requireDir('./frontend/tasks');

const gulp = require('gulp')
const { exec } = require('child_process')
const del = require('del')

gulp.task('clean', () => {
  return del([
    './web/public/*.ttf',
    './web/public/*.eot',
    './web/public/*.woff',
    './web/public/*.woff2',
    './web/public/*.svg',
    './web/public/*.otf',
    './web/public/*.map',
    './web/public/*.js',
    './web/public/index.html',
    './web/public/3rdpartylicenses.txt',
  ]);
})

gulp.task('ng:build:debug', ['clean'], (done) => {
  process.chdir('./ng2')
  exec('ng build', (err, stdout, stderr) => {
    console.log(err)
    console.log(stdout)
    console.log(stderr)
    process.chdir('..')
    done()
  })
})

gulp.task('ng:build:deploy', ['clean'], (done) => {
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