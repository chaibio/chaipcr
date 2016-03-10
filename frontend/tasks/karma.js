// https://gist.github.com/renegare/9173656

/**
 * testing tasks (using karma to test in the browser). Requires a karma.conf.js for full config
 * single-run testing 
 * continuous testing
 */

/** base deps, but you may need more specifically for your application */
var gulp = require('gulp');
var gutil = require('gulp-util');
var path = require('path');
var Server = require('karma').Server;
var karmaParseConfig = require('karma/lib/config').parseConfig;

function runKarma(configFilePath, options, cb) {

	configFilePath = path.resolve(configFilePath);

	var log=gutil.log, colors=gutil.colors;
	var config = karmaParseConfig(configFilePath, {});

    Object.keys(options).forEach(function(key) {
      config[key] = options[key];
    });

   new Server(config, function(exitCode) {
		log('Karma has exited with ' + colors.red(exitCode));
		cb();
		process.exit(exitCode);
	}).start();

}

/** actual tasks */

/** single run */
gulp.task('karma', function(cb) {
	runKarma('karma.conf.js', {
		autoWatch: false,
		singleRun: true,
	}, cb);
});