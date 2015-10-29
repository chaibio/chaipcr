window.App.directive 'statusBar', [
  'Experiment'
  'Status'
  'TestInProgressHelper'
  (Experiment, Status, TestInProgressHelper) ->

    restrict: 'EA'
    scope:
      expId: '='
    templateUrl: 'app/views/directives/status-bar.html'
    link: ($scope, elem, attrs) ->

      # Status.startSync()
      # elem.$on '$destroy', ->
      #   Status.stopSync()

      # $scope.$watch ->
      #   Status.getData()
      # , (data, oldData) ->
        
      # , true



]