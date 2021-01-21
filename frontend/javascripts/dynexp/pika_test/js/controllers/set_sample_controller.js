(function() {
  angular.module('dynexp.pika_test')
  .controller('PikaSetSampleCtrl', [
    '$scope',
    '$window',
    'Experiment',
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
    function PikaSetWellsCtrl($scope, $window, Experiment, $state, $stateParams, Status, GlobalService,
      host, $http, CONSTANTS, $timeout, $rootScope, $uibModal, focus) {

      $window.$('body').addClass('pika-set-sample-active');
      $scope.$on('$destroy', function() {
        $window.$('body').removeClass('pika-set-sample-active');
      });

      angular.element('body').click(function(evt) {
        if(evt.target.id !== 'start-experiment-button' && $scope.start_confirm_show === true) {
          $scope.start_confirm_show = false;
        }
      });

      $scope.samples = ['', '', '', '', '', ''];
      $scope.samples_B = ['', '', '', '', '', '', '', ''];
      $scope.start_confirm_show = false;
      $scope.initial_done = false;
      $scope.is_two_kit = false;
      $scope.well_types = [];
      $scope.exp_samples = [];
      $scope.input_sample = {name: '', notes: ''};
      $scope.experimentId = 0;
      $scope.creating = false;

      function getExperiment(exp_id, cb) {
        Experiment.get({id: exp_id}).then(function(resp) {
          $scope.experiment = resp.experiment;
          $rootScope.pageTitle = resp.experiment.name + " | Open qPCR";

          switch($scope.experiment.guid){
            case "pika_4e_lp_identification_kit":
              if (cb) cb(resp.experiment);
              break;
            default:
              $state.go('pika_test.set-wells', { id: exp_id });              
              break;
          }
        });
      }

      function getId() {
        if ($stateParams.id) {
          $scope.experimentId = $stateParams.id;
          getExperiment($scope.experimentId, function(exp){
            $scope.initial_done = true;
            Experiment.getTargets($stateParams.id).then(function (resp) {
              Experiment.getWellLayout($stateParams.id).then(function (resp) {
                $scope.well_types = [];
                for(var i = 0; i < resp.data.length; i++){
                  var well_type = (resp.data[i].targets && resp.data[i].targets[0].well_type) ? resp.data[i].targets[0].well_type : '';
                  $scope.well_types.push(well_type);
                }

                var j = 0, k;
                for (i = 0; i < 8; i++) {
                  $scope.samples[i] = (resp.data[i].samples) ? resp.data[i].samples[0] : {id: 0, name: ''};
                }

                for (k = 8; k < 16; k++) {
                  $scope.samples_B[k - 8] = (resp.data[k].samples) ? resp.data[k].samples[0] : {id: 0, name: ''};
                }
              });
            });

          });

          Experiment.getSamples($stateParams.id).then(function (resp) {
            for(var i = 0; i < resp.data.length; i++){
              $scope.exp_samples.push(resp.data[i].sample);
            }

            $scope.input_sample = {
              name: $scope.exp_samples[2] && $scope.exp_samples[2].name != '[SAMPLE NAME]' ? $scope.exp_samples[2].name : '',
              notes: $scope.exp_samples[2] ? $scope.exp_samples[2].notes : ''
            };
          });

        } else {
          $timeout(function() {
            getId();
          }, 500);
        }
      }
      getId();

      $scope.startConfirm = function(){
        $scope.start_confirm_show = true;
      };     

      $scope.onContinue = function(){
        if($scope.input_sample.name && $scope.exp_samples[2] && $scope.input_sample.name != $scope.exp_samples[2].name){
          $scope.creating = true;
          async.map($scope.exp_samples, function (sample, done) {
            if([1, 2].indexOf(sample.samples_wells[0] && sample.samples_wells[0].well_num) < 0){
              Experiment.updateSample($scope.experimentId, sample.id, $scope.input_sample).then(function(resp) {
                done(null, resp.data);
              });
            } else {
              Experiment.updateSample($scope.experimentId, sample.id, {notes: $scope.input_sample.notes}).then(function(resp) {
                done(null, resp.data);
              });
            }
          }, function (err, result) {
            if($scope.experiment.started_at){
              $state.go('pika_test.experiment-running', { id: $scope.experimentId });
            } else {              
              Experiment.startExperiment($scope.experimentId).then(function(resp) {
                $state.go('pika_test.experiment-running', { id: $scope.experimentId });
              });
            }
          });
        } else {
          if($scope.experiment.started_at){
            if($scope.experiment.completed_at){
              $state.go('pika_test.experiment-result', { id: $scope.experimentId });
            } else {
              $state.go('pika_test.experiment-running', { id: $scope.experimentId });
            }
          }
        }
      };

      $scope.onBack = function(){
        $state.go('home');
      };
    }
  ]);
})();
