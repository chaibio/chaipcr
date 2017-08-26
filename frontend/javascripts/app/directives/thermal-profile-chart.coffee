
window.App.directive 'thermalProfileChart', [
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
        onMouseMove: '&'
        show: '=' # must be object {}
      link: ($scope, elem, attrs) ->

        chart = null
        changeVal = null;
        $scope.show = $scope.show || true

        initChart = ->
          return if !$scope.data or !$scope.config or !$scope.show
          # chart = new $window.ChaiBioCharts.ThermalProfileChart($scope, elem[0], $scope.data, $scope.config)
          chart = new $window.ChaiBioCharts.ThermalProfileChart(elem[0], $scope.data, $scope.config)
          chart.onZoomAndPan($scope.onZoom())
          chart.setMouseMoveListener($scope.onMouseMove())
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
            if $scope.show
              chart.setYAxis()
              chart.setXAxis()
              chart.drawLines()

        $scope.$watch 'scroll', (scroll) ->
          return if !scroll or !chart or !$scope.show
          chart.scroll(scroll)

        $scope.$watch 'zoom', (zoom) ->
          return if !zoom or !chart or !$scope.show
          chart.zoomTo(zoom)

        $scope.$watch 'show', (show) ->
          if !chart
            initChart()
          else
            dims = chart.getDimensions()
            if dims.width <= 0 or dims.height <= 0 or !dims.width or !dims.height
              initChart()

            if show
              chart.setYAxis()
              chart.setXAxis()
              chart.drawLines()

        $scope.$on 'window:resize', ->
          initChart()

    }
]