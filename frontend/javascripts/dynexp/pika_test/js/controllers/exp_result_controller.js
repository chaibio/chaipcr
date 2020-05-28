(function() {
  angular.module('dynexp.pika_test')
  .controller('PikaExpResultCtrl', [
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
    function PikaExpResultCtrl($scope, $window, Experiment, $state, $stateParams, Status, GlobalService,
      host, $http, CONSTANTS, $timeout, $rootScope, $uibModal, focus) {

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

      $scope.famCq = [];
      $scope.hexCq = [];
      $scope.amount = [];
      $scope.result = [];

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
            $scope.initial_done = true;
          });

          Experiment.getTargets($stateParams.id).then(function (resp) {
            var targets = resp.data;
            for(var i = 0; i < targets.length; i++){
              if(targets[i].target.name.trim() == 'IPC'){
                hexTargets.push(targets[i].target.id);
                $scope.target_ipc = targets[i].target;
              } else {
                famTargets.push(targets[i].target.id);
              }
            }
            $scope.twoKits = (famTargets.length == 2) ? true : false;
          });

          Experiment.getWellLayout($stateParams.id).then(function (resp) {
            $scope.target = (resp.data[0].targets) ? resp.data[0].targets[0] : {id: 0, name: ''};
            $scope.target2 = (resp.data[8].targets) ? resp.data[8].targets[0] : {id: 0, name: ''};
            var j = 0,
            k, i;
            for (i = 0; i < 8; i++) {
              $scope.samples[i] = (resp.data[i].samples) ? resp.data[i].samples[0] : {id: 0, name: ''};
            }

            for (k = 8; k < 16; k++) {
              $scope.samples_B[k - 8] = (resp.data[k].samples) ? resp.data[k].samples[0] : {id: 0, name: ''};
            }
            for (i = 0; i < 16; i++) {
              $scope.notes[i] = '';
            }
          });
        
        } else {
          $timeout(function() {
            getId();
          }, 500);
        }
      }
      getId();

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

      function getAmountArray(){
        var i = 0;
        for (i = 2; i < 8; i++) {
          if($scope.result[i] == "Inhibited"){
            $scope.amount[i] = "Repeat";
          }
          else if($scope.result[i] == "Invalid"){
            $scope.amount[i] = "Repeat";
          }
          else if ($scope.famCq[i]>=10 && $scope.famCq[i]<= 24) {
            $scope.amount[i] = "High";
          }
          else if ($scope.famCq[i]>24 && $scope.famCq[i]<= 30) {
            $scope.amount[i] = "Medium";
          }
          else if ($scope.famCq[i]>30 && $scope.famCq[i]<= 38) {
            $scope.amount[i] = "Low";
          }
          else{
            $scope.amount[i] = "Not Detectable";
          }
        }
        if(!$scope.twoKits){
          for (i = 8; i < 16; i++) {
            if($scope.result[i] == "Inhibited"){
              $scope.amount[i] = "Invalid";
            }
            else if($scope.result[i] == "Invalid"){
              $scope.amount[i] = "Repeat";
            }
            else if ($scope.famCq[i]>=10 && $scope.famCq[i]<= 24) {
              $scope.amount[i] = "High";
            }
            else if ($scope.famCq[i]>24 && $scope.famCq[i]<= 30) {
              $scope.amount[i] = "Medium";
            }
            else if ($scope.famCq[i]>30 && $scope.famCq[i]<= 38) {
              $scope.amount[i] = "Low";
            }
            else{
              $scope.amount[i] = "Not Detectable";
            }
          }
        }
        else{
          $scope.amount[8]="\u2014";
          $scope.amount[9]="\u2014";
          for (i = 10; i < 16; i++) {
            if($scope.result[i] == "Inhibited"){
              $scope.amount[i] = "Repeat";
            }
            else if($scope.result[i] == "Invalid"){
              $scope.amount[i] = "Repeat";
            }
            else if ($scope.famCq[i]>=10 && $scope.famCq[i]<= 24) {
              $scope.amount[i] = "High";
            }
            else if ($scope.famCq[i]>24 && $scope.famCq[i]<= 30) {
              $scope.amount[i] = "Medium";
            }
            else if ($scope.famCq[i]>30 && $scope.famCq[i]<= 38) {
              $scope.amount[i] = "Low";
            }
            else{
              $scope.amount[i] = "Not Detectable";
            }
          }
        }
      }

      function getResultArray() {
        var i = 0;
        if($scope.famCq[0]>=20 && $scope.famCq[0]<=34 ){
          $scope.result[0]="Valid";
        }
        else{
          $scope.result[0]="Invalid";
          $scope.amount[0] = "Repeat";
        }

        if((!$scope.famCq[1] || $scope.famCq[1] == 0 || ($scope.famCq[1]>38 && $scope.famCq[1]<=40)) && ($scope.hexCq[1]>=20 && $scope.hexCq[1]<=36) ){
          $scope.result[1]="Valid";
        }
        else{
          $scope.result[1]="Invalid";
          $scope.amount[1] = "Repeat";
        }

        for (i = 2; i < 8; i++) {
          $scope.result[i]="Invalid";
          if($scope.result[1] == "Invalid"){
            $scope.result[i]="Invalid";
          } else if($scope.result[0] == "Valid" && $scope.result[1] == "Valid") {
            if($scope.famCq[i]>=10 && $scope.famCq[i]<=38){
              $scope.result[i]="Positive";
            } else if ((!$scope.famCq[i]) && ($scope.hexCq[i]>=20 && $scope.hexCq[i]<=36)){
              $scope.result[i]="Negative";
            } else if ($scope.famCq[i] > 38 && ($scope.hexCq[i]>=20 && $scope.hexCq[i]<=36)){
              $scope.result[i]="Negative";
            }
          } 

          if ($scope.result[1] == "Valid"){
            if((!$scope.famCq[i]) && (!$scope.hexCq[i])){
              $scope.result[i]="Inhibited";
            } else if(!($scope.famCq[i]) && $scope.hexCq[i] > 36) {
              $scope.result[i]="Inhibited";
            } else if($scope.famCq[i] > 38 && (!$scope.hexCq[i])){
              $scope.result[i]="Inhibited";
            } else if($scope.famCq[i] > 38 && $scope.hexCq[i] > 36){
              $scope.result[i]="Inhibited";
            }
          }
        }
        if(!$scope.twoKits){
          for (i = 8; i < 16; i++) {
            $scope.result[i]="Invalid";
            if($scope.result[1] == "Invalid"){
              $scope.result[i]="Invalid";
            } else if($scope.result[0] == "Valid" && $scope.result[1] == "Valid") {
              if($scope.famCq[i]>=10 && $scope.famCq[i]<=38){
                $scope.result[i]="Positive";
              } else if ((!$scope.famCq[i]) && ($scope.hexCq[i]>=20 && $scope.hexCq[i]<=36)){
                $scope.result[i]="Negative";
              } else if ($scope.famCq[i] > 38 && ($scope.hexCq[i]>=20 && $scope.hexCq[i]<=36)){
                $scope.result[i]="Negative";
              }
            } 

            if ($scope.result[1] == "Valid"){
              if((!$scope.famCq[i]) && (!$scope.hexCq[i])){
                $scope.result[i]="Inhibited";
              } else if(!($scope.famCq[i]) && $scope.hexCq[i] > 36) {
                $scope.result[i]="Inhibited";
              } else if($scope.famCq[i] > 38 && (!$scope.hexCq[i])){
                $scope.result[i]="Inhibited";
              } else if($scope.famCq[i] > 38 && $scope.hexCq[i] > 36){
                $scope.result[i]="Inhibited";
              }
            }
          }
        }
        else{
          if($scope.famCq[8]>=20 && $scope.famCq[8]<=34 ){
            $scope.result[8]="Valid";
          }
          else{
            $scope.result[8]="Invalid";
          }

          if((!$scope.famCq[9] || $scope.famCq[9] == 0 || ($scope.famCq[9]>38 && $scope.famCq[9]<=40)) && ($scope.hexCq[9]>=20 && $scope.hexCq[9]<=36) ){
            $scope.result[9]="Valid";
          }
          else{
            $scope.result[9]="Invalid";
          }

          for (i = 10; i < 16; i++) {
            $scope.result[i]="Invalid";
            if($scope.result[9] == "Invalid"){
              $scope.result[i]="Invalid";
            } else if($scope.result[8] == "Valid" && $scope.result[9] == "Valid") {
              if($scope.famCq[i]>=10 && $scope.famCq[i]<=38){
                $scope.result[i]="Positive";
              } else if ((!$scope.famCq[i]) && ($scope.hexCq[i]>=20 && $scope.hexCq[i]<=36)){
                $scope.result[i]="Negative";
              } else if ($scope.famCq[i] > 38 && ($scope.hexCq[i]>=20 && $scope.hexCq[i]<=36)){
                $scope.result[i]="Negative";
              }
            } 

            if ($scope.result[9] == "Valid"){
              if((!$scope.famCq[i]) && (!$scope.hexCq[i])){
                $scope.result[i]="Inhibited";
              } else if(!($scope.famCq[i]) && $scope.hexCq[i] > 36) {
                $scope.result[i]="Inhibited";
              } else if($scope.famCq[i] > 38 && (!$scope.hexCq[i])){
                $scope.result[i]="Inhibited";
              } else if($scope.famCq[i] > 38 && $scope.hexCq[i] > 36){
                $scope.result[i]="Inhibited";
              }
            }
          }
        }
        getAmountArray();
      }

      $scope.getResults = function() {
        $scope.analyzing = true;
        $scope.experimentComplete = true;
        Experiment.getFluorescenceData($scope.experimentId).then(function(resp) {
          if (resp.status == 200 && !resp.data.partial) {
            $scope.testFl = true;
            $scope.analyzing = false;
            $scope.summary_data = resp.data.steps[0].summary_data;
            var targets = resp.data.steps[0].targets;
            // $scope.summary_data = [["channel","well_num","cq"],[1,1,"20.76"],[1,2,42.13],[1,3,40.89],[1,4,9.47],[1,5,20],[1,6,"26.33"],[1,7,"33.89"],[1,8,"5"],[1,9,"34.5"],[1,10,"19"],[1,11,"12"],[1,12,"6"],[1,13,"24"],[1,14,"39"],[1,15,"32"],[1,16,"18"],[2,1,"11"],[2,2,"25.15"],[2,3,36],[2,4,"8"],[2,5,"34"],[2,6,"10"],[2,7,"15"],[2,8,"25"],[2,9,"35"],[2,10,"28"],[2,11,"2"],[2,12,"7"],[2,13,"0"],[2,14,"35"],[2,15,"28"],[2,16,"17"]];
            $scope.famCq = [];
            $scope.hexCq = [];
            if($scope.summary_data){
              var cqValue = '';
              for (i = 1; i < 17; i++) {
                $scope.famCq.push(filterSummaryByFam(i));
                $scope.hexCq.push(filterSummaryByHex(i));
              }
              getResultArray();                
            }
          } else if (resp.data.partial || resp.status == 202) {
              $timeout($scope.getResults, 1000);
            }
          })
          .catch(function(resp) {
            if (resp.status == 500) {
              $scope.custom_error = resp.data.errors || "An error occured while trying to analyze the experiment results.";
              $scope.analyzing = false;
            } else if (resp.status == 503) {
              $timeout($scope.getResults, 1000);
            }
          });
      };

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

    }
  ]);
})();
