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
          Experiment.getWellLayout($stateParams.id).then(function (resp) {
            $scope.target = (resp.data[0].targets) ? resp.data[0].targets[0] : {id: 0, name: ''};
            $scope.target2 = (resp.data[8].targets) ? resp.data[8].targets[0] : {id: 0, name: ''};
            if ($scope.target.id != $scope.target2.id && $scope.target2.id && $scope.target.id) {
              $scope.is_two_kit = true;
            }
            var j = 0,
            k, i;
            for (i = 0; i < 8; i++) {
              $scope.samples[i] = (resp.data[i].samples) ? resp.data[i].samples[0] : {id: 0, name: ''};
            }

            for (k = 8; k < 16; k++) {
              $scope.samples_B[k - 8] = (resp.data[k].samples) ? resp.data[k].samples[0] : {id: 0, name: ''};
            }
            
            if($scope.is_two_kit){
              $scope.omit_positive = (($scope.samples[0].id && $scope.samples[0].name == 'Positive Control') || 
                                      ($scope.samples_B[0].id && $scope.samples_B[0].name == 'Positive Control')) ? false : true;
              $scope.omit_negative = (($scope.samples[1].id  && $scope.samples[1].name == 'Negative Control') ||
                                      ($scope.samples_B[1].id && $scope.samples_B[1].name == 'Negative Control')) ? false : true;
            } else {              
              $scope.omit_positive = ($scope.samples[0].id && $scope.samples[0].name == 'Positive Control') ? false : true;
              $scope.omit_negative = ($scope.samples[1].id  && $scope.samples[1].name == 'Negative Control') ? false : true;
            }

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
