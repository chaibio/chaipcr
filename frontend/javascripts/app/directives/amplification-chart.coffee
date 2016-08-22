
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

        initChart = ->
          return if !$scope.data or !$scope.config
          chart = new $window.ChaiBioCharts.BaseChart(elem[0], $scope.data, $scope.config)
          chart.onZoomAndPan($scope.onZoom())
          d = chart.getDimensions()
          $scope.onZoom()(chart.getTransform(), d.width, d.height, chart.getScaleExtent())

        $scope.$watchCollection 'data', (data) ->
          if !chart
            $timeout ->
              initChart()
            , 500
          else
            chart.updateData(data)

        $scope.$watch 'config.axes.y.scale', (i) ->
          return if !chart
          chart.updateInterpolation(i)

        $scope.$watchCollection 'config.axes.x', ->
          initChart()

        $scope.$watchCollection 'config.margin', ->
          initChart()

        $scope.$watchCollection 'config.series', (series) ->
          return if !chart
          chart.updateSeries(series)

        $scope.$watch 'scroll', (scroll) ->
          return if !scroll or !chart
          chart.scroll(scroll)

        $scope.$watch 'zoom', (zoom) ->
          return if !zoom or !chart
          chart.zoomTo(zoom)


    }
]