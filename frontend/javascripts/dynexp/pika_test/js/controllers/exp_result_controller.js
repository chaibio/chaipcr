(function() {
  angular.module('dynexp.pika_test')
  .controller('PikaExpResultCtrl', [
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
    'Testkit',
    function PikaExpResultCtrl($scope, $window, Experiment, $state, $stateParams, Status, GlobalService,
      host, $http, CONSTANTS, $timeout, $rootScope, $uibModal, focus, Testkit) {

      $window.$('body').addClass('pika-exp-result-active');
      $scope.$on('$destroy', function() {
        $window.$('body').removeClass('pika-exp-result-active');
      });

      $scope.state = '';
      $scope.old_state = '';
      var enterState = false;
      $scope.analyzing = true;
      $scope.experimentComplete = false;
      var famTargets = [];
      var hexTargets = [];
      $scope.target_ipc = null;
      $scope.twoKits = false;

      $scope.omit_positive = false;
      $scope.omit_negative = false;
      $scope.neg_exist = false;

      $scope.famCq = [];
      $scope.hexCq = [];
      $scope.amount = [];
      $scope.result = [];
      $scope.notes = [];
      $scope.amount[0] = "\u2014";
      $scope.amount[1] = "\u2014";
      $scope.samples = ['', '', '', '', '', '', '', '', '', '', '', '', '', '', '', ''];
      $scope.targets = [];
      $scope.result_header="Sample";
      $scope.pika_sample="";
      var target2_name = ['IPC'];

      $scope.$on('status:data:updated', function(e, data, oldData) {
        if (!data) return;
        if (!data.experiment_controller) return;
        if (!oldData) return;
        if (!oldData.experiment_controller) return;

        $scope.data = data;
        $scope.state = data.experiment_controller.machine.state;
        $scope.old_state = oldData.experiment_controller.machine.state;
        $scope.stateName = $state.current.name;
      });

      function getResults() {
        $scope.analyzing = true;
        $scope.experimentComplete = true;
        Experiment.getAmplificationData($stateParams.id).then(function(resp) {
          if (resp.status == 200 && !resp.data.partial) {
            $scope.testFl = true;
            $scope.analyzing = false;
            $scope.summary_data = resp.data.steps[0].summary_data;
            var targets = resp.data.steps[0].targets;
            $scope.famCq = [];
            $scope.hexCq = [];
            if($scope.summary_data){
              var cqValue = '';
              for (i = 1; i < 17; i++) {
                $scope.famCq.push(filterSummaryByFam(i));
                $scope.hexCq.push(filterSummaryByHex(i));
              }

              $scope.result = Testkit.getResultArray($scope.famCq, $scope.hexCq, $scope.twoKits, $scope.omit_positive, $scope.omit_negative, $scope.neg_exist);
              $scope.amount = Testkit.getAmountArray($scope.famCq, $scope.twoKits);              
            }
          } else if (resp.data.partial || resp.status == 202) {
            $timeout(getResults, 1000);
          }
        })
        .catch(function(resp) {
          $scope.analyzing = false;
          if (resp.status == 500) {
            $scope.custom_error = (resp.data && resp.data.errors) || "An error occured while trying to analyze the experiment results.";
          } else if (resp.status == 503) {
            $timeout(getResults, 1000);
          }
        });
      }

      function filterSummaryByFam(well_num){
        for (var i = 0; i < $scope.summary_data.length; i++) {
          if(famTargets.includes($scope.summary_data[i][0]) && $scope.summary_data[i][1] == well_num){
            return parseFloat(($scope.summary_data[i].length && $scope.summary_data[i][3]) ? $scope.summary_data[i][3] : 0);
          }
        }
        return 0;
      }

      function filterSummaryByHex(well_num){
        for (var i = 0; i < $scope.summary_data.length; i++) {
          if(hexTargets.includes($scope.summary_data[i][0]) && $scope.summary_data[i][1] == well_num){
            return parseFloat(($scope.summary_data[i].length && $scope.summary_data[i][3]) ? $scope.summary_data[i][3] : 0);
          }
        }
        return 0;
      }

      function getExperiment(exp_id, cb) {
        Experiment.get({id: exp_id}).then(function(resp) {
          $scope.experiment = resp.experiment;
          $rootScope.pageTitle = resp.experiment.name + " | Open qPCR";
          if (cb) cb(resp.experiment);
        });
      }

      function getId() {
        if ($stateParams.id) {
          $scope.experimentId = $stateParams.id;
          getExperiment($scope.experimentId, function(exp){
            $scope.initial_done = true;
            target2_name = ['IPC'];
            switch($scope.experiment.guid){
              case 'pika_4e_lp_identification_kit':
                $scope.result_header="Target";
                break;
              default:
                break;
            }

            Experiment.getWellLayout($stateParams.id).then(function (well_resp) {
              var k, i;
              for (i = 0; i < 16; i++) {
                switch($scope.experiment.guid){
                  case 'pika_4e_lp_identification_kit':
                    if(well_resp.data[i].targets){
                      $scope.samples[i] = well_resp.data[i].targets[0].channel == 1 ? well_resp.data[i].targets[0] : well_resp.data[i].targets[1];
                    } else {
                      $scope.samples[i] = {id: 0, name: ''};
                    }
                    $scope.samples[i].sample_data = (well_resp.data[i].samples) ? well_resp.data[i].samples[0] : {id: 0, name: ''};
                    $scope.pika_sample = (well_resp.data[2] && well_resp.data[2].samples[0]) ? well_resp.data[2].samples[0].name : '';
                    break;
                  default:
                    $scope.samples[i] = (well_resp.data[i].samples) ? well_resp.data[i].samples[0] : {id: 0, name: ''};
                    if($scope.samples[i].name == 'Negative' && well_resp.data[i].targets){
                      for(k = 0; k < well_resp.data[i].targets.length; k++){
                        if(well_resp.data[i].targets[k].name == 'IPC'){
                          $scope.neg_exist = true;
                        }
                      }
                    }
                    break;
                }
              }

              for (i = 0; i < 16; i++) {
                $scope.notes[i] = '';
              }

              $scope.omit_positive = (well_resp.data[0].targets && well_resp.data[0].targets[0].well_type == 'positive_control') ? false : true;
              $scope.omit_negative = (well_resp.data[1].targets && well_resp.data[1].targets[0].well_type == 'negative_control') ? false : true;

              Experiment.getTargets($stateParams.id).then(function (resp) {
                var targets = resp.data;
                for(var i = 0; i < targets.length; i++){
                  if(target2_name.includes(targets[i].target.name.trim())){
                    hexTargets.push(targets[i].target.id);
                    $scope.target_ipc = targets[i].target;
                  } else {
                    famTargets.push(targets[i].target.id);
                    $scope.targets.push(resp.data[i].target);
                  }
                }
                $scope.twoKits = (famTargets.length == 2) ? true : false;
                getResults();
              });
            });

          });
        } else {
          $timeout(function() {
            getId();
          }, 500);
        }
      }
      getId();

      $scope.openNotes = function(index, sample, well_row) {
        switch($scope.experiment.guid){
          case 'pika_4e_lp_identification_kit':
            $scope.selectedSample = sample.sample_data;
            $scope.oriSampleNotes = sample.sample_data.notes;
            break;
          default:
            $scope.selectedSample = sample;
            $scope.oriSampleNotes = sample.notes;
            break;
        }

        $scope.selectedWellIndex = (index < 8) ? index + 1 : index - 7;
        $scope.selectedWellRow = (index < 8) ? 'A' : 'B';

        $scope.modalInstance = $uibModal.open({
          scope: $scope,
          templateUrl: 'dynexp/pika_test/note-modal.html',
          backdrop: true
        });

        $scope.modalInstance.rendered.then(function(){
          var note_pos = document.querySelector(".note-" + index).getBoundingClientRect();
          var body_pos = document.body.getBoundingClientRect();

          var modal_width = document.querySelector('.pika-exp-result-active .modal-dialog').offsetWidth;
          var modal_height = document.querySelector('.pika-exp-result-active .modal-dialog').offsetHeight;
          var modal_top = note_pos.top - modal_height - 10 > 10 ? note_pos.top - modal_height - 10 : note_pos.top + 35;
          var modal_left = (note_pos.left + modal_width > body_pos.width) ? body_pos.width - modal_width - 30 : note_pos.left - modal_width / 2 + 15;

          angular.element(document.querySelector('.pika-exp-result-active .modal-dialog')).css('left', (modal_left) + 'px');
          angular.element(document.querySelector('.pika-exp-result-active .modal-dialog')).css('top', (modal_top) + 'px');
        });

        setTimeout(function(){
          focus('editNotes');
        }, 500);
      };

      $scope.updateNotes = function() {
        Experiment.updateSample($scope.experimentId, $scope.selectedSample.id, {notes: $scope.selectedSample.notes}).then(function(resp) {          
          $scope.modalInstance.close();
        });
      };

      $scope.cancel = function() {
        $scope.selectedSample.notes = $scope.oriSampleNotes;
        $scope.modalInstance.close();
      };

    }
  ]);
})();
