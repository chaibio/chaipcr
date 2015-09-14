(function() {
  window.ChaiBioTech.ngApp.controller('EditExperimentPropertiesCtrl', [
    '$scope', 'focus', 'Experiment', '$stateParams', function($scope, focus, Experiment, $stateParams) {
      $scope.experiment = {};
      Experiment.get({
        id: $stateParams.id
      }, function(data) {
        $scope.experiment = data.experiment;
        return $scope.experimentOrig = angular.copy($scope.experiment);
      });
      $scope.editExpNameMode = false;
      $scope.expTypes = [
        {
          text: 'END POINT'
        }, {
          text: 'PRESENCE/ABSENSE'
        }, {
          text: 'GENOTYPING'
        }, {
          text: 'QUANTIFICATION'
        }
      ];
      $scope.typeSelected = function(type) {
        return $scope.selectedType = type;
      };
      $scope.focusExpName = function() {
        $scope.editExpNameMode = true;
        return focus('editExpNameMode');
      };
      return $scope.saveExperiment = function() {
        var promise;
        promise = Experiment.update({
          id: $scope.experiment.id
        }, {
          experiment: $scope.experiment
        }).$promise;
        promise.then(function() {
          return $scope.success = "Experiment updated successfully";
        });
        promise["catch"](function(resp) {
          $scope.errors = resp.data.errors;
          return $scope.experiment = angular.copy($scope.experimentOrig);
        });
        return promise["finally"](function() {
          return $scope.editExpNameMode = false;
        });
      };
    }
  ]);

}).call(this);

(function() {
  window.ChaiBioTech.ngApp.controller('HomeCtrl', [
    '$scope', 'Experiment', function($scope, Experiment) {
      var _this = this;
      $scope.experiments = null;
      $scope.deleteMode = false;
      this.fetchExperiments = function() {
        return Experiment.query(function(experiments) {
          return $scope.experiments = experiments;
        });
      };
      this.fetchExperiments();
      this.newExperiment = function() {
        var exp,
          _this = this;
        exp = new Experiment({
          experiment: {
            name: 'New Experiment',
            protocol: {}
          }
        });
        return exp.$save(function(data) {
          return _this.fetchExperiments();
        });
      };
      this.confirmDelete = function(exp) {
        if ($scope.deleteMode) {
          return exp.del = true;
        }
      };
      this.deleteExperiment = function(expId) {
        var exp;
        exp = new Experiment({
          id: expId
        });
        return exp.$remove(function() {
          return _this.fetchExperiments();
        });
      };
    }
  ]);

}).call(this);

(function() {
  window.ChaiBioTech.ngApp.controller('RunExperimentCtrl', [
    '$scope', '$stateParams', 'Experiment', function($scope, $stateParams, Experiment) {
      return Experiment.get({
        id: $stateParams.id
      }, function(data) {
        return $scope.experiment = data.experiment;
      });
    }
  ]);

}).call(this);

