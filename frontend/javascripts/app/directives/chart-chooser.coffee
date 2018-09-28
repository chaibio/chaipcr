
window.App.directive 'chartChooser', [
  '$uibModal'
  'ChoosenChartService'
  'Experiment'
  ($uibModal, ChoosenChartService, Experiment) ->

    restrict: 'EA'
    scope:
      currentChart: '='
      experiment: '='
      # onChangeChart: '&'
    link: ($scope, elem, attrs) ->

      hasInit = false
      modal = null

      init = ->
        return if hasInit
        hasInit = true

        $scope.changeChart = (chart) ->
          ChoosenChartService.chooseChart(chart)
          modal.close()


        $scope.hasMeltCurve = ->
          return Experiment.hasMeltCurve($scope.experiment)

        $scope.hasAmplification = ->
          return Experiment.hasAmplificationCurve($scope.experiment)

        $scope.hasStandardCurve = ->
          return Experiment.hasStandardCurve($scope.experiment)
          
        $scope.chartCount = 1
        $scope.chartCount = $scope.chartCount + 1 if $scope.hasMeltCurve()
        $scope.chartCount = $scope.chartCount + 1 if $scope.hasAmplification()
        $scope.chartCount = $scope.chartCount + 1 if $scope.hasStandardCurve()

        elem.click ->
          $scope.$apply ->
            modal = $uibModal.open
              templateUrl: 'app/views/directives/chart-chooser.html'
              windowClass: "modal-#{$scope.chartCount}-row"
              scope: $scope

      $scope.$watch 'currentChart', (chart) ->
        return if !chart or !$scope.experiment
        init()

      $scope.$watch 'experiment', (exp) ->
        return if !exp or !$scope.currentChart
        init()

]