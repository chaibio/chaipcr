
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
          return if !$scope.data or !$scope.config
          chart = new $window.ChaiBioCharts.BaseChart(elem[0], $scope.data, $scope.config)
          chart.onZoomAndPan($scope.onZoom())
          d = chart.getDimensions()
          $scope.onZoom()(chart.getTransform(), d.width, d.height, chart.getScaleExtent())

        # $scope.$watchCollection 'data', (data) ->
        #   if !chart
        #     initChart()
        #   else
        #     chart.updateData(data)

        $scope.$watchCollection ->
          return {
            data: $scope.data,
            y_axis: $scope.config?.axes?.y
            x_axis: $scope.config?.axes?.x
            series: $scope.config?.series
          }
        , (val, old_val) ->
          if !chart
            initChart()
          else
            if !angular.equals(val.data, old_val.data)
              chart.updateData(val.data)
            else if !angular.equals(val.series, old_val.series)
              chart.updateSeries(val.series)
            else if (val.y_axis.scale isnt old_val.y_axis.scale)
              chart.updateInterpolation(val.y_axis.scale)
            else
              initChart()

        # $scope.$watchCollection 'config.series', (series) ->
        #   return if !chart
        #   chart.updateSeries(series)

        $scope.$watch 'scroll', (scroll) ->
          return if !scroll or !chart
          chart.scroll(scroll)

        $scope.$watch 'zoom', (zoom) ->
          return if !zoom or !chart
          chart.zoomTo(zoom)


    }
]