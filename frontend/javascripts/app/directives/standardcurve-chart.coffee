
window.App.directive 'standardCurveChart', [
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
        onUpdateProperties: '&'
        onSelectLine: '&'
        onUnselectLine: '&'
        show: '='
      link: ($scope, elem, attrs) ->

        chart = null
        oldState = null

        isInterpolationChanged = (val, oldState) ->
          return (oldState?.y_axis?.scale isnt val?.y_axis?.scale)

        isBaseBackroundChanged = (val, old_val) ->
          return false if (!val or !old_val)
          return false if !val.series
          return false if !val.series[0]
          return val.series[0].y isnt old_val.series[0]?.y

        initChart = ->
          return if !$scope.data or !$scope.config or !$scope.show

          chart = new $window.ChaiBioCharts.AmplificationChart(elem[0], $scope.data, $scope.config)
          chart.onZoomAndPan($scope.onZoom())
          chart.onSelectLine($scope.onSelectLine())
          chart.onUnselectLine($scope.onUnselectLine())

          chart.onUpdateProperties($scope.onUpdateProperties())

          d = chart.getDimensions()

          # $scope.onZoom()(chart.getTransform(), d.width, d.height, chart.getScaleExtent())
          # $scope.onUpdateProperties()($scope.label_cycle, $scope.label_RFU, $scope.label_dF_dC, $scope.label_D2_dc2)
        
        $scope.$on 'window:resize', ->
          chart.resize() if chart and $scope.show

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
              if isInterpolationChanged(val, oldState) or isBaseBackroundChanged(val, oldState)
                initChart()
              else
                chart.setYAxis()
                chart.setXAxis()
                chart.drawLines()
                chart.updateAxesExtremeValues()

          oldState = angular.copy(val)

        $scope.$watch 'scroll', (scroll) ->
          return if !scroll or !chart or !$scope.show
          chart.scroll(scroll)

        $scope.$watch 'zoom', (zoom) ->
          return if !zoom or !chart or !$scope.show
          chart.zoomTo(zoom)

        reinitChart = ->
          initChart()
          if !$scope.data or !$scope.config or !$scope.show
            return $timeout(reinitChart, 500)
          dims = chart.getDimensions()
          if dims.width <= 0 or dims.height <= 0 or !dims.width or !dims.height
            $timeout(reinitChart, 500)

        $scope.$watch 'show', (show) ->
          if !chart
            reinitChart()
          else
            if $scope.show
              chart.setYAxis()
              chart.setXAxis()
              chart.drawLines()
              chart.updateAxesExtremeValues()

    }
]
 