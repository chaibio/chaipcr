(function () {

  App.directive('rainbowLineChart', [
    function() {
      return {
        restrict: 'EA',
        scope: {
          data: '='
        },
        replace: true,
        template: '<canvas class="rainbow-line-chart">',
        link: function($scope, elem, attrs) {
          var ctx, drawPoint, getMax_X, getMax_Y, height, makeChart, margin, maxX, maxY, prev_X, prev_Y, rainbow, width;
          ctx = elem[0].getContext('2d');
          width = attrs.width;
          height = attrs.height;
          prev_X = 0;
          prev_Y = 0;
          maxY = 0;
          maxX = 0;
          margin = 10;
          rainbow = new Rainbow;
          rainbow.setSpectrum('#00AEEF', 'blue', 'violet', 'red');
          getMax_Y = function(data) {
            var ys;
            ys = _.map(data, function(datum) {
              return datum.y;
            });
            return margin * 2 + Math.max.apply(Math, ys);
          };
          getMax_X = function(data) {
            var xs;
            xs = _.map(data, function(datum) {
              return datum.x;
            });
            return Math.max.apply(Math, xs);
          };
          drawPoint = function(d) {
            var new_X, new_Y, y_diff;
            d.y = d.y + margin;
            new_X = width * d.x / maxX;
            new_Y = height * d.y / maxY;
            if (prev_X === 0) {
              prev_X = new_X;
            }
            if (prev_Y === 0) {
              prev_Y = new_Y;
            }
            y_diff = new_Y - prev_Y;
            ctx.beginPath();
            ctx.moveTo(prev_X, prev_Y);
            prev_X = new_X;
            prev_Y = new_Y;
            ctx.lineTo(prev_X, prev_Y);
            ctx.lineWidth = 3;
            ctx.strokeStyle = "#" + (rainbow.colourAt(d.y - (y_diff / 2)));
            return ctx.stroke();
          };
          makeChart = function(data) {
            var dpt, i, len, results;
            prev_X = 0;
            prev_Y = 0;
            maxY = getMax_Y($scope.data);
            maxY = maxY > 100 ? maxY : 130;
            maxX = getMax_X($scope.data);
            rainbow.setNumberRange(0, maxY);
            ctx.clearRect(0, 0, width, height);
            results = [];
            for (i = 0, len = data.length; i < len; i += 1) {
              dpt = data[i];
              results.push(drawPoint(dpt));
            }
            return results;
          };
          return $scope.$watch('data', function(val, oldVal) {
            if (!val) {
              return;
            }
            if (val.length === 0) {
              return;
            }
            if (val === oldVal) {
              return;
            }
            return makeChart(val);
          });
        }
      };
    }
  ]);

})();