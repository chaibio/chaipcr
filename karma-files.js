function _file_path_prepend (paths) {
  new_paths = [];

  paths.forEach(function (item) {
    new_paths.push(__dirname + '/frontend/javascripts/' + item);
  });

  return new_paths;
}

JS_VENDOR_FILES = _file_path_prepend([
  'libs/jquery-1.10.1.min.js',
  'libs/jquery-ui.min.js',
  'libs/angular.js',
  'libs/angular-mock.js',
  'libs/angular-animate.js',
  'libs/angular-resource.js',
  'libs/perfect-scrollbar.jquery.min.js',
  'libs/angular-perfect-scrollbar.js',
  'libs/slider.js',
  'libs/angular-ui-switch.js',
  'libs/ui-bootstrap-tpls-0.14.3.js',
  'libs/angular-ui-router.js',
  'libs/moment.js',
  'libs/angular-moment.min.js',
  'libs/lodash.min.js',
  'libs/fabric.js',
  'libs/d3.js',
  'libs/n3-line-chart-v2.js',
  'libs/ng-focus-on.js.coffee',
  'libs/http-auth-interceptor.js',
  'libs/http-response-interceptor.js',
  'libs/jstorage.js',
  'libs/spin.min.js',
  'libs/ladda.min.js',
  'libs/angular-ladda.min.js',
  'libs/rainbowvis.js',
  'libs/ellipsis-animated.js',
  'libs/ng-file-upload-shim.js',
  'libs/ng-file-upload.js',
]);

JS_APP_FILES = _file_path_prepend([
  'login.js.coffee',
  'welcome.js.coffee',
  'app/app.js.coffee',
  'app/config.js.coffee',
  'app/routes.js.coffee',
  'app/canvas-app.js',
  'app/canvas/**/*',
  'app/controllers/**/*',
  'app/directives/**/*',
  'app/filters/**/*',
  'app/services/**/*',
  'app/views/**/*',
]);

TEST_FILES = _file_path_prepend([
  'tests/**/*'
]);


module.exports = {
  all: JS_VENDOR_FILES.concat(JS_APP_FILES).concat(TEST_FILES),
  vendor: JS_VENDOR_FILES,
  app: JS_APP_FILES
};