(function() {
  window.ChaiBioTech.ngApp.controller('TemperatureLogCtrl', [
    '$scope', '$stateParams', function($scope, $stateParams) {
      var _this = this;
      $scope.init = function() {
        var _this = this;
        Status.startSync();
        $scope.$watch(function() {
          return Status.getData();
        }, function(val) {
          var _ref, _ref1;
          if (val) {
            $scope.isCurrentExperiment = parseInt((_ref = val.experimentController) != null ? (_ref1 = _ref.expriment) != null ? _ref1.id : void 0 : void 0) === parseInt($stateParams.id);
            if ($scope.isCurrentExperiment && $scope.scrollState >= 1) {
              return $scope.autoUpdateTemperatureLogs();
            } else {
              return $scope.stopInterval();
            }
          }
        });
        $scope.resolutionOptions = [60, 10 * 60, 20 * 60, 30 * 60, 60 * 60, 60 * 60 * 24];
        $scope.resolution = $scope.resolutionOptions[0];
        $scope.temperatureLogs = [];
        $scope.temperatureLogsCache = [];
        $scope.calibration = 800;
        $scope.scrollState = 0;
        $scope.updateInterval = null;
        return Experiment.getTemperatureData($stateParams.id, {
          resolution: 1000
        }).success(function(data) {
          if (data.length > 0) {
            $scope.temperatureLogsCache = angular.copy(data);
            $scope.temperatureLogs = angular.copy(data);
            $scope.updateScale();
            $scope.resizeTemperatureLogs();
            $scope.updateScrollWidth();
            return $scope.updateData();
          } else {
            return $scope.autoUpdateTemperatureLogs();
          }
        });
      };
      $scope.init();
      $scope.updateData = function() {
        var data, left_et, left_et_limit, maxScroll, right_et, scrollState, temp_log, _i, _len, _ref, _ref1;
        if (((_ref = $scope.temperatureLogsCache) != null ? _ref.length : void 0) > 0) {
          left_et_limit = $scope.temperatureLogsCache[$scope.temperatureLogsCache.length - 1].temperature_log.elapsed_time - ($scope.resolution * 1000);
          maxScroll = 0;
          _ref1 = $scope.temperatureLogs;
          for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
            temp_log = _ref1[_i];
            if (temp_log.temperature_log.elapsed_time <= left_et_limit) {
              ++maxScroll;
            } else {
              break;
            }
          }
          scrollState = Math.round($scope.scrollState * maxScroll);
          if ($scope.scrollState < 0) {
            scrollState = 0;
          }
          if ($scope.scrollState > 1) {
            scrollState = maxScroll;
          }
          left_et = $scope.temperatureLogs[scrollState].temperature_log.elapsed_time;
          right_et = left_et + ($scope.resolution * 1000);
          data = _.select($scope.temperatureLogs, function(temp_log) {
            var et;
            et = temp_log.temperature_log.elapsed_time;
            return et >= left_et && et <= right_et;
          });
          return $scope.updateChart(data);
        }
      };
      $scope.updateScale = function() {
        var max_scale, scales;
        scales = _.map($scope.temperatureLogsCache, function(temp_log) {
          var greatest;
          temp_log = temp_log.temperature_log;
          greatest = Math.max.apply(Math, [parseFloat(temp_log.lid_temp), parseFloat(temp_log.heat_block_zone_1_temp), parseFloat(temp_log.heat_block_zone_2_temp)]);
          return greatest;
        });
        max_scale = Math.max.apply(Math, scales);
        return $scope.options.axes.y.max = Math.ceil(max_scale / 10) * 10;
      };
      $scope.updateScrollWidth = function() {
        if ($scope.temperatureLogsCache.length > 0) {
          $scope.greatest_elapsed_time = $scope.temperatureLogsCache[$scope.temperatureLogsCache.length - 1].temperature_log.elapsed_time;
          $scope.widthPercent = $scope.resolution * 1000 / $scope.greatest_elapsed_time;
          if ($scope.widthPercent > 1) {
            $scope.widthPercent = 1;
          }
        } else {
          $scope.widthPercent = 1;
        }
        return elem.find('.scrollbar').css({
          width: "" + ($scope.widthPercent * 100) + "%"
        });
      };
      $scope.resizeTemperatureLogs = function() {
        var averagedLogs, chunkSize, chunked, resolution, temperature_logs;
        resolution = $scope.resolution;
        if ($scope.resolution > $scope.greatest_elapsed_time / 1000) {
          resolution = $scope.greatest_elapsed_time / 1000;
        }
        chunkSize = Math.round(resolution / $scope.calibration);
        temperature_logs = angular.copy($scope.temperatureLogsCache);
        chunked = _.chunk(temperature_logs, chunkSize);
        averagedLogs = _.map(chunked, function(chunk) {
          var i;
          i = Math.floor(chunk.length / 2);
          return chunk[i];
        });
        averagedLogs.unshift(temperature_logs[0]);
        averagedLogs.push(temperature_logs[temperature_logs.length - 1]);
        return $scope.temperatureLogs = averagedLogs;
      };
      $scope.updateResolution = function() {
        if ($scope.temperatureLogsCache.length > 0) {
          if ($scope.resolution) {
            $scope.resizeTemperatureLogs();
            $scope.updateScrollWidth();
            return $scope.updateData();
          } else {
            $scope.resolution = $scope.greatest_elapsed_time / 1000;
            $scope.updateScrollWidth();
            return $scope.updateChart(angular.copy($scope.temperatureLogs));
          }
        }
      };
      $scope.$watch('widthPercent', function() {
        if ($scope.widthPercent === 1 && $scope.isCurrentExperiment) {
          return $scope.autoUpdateTemperatureLogs();
        }
      });
      $scope.$watch('scrollState', function() {
        if ($scope.scrollState && $scope.temperatureLogs && $scope.data) {
          $scope.updateData();
          if ($scope.scrollState >= 1 && $scope.isCurrentExperiment) {
            return $scope.autoUpdateTemperatureLogs();
          } else {
            return $scope.stopInterval();
          }
        }
      });
      $scope.updateChart = function(temperature_logs) {
        return $scope.data = ChartData.temperatureLogs(temperature_logs).toN3LineChart();
      };
      $scope.autoUpdateTemperatureLogs = function() {
        var _ref, _ref1;
        if (!$scope.updateInterval && $scope.isCurrentExperiment && ((_ref = Status.getData().experimentController) != null ? (_ref1 = _ref.machine) != null ? _ref1.state : void 0 : void 0) === 'Running') {
          return $scope.updateInterval = $interval(function() {
            return Experiment.getTemperatureData($stateParams.id, {
              resolution: 1000
            }).success(function(data) {
              $scope.temperatureLogsCache = angular.copy(data);
              $scope.temperatureLogs = angular.copy(data);
              $scope.updateScale();
              $scope.resizeTemperatureLogs();
              $scope.updateScrollWidth();
              return $scope.updateData();
            });
          }, 10000);
        } else if (!$scope.isCurrentExperiment) {
          return $scope.stopInterval();
        }
      };
      $scope.stopInterval = function() {
        if ($scope.updateInterval) {
          $interval.cancel($scope.updateInterval);
        }
        return $scope.updateInterval = null;
      };
      elem.on('$destroy', function() {
        Status.stopSync();
        return $scope.stopInterval();
      });
      return $scope.options = {
        axes: {
          x: {
            key: 'elapsed_time',
            ticksFormatter: function(t) {
              return SecondsDisplay.display2(t);
            },
            ticks: 8
          },
          y: {
            key: 'heat_block_zone_temp',
            type: 'linear',
            min: 0,
            max: 0
          }
        },
        margin: {
          left: 30
        },
        series: [
          {
            y: 'heat_block_zone_temp',
            color: 'steelblue'
          }, {
            y: 'lid_temp',
            color: 'lightsteelblue'
          }
        ],
        lineMode: 'linear',
        tension: 0.7,
        tooltip: {
          mode: 'scrubber',
          formatter: function(x, y, series) {
            if (series.y === 'lid_temp') {
              return "" + (SecondsDisplay.display2(x)) + " | Lid Temp: " + y;
            } else if (series.y === 'heat_block_zone_temp') {
              return "" + (SecondsDisplay.display2(x)) + " | Heat Block Zone Temp: " + y;
            } else {
              return '';
            }
          }
        },
        drawLegend: false,
        drawDots: false,
        hideOverflow: false,
        columnsHGap: 5
      };
    }
  ]);

}).call(this);

