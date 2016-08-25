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

window.ChaiBioTech.ngApp.directive('deleteMode', [
	'HomePageDelete',
	function(HomePageDelete) {
		return {
			restric: 'EA',
			replace: true,
			templateUrl: 'app/views/directives/delete-mode.html',
			scope: {
				'deleteMode': '=mode',
				'deleteExp': '&',
				'experiment': '=experiment'
			},

			link: function(scope, elem, attr) {

				scope.deleteClicked = false;
				scope.running = false;
				scope.deleting = false

				var identifierClass = 'home-page-active-del-identifier';

				scope.$watch('deleteMode', function(newVal, oldVal) {
					HomePageDelete.activeDelete = HomePageDelete.activeDeleteElem = false;
					if (newVal === false && scope.deleteClicked) {
						scope.reset();
					}
				});

				scope.$watch('experiment', function(newVal, oldVal) {
					if (newVal) {
						scope.running = (newVal.started_at || false) && !(newVal.completed_at || false);
						// console.log(scope.running, newVal.started_at, newVal.completed_at);
					}
				});

				scope.deleteClickedHandle = function() {

					if (!scope.running) {
						scope.deleteClicked = !scope.deleteClicked;
						HomePageDelete.deactiveate(scope, elem);

						if (scope.deleteClicked) {
							angular.element(elem).parent()
								.addClass(identifierClass);
							angular.element(HomePageDelete.activeDeleteElem).parent()
								.removeClass(identifierClass);
							HomePageDelete.activeDeleteElem = elem;
						} else {
							angular.element(elem).parent().removeClass(identifierClass);
						}

						HomePageDelete.activeDelete = scope;
					}
				};

				scope.reset = function() {
					scope.deleteClicked = false;
					angular.element(elem).parent().removeClass(identifierClass);
				};

				scope.tryDeletion = function() {
					scope.deleting = true;
					debugger;
					scope.deleteClicked = true;
					//scope.deleting = true;
					scope.deleteExp(scope.experiment);
					//scope.deleting = false;
				};

			}
		};
	}
]);
