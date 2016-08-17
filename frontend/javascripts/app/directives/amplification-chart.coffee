
angular.module("canvasApp").directive 'amplificationChart', [
  '$window'
  ($window) ->
    return {
      restrict: 'EA'
      replace: true
      template: '<div></div>'
      scope:
        data: '='
        config: '='
        scroll: '='
        zoom: '='
        onZoom: '&'
      link: ($scope, elem, attrs) ->

        chart = null

        initChart = ->
          return if !$scope.data or !$scope.config
          chart = new $window.ChaiBioCharts.AmplificationChart(elem[0], $scope.data, $scope.config)

          chart.onZoomAndPan($scope.onZoom())

        $scope.$watchCollection 'data', (data) ->
          initChart()

        $scope.$watchCollection 'config', (config) ->
          initChart()

        $scope.$watch 'scroll', (scroll) ->
          return if !scroll or !chart
          chart.scroll(scroll)

        $scope.$watch 'zoom', (zoom) ->
          return if !zoom or !chart
          chart.zoomTo(zoom)


    }
]