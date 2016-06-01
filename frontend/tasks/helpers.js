var gutil = require('gulp-util');

var fs = require('fs'),
    path = require('path');

function getDirectories(srcpath) {
  return fs.readdirSync(srcpath).filter(function(file) {
    return fs.statSync(path.join(srcpath, file)).isDirectory();
  });
}

module.exports = {
  makeHash: function _makeHash() {
      var text = "";
      var possible = "abcdef0123456789";
      var length = 30;

      for( var i=0; i < length; i++ )
          text += possible.charAt(Math.floor(Math.random() * possible.length));

      return text;
  },

  swallowError: function swallowError (err) {
    gutil.log(err);
    gutil.beep();
    this.emit('end');
  },

  getDirectories: getDirectories

};