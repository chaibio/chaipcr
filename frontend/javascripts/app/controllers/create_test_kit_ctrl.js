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
	function(Device, $scope, Status, $http, $window, $timeout, $location) {

		$scope.is_dual_channel = false;
		$scope.update_available = 'unavailable';
		$scope.exporting = false;
		$scope.value = "Select a value ";
		$scope.selectedKit = "1";
		$scope.kit = {
				name: 'Lactobacillaceae Screening'
			};


		$scope.myFunction = function() {
			document.getElementById("myDropdown").classList.toggle("show");
		};

		$scope.select = function(kit){
			alert(kit);
		};

		$scope.create = function(){
			$window.location.href = "/dynexp/pika_test/index.html#/setWellsA/5" ;

		};


		// Close the dropdown if the user clicks outside of it
		window.onclick = function(event) {
			if (!event.target.matches('.dropbtn')) {

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
