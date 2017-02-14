(function () {

	App.config([
		'$stateProvider',
		'$urlRouterProvider',
		function ($stateProvider, $urlRouterProvider) {

			$urlRouterProvider.otherwise('setWellsA');

			$stateProvider
			.state('introduction', {
				url: '/introduction',
				templateUrl: './views/intro.html'
			})
			.state('exp-running', {
				url: '/exp-running',
				templateUrl: './views/exp-running.html'
			})
			.state('setWellsA', {
				url: '/setWellsA/:id',
				templateUrl: './views/setWellsA.html'
			})
			.state('setWellsB', {
				url: '/setWellsB',
				templateUrl: './views/setWellsB.html'
			})
			.state('analyze', {
				url: '/analyze/:id',
				templateUrl: './views/analyze.html'
			});

		}
	]);
})();
