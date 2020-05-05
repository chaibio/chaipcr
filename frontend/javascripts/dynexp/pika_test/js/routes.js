(function () {

	App.config([
		'$stateProvider',
		'$urlRouterProvider',
		function ($stateProvider, $urlRouterProvider) {

			// $urlRouterProvider.otherwise('setWellsA');

			$stateProvider
			.state('pika_test', {
				abstract: true,
				url: '/dynexp/pika-test',
				templateUrl: 'dynexp/pika_test/index.html'
			})
			.state('pika_test.set-wells', {
				url: '/set-wells/:id',
				templateUrl: 'dynexp/pika_test/views/v2/set-wells.html'
			})

			.state('pika_test.introduction', {
				url: '/introduction',
				templateUrl: 'dynexp/pika_test/views/intro.html'
			})
			.state('pika_test.exp-running', {
				url: '/exp-running/:id',
				templateUrl: 'dynexp/pika_test/views/exp-running.html'
			})
			.state('pika_test.setWellsA', {
				url: '/setWellsA/:id',
				templateUrl: 'dynexp/pika_test/views/setWellsA.html'
			})
			.state('pika_test.setWellsB', {
				url: '/setWellsB/:id',
				templateUrl: 'dynexp/pika_test/views/setWellsB.html'
			})
			.state('pika_test.review', {
				url: '/review/:id',
				templateUrl: 'dynexp/pika_test/views/review.html'
			})
			.state('pika_test.results', {
				url: '/results/:id',
				templateUrl: 'dynexp/pika_test/views/results.html'
			});

		}
	]);
})();