(function() {
  window.ChaiBioTech.ngApp.controller('UserSettingsCtrl', [
    '$scope', '$window', '$modal', 'User', function($scope, $window, $modal, User) {
      var fetchUsers;
      $scope.settings = {
        option: 'A',
        checkbox: true
      };
      $scope.goHome = function() {
        return $window.location = '#home';
      };
      fetchUsers = function() {
        return User.fetch().then(function(users) {
          return $scope.users = users;
        });
      };
      fetchUsers();
      $scope.currentUser = User.currentUser();
      $scope.user = {};
      $scope.addUser = function() {
        var user;
        user = angular.copy($scope.user);
        user.role = $scope.user.role ? 'admin' : 'default';
        return User.save(user).then(function() {
          $scope.user = {};
          fetchUsers();
          return $scope.modal.close();
        })["catch"](function(data) {
          data.user.role = data.user.role === 'default' ? false : true;
          return $scope.user.errors = data.user.errors;
        });
      };
      $scope.removeUser = function(id) {
        if ($window.confirm('Are you sure?')) {
          return User.remove(id).then(fetchUsers);
        }
      };
      return $scope.openAddUserModal = function() {
        return $scope.modal = $modal.open({
          scope: $scope,
          templateUrl: 'app/views/user/modal-add-user.html'
        });
      };
    }
  ]);

}).call(this);

(function() {
  window.ChaiBioTech.ngApp.directive('amplificationCircleButton', [
    function() {
      return {
        restrict: 'EA',
        require: 'ngModel',
        replace: true,
        template: '<div class="circle" ng-click="toggleState()" ng-style="style">{{text}}</div>',
        link: function($scope, elem, attrs, ngModel) {
          var color;
          color = elem.css('borderColor');
          $scope.state = angular.copy(ngModel.$modelValue) || false;
          $scope.updateUI = function() {
            if ($scope.state) {
              $scope.style = {
                color: color
              };
              return $scope.text = 'On';
            } else {
              $scope.style = {
                color: 'gray'
              };
              return $scope.text = 'Off';
            }
          };
          $scope.toggleState = function() {
            $scope.state = !$scope.state;
            ngModel.$setViewValue($scope.state);
            return $scope.updateUI();
          };
          return $scope.updateUI();
        }
      };
    }
  ]);

}).call(this);

(function() {
  window.ChaiBioTech.ngApp.directive('chooseChart', [
    function() {
      return {
        restrict: 'EA',
        require: '?ngModel',
        templateUrl: 'app/views/directives/choose-chart.html',
        link: function($scope, elem, attrs, ngModel) {
          $scope.chartTypesData = [
            {
              chartType: 'Amplification Chart',
              buttons: {
                A: [],
                B: []
              }
            }, {
              chartType: 'Thermal Profile'
            }
          ];
          $scope.setChartType = function(chart) {
            $scope.selectedChart = chart;
            return ngModel.$setViewValue(chart);
          };
          return $scope.setChartType($scope.chartTypesData[1]);
        }
      };
    }
  ]);

}).call(this);

(function() {
  window.ChaiBioTech.ngApp.directive('duplicateExperiment', [
    'Experiment', '$state', function(Experiment, $state) {
      return {
        restrict: 'EA',
        scope: {
          expId: '=experimentId'
        },
        link: function($scope, elem) {
          $scope.copy = function() {
            return Experiment.get({
              id: $scope.expId
            }, function(resp) {
              var copy;
              copy = Experiment.duplicate($scope.expId, resp);
              copy.success(function(resp) {
                return $state.go('edit-protocol', {
                  id: resp.experiment.id
                });
              });
              return copy.error(function() {
                return alert("Unable to copy experiment!");
              });
            });
          };
          return elem.click($scope.copy);
        }
      };
    }
  ]);

}).call(this);

(function() {
  window.ChaiBioTech.ngApp.directive('experimentStartStopButton', [
    'Status', 'Experiment', function(Status, Experiment) {
      return {
        restrict: 'EA',
        replace: true,
        scope: {
          experimentId: '='
        },
        templateUrl: 'app/views/directives/experiment-start-stop-button.html',
        link: function($scope, elem) {
          var getExperiment;
          getExperiment = function(cb) {
            return Experiment.get({
              id: $scope.experimentId
            }, function(resp) {
              $scope.experiment = resp.experiment;
              return cb();
            });
          };
          $scope.$watch('experimentId', function(val) {
            if (angular.isNumber(val)) {
              return getExperiment($scope.init);
            }
          });
          $scope.init = function() {
            Status.startSync();
            elem.on('$destroy', function() {
              return Status.stopSync();
            });
            $scope.stopped = false;
            return $scope.$watch(function() {
              return Status.getData();
            }, function(val) {
              return $scope.data = val;
            });
          };
          $scope.startExperiment = function(expId) {
            $scope.stopped = false;
            return Experiment.startExperiment(expId);
          };
          $scope.stopExperiment = function() {
            $scope.stopped = true;
            return Experiment.stopExperiment().then(function() {
              return getExperiment(angular.noop);
            });
          };
          return $scope.completedAndStopped = function() {
            var _ref, _ref1;
            return (((_ref = $scope.data) != null ? (_ref1 = _ref.experimentController) != null ? _ref1.machine.state : void 0 : void 0) === 'Complete') && $scope.stopped;
          };
        }
      };
    }
  ]);

}).call(this);

(function() {
  window.ChaiBioTech.ngApp.directive('logout', [
    '$state', 'Auth', '$rootScope', '$window', function($state, Auth, $rootScope, $window) {
      return {
        restrict: 'EA',
        link: function($scope, elem) {
          return elem.click(function() {
            return Auth.logout().then(function() {
              return $window.location.assign('/');
            });
          });
        }
      };
    }
  ]);

}).call(this);

