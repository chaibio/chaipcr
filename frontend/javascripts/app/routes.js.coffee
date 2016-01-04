window.ChaiBioTech.ngApp

.config [
  '$stateProvider'
  '$urlRouterProvider'
  ($stateProvider, $urlRouterProvider) ->

      $urlRouterProvider.otherwise("/home");

      $stateProvider

      .state 'signup',
        url: '/signup'
        templateUrl: 'app/views/signup.html'
        controller: 'SignUpCtrl'

      .state 'login',
        url: '/login'
        templateUrl: 'app/views/login.html'
        controller: 'LoginCtrl as LoginCtrl'

      .state 'home',
        url: '/home'
        templateUrl: 'app/views/home.html'
        controller: 'HomeCtrl as HomeCtrl'

      .state 'settings',
        abstruct: true
        url: '/settings'
        templateUrl: 'app/views/settings/root-menu.html'

      .state 'settings.root',
        url: '/'
        template: '<version-info></version-info>'

      .state 'settings.system',
        url: '/system'
        templateUrl: 'app/views/settings/system.html'

      .state 'settings.diagnostics',
        url: '/diagnostics'
        templateUrl: 'app/views/settings/diagnostics.html'

      .state 'settings.calibration',
        url: '/calibration'
        templateUrl: 'app/views/settings/calibration.html'

      .state 'settings.usermanagement',
        url: '/usermanagement'
        templateUrl: 'app/views/settings/usermanagement.html'

      .state 'settings.usermanagement.new',
        url: '/new'
        templateUrl: 'app/views/settings/user-details.html'
        controller: 'newUserController'

      .state 'settings.current-user',
        url: '/current-user'
        templateUrl: 'app/views/settings/edit-current-user.html'
        controller: 'userDataController'

      .state 'settings.usermanagement.user',
        url: '/:id'
        templateUrl: 'app/views/settings/user-details.html'
        controller: 'userDataController'

      .state 'edit-protocol',
        url: '/edit-protocol/:id'
        templateUrl: 'app/views/skelton.html'
        controller: 'ProtocolCtrl'

      .state 'run-experiment',
        url: '/experiments/:id/run-experiment?chart?max_cycle'
        templateUrl: 'app/views/experiment/run-experiment.html'

      .state 'upload-image',
        url: '/upload-image'
        templateUrl: 'app/views/upload-image.html'

]
