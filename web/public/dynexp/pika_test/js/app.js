(function () {
	'use strict';

	var App = window.App = angular.module('PikaTest', [
		'ui.router',
		'ngResource',
		'http-auth-interceptor',
		'angularMoment',
		'ui.bootstrap',
		'auth',
		'global.service',
		'status.service',
		'experiment.service',
		'wizard.header',
		'focusOn',
	]);

	App.run([
		'Status',
		function (Status) {
			Status.startSync();
		}
	]);

	App.value('host', 'http://' + window.location.hostname);

})();