(function() {
  window.ChaiBioTech.ngApp.directive('menuOverlay', [
    '$rootScope', '$templateCache', '$compile', function($rootScope, $templateCache, $compile) {
      return {
        restrict: 'EA',
        transclude: true,
        replace: true,
        scope: {
          sidemenuTemplate: '@'
        },
        templateUrl: 'app/views/directives/menu-overlay.html',
        link: function($scope, elem) {
          var compiled, sidemenu, sidemenuContainer;
          $scope.sideMenuOpen = false;
          $scope.sideMenuOptionsOpen = false;
          sidemenu = $templateCache.get($scope.sidemenuTemplate);
          compiled = $compile(sidemenu)($scope.$parent);
          sidemenuContainer = elem.find('#sidemenu');
          sidemenuContainer.html(compiled);
          $rootScope.$on('sidemenu:toggle', function() {
            sidemenuContainer.css({
              minHeight: elem.find('.page-wrapper').height()
            });
            $scope.sideMenuOpen = !$scope.sideMenuOpen;
            if (!$scope.sideMenuOpen) {
              $scope.sideMenuOptionsOpen = false;
              return elem.find('.menu-overlay-menu-item').removeClass('active');
            }
          });
          return $rootScope.$on('submenu:toggle', function(e, html, subOption) {
            $scope.sideMenuOptionsOpen = !$scope.sideMenuOptionsOpen;
            elem.find('#submenu').html(html);
            if ($scope.sideMenuOptionsOpen) {
              return subOption.addClass('active');
            } else {
              return subOption.removeClass('active');
            }
          });
        }
      };
    }
  ]);

}).call(this);

(function() {
  window.ChaiBioTech.ngApp.directive('sidemenuSuboption', [
    '$compile', '$templateCache', '$rootScope', function($compile, $templateCache, $rootScope) {
      return {
        restrict: 'EA',
        scope: {
          menuTemplate: '@'
        },
        link: function($scope, elem) {
          var arrow, compiled, template;
          template = $templateCache.get($scope.menuTemplate);
          compiled = $compile(template)($scope.$parent);
          arrow = elem.find('.arrow-right');
          return elem.click(function() {
            $rootScope.$broadcast('submenu:toggle', compiled, elem);
            return $rootScope.$apply();
          });
        }
      };
    }
  ]);

}).call(this);

