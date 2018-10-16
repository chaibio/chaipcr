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

window.ChaiBioTech.ngApp.controller('PlateLayoutCtrl', [

	'$scope',
	'Status',
	'$http',
	'Device',
	'$window',
	'$timeout',
	'$location',
	'$state',
	'Experiment',
	'$stateParams',
	'AmplificationChartHelper',
	function ($scope, Status, $http, Device, $window, $timeout, $location, $state, Experiment, $stateParams, AmplificationChartHelper) {

		Experiment.get({ id: $stateParams.id }).then(function (response) {
			$scope.experiment = response.experiment;
		});

		$scope.wellInf = [];
		$scope.rowCharacters = ['A', 'B', 'C', 'D'];

		$scope.sampleSelected = "Select a Sample";
		$scope.target1Selected = "Select a Target";
		$scope.target2Selected = "Select a Target";
		$scope.target2SelectedColor = "white";
		$scope.target1SelectedColor = "white";
		$scope.colors = AmplificationChartHelper.COLORS;
		$scope.enableTarget1Type = false;
		$scope.clearSelected = "Select a value";
		//console.log($scope.colors);

		$scope.enableTarget1Qty = false;
		$scope.enableTarget2Qty = false;
		$scope.showSampleOptions = false;
		$scope.showTarget1Options = false;
		$scope.showTarget2Options = false;
		$scope.showClearOptions = false;
		$scope.target1Quantity = {
			value: null
		};
		$scope.target2Quantity = {
			value: null
		};

		$scope.selectionMade = false;

		$scope.clearValues = [
			{ value: 'Clear Ch 1 Target', id: 'Target1' }, { value: 'Clear Ch 2 Target', id: 'Target2' }, { value: 'Clear Sample', id: 'Sample' }
		];

		$scope.selected = null;

		$scope.openSampleOptions = function () {
			$scope.showSampleOptions = true;
			$scope.showTarget1Options = false;
			$scope.showTarget2Options = false;
			$scope.showClearOptions = false;
			$(".options-div").each(function (index) {
				$(this).css({ 'display': 'block' });
			});
		};

		$scope.openTarget1Options = function () {
			$scope.showTarget1Options = true;
			$scope.showSampleOptions = false;
			$scope.showTarget2Options = false;
			$scope.showClearOptions = false;
			$(".options-div").each(function (index) {
				$(this).css({ 'display': 'block' });
			});
		};

		$scope.openTarget2Options = function () {
			$scope.showTarget2Options = true;
			$scope.showSampleOptions = false;
			$scope.showTarget1Options = false;
			$scope.showClearOptions = false;
			$(".options-div").each(function (index) {
				$(this).css({ 'display': 'block' });
			});
		};

		$scope.openClearOptions = function () {
			$scope.showClearOptions = true;
			$scope.showTarget2Options = false;
			$scope.showSampleOptions = false;
			$scope.showTarget1Options = false;
			$(".options-div").each(function (index) {
				$(this).css({ 'display': 'block' });
			});
		};

		var string = "1eee10";
		var re = new RegExp("^[0-9]*.?[0-9]*[e]?[-|+]?[0-9]*$");
		if (re.test(string)) {
			console.log("Valid");
		} else {
			console.log("Invalid");
		}

		Device.isDualChannel().then(function (is_dual_channel) {
			$scope.is_dual_channel = is_dual_channel;
			if ($scope.is_dual_channel) {
				for (var x = 0; x < 16; x++) {
					$scope.wellInf[x] = {
						sample: "No sample",
						sampleid: 0,
						target1: "Not set",
						target1id: 0,
						target1type: "",
						target1quantityTotal: "",
						target1quantityM: "",
						target1quantityB: "",
						target2: "Not set",
						target2id: 0,
						target2type: "",
						target2quantityTotal: "",
						target2quantityM: "",
						target2quantityB: ""
					};
				}
				$scope.getWellLayout();
			}
			else {
				for (var y = 0; y < 16; y++) {
					$scope.wellInf[y] = {
						sample: "No sample",
						sampleid: 0,
						target1: "Not set",
						target1id: 0,
						target1type: "",
						target1quantityTotal: "",
						target1quantityM: "",
						target1quantityB: ""
					};
				}
				$scope.getWellLayout();

			}
		});


		$scope.samples = [];
		$scope.getSamples = function () {
			Experiment.getSamples($stateParams.id).then(function (resp) {
				var i;
				for (i = 0; i < resp.data.length; i++) {
					$scope.samples[i] = resp.data[i].sample;
				}

			});
		};

		$scope.getSamples();

		$scope.targets1 = [];

		$scope.targets2 = [];

		var lookup = [];

		$scope.getTargets = function () {
			Experiment.getTargets($stateParams.id).then(function (resp) {
				var i, l;
				var p = 0;
				var q = 0;
				for (i = 0; i < resp.data.length; i++) {
					if (resp.data[i].target.channel == 1) {
						$scope.targets1[p] = resp.data[i].target;
						$scope.targets1[p].color = $scope.colors[i];
						p++;
					}
					else {
						$scope.targets2[q] = resp.data[i].target;
						$scope.targets2[q].color = $scope.colors[i];
						q++;
					}
				}
				for (l = 0; l < resp.data.length; l++) {
					lookup[resp.data[l].target.id] = $scope.colors[l];
				}
			});
		};

		$scope.getTargets();

		function isEmpty(obj) {
			for (var key in obj) {
				if (obj.hasOwnProperty(key))
					return false;
			}
			return true;
		}

		$scope.getWellLayout = function () {
			Experiment.getWellLayout($stateParams.id).then(function (resp) {
				if (resp.data.length > 0) {
					for (i = 0; i < 16; i++) {
						if (resp.data[i].samples) {
							$scope.wellInf[i].sample = resp.data[i].samples[0].name;
							$scope.wellInf[i].sampleid = resp.data[i].samples[0].id;
						}
						if (resp.data[i].targets) {
							if (!isEmpty(resp.data[i].targets[0]) && !isEmpty(resp.data[i].targets[1])) {
								$scope.wellInf[i].target1 = resp.data[i].targets[0].name;
								$scope.wellInf[i].target1id = resp.data[i].targets[0].id;
								$scope.wellInf[i].target1color = lookup[resp.data[i].targets[0].id];
								if (resp.data[i].targets[0].well_type) {
									$scope.wellInf[i].target1type = resp.data[i].targets[0].well_type;
								}
								if (resp.data[i].targets[0].quantity) {
									$scope.wellInf[i].target1quantityTotal = resp.data[i].targets[0].quantity.m.toString() + 'e' + resp.data[i].targets[0].quantity.b.toString();
									$scope.wellInf[i].target1quantityM = resp.data[i].targets[0].quantity.m.toFixed(2);
									$scope.wellInf[i].target1quantityB = resp.data[i].targets[0].quantity.b;
								}
								$scope.wellInf[i].target2 = resp.data[i].targets[1].name;
								$scope.wellInf[i].target2id = resp.data[i].targets[1].id;
								$scope.wellInf[i].target2color = lookup[resp.data[i].targets[1].id];
								if (resp.data[i].targets[1].well_type) {
									$scope.wellInf[i].target2type = resp.data[i].targets[1].well_type;
								}
								if (resp.data[i].targets[1].quantity) {
									$scope.wellInf[i].target2quantityTotal = resp.data[i].targets[1].quantity.m.toString() + 'e' + resp.data[i].targets[1].quantity.b.toString();
									$scope.wellInf[i].target2quantityM = resp.data[i].targets[1].quantity.m.toFixed(2);
									$scope.wellInf[i].target2quantityB = resp.data[i].targets[1].quantity.b;
								}
							}
							else {
								if (!isEmpty(resp.data[i].targets[0])) {
									$scope.wellInf[i].target1 = resp.data[i].targets[0].name;
									$scope.wellInf[i].target1id = resp.data[i].targets[0].id;
									$scope.wellInf[i].target1color = lookup[resp.data[i].targets[0].id];
									if (resp.data[i].targets[0].well_type) {
										$scope.wellInf[i].target1type = resp.data[i].targets[0].well_type;
									}
									if (resp.data[i].targets[0].quantity) {
										$scope.wellInf[i].target1quantityTotal = resp.data[i].targets[0].quantity.m.toString() + 'e' + resp.data[i].targets[0].quantity.b.toString();
										$scope.wellInf[i].target1quantityM = resp.data[i].targets[0].quantity.m.toFixed(2);
										$scope.wellInf[i].target1quantityB = resp.data[i].targets[0].quantity.b;
									}
								}
								else {
									$scope.wellInf[i].target2 = resp.data[i].targets[1].name;
									$scope.wellInf[i].target2id = resp.data[i].targets[1].id;
									$scope.wellInf[i].target2color = lookup[resp.data[i].targets[1].id];
									if (resp.data[i].targets[1].well_type) {
										$scope.wellInf[i].target2type = resp.data[i].targets[1].well_type;
									}
									if (resp.data[i].targets[1].quantity) {
										$scope.wellInf[i].target2quantityTotal = resp.data[i].targets[1].quantity.m.toString() + 'e' + resp.data[i].targets[1].quantity.b.toString();
										$scope.wellInf[i].target2quantityM = resp.data[i].targets[1].quantity.m.toFixed(2);
										$scope.wellInf[i].target2quantityB = resp.data[i].targets[1].quantity.b;
									}

								}
							}
						}
					}
				}
			});
		};

		$scope.check = function () {
			$scope.testing();
			var notSame = 0;
			var flag = 0;
			var test;
			for (i = 0; i < 16; i++) {
				if ($scope.wells["well_" + i].selected) {
					flag++;
					if (flag == 1) {
						test = $scope.wellInf[i].sample;
					}
					else {
						if (test != $scope.wellInf[i].sample) {
							notSame = 1;
							break;
						}
					}
				}

			}
			if (notSame == 0) {
				$scope.sampleSelected = test;
			}
			else {
				$scope.sampleSelected = "Select a Sample";
			}

		};

		$scope.checkTarget1 = function () {
			var notSame = 0;
			var typeAll = 0;
			var flag = 0;
			var sameQty = 0;
			var test, testType, testName, testColor, testQuantity;
			for (i = 0; i < 16; i++) {
				if ($scope.wells["well_" + i].selected) {
					flag++;
					if (flag == 1) {
						test = $scope.wellInf[i].target1id;
						testType = $scope.wellInf[i].target1type;
						testName = $scope.wellInf[i].target1;
						testColor = $scope.wellInf[i].target1color;
						testQuantity = $scope.wellInf[i].target1quantityTotal;
					}
					else {
						if (test != $scope.wellInf[i].target1id) {
							notSame = 1;
							break;
						}
						if (testType != $scope.wellInf[i].target1type) {
							typeAll = 1;
						}
						if (testQuantity != $scope.wellInf[i].target1quantityTotal) {
							sameQty = 1;
						}
					}
				}
			}
			if (notSame == 0 && test != 0) {
				$scope.target1SelectedId = test;
				$scope.target1Selected = testName;
				$scope.target1SelectedColor = testColor;
				if (typeAll == 0) {
					$scope.enableTarget1Type = true;
					$scope.selectedTarget1Type = testType;
					if (testType == "standard") {
						$scope.enableTarget1Qty = true;
					}
					else {
						$scope.enableTarget1Qty = false;
					}
					if (sameQty == 0 && testQuantity != "") {
						$scope.target1Quantity.value = testQuantity;
					}
					else {
						$scope.target1Quantity.value = null;
					}
				}
				else {
					$scope.enableTarget1Type = false;
					$scope.enableTarget1Qty = false;
					$scope.selectedTarget1Type = "";
					$scope.target1Quantity.value = null;
				}
			}
			else {
				$scope.target1Selected = "Select a Target";
				$scope.target1SelectedColor = "white";
				$scope.enableTarget1Type = false;
				$scope.enableTarget1Qty = false;
				$scope.selectedTarget1Type = "";
				$scope.target1Quantity.value = null;
			}

		};

		$scope.checkTarget2 = function () {
			var notSame = 0;
			var typeAll = 0;
			var flag = 0;
			var sameQty = 0;
			var test, testType, testName, testColor, testQuantity;
			for (i = 0; i < 16; i++) {
				if ($scope.wells["well_" + i].selected) {
					flag++;
					if (flag == 1) {
						test = $scope.wellInf[i].target2id;
						testType = $scope.wellInf[i].target2type;
						testName = $scope.wellInf[i].target2;
						testColor = $scope.wellInf[i].target2color;
						testQuantity = $scope.wellInf[i].target2quantityTotal;
					}
					else {
						if (test != $scope.wellInf[i].target2id) {
							notSame = 1;
							break;
						}
						if (testType != $scope.wellInf[i].target2type) {
							typeAll = 1;
						}
						if (testQuantity != $scope.wellInf[i].target2quantityTotal) {
							sameQty = 1;
						}
					}
				}

			}
			if (notSame == 0 && test != 0) {
				$scope.target2SelectedId = test;
				$scope.target2Selected = testName;
				$scope.target2SelectedColor = testColor;
				if (typeAll == 0) {
					$scope.enableTarget2Type = true;
					$scope.selectedTarget2Type = testType;
					if (testType == "standard") {
						$scope.enableTarget2Qty = true;
					}
					else {
						$scope.enableTarget2Qty = false;
					}
					if (sameQty == 0 && testQuantity != "") {
						$scope.target2Quantity.value = testQuantity;
					}
					else {
						$scope.target2Quantity.value = null;
					}
				}
				else {
					$scope.enableTarget2Type = false;
					$scope.enableTarget2Qty = false;
					$scope.selectedTarget2Type = "";
					$scope.target2Quantity.value = null;
				}
			}
			else {
				$scope.target2Selected = "Select a target";
				$scope.target2SelectedColor = "white";
				$scope.enableTarget2Type = false;
				$scope.enableTarget2Qty = false;
				$scope.selectedTarget2Type = "";
				$scope.target2Quantity.value = null;
			}

		};

		/*		$(window).load(function() {
			console.log($('.samples-div').height());
				var heightDiv;
				//$('.samples-div').css({'top': '-'+heightDiv+'px'});
				$( ".options-div" ).each(function( index ) {
					heightDiv = $(this).height() - 34;
		  $(this).css({'top': '-'+heightDiv+'px'});
		});
		});*/

		$scope.testing = function () {
			//console.log($('.samples-div').height());
			//var heightDiv;
			//$('.samples-div').css({'top': '-'+heightDiv+'px'});
			//$( ".options-div" ).each(function( index ) {
			//heightDiv = $(this).height() - 34;
			//$(this).css({'top': '-'+heightDiv+'px'});
			//});
		};

		window.onclick = function (event) {
			if (!event.target.matches('.options-div') && !event.target.matches('.select-style') && !event.target.matches('.testing-clicking')) {

				//document.getElementsByClassName("options-div").classList.add("hiding-div");
				$(".options-div").each(function (index) {
					$(this).css({ 'display': 'none' });
				});
				$scope.showTarget1Options = false;

				$scope.showSampleOptions = false;

				$scope.showTarget2Options = false;

				$scope.showClearOptions = false;



			}
		};









		var ACTIVE_BORDER_WIDTH, COLORS, b, i, isCtrlKeyHeld, is_cmd_key_held, wells, _i, _j, _k;
		COLORS = AmplificationChartHelper.COLORS;
		ACTIVE_BORDER_WIDTH = 2;
		is_cmd_key_held = false;
		wells = {};
		$scope.dragging = false;
		$scope.$on('keypressed:command', function () {
			is_cmd_key_held = true;
			return is_cmd_key_held;
		});
		$scope.$on('keyreleased:command', function () {
			is_cmd_key_held = false;
			return is_cmd_key_held;
		});
		isCtrlKeyHeld = function (evt) {
			return evt.ctrlKey || is_cmd_key_held;
		};
		for (b = _i = 0; _i < 16; b = _i += 1) {
			wells["well_" + b] = {
				selected: false,
				active: false
				//color: $scope.colorBy === 'well' ? COLORS[b] : '#75278E'
			};
		}
		//ngModel.$setViewValue(wells);
		$scope.wells = wells;
		//console.log($scope.wells);
		$scope.row_header_width = 30;
		$scope.columns = [];
		$scope.rows = [];
		for (i = _j = 0; _j < 8; i = ++_j) {
			$scope.columns.push({
				index: i,
				selected: false
			});
		}
		for (i = _k = 0; _k < 2; i = ++_k) {
			$scope.rows.push({
				index: i,
				selected: false
			});
		}

		$scope.getStyleForWellBar = function (row, col, config, i) {
			return {
				'background-color': config.color,
				'opacity': config.selected ? 1 : 0.25
			};
		};
		$scope.dragStart = function (evt, type, index) {
			$scope.dragging = true;
			$scope.dragStartingPoint = {
				type: type,
				index: index
			};

			return $scope.dragStartingPoint;
		};
		$scope.dragged = function (evt, type, index) {
			var col1, col2, max, max_col, max_row, min, min_col, min_row, row1, row2;
			if (!$scope.dragging) {
				return;
			}
			if (type === $scope.dragStartingPoint.type && index === $scope.dragStartingPoint.index) {
				return;
			}
			if ($scope.dragStartingPoint.type === 'column') {
				if (type === 'well') {
					index = index >= $scope.columns.length ? index - $scope.columns.length : index;
				}
				max = Math.max.apply(Math, [index, $scope.dragStartingPoint.index]);
				min = max === index ? $scope.dragStartingPoint.index : index;
				$scope.columns.forEach(function (col) {
					col.selected = col.index >= min && col.index <= max;
					return $scope.rows.forEach(function (row) {
						var well;
						well = $scope.wells["well_" + (row.index * $scope.columns.length + col.index)];
						if (!(isCtrlKeyHeld(evt) && well.selected)) {
							well.selected = col.selected;
							return well.selected;
						}
					});
				});
			}
			if ($scope.dragStartingPoint.type === 'row') {
				if (type === 'well') {
					index = index >= 8 ? 1 : 0;
				}
				max = Math.max.apply(Math, [index, $scope.dragStartingPoint.index]);
				min = max === index ? $scope.dragStartingPoint.index : index;
				$scope.rows.forEach(function (row) {
					row.selected = row.index >= min && row.index <= max;
					return $scope.columns.forEach(function (col) {
						var well;
						well = $scope.wells["well_" + (row.index * $scope.columns.length + col.index)];
						if (!(isCtrlKeyHeld(evt) && well.selected)) {
							well.selected = row.selected;
							return well.selected;
						}
					});
				});
			}
			if ($scope.dragStartingPoint.type === 'well') {
				if (type === 'well') {
					row1 = Math.floor($scope.dragStartingPoint.index / $scope.columns.length);
					$scope.selectionMade = true;
					$scope.check();
					$scope.checkTarget1();
					$scope.checkTarget2();
					col1 = $scope.dragStartingPoint.index - row1 * $scope.columns.length;
					row2 = Math.floor(index / $scope.columns.length);
					col2 = index - row2 * $scope.columns.length;
					max_row = Math.max.apply(Math, [row1, row2]);
					min_row = max_row === row1 ? row2 : row1;
					max_col = Math.max.apply(Math, [col1, col2]);
					min_col = max_col === col1 ? col2 : col1;
					return $scope.rows.forEach(function (row) {
						return $scope.columns.forEach(function (col) {
							var selected, well;
							selected = (row.index >= min_row && row.index <= max_row) && (col.index >= min_col && col.index <= max_col);
							well = $scope.wells["well_" + (row.index * $scope.columns.length + col.index)];
							if (!(isCtrlKeyHeld(evt) && well.selected)) {
								well.selected = selected;
								return well.selected;
							}
						});
					});
				}
			}
		};
		$scope.dragStop = function (evt, type, index) {
			var well;
			$scope.dragging = false;
			$scope.columns.forEach(function (col) {
				col.selected = false;
				return col.selected;
			});
			$scope.rows.forEach(function (row) {
				row.selected = false;
				return row.selected;
			});
			if (type === 'well' && index === $scope.dragStartingPoint.index) {
				if (!isCtrlKeyHeld(evt)) {
					$scope.rows.forEach(function (r) {
						return $scope.columns.forEach(function (c) {
							$scope.wells["well_" + (r.index * $scope.columns.length + c.index)].selected = false;
							return $scope.wells["well_" + (r.index * $scope.columns.length + c.index)].selected;
						});
					});
				}
				well = $scope.wells["well_" + index];
				well.selected = isCtrlKeyHeld(evt) ? !well.selected : true;
				$scope.selectionMade = true;
				$scope.check();
				$scope.checkTarget1();
				$scope.checkTarget2();
			}
			//ngModel.$setViewValue(angular.copy($scope.wells));
			return console.log($scope.wells);
		};
		$scope.getWellStyle = function (row, col, well, index) {
			var border, style, well_bottom, well_bottom_index, well_left, well_left_index, well_right, well_right_index, well_top, well_top_index;
			if (well.active) {
				return {};
			}
			well_left_index = (col.index + 1) % $scope.columns.length === 1 ? null : index - 1;
			well_right_index = (col.index + 1) % $scope.columns.length === 0 ? null : index + 1;
			well_top_index = (row.index + 1) % $scope.rows.length === 1 ? null : index - $scope.columns.length;
			well_bottom_index = (row.index + 1) % $scope.rows.length === 0 ? null : index + $scope.columns.length;
			well_left = $scope.wells["well_" + well_left_index];
			well_right = $scope.wells["well_" + well_right_index];
			well_top = $scope.wells["well_" + well_top_index];
			well_bottom = $scope.wells["well_" + well_bottom_index];
			style = {};
			border = '2px solid #000';
			if (well.selected) {
				if (!(well_left != null ? well_left.selected : void 0)) {
					style['border-left'] = border;
				}
				if (!(well_right != null ? well_right.selected : void 0)) {
					style['border-right'] = border;
				}
				if (!(well_top != null ? well_top.selected : void 0)) {
					style['border-top'] = border;
				}
				if (!(well_bottom != null ? well_bottom.selected : void 0)) {
					style['border-bottom'] = border;
				}
			}
			return style;
		};
		$scope.getWellContainerStyle = function (row, col, well, i) {
			var style;
			style = {};
			if (well.active) {
				style.width = (this.getCellWidth() + ACTIVE_BORDER_WIDTH * 4) + "px";
			}
			return style;
		};


		$scope.assignSamples = function (id, name) {
			$scope.sampleSelected = name;
			k = 0;
			var linkSampleWell = [];
			for (i = 0; i < 16; i++) {
				if ($scope.wells["well_" + i].selected) {
					linkSampleWell[k] = i + 1;
					k++;
					//console.log($scope.wells["well_" + i]);
				}
			}

			Experiment.linkSample($stateParams.id, id, { wells: linkSampleWell }).then(function (response) {
				for (i = 0; i < response.data.sample.samples_wells.length; i++) {
					$scope.wellInf[response.data.sample.samples_wells[i].well_num - 1].sample = response.data.sample.name;
					$scope.wellInf[response.data.sample.samples_wells[i].well_num - 1].sampleid = response.data.sample.id;
				}

				// $scope.getWellLayout();
			});			

		};

		$scope.assignTarget = function (id, channel, name) {
			k = 0;
			if (channel == '1') {
				$scope.enableTarget1Type = true;
				$scope.target1Selected = name;
				$scope.target1SelectedId = id;
				$scope.target1SelectedColor = lookup[id];
			}
			else {
				$scope.enableTarget2Type = true;
				$scope.target2Selected = name;
				$scope.target2SelectedId = id;
				$scope.target2SelectedColor = lookup[id];
			}
			var linkTargetName = [];
			for (i = 0; i < 16; i++) {
				if ($scope.wells["well_" + i].selected) {
					linkTargetName[k] = {
						well_num: i + 1
					};
					k++;
				}
			}

			Experiment.linkTarget($stateParams.id, id, { wells: linkTargetName }).then(function (response) {
				updateTargetWell(response);
				// $scope.getWellLayout();
			});
		};

		updateTargetWell = function(response){
			var index = 0;
			if(response.data.target.channel == 1){
				for (i = 0; i < response.data.target.targets_wells.length; i++) {
					index = response.data.target.targets_wells[i].well_num - 1;
					$scope.wellInf[index].target1 = response.data.target.name;
					$scope.wellInf[index].target1id = response.data.target.id;
					$scope.wellInf[index].target1color = lookup[response.data.target.id];
					if (response.data.target.targets_wells[i].well_type) {
						$scope.wellInf[index].target1type = response.data.target.targets_wells[i].well_type;
					} else {
						$scope.wellInf[index].target1type = '';
					}
					if (response.data.target.targets_wells[i].quantity) {
						$scope.wellInf[index].target1quantityTotal = response.data.target.targets_wells[i].quantity.m.toString() + 'e' + response.data.target.targets_wells[i].quantity.b.toString();
						$scope.wellInf[index].target1quantityM = response.data.target.targets_wells[i].quantity.m.toFixed(2);
						$scope.wellInf[index].target1quantityB = response.data.target.targets_wells[i].quantity.b;
					} else {
						$scope.wellInf[index].target1quantityTotal = '';
						$scope.wellInf[index].target1quantityM = '';
						$scope.wellInf[index].target1quantityB = '';
					}
				}
			} else {
				for (i = 0; i < response.data.target.targets_wells.length; i++) {
					index = response.data.target.targets_wells[i].well_num - 1;
					$scope.wellInf[index].target2 = response.data.target.name;
					$scope.wellInf[index].target2id = response.data.target.id;
					$scope.wellInf[index].target2color = lookup[response.data.target.id];
					if (response.data.target.targets_wells[i].well_type) {
						$scope.wellInf[index].target2type = response.data.target.targets_wells[i].well_type;
					} else {
						$scope.wellInf[index].target2type = '';
					}
					if (response.data.target.targets_wells[i].quantity) {
						$scope.wellInf[index].target2quantityTotal = response.data.target.targets_wells[i].quantity.m.toString() + 'e' + response.data.target.targets_wells[i].quantity.b.toString();
						$scope.wellInf[index].target2quantityM = response.data.target.targets_wells[i].quantity.m.toFixed(2);
						$scope.wellInf[index].target2quantityB = response.data.target.targets_wells[i].quantity.b;
					} else {
						$scope.wellInf[index].target2quantityTotal = '';
						$scope.wellInf[index].target2quantityM = '';
						$scope.wellInf[index].target2quantityB = '';
					}
				}					
			}
		};

		$scope.unLinkTarget1 = function (id) {

		};

		$scope.assignTargetType = function (type) {
			var linkTargetType = [];
			$scope.selectedTarget1Type = type;
			if (type == "standard") {
				$scope.enableTarget1Qty = true;
			}
			else {
				$scope.enableTarget1Qty = false;
			}
			k = 0;
			for (i = 0; i < 16; i++) {
				if ($scope.wells["well_" + i].selected) {
					linkTargetType[k] = {
						well_num: i + 1,
						well_type: type
					};
					k++;
				}
			}
			Experiment.linkTarget($stateParams.id, $scope.target1SelectedId, { wells: linkTargetType }).then(function (response) {
				updateTargetWell(response);
				// $scope.getWellLayout();
			});
		};

		$scope.assignTarget2Type = function (type) {
			var linkTargetType = [];
			$scope.selectedTarget2Type = type;
			if (type == "standard") {
				$scope.enableTarget2Qty = true;
			}
			else {
				$scope.enableTarget2Qty = false;
			}
			k = 0;
			for (i = 0; i < 16; i++) {
				if ($scope.wells["well_" + i].selected) {
					linkTargetType[k] = {
						well_num: i + 1,
						well_type: type
					};
					k++;
				}
			}
			Experiment.linkTarget($stateParams.id, $scope.target2SelectedId, { wells: linkTargetType }).then(function (response) {
				updateTargetWell(response);
				// $scope.getWellLayout();
			});
		};

		$scope.clearWells = function (clearType, value) {
			$scope.clearSelected = value;

			var unLink = [];
			for (var z = 0; z < 16; z++) {
				if ($scope.wells["well_" + z].selected) {
					unlinkElem(z, clearType);
				}
			}
		};

		function unlinkElem (z, clearType){
			if ($scope.wellInf[z].target1id != 0 && (clearType == "Target1")) {
				Experiment.unlinkTarget($stateParams.id, $scope.wellInf[z].target1id, { wells: [z + 1] }).then(function (response) {
					$scope.wellInf[response.config.data.wells[0] - 1].target1id = 0;
					$scope.wellInf[response.config.data.wells[0] - 1].target1 = "Not set";
					$scope.wellInf[response.config.data.wells[0] - 1].target1type = "";
					$scope.wellInf[response.config.data.wells[0] - 1].target1quantity = "";
					$scope.wellInf[response.config.data.wells[0] - 1].target1color = "";
					$scope.wellInf[response.config.data.wells[0] - 1].target1quantityTotal = "";
					$scope.wellInf[response.config.data.wells[0] - 1].target1quantityM = "";
					$scope.wellInf[response.config.data.wells[0] - 1].target1quantityB = "";					

					$scope.enableTarget1Type = false;
					$scope.enableTarget1Qty = false;
					$scope.target1Selected = "Select a target";
					$scope.target1SelectedColor = "white";
					$scope.selectedTarget1Type = "";
				});
			}
			if ($scope.wellInf[z].target2id != 0 && (clearType == "Target2")) {
				Experiment.unlinkTarget($stateParams.id, $scope.wellInf[z].target2id, { wells: [z + 1] }).then(function (response) {
					$scope.wellInf[response.config.data.wells[0] - 1].target2id = 0;
					$scope.wellInf[response.config.data.wells[0] - 1].target2 = "Not set";
					$scope.wellInf[response.config.data.wells[0] - 1].target2type = "";
					$scope.wellInf[response.config.data.wells[0] - 1].target2quantity = "";
					$scope.wellInf[response.config.data.wells[0] - 1].target2color = "";
					$scope.wellInf[response.config.data.wells[0] - 1].target2quantityTotal = "";
					$scope.wellInf[response.config.data.wells[0] - 1].target2quantityM = "";
					$scope.wellInf[response.config.data.wells[0] - 1].target2quantityB = "";					

					$scope.enableTarget2Type = false;
					$scope.enableTarget2Qty = false;
					$scope.target2Selected = "Select a target";
					$scope.target2SelectedColor = "white";
					$scope.selectedTarget2Type = "";
				});
			}
			if ($scope.wellInf[z].sampleid != 0 && (clearType == "Sample")) {
				Experiment.unlinkSample($stateParams.id, $scope.wellInf[z].sampleid, { wells: [z + 1] }).then(function (response) {
					$scope.wellInf[response.config.data.wells[0] - 1].sampleid = 0;
					$scope.wellInf[response.config.data.wells[0] - 1].sample = "No sample";
					$scope.sampleSelected = "Select a sample";
				});
			}
		}

		$scope.assignTargetQuantity = function () {

			var stn;

			if (!isNaN($scope.target1Quantity.value) && ($scope.target1Quantity.value != null)) {

				stn = Number($scope.target1Quantity.value);

				console.log(stn.toExponential());
				console.log(stn.toExponential().toString().split(/[eE]/));

				var data = stn.toExponential().toString().split(/[eE]/);
				var m1 = Number(data[0]);
				var b1 = Number(data[1]);

				console.log(m1);
				console.log(b1);
				k = 0;
				var linkTargetQuantity = [];
				for (i = 0; i < 16; i++) {
					if ($scope.wells["well_" + i].selected) {
						linkTargetQuantity[k] = {
							well_num: i + 1,
							quantity: { m: m1, b: b1 }
						};
						k++;
					}
				}
				Experiment.linkTarget($stateParams.id, $scope.target1SelectedId, { wells: linkTargetQuantity }).then(function (response) {
					updateTargetWell(response);
					// $scope.getWellLayout();
				});
			}

			else {
				console.log("error");
			}

		};

		$scope.assignTarget2Quantity = function () {

			var stn;

			if (!isNaN($scope.target2Quantity.value) && ($scope.target2Quantity.value != null)) {

				stn = Number($scope.target2Quantity.value);

				console.log(stn.toExponential());
				console.log(stn.toExponential().toString().split(/[eE]/));

				var data = stn.toExponential().toString().split(/[eE]/);
				var m1 = Number(data[0]);
				var b1 = Number(data[1]);

				console.log(m1);
				console.log(b1);
				k = 0;
				var linkTargetQuantity = [];
				for (i = 0; i < 16; i++) {
					if ($scope.wells["well_" + i].selected) {
						linkTargetQuantity[k] = {
							well_num: i + 1,
							quantity: { m: m1, b: b1 }
						};
						k++;
					}
				}
				Experiment.linkTarget($stateParams.id, $scope.target2SelectedId, { wells: linkTargetQuantity }).then(function (response) {
					updateTargetWell(response);
					// $scope.getWellLayout();
				});
			}

			else {
				console.log("error");
			}
		};
	}
]);
