(function() {
  angular.module('dynexp.chai-test')
  .controller('ChaiTestExpSetWellsCtrl', [
    '$scope',
    '$window',
    'Experiment',
    '$state',
    '$stateParams',
    'Status',
    'dynexpGlobalService',
    'host',
    '$http',
    '$timeout',
    '$rootScope',
    '$uibModal',
    'focus',
    function ChaiTestExpSetWellsCtrl($scope, $window, Experiment, $state, $stateParams, Status, GlobalService,
      host, $http, $timeout, $rootScope, $uibModal, focus) {

      $window.$('body').addClass('pika-set-well-active');
      $scope.$on('$destroy', function() {
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
      $scope.targets = [];
      $scope.target_ipc = null;
      $scope.well_types = [];
      $scope.exp_samples = [];
      $scope.target1_name = '';
      $scope.is_loading = true;

      $scope.is_omittable = false;

      var target2_name = ['IPC'];

      function getExperiment(exp_id, cb) {
        Experiment.get({id: exp_id}).then(function(resp) {
          $scope.experiment = resp.experiment;
          $rootScope.pageTitle = resp.experiment.name + " | Open qPCR";
          if (cb) cb(resp.experiment);
        });
      }

      function findSampleByName(sample_name){
        for(var i = 0; i < $scope.exp_samples.length; i++){
          if($scope.exp_samples[i].name == sample_name){
            return $scope.exp_samples[i];
          }
        }
        return false;
      }

      function getId() {
        if ($stateParams.id) {
          $scope.experimentId = $stateParams.id;
          getExperiment($scope.experimentId, function(exp){
            // if(exp.completion_status) $scope.viewResults();
            $scope.initial_done = true;
            switch($scope.experiment.guid){
              case 'chai_coronavirus_env_kit':
                target2_name = ['IAC'];
                $scope.is_omittable = false;
                break;
              case 'chai_covid19_surv_kit':
                target2_name = ['RPLP0'];
                $scope.is_omittable = false;
                break;
            }

            Experiment.getTargets($stateParams.id).then(function (resp) {
              for(var i = 0; i < resp.data.length; i++){
                if(!target2_name.includes(resp.data[i].target.name.trim())){
                  $scope.targets.push(resp.data[i].target);
                } else {
                  $scope.target_ipc = resp.data[i].target;
                  switch($scope.target_ipc.name){
                    case 'IAC':
                      $scope.target1_name = 'Coronavirus Environmental Surface';
                      break;
                    case 'RPLP0':
                      $scope.target1_name = 'COVID-19 Surveillance';
                      break;
                  }
                }
              }
              $scope.is_two_kit = ($scope.targets.length == 2) ? true : false;

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

                $scope.omit_positive = (resp.data[0].targets && resp.data[0].targets[0].well_type == 'positive_control') ? false : true;
                $scope.omit_negative = (resp.data[1].targets && resp.data[1].targets[0].well_type == 'negative_control') ? false : true;
                $scope.is_loading = false;
              });
            });

          });

          Experiment.getSamples($stateParams.id).then(function (resp) {
            for(var i = 0; i < resp.data.length; i++){
              $scope.exp_samples.push(resp.data[i].sample);
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
        switch($scope.experiment.guid){
          case 'chai_coronavirus_env_kit':
            $state.go('coronavirus-env.experiment-result', { id: $scope.experimentId });
            break;
          case 'chai_covid19_surv_kit':
            $state.go('covid19-surv.experiment-result', { id: $scope.experimentId });
            break;
        }
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
              Experiment.unlinkTarget($scope.experimentId, $scope.targets[0].id, { wells: [index + 1], channel: 0 }).then(function (response) {
                $scope.well_types[index] = '';
              });
            }
          } else {
            if(x.name){
              Experiment.createSample($scope.experimentId, {name: x.name}).then(function(resp) {              
                $scope.samples[index] = resp.data.sample;              
                Experiment.linkSample($scope.experimentId, resp.data.sample.id, { wells: [index+1] }).then(function (response) {
                });
              });

              var well_type = 'unknown';
              if(!$scope.omit_positive){
                if(index == 0){
                  well_type = 'positive_control';
                }
              }

              if(!$scope.omit_negative){
                if(index == 1){
                  well_type = 'negative_control';
                }
              }

              Experiment.linkTarget($scope.experimentId, $scope.targets[0].id, { wells: [{ well_num: index + 1, well_type: well_type }] }).then(function (response) {
                $scope.well_types[index] = well_type;
              });
              if($scope.target_ipc){
                Experiment.linkTarget($scope.experimentId, $scope.target_ipc.id, { wells: [{ well_num: index + 1, well_type: well_type }] }).then(function (response) {
                });
              }
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
              Experiment.unlinkTarget($scope.experimentId, ($scope.is_two_kit) ? $scope.targets[1].id : $scope.targets[0].id, { wells: [index + 9], channel: 0 }).then(function (response) {
                $scope.well_types[index] = '';
              });
            }
          } else {
            if(x.name){
              Experiment.createSample($scope.experimentId, {name: x.name}).then(function(resp) {              
                $scope.samples_B[index] = resp.data.sample;              
                Experiment.linkSample($scope.experimentId, resp.data.sample.id, { wells: [index + 9] }).then(function (response) {
                });
              });

              if($scope.is_two_kit){
                var well_type = 'unknown';
                if(!$scope.omit_positive){
                  if(index == 0){
                    well_type = 'positive_control';
                  }
                }

                if(!$scope.omit_negative){
                  if(index == 1){
                    well_type = 'negative_control';
                  }
                }
                Experiment.linkTarget($scope.experimentId, $scope.targets[1].id, { wells: [{ well_num: index + 9, well_type: well_type }] }).then(function (response) {
                  $scope.well_types[index + 8] = well_type;
                });
                if($scope.target_ipc){
                  Experiment.linkTarget($scope.experimentId, $scope.target_ipc.id, { wells: [{ well_num: index + 9, well_type: well_type }] }).then(function (response) {
                  });
                }
              } else {
                Experiment.linkTarget($scope.experimentId, $scope.targets[0].id, { wells: [{ well_num: index + 9, well_type: 'unknown' }] }).then(function (response) {                                
                  $scope.well_types[index + 8] = 'unknown';
                });
                if($scope.target_ipc){
                  Experiment.linkTarget($scope.experimentId, $scope.target_ipc.id, { wells: [{ well_num: index + 9, well_type: 'unknown' }] }).then(function (response) {
                  });
                }
              }
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
          templateUrl: 'dynexp/chai_test/note-modal.html',
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
        var well_row = $scope.selectedWellIndex - 1;
        var notes = $scope.selectedSample.notes;

        $scope.selectedSample = ($scope.selectedSample && $scope.selectedSample.id) ? $scope.selectedSample : ($scope.selectedWellRow == 'A' ? $scope.samples[well_row] : $scope.samples_B[well_row]);
        $scope.selectedSample.notes = notes;

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
        Experiment.startExperiment($scope.experimentId).then(function(resp) {
          switch($scope.experiment.guid){
            case 'chai_coronavirus_env_kit':
              $state.go('coronavirus-env.experiment-running', { id: $scope.experimentId });
              break;
            case 'chai_covid19_surv_kit':
              $state.go('covid19-surv.experiment-running', { id: $scope.experimentId });
              break;
          }
        });
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
        var omit_well_type = 'positive_control';
        if(is_positive){
          $scope.omit_positive = !$scope.omit_positive;
          omit_control = $scope.omit_positive;
          omit_sample_index = 0;
          omit_sample_name = 'Positive Control';
          omit_well_type = 'positive_control';
        } else {
          $scope.omit_negative = !$scope.omit_negative;
          omit_control = $scope.omit_negative;
          omit_sample_index = 1;
          omit_sample_name = 'Negative Control';
          omit_well_type = 'negative_control';
        }

        if(omit_control){
          if($scope.samples[omit_sample_index].id){
            Experiment.deleteLinkedSample($scope.experimentId, $scope.samples[omit_sample_index].id).then(function(resp) {
              $scope.samples[omit_sample_index] = {id: 0, name: ''};
            });
            Experiment.unlinkTarget($scope.experimentId, $scope.targets[0].id, { wells: [omit_sample_index + 1], channel: 0 }).then(function (response) {
              $scope.well_types[omit_sample_index] = '';
            });
          }
          if($scope.is_two_kit && $scope.samples_B[omit_sample_index].id){
            Experiment.deleteLinkedSample($scope.experimentId, $scope.samples_B[omit_sample_index].id).then(function(resp) {
              $scope.samples_B[omit_sample_index] = {id: 0, name: ''};
            });
            Experiment.unlinkTarget($scope.experimentId, $scope.targets[1].id, { wells: [omit_sample_index + 9], channel: 0 }).then(function (response) {
              $scope.well_types[omit_sample_index + 8] = '';
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

          Experiment.linkTarget($scope.experimentId, $scope.targets[0].id, { wells: [{ well_num: omit_sample_index + 1, well_type: omit_well_type }] }).then(function (response) {
            $scope.well_types[omit_sample_index] = omit_well_type;
          });

          if($scope.target_ipc){
            Experiment.linkTarget($scope.experimentId, $scope.target_ipc.id, { wells: [{ well_num: omit_sample_index + 1, well_type: omit_well_type }] }).then(function (response) {
            });
          }         

          if($scope.is_two_kit && $scope.samples_B[omit_sample_index].name != omit_sample_name){            
            Experiment.createSample($scope.experimentId, {name: omit_sample_name}).then(function(resp) {
              var new_sample = resp.data.sample;
              $scope.samples_B[omit_sample_index] = new_sample;
              Experiment.linkSample($scope.experimentId, new_sample.id, { wells: [omit_sample_index + 9] }).then(function (response) {
              });
            });

            Experiment.linkTarget($scope.experimentId, $scope.targets[1].id, { wells: [{ well_num: omit_sample_index + 9, well_type: omit_well_type }] }).then(function (response) {
              $scope.well_types[omit_sample_index + 8] = omit_well_type;
            });

            if($scope.target_ipc){
              Experiment.linkTarget($scope.experimentId, $scope.target_ipc.id, { wells: [{ well_num: omit_sample_index + 9, well_type: omit_well_type }] }).then(function (response) {
              });
            }            
          }
        }
      }

      $scope.isControlWell = function(sample, index, well_row){
        var type_index = (well_row == 'A') ? index : index + 8;
        return ($scope.well_types[type_index] == 'positive_control' || $scope.well_types[type_index] == 'negative_control');
      };

      $scope.learnMoreClick = function(is_positive){
        if(is_positive){
          $scope.omit_negative_help = false; $scope.omit_positive_help = !$scope.omit_positive_help;
        } else {
          $scope.omit_positive_help = false; $scope.omit_negative_help = !$scope.omit_negative_help;
        }
      };
    }
  ]);
})();
