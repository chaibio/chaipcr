(function () {

	App.config([
		'$stateProvider',
		'$urlRouterProvider',
		function ($stateProvider, $urlRouterProvider) {
			// Coronavirus Environment routes
			$stateProvider
			.state('coronavirus-env', {
				abstract: true,
				url: '/dynexp/coronavirus-environmental-surface',
				templateUrl: 'dynexp/chai_test/index.html'
			})
			.state('coronavirus-env.set-wells', {
				url: '/set-wells/:id',
				templateUrl: 'dynexp/chai_test/views/v2/set-wells.html'
			})
			.state('coronavirus-env.experiment-running', {
				url: '/experiment-running/:id',
				templateUrl: 'dynexp/chai_test/views/v2/exp-running.html'
			})
			.state('coronavirus-env.experiment-result', {
				url: '/experiment-result/:id',
				templateUrl: 'dynexp/chai_test/views/v2/exp-result.html'
			})

			// COVID-19 surveillance routes
			.state('covid19-surv', {
				abstract: true,
				url: '/dynexp/covid-19-surveillance',
				templateUrl: 'dynexp/chai_test/index.html'
			})
			.state('covid19-surv.set-wells', {
				url: '/set-wells/:id',
				templateUrl: 'dynexp/chai_test/views/v2/set-wells.html'
			})
			.state('covid19-surv.experiment-running', {
				url: '/experiment-running/:id',
				templateUrl: 'dynexp/chai_test/views/v2/exp-running.html'
			})
			.state('covid19-surv.experiment-result', {
				url: '/experiment-result/:id',
				templateUrl: 'dynexp/chai_test/views/v2/exp-result.html'
			});
		}
	]);
})();