(function() {
  window.ChaiBioTech.ngApp.directive('temperatureLogChart', [
    'Experiment', 'ChartData', 'SecondsDisplay', '$interval', 'Status', function(Experiment, ChartData, SecondsDisplay, $interval, Status) {
      return {
        restrict: 'AE',
        scope: {
          experimentId: '='
        },
        templateUrl: 'app/views/directives/temperature-log-chart.html',
        link: function($scope, elem) {
          var _this = this;
          $scope.$watch('experimentId', function(id) {
            if (id) {
              return $scope.init();
            }
          });
          $scope.init = function() {
            var _this = this;
            Status.startSync();
            $scope.$watch(function() {
              return Status.getData();
            }, function(val) {
              var _ref, _ref1;
              if (val) {
                $scope.isCurrentExperiment = parseInt((_ref = val.experimentController) != null ? (_ref1 = _ref.expriment) != null ? _ref1.id : void 0 : void 0) === parseInt($scope.experimentId);
                if ($scope.isCurrentExperiment && $scope.scrollState >= 1) {
                  return $scope.autoUpdateTemperatureLogs();
                } else {
                  return $scope.stopInterval();
                }
              }
            });
            $scope.resolutionOptions = [60, 10 * 60, 20 * 60, 30 * 60, 60 * 60, 60 * 60 * 24];
            $scope.resolution = $scope.resolutionOptions[0];
            $scope.temperatureLogs = [];
            $scope.temperatureLogsCache = [];
            $scope.calibration = 800;
            $scope.scrollState = 0;
            $scope.updateInterval = null;
            return Experiment.getTemperatureData($scope.experimentId, {
              resolution: 1000
            }).success(function(data) {
              if (data.length > 0) {
                $scope.temperatureLogsCache = angular.copy(data);
                $scope.temperatureLogs = angular.copy(data);
                $scope.updateScale();
                $scope.resizeTemperatureLogs();
                $scope.updateScrollWidth();
                return $scope.updateData();
              } else {
                return $scope.autoUpdateTemperatureLogs();
              }
            });
          };
          $scope.updateData = function() {
            var data, left_et, left_et_limit, maxScroll, right_et, scrollState, temp_log, _i, _len, _ref, _ref1;
            if (((_ref = $scope.temperatureLogsCache) != null ? _ref.length : void 0) > 0) {
              left_et_limit = $scope.temperatureLogsCache[$scope.temperatureLogsCache.length - 1].temperature_log.elapsed_time - ($scope.resolution * 1000);
              maxScroll = 0;
              _ref1 = $scope.temperatureLogs;
              for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
                temp_log = _ref1[_i];
                if (temp_log.temperature_log.elapsed_time <= left_et_limit) {
                  ++maxScroll;
                } else {
                  break;
                }
              }
              scrollState = Math.round($scope.scrollState * maxScroll);
              if ($scope.scrollState < 0) {
                scrollState = 0;
              }
              if ($scope.scrollState > 1) {
                scrollState = maxScroll;
              }
              left_et = $scope.temperatureLogs[scrollState].temperature_log.elapsed_time;
              right_et = left_et + ($scope.resolution * 1000);
              data = _.select($scope.temperatureLogs, function(temp_log) {
                var et;
                et = temp_log.temperature_log.elapsed_time;
                return et >= left_et && et <= right_et;
              });
              return $scope.updateChart(data);
            }
          };
          $scope.updateScale = function() {
            var max_scale, scales;
            scales = _.map($scope.temperatureLogsCache, function(temp_log) {
              var greatest;
              temp_log = temp_log.temperature_log;
              greatest = Math.max.apply(Math, [parseFloat(temp_log.lid_temp), parseFloat(temp_log.heat_block_zone_1_temp), parseFloat(temp_log.heat_block_zone_2_temp)]);
              return greatest;
            });
            max_scale = Math.max.apply(Math, scales);
            return $scope.options.axes.y.max = Math.ceil(max_scale / 10) * 10;
          };
          $scope.updateScrollWidth = function() {
            if ($scope.temperatureLogsCache.length > 0) {
              $scope.greatest_elapsed_time = $scope.temperatureLogsCache[$scope.temperatureLogsCache.length - 1].temperature_log.elapsed_time;
              $scope.widthPercent = $scope.resolution * 1000 / $scope.greatest_elapsed_time;
              if ($scope.widthPercent > 1) {
                $scope.widthPercent = 1;
              }
            } else {
              $scope.widthPercent = 1;
            }
            return elem.find('.scrollbar').css({
              width: "" + ($scope.widthPercent * 100) + "%"
            });
          };
          $scope.resizeTemperatureLogs = function() {
            var averagedLogs, chunkSize, chunked, resolution, temperature_logs;
            resolution = $scope.resolution;
            if ($scope.resolution > $scope.greatest_elapsed_time / 1000) {
              resolution = $scope.greatest_elapsed_time / 1000;
            }
            chunkSize = Math.round(resolution / $scope.calibration);
            temperature_logs = angular.copy($scope.temperatureLogsCache);
            chunked = _.chunk(temperature_logs, chunkSize);
            averagedLogs = _.map(chunked, function(chunk) {
              var i;
              i = Math.floor(chunk.length / 2);
              return chunk[i];
            });
            averagedLogs.unshift(temperature_logs[0]);
            averagedLogs.push(temperature_logs[temperature_logs.length - 1]);
            return $scope.temperatureLogs = averagedLogs;
          };
          $scope.updateResolution = function() {
            if ($scope.temperatureLogsCache.length > 0) {
              if ($scope.resolution) {
                $scope.resizeTemperatureLogs();
                $scope.updateScrollWidth();
                return $scope.updateData();
              } else {
                $scope.resolution = $scope.greatest_elapsed_time / 1000;
                $scope.updateScrollWidth();
                return $scope.updateChart(angular.copy($scope.temperatureLogs));
              }
            }
          };
          $scope.$watch('widthPercent', function() {
            if ($scope.widthPercent === 1 && $scope.isCurrentExperiment) {
              return $scope.autoUpdateTemperatureLogs();
            }
          });
          $scope.$watch('scrollState', function() {
            if ($scope.scrollState && $scope.temperatureLogs && $scope.data) {
              $scope.updateData();
              if ($scope.scrollState >= 1 && $scope.isCurrentExperiment) {
                return $scope.autoUpdateTemperatureLogs();
              } else {
                return $scope.stopInterval();
              }
            }
          });
          $scope.updateChart = function(temperature_logs) {
            return $scope.data = ChartData.temperatureLogs(temperature_logs).toN3LineChart();
          };
          $scope.autoUpdateTemperatureLogs = function() {
            var _ref, _ref1;
            if (!$scope.updateInterval && $scope.isCurrentExperiment && ((_ref = Status.getData().experimentController) != null ? (_ref1 = _ref.machine) != null ? _ref1.state : void 0 : void 0) === 'Running') {
              return $scope.updateInterval = $interval(function() {
                return Experiment.getTemperatureData($scope.experimentId, {
                  resolution: 1000
                }).success(function(data) {
                  $scope.temperatureLogsCache = angular.copy(data);
                  $scope.temperatureLogs = angular.copy(data);
                  $scope.updateScale();
                  $scope.resizeTemperatureLogs();
                  $scope.updateScrollWidth();
                  return $scope.updateData();
                });
              }, 10000);
            } else if (!$scope.isCurrentExperiment) {
              return $scope.stopInterval();
            }
          };
          $scope.stopInterval = function() {
            if ($scope.updateInterval) {
              $interval.cancel($scope.updateInterval);
            }
            return $scope.updateInterval = null;
          };
          elem.on('$destroy', function() {
            Status.stopSync();
            return $scope.stopInterval();
          });
          $scope.options = {
            axes: {
              x: {
                key: 'elapsed_time',
                ticksFormatter: function(t) {
                  return SecondsDisplay.display2(t);
                },
                ticks: 8
              },
              y: {
                key: 'heat_block_zone_temp',
                type: 'linear',
                min: 0,
                max: 0
              }
            },
            margin: {
              left: 30
            },
            series: [
              {
                y: 'heat_block_zone_temp',
                color: 'steelblue'
              }, {
                y: 'lid_temp',
                color: 'lightsteelblue'
              }
            ],
            lineMode: 'linear',
            tension: 0.7,
            tooltip: {
              mode: 'scrubber',
              formatter: function(x, y, series) {
                if (series.y === 'lid_temp') {
                  return "" + (SecondsDisplay.display2(x)) + " | Lid Temp: " + y;
                } else if (series.y === 'heat_block_zone_temp') {
                  return "" + (SecondsDisplay.display2(x)) + " | Heat Block Zone Temp: " + y;
                } else {
                  return '';
                }
              }
            },
            drawLegend: false,
            drawDots: false,
            hideOverflow: false,
            columnsHGap: 5
          };
        }
      };
    }
  ]);

}).call(this);

