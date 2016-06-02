var gulp = require('gulp');
var rename = require('gulp-rename');
var replace = require('gulp-replace');
var del = require('del');
var helpers = require('./helpers.js')
var hashes_cache = {};
var experiments = helpers.getDirectories('./web/public/dynexp').filter(function (path) {return path !== 'outputs'; });

function _rehash (path) {
  for (var i=0; i < experiments.length; i ++) {
    var pattern = new RegExp('^'+experiments[i]);
    if (pattern.test(path.dirname)) {
      path.dirname = path.dirname.replace(experiments[i], hashes_cache[experiments[i]]);
      break;
    }
  }
  return path;
};


gulp.task('dynamicexp:clean_old', function(done) {
  del(['web/public/dynexp/outputs/']).then(paths =>{
      done();
    });
});

gulp.task('dynamicexp:init_hashes', function (done) {
  hashes_cache = {};
  for (var i=0; i < experiments.length; i++) {
    hashes_cache[experiments[i]] = helpers.makeHash();
  }
  done();
});

gulp.task('dynamicexp:rehash', ['dynamicexp:clean_old', 'dynamicexp:init_hashes'], function () {
  return gulp.src('./web/public/dynexp/**/*.!(R)')
              .pipe(rename(_rehash))
              .pipe(gulp.dest('web/public/dynexp/outputs'));
});

gulp.task('dynamicexp:relink_libs', ['dynamicexp:clean_old', 'dynamicexp:init_hashes', 'dynamicexp:rehash'], function() {
    var stream = gulp.src('web/public/dynexp/outputs/**/*.{js,html,css}');

    for (var i = 0; i < experiments.length; i++) {
        stream = stream
            .pipe(replace('../' + experiments[i], '../' + hashes_cache[experiments[i]]))
            .pipe(replace('dynexp/' + experiments[i], 'dynexp/outputs/' + hashes_cache[experiments[i]]))
    }

    return stream.pipe(gulp.dest('web/public/dynexp/outputs'));
});

gulp.task('dynamicexp:relink', ['dynamicexp:clean_old', 'dynamicexp:rehash', 'dynamicexp:relink_libs', 'templates'], function () {
  var stream = gulp.src('.tmp/js/templates.js');

  for (var i=0; i < experiments.length; i++) {
    var pattern = new RegExp('/dynexp/'+experiments[i]);
    stream.pipe(replace(pattern, '/dynexp/outputs/'+hashes_cache[experiments[i]]));
  }

  return stream.pipe(gulp.dest('.tmp/js'));

});