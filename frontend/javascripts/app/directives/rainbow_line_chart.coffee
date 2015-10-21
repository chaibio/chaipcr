# Usage:
#   data should be a series of y datapoints
#   <rainbow-line-chart data="[2,3,45,6,0]"></rainbow-line-chart>

window.ChaiBioTech.ngApp.directive 'rainbowLineChart', [
  ->
    restrict: 'EA'
    scope:
      data: '='
    replace: true
    template: '<canvas class="rainbow-line-chart">'
    link: ($scope, elem, attrs) ->

      ctx = elem[0].getContext('2d');
      width = attrs.width
      height = attrs.height;
      prev_X = 0;
      prev_Y = 0;
      maxY = 0;
      maxX = 0;
      margin = 10

      rainbow = new Rainbow
      rainbow.setSpectrum '#00AEEF', 'blue', 'violet', 'red'

      getMax_Y = (data) ->
        ys = _.map data, (datum) ->
          datum.y
        margin*2 + Math.max.apply Math, ys

      getMax_X = (data) ->
        xs = _.map data, (datum) ->
          datum.x
        Math.max.apply Math, xs

      drawPoint = (d) ->
        d.y = d.y + margin
        new_X = width * d.x / maxX
        new_Y = height * d.y / maxY
        prev_X = new_X if prev_X is 0
        prev_Y = new_Y if prev_Y is 0
        y_diff = new_Y - prev_Y

        ctx.beginPath()
        ctx.moveTo prev_X, prev_Y
        prev_X = new_X
        prev_Y= new_Y
        ctx.lineTo prev_X, prev_Y
        ctx.lineWidth = 3
        ctx.strokeStyle = "##{rainbow.colourAt(d.y - (y_diff/2))}"
        ctx.stroke()

      makeChart = (data) ->
        prev_X = 0;
        prev_Y = 0;
        maxY = getMax_Y($scope.data)
        maxY = if maxY > 100 then maxY else 100
        maxX = getMax_X($scope.data)
        rainbow.setNumberRange 0, maxY
        ctx.clearRect(0, 0, width, height)
        for dpt in data by 1
          drawPoint dpt

      $scope.$watch 'data', (val, oldVal) ->
        return if !val
        return if val.length is 0
        return if val is oldVal
        makeChart val

]