(function() {
  window.ChaiBioTech.ngApp.directive('testInProgress', [
    'Status', '$interval', 'Experiment', function(Status, $interval, Experiment) {
      return {
        restrict: 'EA',
        scope: {
          experimentId: '='
        },
        replace: true,
        templateUrl: 'app/views/directives/test-in-progress.html',
        link: function($scope, elem) {
          var updateData;
          Status.startSync();
          updateData = function(data) {
            var _ref;
            if ((data != null ? (_ref = data.experimentController) != null ? _ref.machine.state : void 0 : void 0) === 'Complete' && $scope.experimentId) {
              return Experiment.get({
                id: $scope.experimentId
              }, function(exp) {
                $scope.data = data;
                $scope.completionStatus = exp.experiment.completion_status;
                return $scope.experiment = exp.experiment;
              });
            } else {
              return $scope.data = data;
            }
          };
          if (Status.getData()) {
            updateData(Status.getData());
          }
          $scope.$watch(function() {
            return Status.getData();
          }, function(data) {
            return updateData(data);
          });
          $scope.timeRemaining = function() {
            var exp, time;
            if ($scope.data && $scope.data.experimentController.machine.state === 'Running') {
              exp = $scope.data.experimentController.expriment;
              time = (exp.estimated_duration * 1 + exp.paused_duration * 1) - exp.run_duration * 1;
              if (time < 0) {
                time = 0;
              }
              return time;
            } else {
              return 0;
            }
          };
          $scope.barWidth = function() {
            var exp, width;
            if ($scope.data && $scope.data.experimentController.machine.state === 'Running') {
              exp = $scope.data.experimentController.expriment;
              width = exp.run_duration / exp.estimated_duration;
              if (width > 1) {
                width = 1;
              }
              return width;
            } else {
              return 0;
            }
          };
          return elem.on('$destroy', function() {
            return Status.stopSync();
          });
        }
      };
    }
  ]);

}).call(this);

(function() {
  window.ChaiBioTech.ngApp.directive('timeScrollbar', [
    '$window', function($window) {
      return {
        restrict: 'EA',
        replace: true,
        templateUrl: 'app/views/directives/time-scrollbar.html',
        require: 'ngModel',
        link: function($scope, elem, attr, ngModel) {
          var disableSelect, enableSelect, getElemWidth, getMarginLeft, getScrollBarWidth, getSpaceWidth, held, margin, newMargin, oldMargin, pageX, scaleSize, scrollbar, spaceWidth, updateState;
          held = false;
          oldMargin = 0;
          newMargin = 0;
          pageX = 0;
          margin = 0;
          spaceWidth = 0;
          scaleSize = 0;
          scrollbar = elem.find('.scrollbar');
          $scope.$watch(function() {
            return scrollbar.css('width');
          }, function(newVal, oldVal) {
            if (newVal !== oldVal) {
              oldMargin = getMarginLeft();
              spaceWidth = getSpaceWidth();
              pageX = 0;
              return updateState(0);
            }
          });
          disableSelect = function() {
            return $window.$(document.body).css({
              'userSelect': 'none'
            });
          };
          enableSelect = function() {
            return $window.$(document.body).css({
              'userSelect': ''
            });
          };
          getMarginLeft = function() {
            return parseFloat(scrollbar.css('marginLeft').replace(/px/, ''));
          };
          getElemWidth = function() {
            return parseFloat(elem.css('width').replace(/px/, ''));
          };
          getScrollBarWidth = function() {
            return parseFloat(scrollbar.css('width').replace(/px/, ''));
          };
          getSpaceWidth = function() {
            return getElemWidth() - getScrollBarWidth();
          };
          updateState = function(ePageX) {
            var val, xDiff;
            xDiff = ePageX - pageX;
            newMargin = oldMargin + xDiff;
            if (newMargin < 0) {
              newMargin = 0;
            }
            if (newMargin > spaceWidth) {
              newMargin = spaceWidth;
            }
            scrollbar.css({
              marginLeft: "" + newMargin + "px"
            });
            val = spaceWidth > 0 ? Math.round((oldMargin + xDiff) / spaceWidth * 1000) / 1000 : 0;
            return ngModel.$setViewValue(val);
          };
          elem.on('mousedown', function(e) {
            held = true;
            pageX = e.pageX;
            disableSelect();
            oldMargin = getMarginLeft();
            return spaceWidth = getSpaceWidth();
          });
          $window.$(document).on('mouseup', function(e) {
            held = false;
            return enableSelect();
          });
          return $window.$(document).on('mousemove', function(e) {
            if (held) {
              return updateState(e.pageX);
            }
          });
        }
      };
    }
  ]);

}).call(this);

(function() {
  window.ChaiBioTech.ngApp.directive('toggleSidemenu', [
    '$rootScope', function($rootScope) {
      return {
        restrict: 'A',
        scope: {},
        link: function($scope, elem) {
          return elem.on('click', function(e) {
            $rootScope.$broadcast('sidemenu:toggle');
            return $scope.$apply();
          });
        }
      };
    }
  ]);

}).call(this);

(function() {
  window.ChaiBioTech.ngApp.filter('round', [
    function() {
      return function(input, numDigit) {
        var num;
        num = parseFloat(input);
        return num.toFixed(numDigit);
      };
    }
  ]);

}).call(this);

(function() {
  window.ChaiBioTech.ngApp.filter('secondsDisplay', [
    'SecondsDisplay', function(SecondsDisplay) {
      return function(input, display) {
        return SecondsDisplay[display](parseInt(input));
      };
    }
  ]);

}).call(this);

