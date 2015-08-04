window.ChaiBioTech.ngApp.controller('StageStepCtrl', [
  '$scope',
  'ExperimentLoader',
  'canvas',
  function($scope, ExperimentLoader, canvas) {

    var that = this;
    $scope.stage = {};
    $scope.step = {};

    $scope.initiate = function() {

      ExperimentLoader.getExperiment()
        .then(function(data) {
          $scope.protocol = data.experiment;
          $scope.stage = ExperimentLoader.loadFirstStages();
          $scope.step = ExperimentLoader.loadFirstStep();
          $scope.$emit('general-data-ready');
          canvas.init($scope);
        });
    };

    $scope.initiate();

    $scope.applyValuesFromOutSide = function(circle) {
      // when the event or function call is initiated from non anular part of the app ... !!
      $scope.$apply(function() {
        $scope.step = circle.parent.model;
        $scope.stage = circle.parent.parentStage.model;
        $scope.fabricStep = circle.parent;
      });
    };

    $scope.applyValues = function(circle) {

      $scope.step = circle.parent.model;
      $scope.stage = circle.parent.parentStage.model;
      $scope.fabricStep = circle.parent;
    };

    $scope.convertToMinute = function(deltaTime) {

      var value = deltaTime.indexOf(":");
      if(value != -1) {
        var hr = deltaTime.substr(0, value);
        var min = deltaTime.substr(value + 1);

        if(isNaN(hr) || isNaN(min)) {
          deltaTime = null;
          alert("Please enter a valid value");
          return false;
        } else {
          deltaTime = (hr * 60) + (min * 1);
          return deltaTime;
        }
      }

      if(isNaN(deltaTime) || !deltaTime) {
        alert("Please enter a valid value");
        return false;
      } else {
        return parseInt(Math.abs(deltaTime));
      }
    };

    $scope.timeFormating = function(reading) {

      var hour = Math.floor(reading / 60);
      hour = (hour < 10) ? "0" + hour : hour;

      var min = reading % 60;
      min = (min < 10) ? "0" + min : min;

      return hour + ":" + min;
    };

  }
]);
