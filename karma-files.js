function _file_path_prepend (paths) {
  new_paths = [];

  paths.forEach(function (item) {
    new_paths.push(__dirname + '/frontend/' + item);
  });

  return new_paths;
}

JS_VENDOR_FILES = _file_path_prepend([
  'javascripts/libs/jquery-1.10.1.min.js',
  'javascripts/libs/jquery-ui.min.js',
  'javascripts/libs/angular.js',
  'javascripts/libs/angular-mock.js',
  'javascripts/libs/angular-animate.js',
  'javascripts/libs/angular-resource.js',
  'javascripts/libs/perfect-scrollbar.jquery.min.js',
  'javascripts/libs/angular-perfect-scrollbar.js',
  'javascripts/libs/slider.js',
  'javascripts/libs/angular-ui-switch.js',
  'javascripts/libs/ui-bootstrap-tpls-0.14.3.js',
  'javascripts/libs/angular-ui-router.js',
  'javascripts/libs/moment.js',
  'javascripts/libs/angular-moment.min.js',
  'javascripts/libs/lodash.min.js',
  'javascripts/libs/fabric.js',
  'javascripts/libs/d3.js',
  'javascripts/libs/n3-line-chart-v2.js',
  'javascripts/libs/ng-focus-on.js.coffee',
  'javascripts/libs/http-auth-interceptor.js',
  'javascripts/libs/http-response-interceptor.js',
  'javascripts/libs/jstorage.js',
  'javascripts/libs/spin.min.js',
  'javascripts/libs/ladda.min.js',
  'javascripts/libs/angular-ladda.min.js',
  'javascripts/libs/rainbowvis.js',
  'javascripts/libs/ellipsis-animated.js',
  'javascripts/libs/ng-file-upload-shim.js',
  'javascripts/libs/ng-file-upload.js',
  'javascripts/libs/ng-webworker.js'
]);

JS_APP_FILES = _file_path_prepend([
  'javascripts/login.js.coffee',
  'javascripts/welcome.js.coffee',
  'javascripts/app/app.js.coffee',
  'javascripts/app/config.js.coffee',
  'javascripts/app/routes.js.coffee',
  'javascripts/app/canvas-app.js',
  'javascripts/app/canvas/**/*',
  'javascripts/app/controllers/**/*',
  'javascripts/app/directives/**/*',
  'javascripts/app/filters/**/*',
  'javascripts/app/services/**/*',
  'javascripts/app/views/**/*',
]);

TEST_FILES = _file_path_prepend([
  'tests/spec/**/*'
]);


module.exports = JS_VENDOR_FILES.concat(JS_APP_FILES).concat(TEST_FILES);
