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
				$scope.editExpName = false;
				$scope.amount[0]="\u2014";
				$scope.amount[1]="\u2014";
				$scope.assignA = true;
				$scope.assignB = false;
				$scope.assignReview = false;
				$scope.experimentComplete = false;
				$('.content').addClass('analyze');
				$scope.editExpNameMode = [false,false,false,false,false,false];
				var enterState = false;
				var fromHome = true;
				$scope.analyzing = true;
				$scope.twoKits = false;
				$scope.notes = [];
				//$scope.notes_B = [];
				$scope.indexA = "fdsfsfdsfdsf";
				$scope.editNotes = false;
				//	$scope.cq = [["channel","well_num","cq"],[1,1,"39"],[1,2,2],[1,3,40],[1,4,9],[1,5,20],[1,6,"26"],[1,7,"33"],[1,8,"5"],[1,9,"34.5"],[1,10,"19"],[1,11,"12"],[1,12,"6"],[1,13,"24"],[1,14,"39"],[1,15,"32"],[1,16,"18"],[2,1,"11"],[2,2,"25.15"],[2,3,36],[2,4,"8"],[2,5,"34"],[2,6,"10"],[2,7,"15"],[2,8,"25"],[2,9,"35"],[2,10,"28"],[2,11,"2"],[2,12,"7"],[2,13,"0"],[2,14,"35"],[2,15,"28"],[2,16,"17"]];

				this.getResultArray = getResultArray;

				function getId(){
					if($stateParams.id){
						$scope.experimentId = $stateParams.id;
						getExperiment($scope.experimentId);
						Experiment.getWells($scope.experimentId).then(function(resp){
							console.log(resp);
							$scope.target = resp.data[0].well.targets[0];
							$scope.target2 = resp.data[8].well.targets[0];
							if($scope.target != $scope.target2){
								$scope.twoKits = true;
							}

							var j=0;
							for (var i = 2; i < 8; i++) {
								$scope.samples[j] = resp.data[i].well.sample_name;
								j++;
							}
							if(!$scope.twoKits){
								for (var k = 8; k < 16; k++){
									$scope.samples_B[k-8] = resp.data[k].well.sample_name;
								}
							}
							else{
								$scope.samples_B = ['','','','','',''];
								for (var k = 10; k < 16; k++){
									$scope.samples_B[k-10] = resp.data[k].well.sample_name;
								}
							}
							for(var i = 0; i<16; i++){
								$scope.notes[i] = resp.data[i].well.notes;
							}
							//for(var i = 8; i<16; i++){
							//$scope.notes_B[i-8] = resp.data[i].well.notes;
							//}
						});
					}
					else{
						$timeout(function () {
							getId();
						}, 500);
					}
				}
				getId();


				$scope.focusExpName = function(index){
					$scope.editExpName = true;
					focus('editExpName');
				}

				$scope.focusNotes = function(){
					$scope.editNotes = true;
					focus('editNotes');
				}

				$scope.updateNotes = function(index,x){
					Experiment.updateWell($scope.experimentId,index+1,{'notes':x}).then(function(resp){
						$scope.editNotes = false;
						$scope.cancel();
					});
				}

				$scope.updateExperimentName = function(){
					Experiment.updateExperimentName($scope.experimentId,{name:$scope.experiment.name}).then(function(resp){
						$scope.editExpName = false;
					});
				}

				$scope.cancel = function() {
					$scope.modalInstance.close();
					Experiment.getWells($scope.experimentId).then(function(resp){
						for(var i = 0; i<16; i++){
							$scope.notes[i] = resp.data[i].well.notes;
						}
					});
				};

				$scope.updateWellA = function(index,x){
					document.activeElement.blur();
					Experiment.updateWell($scope.experimentId,index,{'sample_name':x}).then(function(resp){
					});
					$scope.editExpNameMode[index] = false;
					$scope.samples[index-3] = x;
				}

				$scope.openNotes = function (index){
					$scope.indexAB = index;
					if(!$scope.notes[index]){
						$scope.editNotes =true;
					}
					openInstance();
				}

				function openInstance(){
					 $scope.modalInstance = $uibModal.open({
						scope: $scope,
						templateUrl: '/dynexp/pika_test/intro.html',
						backdrop: false
					});
				}

				$scope.updateWellB = function(index,name){
					Experiment.updateWell($scope.experimentId,index,{'sample_name':name}).then(function(resp){
					});
					$scope.editExpNameMode[index] = false;
					if(!$scope.twoKits){
						$scope.samples_B[index-9] = name;
					}
					else{
						$scope.samples_B[index-11] = name;
					}
				}

				$scope.setB = function(){
					$state.go('setWellsB');
					$scope.setProgress(70);
					$scope.assignB = true;
				}

				$scope.review = function(){
					$state.go('review');
					$scope.assignReview = true;
					$scope.setProgress(160);
				}

				$scope.goToResults = function (){
					//$scope.showSidebar = false;
					if(fromHome){
						$scope.showSidebar = false;
					}
					if (!enterState){
						if($scope.experimentId){
							$scope.getResults();
							enterState = true;
						}
						else{
							$timeout(function () {
								$scope.goToResults();
							}, 500);
						}
					}
					//$scope.getResults();
					//$state.go('results',{id: $scope.experimentId});
				}

				$scope.startExperiment = function(){
					Experiment.startExperiment($scope.experimentId).then(function(resp){
						$state.go('exp-running',{id: $scope.experimentId});
					});
				}

				$scope.setProgress = function(value){
					var skillBar = $('.inner');
					$(skillBar).animate({
						height: value
					}, 1500);
				}

				$scope.goBackToA = function () {
					$state.go('setWellsA',{id: $scope.experimentId});
					$scope.setProgress(0);
					$scope.assignB = false;
				}

				$scope.goBackToB = function(){
					$state.go('setWellsB');
					$scope.setProgress(70);
					$scope.assignB = true;
					$scope.assignReview = false;
				}

				$scope.goBackToHome = function(){
					$window.location = '/#/'
				}

				$scope.goToAmplification = function(){
					$window.location = '/#/experiments/' + $scope.experimentId + '/run-experiment?chart=amplification';
				}

				$scope.viewResults = function(){
					$scope.showSidebar = false;
					$state.go('results',{id: $scope.experimentId});
				}

				function getAmountArray(){
					for (var i = 2; i < 8; i++) {
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
						for (var i = 8; i < 16; i++) {
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
						for (var i = 10; i < 16; i++) {
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

				function getResultArray(){
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

					for (var i = 2; i < 8; i++) {
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
						for (var i = 8; i < 16; i++) {
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

						for (var i = 10; i < 16; i++) {
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


				$scope.getResults = function (){
					$scope.analyzing = true;
					$scope.experimentComplete = true;
					Experiment.getFluorescenceData($scope.experimentId).then(function(resp){
						if(resp.status == 200 && !resp.data.partial){
							$scope.analyzing = false;
							$scope.cq = resp.data.steps[0].cq;
							//$scope.cq = [["channel","well_num","cq"],[1,1,"20.76"],[1,2,42.13],[1,3,40.89],[1,4,9.47],[1,5,20],[1,6,"26.33"],[1,7,"33.89"],[1,8,"5"],[1,9,"34.5"],[1,10,"19"],[1,11,"12"],[1,12,"6"],[1,13,"24"],[1,14,"39"],[1,15,"32"],[1,16,"18"],[2,1,"11"],[2,2,"25.15"],[2,3,36],[2,4,"8"],[2,5,"34"],[2,6,"10"],[2,7,"15"],[2,8,"25"],[2,9,"35"],[2,10,"28"],[2,11,"2"],[2,12,"7"],[2,13,"0"],[2,14,"35"],[2,15,"28"],[2,16,"17"]];
							for (var i = 1; i < 17; i++) {
								$scope.famCq[i-1] = parseFloat($scope.cq[i][2]);
							}
							for (var i = 17; i < 33; i++) {
								$scope.hexCq[i-17] = parseFloat($scope.cq[i][2]);
							}
							getResultArray();
						}
						else if(resp.data.partial || resp.status == 202){
							$timeout($scope.getResults, 1000);
						}

					})
					.catch(function (resp) {
						console.log(resp);
						if(resp.status == 500){
							$scope.custom_error = resp.data.errors || "An error occured while trying to analyze the experiment results.";
							$scope.analyzing = false;
							$state.go('results', {id: $scope.experiment.id});
							fromHome = true;
							enterState =true;
						}
						else if(resp.status ==503){
							$timeout($scope.getResults, 1000);
						}
					});
					/*	for (var i = 1; i < 17; i++) {
					$scope.famCq[i-1] = parseFloat($scope.cq[i][2]);
				}
				for (var i = 17; i < 33; i++) {
				$scope.hexCq[i-17] = parseFloat($scope.cq[i][2]);
			}

			getResultArray(); */

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
			$scope.stateName = $state.current.name;

			if($scope.state === 'idle' && $scope.old_state !=='idle') {
				// exp complete
				checkExperimentStatus();
			}

			if($state.current.name === 'exp-running'){
				$scope.hideAbondon = true;
				$scope.setProgress(160);
			}

			if($scope.state === 'idle' && $scope.old_state ==='idle' && $state.current.name === 'exp-running') {
				getExperiment($scope.experimentId);
				if($scope.experiment.completion_status && $scope.experiment.completion_status !== 'success') {
					$state.go('results', {id: $scope.experiment.id});
					//fromHome = true;
					enterState =true;
					$scope.analyzing = false;
				}
			}

			if ($state.current.name === 'analyze') Status.stopSync();

		}, true);

		function checkExperimentStatus(){
			Experiment.get($scope.experiment.id).then(function (resp) {
				$scope.experiment = resp.data.experiment;
				if($scope.experiment.completed_at){
					if($scope.experiment.completion_status === 'success'){
						fromHome = false;
						$scope.goToResults();
					}
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
				} else if((deviceStatus.data.experiment_controller.id !== $scope.experimentId) && (deviceStatus.data.experiment_controller.machine.state !== "idle")) {
					$scope.error = true;
					$scope.lidMessage = "Another experiment in Progress.";
				}
				else{
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

		$scope.cancelExperiment = function () {
			Experiment.stopExperiment($scope.experimentId).then(function () {
				var redirect = '/#/';
				$window.location = redirect;
			});
		};


	}
]);
})();
