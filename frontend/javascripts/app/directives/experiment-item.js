/*
 * Chai PCR - Software platform for Open qPCR and Chai's Real-Time PCR instruments.
 * For more information visit http://www.chaibio.com
 *
 * Copyright 2016 Chai Biotechnologies Inc. <info@chaibio.com>
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

window.ChaiBioTech.ngApp.directive('experimentItem', [
  '$state',
  '$stateParams',
  '$rootScope',
  'Status',
  'Experiment',
  '$rootScope',
  '$timeout',
  function($state, $stateParams, $rootScope, Status, Experiment, $timeout){
    return {
      restrict: 'EA',
      //replace: true,
      scope: {
        state: '@stateVal',
        lidOpen: '=lidOpen',
        maxCycle: '=maxCycle',
        showProp: '=showProp',
        experiment: "=exp"
      },
      templateUrl: "app/views/directives/experiment-item.html",

      link: function(scope, elem) {

        scope.runReady = false;
        scope.expID = $stateParams.id;

       scope.$watch('lidOpen', function(val) {
          if(val !== null) {
      			if(val === true){
      				scope.runReady = false;
      			}
          }
        });

        scope.$watch('state', function(val) {
          if(val) {
            if(scope.state === "NOT_STARTED") {
              scope.message = "Run Experiment";
            } else if(scope.state === "RUNNING") {
              scope.message = "Experiment Status";
            } else if(scope.state === 'COMPLETED') {
              scope.message = "View Result";
            }
          }
        });

        $rootScope.$on('lidOpen:true', function() {
          scope.runReady = false;
        });

        $rootScope.$on('sidemenu:toggle', function() {
          scope.runReady = false;
        });

        // Incase user has confirm box shown and user clicks somewhere else in the sidemenu
        $rootScope.$on("runReady:false", function() {
          scope.$apply(function() { // only reason we apply it here, so that speeds up the action.
            scope.runReady = false;
          });
	       });


        scope.manageAction = function() {
          if(scope.state === "NOT_STARTED" && scope.lidOpen === false) {
            scope.runReady = !scope.runReady;
            if(scope.runReady === true) {
              $rootScope.$broadcast("runReady:true");
			       }
            return;
          }
          if(scope.state === "NOT_STARTED" && scope.lidOpen === true) {
            return;
          }
          $state.go('run-experiment', {id: $stateParams.id, chart: 'amplification', max_cycle: scope.maxCycle});
        };

        scope.startExp = function() {
          Experiment.startExperiment($stateParams.id).then(function(data) {
            $rootScope.$broadcast('experiment:started', $stateParams.id);
            if($state.is('edit-protocol')) {
              var max_cycle = Experiment.getMaxExperimentCycle(scope.experiment);
              $state.go('run-experiment', {'id': $stateParams.id, 'chart': 'amplification', 'max_cycle': max_cycle});
            }
          });
        };

      }
    };
  }
]);
