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
				$('.content').addClass('analyze');
				$scope.editExpNameMode = [false,false,false,false,false,false];

				function getId(){
					if($state.current.name == "setWellsA"){
						$scope.experimentId = $stateParams.id;
						//alert($stateParams.id);
						getExperiment($scope.experimentId)
					}
					else{
						$timeout(function () {
							getId();
						}, 500);
					}
				}
				getId();

				$scope.focusExpName = function(index){
					$scope.editExpNameMode[index] = true;
					focus('editExpNameMode');
				}

				$scope.updateWellA = function(index,x){
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
					$scope.setProgress(100);
				}

				$scope.setProgress = function(value){
					//$('.skill').on('click', 'button', function(){
					var skillBar = $('.inner');
					$(skillBar).animate({
						height: value
					}, 1500);
					//});
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
