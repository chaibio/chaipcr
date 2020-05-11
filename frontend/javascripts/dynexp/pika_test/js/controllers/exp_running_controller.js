(function() {
  angular.module('dynexp.pika_test')
  .controller('PikaExpRunningCtrl', [
    '$scope',
    '$window',
    'dynexpExperimentService',
    '$state',
    '$stateParams',
    'Status',
    'dynexpGlobalService',
    'host',
    '$http',
    'PikaTestConstants',
    '$timeout',
    '$rootScope',
    '$uibModal',
    'focus',
    function PikaExpRunningCtrl($scope, $window, Experiment, $state, $stateParams, Status, GlobalService,
      host, $http, CONSTANTS, $timeout, $rootScope, $uibModal, focus) {

      $window.$('body').addClass('chai-mode');
      $window.$('body').addClass('pika-exp-running-active');
      $scope.$on('$destroy', function() {
        $window.$('body').removeClass('chai-mode');
        $window.$('body').removeClass('pika-exp-running-active');
      });

      function getExperiment(exp_id, cb) {
        Experiment.get(exp_id).then(function(resp) {
          $scope.experiment = resp.data.experiment;
          if (cb) cb(resp.data.experiment);
        });
      }

      function getId() {
        if ($stateParams.id) {
          $scope.experimentId = $stateParams.id;
          getExperiment($scope.experimentId, function(exp){
            if(exp.completion_status) $scope.viewResults();
            $scope.initial_done = true;
          });
        } else {
          $timeout(function() {
            getId();
          }, 500);
        }
      }
      getId();
      
    }
  ]);
})();
