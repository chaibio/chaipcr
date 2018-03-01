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

window.ChaiBioTech.ngApp.controller('CreateTestKitCtrl', [
	'Device',
	'$scope',
	'Status',
	'$http',
	'$window',
	'$timeout',
	'$location',
	'$state',
	'Testkit',
	function(Device, $scope, Status, $http, $window, $timeout, $location, $state, Testkit) {

		$scope.is_dual_channel = false;
		$scope.update_available = 'unavailable';
		$scope.exporting = false;
		$scope.value = "Choose Manufacturer ..";
		$scope.selectedKit = 1;
		$scope.kit = {
			name: 'Lactobacillaceae Screening'
		};
		$scope.kit1 = {
			name: 'Lactobacillaceae Screening'
		};
		$scope.kit2 = {
			name: 'Lactobacillaceae Screening'
		};

		$scope.creating = false;

		$scope.myFunction = function() {
			document.getElementById("myDropdown").classList.toggle("show");
		};

		$scope.select = function(kit){
			alert(kit);
		};

		$scope.create = function(){
			$scope.creating = true;
			if($scope.selectedKit == 1 || ($scope.selectedKit == 2 && $scope.kit1.name == $scope.kit2.name )){
				$scope.wells = [
					{'well_num':1,'well_type':'positive_control','sample_name':'Positive Control','notes':'','targets':[$scope.kit.name,'']},
					{'well_num':2,'well_type':'no_template_control','sample_name':'Negative Control','notes':'','targets':[$scope.kit.name,'']},
					{'well_num':3,'well_type':'sample','sample_name':'','notes':'','targets':[$scope.kit.name,'']},
					{'well_num':4,'well_type':'sample','sample_name':'','notes':'','targets':[$scope.kit.name,'']},
					{'well_num':5,'well_type':'sample','sample_name':'','notes':'','targets':[$scope.kit.name,'']},
					{'well_num':6,'well_type':'sample','sample_name':'','notes':'','targets':[$scope.kit.name,'']},
					{'well_num':7,'well_type':'sample','sample_name':'','notes':'','targets':[$scope.kit.name,'']},
					{'well_num':8,'well_type':'sample','sample_name':'','notes':'','targets':[$scope.kit.name,'']},
					{'well_num':9,'well_type':'sample','sample_name':'','notes':'','targets':[$scope.kit.name,'']},
					{'well_num':10,'well_type':'sample','sample_name':'','notes':'','targets':[$scope.kit.name,'']},
					{'well_num':11,'well_type':'sample','sample_name':'','notes':'','targets':[$scope.kit.name,'']},
					{'well_num':12,'well_type':'sample','sample_name':'','notes':'','targets':[$scope.kit.name,'']},
					{'well_num':13,'well_type':'sample','sample_name':'','notes':'','targets':[$scope.kit.name,'']},
					{'well_num':14,'well_type':'sample','sample_name':'','notes':'','targets':[$scope.kit.name,'']},
					{'well_num':15,'well_type':'sample','sample_name':'','notes':'','targets':[$scope.kit.name,'']},
					{'well_num':16,'well_type':'sample','sample_name':'','notes':'','targets':[$scope.kit.name,'']}
				];
				Testkit.create({guid:'pika_4e_kit',name:$scope.kit.name}).then(function (resp){
					Testkit.createWells(resp.data.experiment.id,$scope.wells).then(function(response){
						$state.go('pika_test.setWellsA', {id: resp.data.experiment.id});
						$scope.$close();
						// $window.location.href = "/dynexp/pika_test/index.html#/setWellsA/"+resp.data.experiment.id ;
					})
					.catch(function(response){
						$scope.creating = false;
						$scope.error = response.data.errors || "An error occured while trying to create the experiment.";
					});
				});
			}
			else if($scope.selectedKit == 2 && $scope.kit1.name != $scope.kit2.name){
				$scope.wells = [
					{'well_num':1,'well_type':'positive_control','sample_name':'Positive Control','notes':'','targets':[$scope.kit1.name,'']},
					{'well_num':2,'well_type':'no_template_control','sample_name':'Negative Control','notes':'','targets':[$scope.kit1.name,'']},
					{'well_num':3,'well_type':'sample','sample_name':'','notes':'','targets':[$scope.kit1.name,'']},
					{'well_num':4,'well_type':'sample','sample_name':'','notes':'','targets':[$scope.kit1.name,'']},
					{'well_num':5,'well_type':'sample','sample_name':'','notes':'','targets':[$scope.kit1.name,'']},
					{'well_num':6,'well_type':'sample','sample_name':'','notes':'','targets':[$scope.kit1.name,'']},
					{'well_num':7,'well_type':'sample','sample_name':'','notes':'','targets':[$scope.kit1.name,'']},
					{'well_num':8,'well_type':'sample','sample_name':'','notes':'','targets':[$scope.kit1.name,'']},
					{'well_num':9,'well_type':'sample','sample_name':'Positive Control','notes':'','targets':[$scope.kit2.name,'']},
					{'well_num':10,'well_type':'sample','sample_name':'Negative Control','notes':'','targets':[$scope.kit2.name,'']},
					{'well_num':11,'well_type':'sample','sample_name':'','notes':'','targets':[$scope.kit2.name,'']},
					{'well_num':12,'well_type':'sample','sample_name':'','notes':'','targets':[$scope.kit2.name,'']},
					{'well_num':13,'well_type':'sample','sample_name':'','notes':'','targets':[$scope.kit2.name,'']},
					{'well_num':14,'well_type':'sample','sample_name':'','notes':'','targets':[$scope.kit2.name,'']},
					{'well_num':15,'well_type':'sample','sample_name':'','notes':'','targets':[$scope.kit2.name,'']},
					{'well_num':16,'well_type':'sample','sample_name':'','notes':'','targets':[$scope.kit2.name,'']}
				];
				Testkit.create({guid:'pika_4e_kit',name:$scope.kit1.name + ' & ' + $scope.kit2.name }).then(function (resp){
					Testkit.createWells(resp.data.experiment.id,$scope.wells).then(function(response){
						$state.go('pika_test.setWellsA', {id: resp.data.experiment.id});
						$scope.$close();
						// $window.location.href = "/dynexp/pika_test/index.html#/setWellsA/"+resp.data.experiment.id ;
					})
					.catch(function(response){
						$scope.creating = false;
						$scope.error = response.data.errors || "An error occured while trying to create the experiment.";
					});
				});
			}
			//$window.location.href = "/dynexp/pika_test/index.html#/setWellsA/5" ;
		};

		// Close the dropdown if the user clicks outside of it
		window.onclick = function(event) {

			if(! event.target || ! event.target.matches) {
				return false;
			}
			if (!event.target.matches('.dropbtn') && !event.target.matches('.test') && !event.target.matches('.arrow-down') ) {
				var dropdowns = document.getElementsByClassName("dropdown-content");
				var i;
				for (i = 0; i < dropdowns.length; i++) {
					var openDropdown = dropdowns[i];
					if (openDropdown.classList.contains('show')) {
						openDropdown.classList.remove('show');
					}
				}
			}
		};
	}

]);
