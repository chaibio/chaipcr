
angular.module("canvasApp").directive 'amplificationChart', [
  '$window'
  '$timeout'
  ($window, $timeout) ->
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
        changeVal = null;

        initChart = ->
          return if !$scope.data or !$scope.config or !!chart
          chart = new $window.ChaiBioCharts.BaseChart(elem[0], $scope.data, $scope.config)
          chart.onZoomAndPan($scope.onZoom())
          d = chart.getDimensions()
          $scope.onZoom()(chart.getTransform(), d.width, d.height, chart.getScaleExtent())

        $scope.$watchCollection ($scope) ->
          return {
            data: $scope.data,
            y_axis: $scope.config?.axes?.y
            x_axis: $scope.config?.axes?.x
            series: $scope.config?.series
          }
        , (val) ->
          if !chart
            initChart()
          else
            chart.updateData($scope.data)
            chart.updateConfig($scope.config)
            chart.setYAxis()
            chart.setXAxis()
            chart.drawLines()

        $scope.$watch 'scroll', (scroll) ->
          return if !scroll or !chart
          chart.scroll(scroll)

        $scope.$watch 'zoom', (zoom) ->
          return if !zoom or !chart
          chart.zoomTo(zoom)


    }
]