var requireDir = require('require-dir');
var tasks = requireDir('./frontend/tasks');

// start angular 2 tasks

const gulp = require('gulp')
const { exec } = require('child_process')
const del = require('del')

gulp.task('ng2:clean', () => {
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

gulp.task('ng2:build:debug', ['ng2:clean'], (done) => {
  process.chdir('./ng2')
  exec('ng build', (err, stdout, stderr) => {
    console.log(err)
    console.log(stdout)
    console.log(stderr)
    process.chdir('..')
    done()
  })
})

gulp.task('ng2:build:deploy', ['ng2:clean'], (done) => {
  process.chdir('./ng2')
  exec('ng build --target=production', (err, stdout, stderr) => {
    console.log(err)
    console.log(stdout)
    console.log(stderr)
    process.chdir('..')
    done()
  })
})

gulp.task('ng2:debug', ['ng2:build:debug'], () => {
  return gulp.src('./ng2/dist/**/*')
    .pipe(gulp.dest('./web/public'))
})

gulp.task('ng2:deploy', ['ng2:build:deploy'], () => {
  return gulp.src('./ng2/dist/**/*')
    .pipe(gulp.dest('./web/public'))
})