(function() {
  window.ChaiBioTech.ngApp.config([
    '$stateProvider', '$urlRouterProvider', '$locationProvider', function($stateProvider, $urlRouterProvider) {
      $urlRouterProvider.otherwise("/home");
      return $stateProvider.state('signup', {
        url: '/signup',
        templateUrl: 'app/views/signup.html',
        controller: 'SignUpCtrl'
      }).state('login', {
        url: '/login',
        templateUrl: 'app/views/login.html',
        controller: 'LoginCtrl as LoginCtrl'
      }).state('home', {
        url: '/home',
        templateUrl: 'app/views/home.html',
        controller: 'HomeCtrl as HomeCtrl'
      }).state('settings', {
        url: '/user/settings',
        templateUrl: 'app/views/user/settings.html',
        controller: 'UserSettingsCtrl'
      }).state('edit-protocol', {
        url: '/edit-protocol/:id',
        templateUrl: 'app/views/skelton.html',
        controller: 'ProtocolCtrl'
      }).state('runExperiment', {
        url: '/run-experiment/:id',
        templateUrl: 'app/views/experiment/run-experiment.html',
        controller: 'RunExperimentCtrl'
      }).state('temperatureLog', {
        url: '/experiments/:id/temperature-logs',
        templateUrl: 'app/views/experiment/temperature-logs.html'
      });
    }
  ]);

}).call(this);

(function() {
  var app;

  app = window.ChaiBioTech.ngApp;

  app.factory('Auth', [
    '$http', function($http) {
      return {
        logout: function() {
          return $http.post('/logout').then(function() {
            return $.jStorage.deleteKey('authToken');
          });
        }
      };
    }
  ]);

  app.factory('AuthToken', [
    function() {
      return {
        request: function(config) {
          var access_token;
          access_token = $.jStorage.get('authToken', null);
          if (access_token && config.url.indexOf('8000') >= 0) {
            config.url = "" + config.url + (config.url.indexOf('&') < 0 ? '?' : '&') + "access_token=" + access_token;
            config.headers['Content-Type'] = 'text/plain';
          }
          return config;
        }
      };
    }
  ]);

  app.config([
    '$httpProvider', function($httpProvider) {
      return $httpProvider.interceptors.push('AuthToken');
    }
  ]);

}).call(this);

(function() {
  window.ChaiBioTech.ngApp.service('ChartData', [
    'SecondsDisplay', function(SecondsDisplay) {
      this.temperatureLogs = function(temperature_logs) {
        return {
          toAngularCharts: function() {
            var elapsed_time, hbz, heat_block_zone_temp, lid_temp, temp_log, _i, _len, _ref;
            elapsed_time = [];
            heat_block_zone_temp = [];
            lid_temp = [];
            _ref = angular.copy(temperature_logs);
            for (_i = 0, _len = _ref.length; _i < _len; _i++) {
              temp_log = _ref[_i];
              elapsed_time.push(SecondsDisplay.display2(Math.round(temp_log.temperature_log.elapsed_time / 1000)));
              hbz = (parseFloat(temp_log.temperature_log.heat_block_zone_1_temp) + parseFloat(temp_log.temperature_log.heat_block_zone_2_temp)) / 2;
              hbz = Math.ceil(hbz * 100) / 100;
              heat_block_zone_temp.push(hbz);
              lid_temp.push(parseFloat(temp_log.temperature_log.lid_temp));
            }
            return {
              elapsed_time: elapsed_time,
              heat_block_zone_temp: heat_block_zone_temp,
              lid_temp: lid_temp
            };
          },
          toNVD3: function() {
            var et, hbzAverage, heat_block_zone_temps, lid_temps, temp_log, _i, _len, _ref;
            lid_temps = [];
            heat_block_zone_temps = [];
            _ref = angular.copy(temperature_logs);
            for (_i = 0, _len = _ref.length; _i < _len; _i++) {
              temp_log = _ref[_i];
              et = temp_log.temperature_log.elapsed_time;
              lid_temps.push([et, parseFloat(temp_log.temperature_log.lid_temp)]);
              hbzAverage = (parseFloat(temp_log.temperature_log.heat_block_zone_1_temp + parseFloat(temp_log.temperature_log.heat_block_zone_2_temp))) / 2;
              heat_block_zone_temps.push([et, Math.round(hbzAverage * 100) / 100]);
            }
            return {
              lid_temps: lid_temps,
              heat_block_zone_temps: heat_block_zone_temps
            };
          },
          toN3LineChart: function() {
            var et, hbz, lid_temp, temp_log, tmp_logs, _i, _len, _ref;
            tmp_logs = [];
            _ref = angular.copy(temperature_logs);
            for (_i = 0, _len = _ref.length; _i < _len; _i++) {
              temp_log = _ref[_i];
              et = temp_log.temperature_log.elapsed_time / 1000;
              hbz = (parseFloat(temp_log.temperature_log.heat_block_zone_1_temp) + parseFloat(temp_log.temperature_log.heat_block_zone_2_temp)) / 2;
              hbz = Math.ceil(hbz * 100) / 100;
              lid_temp = parseFloat(temp_log.temperature_log.lid_temp);
              tmp_logs.push({
                elapsed_time: et,
                heat_block_zone_temp: hbz,
                lid_temp: lid_temp
              });
            }
            return tmp_logs;
          }
        };
      };
    }
  ]);

}).call(this);

(function() {
  var app;

  app = window.ChaiBioTech.ngApp;

  app.service('CSRFToken', [
    '$window', function($window) {
      return {
        request: function(config) {
          if (config.url.indexOf('8000') < 0) {
            config.headers['X-CSRF-Token'] = $window.$('meta[name=csrf-token]').attr('content');
            config.headers['X-Requested-With'] = 'XMLHttpRequest';
          }
          return config;
        }
      };
    }
  ]);

  app.config([
    '$httpProvider', function($httpProvider) {
      return $httpProvider.interceptors.push('CSRFToken');
    }
  ]);

}).call(this);

