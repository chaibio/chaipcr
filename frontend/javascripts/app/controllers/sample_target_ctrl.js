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

window.ChaiBioTech.ngApp.controller('SampleTargetCtrl', [
	'$scope',
	'Status',
	'$http',
	'Device',
	'$window',
	'$timeout',
	'$location',
	'$state',
	'Experiment',
	'$uibModal',
	'$stateParams',
	'AmplificationChartHelper',
	function($scope, Status, $http, Device, $window, $timeout, $location, $state, Experiment, $uibModal, $stateParams, AmplificationChartHelper) {

		Experiment.get({id: $stateParams.id}).then(function(response){
			$scope.experiment = response.experiment;
		});

		Device.isDualChannel().then(function(is_dual_channel){
			$scope.is_dual_channel = is_dual_channel ;
			console.log(is_dual_channel);
		});

		$scope.rows = [];
		$scope.targets = [];

		$scope.colors = AmplificationChartHelper.COLORS ;

		console.log($scope.colors);

		$scope.getSamples = function(){
			Experiment.getSamples($stateParams.id).then(function(resp){
				$scope.rows = [];
				var i;
				for (i = 0; i < resp.data.length; i++) {
					$scope.rows[i] = resp.data[i].sample;
					$scope.rows[i].confirmDelete = false;
				}

			});
		};

		$scope.getTargets = function(){
			Experiment.getTargets($stateParams.id).then(function(resp){
				$scope.targets = [];
				var i;
				for (i = 0; i < resp.data.length; i++) {
					$scope.targets[i] = resp.data[i].target;
					$scope.targets[i].confirmDelete = false;
					$scope.targets[i].selectChannel = false;
					if(resp.data[i].target.targets_wells.length > 0){
						$scope.targets[i].assigned = true;
					}
					else{
						$scope.targets[i].assigned = false;
					}
				}
				console.log($scope.targets);

			});
		};

		$scope.getSamples();
		$scope.getTargets();


		$scope.create = function() {
			Experiment.getSamples($stateParams.id).then(function(resp){
				Experiment.createSample($stateParams.id,{name: "Sample "+(resp.data.length+1)}).then(function(response) {
					$scope.getSamples();
				});
			});

		};

		$scope.createTarget = function(){
			Experiment.getTargets($stateParams.id).then(function(resp){
				Experiment.createTarget($stateParams.id,{name: "Target "+(resp.data.length+1), channel: 1}).then(function(response) {
					$scope.getTargets();
				});
			});
		};

		$scope.updateTargetChannel = function(id, value){
			Experiment.updateTarget($stateParams.id, id, {channel: value}).then(function(resp) {
				$scope.getTargets();
			});
		};

		$scope.focusSample = function (id, value, indexValue){
			if(value == "Sample " + (indexValue+1)){
				$scope.rows[indexValue].name = "";
			}
		};

		$scope.focusTarget = function (id, value, indexValue){
			if(value == "Target " + (indexValue+1)){
				$scope.targets[indexValue].name = "";
			}
		};

		$scope.updateSample = function(id, value, indexValue) {
			document.activeElement.blur();
			if(value == ""){
				value = "Sample " + (indexValue+1);
			}
			Experiment.updateSample($stateParams.id, id, {name: value}).then(function(resp) {
				$scope.getSamples();
			});
			//$scope.editExpNameMode[index] = false;
			//$scope.samples[index - 3] = x;
		};

		$scope.updateTargetName = function(id, value, indexValue) {
			document.activeElement.blur();
			if(value == ""){
				value = "Target " + (indexValue+1);
			}
			Experiment.updateTarget($stateParams.id, id, {name: value}).then(function(resp) {
				$scope.getTargets();
			});
			//$scope.editExpNameMode[index] = false;
			//$scope.samples[index - 3] = x;
		};

		$scope.deleteSample = function (id) {
			Experiment.deleteSample($stateParams.id,id).then(function(resp){
				$scope.getSamples();
			})
			.catch(function(response){
				if(response.status == 422){
					console.log(response.data.sample.errors.base[0]);
				}
			});
		};

		$scope.deleteTarget = function (id) {
			Experiment.deleteLinkedTarget($stateParams.id,id).then(function(resp){
				$scope.getTargets();
			})
			.catch(function(response){
				if(response.status == 422){
					console.log(response.data.target.errors.base[0]);
				}
			});
		};

		$scope.openImportStandards = function(){
			modalInstance = $uibModal.open({
				templateUrl: 'app/views/import-standards.html',
				controller: 'SampleTargetCtrl',
				openedClass: 'modal-open-standards',
				backdrop: false
			});

		return modalInstance;
		};



	}

]);
