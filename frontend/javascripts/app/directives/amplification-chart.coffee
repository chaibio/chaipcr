
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
          elem.empty()
          chart = new $window.ChaiBioCharts.AmplificationChart(elem[0], $scope.data, $scope.config)

          chart.onZoomAndPan($scope.onZoom())

        $scope.$watchCollection 'data', (data) ->
          if !chart
            initChart()
          else
            chart.updateData(data)

        $scope.$watch 'config.axes.y.scale', (i) ->
          console.log 'config.axes.y change'
          return if !chart
          chart.updateInterpolation(i)

        $scope.$watchCollection 'config.axes.x', ->
          initChart()

        $scope.$watchCollection 'config.margin', ->
          initChart()

        $scope.$watchCollection 'config.series', (series) ->
          return if !chart
          console.log 'series change'
          chart.updateSeries(series)

        $scope.$watch 'scroll', (scroll) ->
          return if !scroll or !chart
          chart.scroll(scroll)

        $scope.$watch 'zoom', (zoom) ->
          return if !zoom or !chart
          chart.zoomTo(zoom)


    }
]