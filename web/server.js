(function () {
  'use strict';

  var connect = require('connect');
  var serveStatic = require('serve-static');
  var header = require('connect-header');

  var app = connect()
  app.use(serveStatic(__dirname)).listen(8000)
  app.use(header({
    'content-type': 'application/json'
  }));

}).call(this);