(function() {
  window.ChaiBioTech.ngApp.service('Experiment', [
    '$resource', '$http', 'host', function($resource, $http, host) {
      var self;
      self = $resource('/experiments/:id', {
        id: '@id'
      }, {
        'update': {
          method: 'PUT'
        }
      });
      self.getTemperatureData = function(expId, opts) {
        if (opts == null) {
          opts = {};
        }
        opts.starttime = opts.starttime || 0;
        opts.resolution = opts.resolution || 1000;
        return $http.get("/experiments/" + expId + "/temperature_data", {
          params: {
            starttime: opts.starttime,
            endtime: opts.endtime,
            resolution: opts.resolution
          }
        });
      };
      self.duplicate = function(expId, data) {
        return $http.post("/experiments/" + expId + "/copy", data);
      };
      self.startExperiment = function(expId) {
        return $http.post("" + host + ":8000/control/start", {
          experimentId: expId
        });
      };
      self.stopExperiment = function() {
        return $http.post("" + host + ":8000/control/stop");
      };
      return self;
    }
  ]);

}).call(this);

(function() {
  window.ChaiBioTech.ngApp.service('SecondsDisplay', [
    function() {
      var _this = this;
      this.getSecondsComponents = function(secs) {
        var days, hours, mins, seconds;
        secs = Math.round(secs);
        mins = Math.floor(secs / 60);
        seconds = secs - mins * 60;
        hours = Math.floor(mins / 60);
        mins = mins - hours * 60;
        days = Math.floor(hours / 24);
        hours = hours - days * 24;
        return {
          days: days,
          hours: hours,
          mins: mins,
          seconds: seconds
        };
      };
      this.display1 = function(seconds) {
        var sec, text;
        sec = _this.getSecondsComponents(seconds);
        text = '';
        if (sec.days > 0) {
          text = "" + text + " " + sec.days + " d";
        }
        if (sec.hours > 0) {
          text = "" + text + " " + sec.hours + " hr";
        }
        if (sec.mins > 0) {
          text = "" + text + " " + sec.mins + " min";
        }
        if (sec.days === 0 && sec.hours === 0 && sec.mins === 0) {
          text = "" + text + " " + sec.seconds + " sec";
        }
        return text;
      };
      this.display2 = function(seconds) {
        var sec, text;
        sec = _this.getSecondsComponents(seconds);
        text = '';
        if (sec.days < 10) {
          sec.days = "0" + sec.days;
        }
        if (sec.hours < 10) {
          sec.hours = "0" + sec.hours;
        }
        if (sec.mins < 10) {
          sec.mins = "0" + sec.mins;
        }
        if (sec.seconds < 10) {
          sec.seconds = "0" + sec.seconds;
        }
        return "" + ((parseInt(sec.days)) > 0 ? sec.days + ':' : '') + sec.hours + ":" + sec.mins + ":" + sec.seconds;
      };
      this.display3 = function(seconds) {
        var text;
        seconds = _this.getSecondsComponents(seconds);
        text = '';
        if (seconds.days > 0) {
          text = "" + text + " " + seconds.days + "d";
        }
        if (seconds.hours > 0) {
          text = "" + text + " " + seconds.hours + "hr";
        }
        if (seconds.days === 0 && seconds.mins > 0) {
          text = "" + text + " " + seconds.mins + "m";
        }
        if (seconds.days === 0 && seconds.hours === 0) {
          text = "" + text + " " + seconds.seconds + "s";
        }
        return text;
      };
    }
  ]);

}).call(this);

(function() {
  window.ChaiBioTech.ngApp.service('Status', [
    '$http', '$q', 'host', '$interval', function($http, $q, host, $interval) {
      var data;
      data = null;
      this.interval = null;
      this.listenersCount = 0;
      this.fetching = false;
      this.getData = function() {
        return data;
      };
      this.fetch = function() {
        var deferred,
          _this = this;
        this.fetching = true;
        deferred = $q.defer();
        $http.get("" + host + "\:8000/status").success(function(resp) {
          data = resp;
          return deferred.resolve(data);
        }).error(function(resp) {
          return deferred.reject(resp);
        })["finally"](function() {
          return this.fetching = false;
        });
        return deferred.promise;
      };
      this.startSync = function() {
        this.listenersCount += 1;
        if (!this.fetching) {
          this.fetch();
        }
        if (!this.interval) {
          return this.interval = $interval(this.fetch, 3000);
        }
      };
      this.stopSync = function() {
        this.listenersCount -= 1;
        if (this.listenersCount === 0) {
          $interval.cancel(this.interval);
          return this.interval = null;
        }
      };
    }
  ]);

}).call(this);

(function() {
  window.ChaiBioTech.ngApp.service('User', [
    '$http', '$q', function($http, $q) {
      var user;
      user = {
        id: $.jStorage.get('userId', null)
      };
      this.currentUser = function() {
        return user;
      };
      this.save = function(user) {
        var deferred;
        deferred = $q.defer();
        $http.post('/users', {
          user: user
        }).then(function(resp) {
          return deferred.resolve(resp.data.user);
        })["catch"](function(resp) {
          return deferred.reject(resp.data);
        });
        return deferred.promise;
      };
      this.fetch = function() {
        var deferred;
        deferred = $q.defer();
        $http.get('/users').then(function(resp) {
          return deferred.resolve(resp.data);
        });
        return deferred.promise;
      };
      this.remove = function(id) {
        return $http["delete"]("/users/" + id);
      };
    }
  ]);

}).call(this);
