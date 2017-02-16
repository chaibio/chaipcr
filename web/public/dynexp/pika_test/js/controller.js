(function () {
	window.App.controller('AppController', [
		'$scope',
		'$window',
		'Experiment',
		'$state',
		'$stateParams',
		'Status',
		'GlobalService',
		'host',
		'$http',
		'CONSTANTS',
		'DeviceInfo',
		'$timeout',
		'$rootScope',
		'$uibModal',
		'focus',
		function AppController ($scope, $window, Experiment, $state, $stateParams, Status, GlobalService,
			host, $http, CONSTANTS, DeviceInfo, $timeout, $rootScope, $uibModal, focus) {

				$scope.error = true;
				$scope.cancel = false;
				$scope.loop = [];
				$scope.samples = ['','','','','',''];
				$scope.samples_B = ['','','','','','','',''];
				$scope.CONSTANTS = CONSTANTS;
				$scope.isFinite = isFinite;
				$scope.showSidebar = true;
				$scope.famCq=[];
				$scope.hexCq=[];
				$scope.amount=[];
				$scope.result=[];
				$scope.amount[0]="-";
				$scope.amount[1]="-";
				$('.content').addClass('analyze');
				$scope.editExpNameMode = [false,false,false,false,false,false];
				$scope.cq = [["channel","well_num","cq"],[1,1,11],[1,2,null],[1,3,22],[1,4,40],[1,5,40],[1,6,null],[1,7,null],[1,8,null],[1,9,null],[1,10,null],[1,11,null],[1,12,null],[1,13,null],[1,14,null],[1,15,null],[1,16,null],[2,1,null],[2,2,"25.15"],[2,3,null],[2,4,"6.79"],[2,5,null],[2,6,null],[2,7,null],[2,8,null],[2,9,null],[2,10,null],[2,11,null],[2,12,null],[2,13,null],[2,14,null],[2,15,null],[2,16,null]];

				function getId(){
					if($stateParams.id){
						$scope.experimentId = $stateParams.id;
						getExperiment($scope.experimentId)
						Experiment.getWells($scope.experimentId).then(function(resp){
							console.log(resp);
							var j=0;
							for (var i = 2; i < 8; i++) {
								$scope.samples[j] = resp.data[i].well.sample_name;
								j++;
							}
							for (var k = 8; k < 16; k++){
								$scope.samples_B[k-8] = resp.data[k].well.sample_name;
							}
						});
					}
					else{
						$timeout(function () {
							getId();
						}, 500);
					}
				}
				getId();

				console.log($scope.cq);

				$scope.focusExpName = function(index){
					$scope.editExpNameMode[index] = true;
					focus('editExpNameMode');
				}

				$scope.updateWellA = function(index,x){
					document.activeElement.blur();
					Experiment.updateWell($scope.experimentId,index,{'sample_name':x}).then(function(resp){
					});
					$scope.editExpNameMode[index] = false;
					$scope.samples[index-3] = x;
				}

				$scope.updateWellB = function(index,name){
					Experiment.updateWell($scope.experimentId,index,{'sample_name':name}).then(function(resp){
					});
					$scope.editExpNameMode[index] = false;
					$scope.samples_B[index-9] = name;
				}

				$scope.setB = function(){
					$state.go('setWellsB');
					$scope.setProgress(70);
				}

				$scope.review = function(){
					$state.go('review');
					$scope.setProgress(140);
				}

				$scope.goToResults = function (){
					$scope.showSidebar = false;
					$scope.getResults();
					$state.go('results',{id: $scope.experimentId});
				}

				$scope.setProgress = function(value){
					var skillBar = $('.inner');
					$(skillBar).animate({
						height: value
					}, 1500);
				}

				function getAmountArray(){
					for (var i = 2; i < 16; i++) {
						if($scope.result[i] == "Inhibited"){
							$scope.amount[i] = "Invalid";
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

				function getResultArray(){
					if($scope.famCq[0]>0 && $scope.famCq[0]<38 ){
						$scope.result[0]="Valid";
					}
					else{
						$scope.result[0]="Invalid";
					}
					if(($scope.famCq[1] == 0 || $scope.famCq[1]>39 || !$scope.famCq[1]) && ($scope.hexCq[1]>=25 && $scope.hexCq[1]<=36) ){
						$scope.result[1]="Valid";
					}
					else{
						$scope.result[1]="Invalid";
					}

					for (var i = 2; i < 16; i++) {
						if($scope.famCq[i]>=10 && $scope.famCq[i]<=38){
							$scope.result[i]="Positive";
						}

						else if (($scope.famCq[i]>38 || !$scope.famCq[i]) && ($scope.hexCq[i]>0 && $scope.hexCq[i]<=36)) {
							$scope.result[i]="Negative";
						}

						else if (($scope.famCq[i]>38 || $scope.famCq[i]<9.9) && ($scope.hexCq[i]>36 || !$scope.hexCq[i])) {
							$scope.result[i]="Inhibited";
						}

						else{
							$scope.result[i]="";
						}
					}
				}


				$scope.getResults = function (){
					for (var i = 1; i < 17; i++) {
						//if($scope.cq[i][2]){
							$scope.famCq[i-1] = parseFloat($scope.cq[i][2]);
						//}
						//else{
							//$scope.famCq[i-1] = "";
						//}
					}
					for (var i = 17; i < 33; i++) {
						//if($scope.cq[i][2]){
							$scope.hexCq[i-17] = parseFloat($scope.cq[i][2]);
						//}
						//else{
							//$scope.hexCq[i-17] = "";
						//}
					}

					getResultArray();

				}

				function getExperiment(exp_id, cb) {
					Experiment.get(exp_id).then(function (resp) {
						$scope.experiment = resp.data.experiment;
						if(cb) cb(resp.data.experiment);
					});
				}


				$scope.$watch(function () {
					return Status.getData();
				}, function (data, oldData) {
					if (!data) return;
					if (!data.experiment_controller) return;
					if (!oldData) return;
					if (!oldData.experiment_controller) return;

					$scope.data = data;
					$scope.state = data.experiment_controller.machine.state;
					$scope.old_state = oldData.experiment_controller.machine.state;
					$scope.timeRemaining = GlobalService.timeRemaining(data);

					if (data.experiment_controller.experiment && !$scope.experiment) {
						getExperiment(data.experiment_controller.experiment.id);
					}

					if($scope.state === 'idle' && $scope.old_state !=='idle') {
						// exp complete
						checkExperimentStatus();
					}

					if($scope.state === 'idle' && $scope.old_state ==='idle' && $state.current.name === 'exp-running') {
						getExperiment(data.experiment_controller.experiment.id);
						if($scope.experiment.completion_status === 'failure') {
							$state.go('analyze', {id: $scope.experiment.id});
						}
					}

					if ($state.current.name === 'analyze') Status.stopSync();

				}, true);

				function checkExperimentStatus(){
					Experiment.get($scope.experiment.id).then(function (resp) {
						$scope.experiment = resp.data.experiment;
						if($scope.experiment.completed_at){
							$state.go('analyze', {id: $scope.experiment.id});
						}
						else{
							$timeout(checkExperimentStatus, 1000);
						}
					});
				}


				$scope.checkMachineStatus = function() {

					DeviceInfo.getInfo($scope.check).then(function(deviceStatus) {
						// Incase connected
						if($scope.modal) {
							$scope.modal.close();
							$scope.modal = null;
						}

						if(deviceStatus.data.optics.lid_open === "true" || deviceStatus.data.lid.open === true) { // lid is open
							$scope.error = true;
							$scope.lidMessage = "Close lid to begin.";
						} else {
							$scope.error = false;
						}
					}, function(err) {
						// Error
						$scope.error = true;
						$scope.lidMessage = "Cant connect to machine.";

						if(err.status === 500) {

							if(! $scope.modal) {
								var scope = $rootScope.$new();
								scope.message = {
									title: "Cant connect to machine.",
									body: err.data.errors || "Error"
								};

								$scope.modal = $uibModal.open({
									templateUrl: './views/modal-error.html',
									scope: scope
								});
							}
						}
					});

					$scope.timeout = $timeout($scope.checkMachineStatus, 1000);
				};

				$scope.checkMachineStatus();

				$scope.analyzeExperiment = function () {
					$scope.analyzing = true;
					if (!$scope.analyzedExp) {
						getExperiment($stateParams.id, function (exp) {
							if (exp.completion_status === 'success') {
								Experiment.analyze($stateParams.id)
								.then(function (resp) {
									console.log(resp);
									if(resp.status == 200){
										$scope.analyzedExp = resp.data;
										$scope.tm_values = GlobalService.getTmValues(resp.data);
										$scope.analyzing = false;
									}
									else if (resp.status == 202){
										$timeout($scope.analyzeExperiment, 1000);
									}
								})
								.catch(function (resp) {
									console.log(resp);
									if(resp.status == 500){
										$scope.custom_error = resp.data.errors || "An error occured while trying to analyze the experiment results.";
										$scope.analyzing = false;
									}
									else if(resp.status ==503){
										$timeout($scope.analyzeExperiment, 1000);
									}
								});
							}
							else {
								$scope.analyzing = false;
							}
						});
					}
				};

				$scope.lidHeatPercentage = function () {
					if (!$scope.experiment) return 0;
					if (!$scope.data) return 0;
					return ($scope.data.lid.temperature/$scope.experiment.protocol.lid_temperature);
				};

				$scope.blockHeatPercentage = function () {
					var blockHeat = $scope.getBlockHeat();
					if (!blockHeat) return 0;
					if (!$scope.experiment) return 0;
					return ($scope.data.heat_block.temperature/blockHeat);
				};

				$scope.getBlockHeat = function () {
					if (!$scope.experiment) return;
					if (!$scope.experiment.protocol.stages[0]) return;
					if (!$scope.experiment.protocol.stages[0].stage.steps[0]) return;
					if (!$scope.currentStep()) return;
					return $scope.currentStep().temperature;
				};

				$scope.createExperiment = function () {
					Experiment.create({guid: 'thermal_consistency'}).then(function (resp) {
						$timeout.cancel($scope.timeout);
						Experiment.startExperiment(resp.data.experiment.id).then(function () {
							$scope.experiment = resp.data.experiment;
							$state.go('exp-running');
						});
					});
				};

				$scope.cancelExperiment = function () {
					Experiment.stopExperiment($scope.experiment_id).then(function () {
						var redirect = '/#/settings/';
						$window.location = redirect;
					});
				};


			}
		]);
	})();
