(function() {
  angular.module('dynexp.pika_test')
  .controller('PikaSetWellsCtrl', [
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
    function PikaSetWellsCtrl($scope, $window, Experiment, $state, $stateParams, Status, GlobalService,
      host, $http, CONSTANTS, $timeout, $rootScope, $uibModal, focus) {

      $window.$('body').addClass('chai-mode');
      $window.$('body').addClass('pika-set-well-active');
      $scope.$on('$destroy', function() {
        $window.$('body').removeClass('chai-mode');
        $window.$('body').removeClass('pika-set-well-active');
      });

      angular.element('body').click(function(evt) {
        if(evt.target.id !== 'start-experiment-button' && $scope.start_confirm_show === true) {
          $scope.start_confirm_show = false;
        }
      });

      $scope.samples = ['', '', '', '', '', ''];
      $scope.samples_B = ['', '', '', '', '', '', '', ''];
      $scope.initial_done = false;
      $scope.start_confirm_show = false;
      $scope.omit_positive_help = false;
      $scope.omit_negative_help = false;
      $scope.omit_positive = false;
      $scope.omit_negative = false;
      $scope.current_well_index = -1;
      $scope.original_sample_name = '';
      $scope.is_two_kit = false;

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


      $scope.viewResults = function() {
        $scope.showSidebar = false;
        $state.go('pika_test.results', { id: $scope.experimentId });
      };

      $scope.updateWellA = function(index, x) {
        document.activeElement.blur();
        if(x.name != $scope.original_sample_name){
          if(x.id){
            if(x.name){
              Experiment.updateSample($scope.experimentId, x.id, {name: x.name}).then(function(resp) {
                $scope.samples[index] = x;              
              });
            } else {
              Experiment.deleteLinkedSample($scope.experimentId, x.id).then(function(resp) {
                $scope.samples[index] = {id: 0, name: ''};
              });              
            }
          } else {
            if(x.name){
              Experiment.createSample($scope.experimentId, {name: x.name}).then(function(resp) {              
                $scope.samples[index] = resp.data.sample;              
                Experiment.linkSample($scope.experimentId, resp.data.sample.id, { wells: [index+1] }).then(function (response) {
                });
              });              
            }
          }

          if($scope.is_two_kit){

          } else {
            if(x.name == 'Positive Control' && index == 0){
              $scope.omit_positive = false;
            }

            if(x.name == 'Negative Control' && index == 1){
              $scope.omit_negative = false;
            }            
          }
        }
        $scope.current_well_row = '';
        $scope.current_well_index = -1;
        $scope.original_sample_name = '';
      };

      $scope.updateWellB = function(index, x) {
        document.activeElement.blur();
        if(x.name != $scope.original_sample_name){
          if(x.id){
            if(x.name){
              Experiment.updateSample($scope.experimentId, x.id, {name: x.name}).then(function(resp) {
                $scope.samples_B[index] = x;              
              });              
            } else {
              Experiment.deleteLinkedSample($scope.experimentId, x.id).then(function(resp) {
                $scope.samples_B[index] = {id: 0, name: ''};
              });              
            }
          } else {
            if(x.name){
              Experiment.createSample($scope.experimentId, {name: x.name}).then(function(resp) {              
                $scope.samples_B[index] = resp.data.sample;              
                Experiment.linkSample($scope.experimentId, resp.data.sample.id, { wells: [index + 9] }).then(function (response) {
                });
              });
            }
          }

          if($scope.is_two_kit){
            if(x.name == 'Positive Control' && index == 0){
              $scope.omit_positive = false;
            }

            if(x.name == 'Negative Control' && index == 1){
              $scope.omit_negative = false;
            }            
          }
        }
        $scope.current_well_row = '';
        $scope.current_well_index = -1;
        $scope.original_sample_name = '';
      };

      $scope.openNotes = function(index, sample, well_row) {
        $scope.selectedSample = sample;
        $scope.selectedWellIndex = index + 1;
        $scope.selectedWellRow = well_row;
        $scope.oriSampleNotes = sample.notes;

        $scope.modalInstance = $uibModal.open({
          scope: $scope,
          templateUrl: 'dynexp/pika_test/note-modal.html',
          backdrop: true
        });

        $scope.modalInstance.rendered.then(function(){
          var note_pos = document.querySelector(".note-" + well_row + index).getBoundingClientRect();
          var body_pos = document.body.getBoundingClientRect();

          var modal_width = document.querySelector('.pika-set-well-active .modal-dialog').offsetWidth;
          var modal_height = document.querySelector('.pika-set-well-active .modal-dialog').offsetHeight;
          var modal_top = note_pos.top - modal_height - 10 > 10 ? note_pos.top - modal_height - 10 : note_pos.top + 35;
          var modal_left = (note_pos.left + modal_width > body_pos.width) ? body_pos.width - modal_width - 30 : note_pos.left - modal_width / 2 + 15;

          angular.element(document.querySelector('.pika-set-well-active .modal-dialog')).css('left', (modal_left) + 'px');
          angular.element(document.querySelector('.pika-set-well-active .modal-dialog')).css('top', (modal_top) + 'px');
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

      $scope.focusWell = function(well_row, index, sample_name){
        $scope.current_well_row = well_row;
        $scope.current_well_index = index;
        $scope.original_sample_name = sample_name;
      };

      $scope.startConfirm = function(){
        $scope.start_confirm_show = true;
      };     


      $scope.startExperiment = function(){
        // Experiment.startExperiment($scope.experimentId).then(function(resp) {
          $state.go('pika_test.experiment-running', { id: $scope.experimentId });
        // });
      };

      $scope.omitPositive = function(){
        assignControlSample(true);
      };

      $scope.omitNegative = function(){
        assignControlSample(false);
      };

      function assignControlSample(is_positive){
        var omit_control = false;
        var omit_sample_index = 0;
        var omit_sample_name = 'Positive Control';
        if(is_positive){
          $scope.omit_positive = !$scope.omit_positive;
          omit_control = $scope.omit_positive;
          omit_sample_index = 0;
          omit_sample_name = 'Positive Control';
        } else {
          $scope.omit_negative = !$scope.omit_negative;
          omit_control = $scope.omit_negative;
          omit_sample_index = 1;
          omit_sample_name = 'Negative Control';
        }

        if(omit_control){
          if($scope.samples[omit_sample_index].name == omit_sample_name){
            Experiment.deleteLinkedSample($scope.experimentId, $scope.samples[omit_sample_index].id).then(function(resp) {
              $scope.samples[omit_sample_index] = {id: 0, name: ''};
            });
          }
          if($scope.is_two_kit && $scope.samples_B[omit_sample_index].name == omit_sample_name){
            Experiment.deleteLinkedSample($scope.experimentId, $scope.samples_B[omit_sample_index].id).then(function(resp) {
              $scope.samples_B[omit_sample_index] = {id: 0, name: ''};
            });
          }
        } else {
          if($scope.samples[omit_sample_index].name != omit_sample_name){      
            Experiment.createSample($scope.experimentId, {name: omit_sample_name}).then(function(resp) {
              var new_sample = resp.data.sample;
              $scope.samples[omit_sample_index] = new_sample;
              Experiment.linkSample($scope.experimentId, new_sample.id, { wells: [omit_sample_index + 1] }).then(function (response) {});
            });
          }

          if($scope.is_two_kit && $scope.samples_B[omit_sample_index].name != omit_sample_name){            
            Experiment.createSample($scope.experimentId, {name: omit_sample_name}).then(function(resp) {
              var new_sample = resp.data.sample;
              $scope.samples_B[omit_sample_index] = new_sample;
              Experiment.linkSample($scope.experimentId, new_sample.id, { wells: [omit_sample_index + 9] }).then(function (response) {
              });
            });
          }

        }
      }

      $scope.isControlWell = function(sample, index, well_row){
        return (sample.name == 'Positive Control' || sample.name == 'Negative Control') && 
                sample.id && index < 2 && ($scope.is_two_kit || well_row == 'A') &&
                ($scope.original_sample_name == 'Positive Control' || $scope.original_sample_name == 'Negative Control');
      };
    }
  ]);
})();
