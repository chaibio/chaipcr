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

window.ChaiBioTech.ngApp.controller('systemController', [
	'Device',
	'$scope',
	'Status',
	'$http',
	'$window',
	'$timeout',
	function(Device, $scope, Status, $http, $window, $timeout) {

		$scope.is_dual_channel = false;
		$scope.update_available = 'unavailable';
		$scope.exporting = false;
		$scope.getVersionSoft = function() {
			Device.getVersion(true).then(function(resp) {
				console.log(resp);
				$scope.data = resp;
			}, function(noData) {
				console.log(noData);
				// This is dummy data, to local checking. Will be removed.
				$scope.data = {
					"serial_number": "1234789127894212",
					"model_number": "M2342JA",
					"processor_architecture": "armv7l",
					"software": {
						"version": "1.0.0",
						"platform": "S0100"
					}
				};
			});
		};

		$scope.$on('status:data:updated', function(e, data) {
			status = (data && data.device) ? data.device.update_available : 'unknown';
			if (status !== 'unknown')
				$scope.update_available = status;
			if (data.device.update_available == 'unknown' && data.device.update_error) {
				if ($scope.checkedUpdate){
					//$scope.openUpdateModal();
				}
				//$scope.update_available = 'unavailable';
				//$scope.checkedUpdate = false;
				//$scope.openUpdateModal();
			}
		});

		$scope.openUpdateModal = function() {
			Device.openUpdateModal();
		};

		$scope.openUploadModal = function() {
			Device.openUploadModal();
		};

		$scope.export = function() {
			$scope.exporting = true;
			var isChrome = !!window.chrome;
			//alert(/Edge/.test(navigator.userAgent));
			console.log(isChrome);
			//debugger;
			if (isChrome && !(/Edge/.test(navigator.userAgent))) {
				Device.exportDatabase().then(function(response) {
					var blob = new Blob([response.data], {
						type: 'application/octet-stream'
					});
					var link = document.createElement('a');
					link.href = window.URL.createObjectURL(blob);
					link.download = "exportdb.zip";
					link.click();
					$scope.exporting = false;
					console.log(response);
				}, function(response) {
					console.log(response);
					$scope.exporting = false;
				});
			} else {
				$scope.exporting = false;
				$window.location.assign("/device/export_database");
			}
		};

		$scope.checkUpdate = function() {

			var checkPromise;
			$scope.checking_update = true;
			checkPromise = Device.checkForUpdate();
			checkPromise.then(function(is_available) {
				console.log(is_available);
				$scope.update_available = is_available;
				$scope.checkedUpdate = true;
				if (is_available === 'available') {
					$scope.openUpdateModal();
				}
			});
			checkPromise["catch"](function() {
				alert('Error while checking update!');
				$scope.update_available = 'unavailable';
				$scope.checkedUpdate = false;
			});
			return checkPromise["finally"](function() {
				$scope.checking_update = false;
			});
		};

		$scope.getVersionSoft();
	}

]);
