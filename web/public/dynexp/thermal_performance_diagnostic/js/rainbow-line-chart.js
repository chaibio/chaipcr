(function () {

  App.directive('rainbowLineChart', [
    '$interval',
    function ($interval) {
      return {
        restrict: 'EA',
        scope: {
          data: '=?',
          maxY: '=?',
          maxX: '=?',
          minX: '=?'
        },
        replace: true,
        template: '<canvas class="rainbow-line-chart">',
        link: function($scope, elem, attrs) {

          var ctx = elem[0].getContext('2d');
          var width = attrs.width;
          var height = attrs.height;
          var prev_X = 0;
          var prev_Y = 0;
          var maxY = 0;
          var maxX = 0;
          var minX = 0;
          var margin = 10;
          var prev_data_points = [];
          var old_data = [];

          var rainbow = new Rainbow;
          rainbow.setSpectrum('#00AEEF', 'blue', 'violet', 'red');

          function getMax_Y() {
            // if ($scope.maxY) return margin * 2 + parseFloat($scope.maxY);
            var ys;
            ys = _.map($scope.data, function(datum) {
              return datum.y;
            });
            return (margin*2)+Math.max.apply(Math, ys);
          };
          function getMin_Y() {
            // if ($scope.minY) return margin * 2 + parseFloat($scope.minY);
            var ys;
            ys = _.map($scope.data, function(datum) {
              return datum.y;
            });
            return Math.min.apply(Math, ys);
          };

          function getMax_X() {
            if ($scope.maxX) return parseFloat($scope.maxX);
            var xs;
            xs = _.map($scope.data, function(datum) {
              return datum.x;
            });
            return Math.max.apply(Math, xs);
          };

          function getMin_X() {
            if ($scope.minX) return parseFloat($scope.minX);
            var xs;
            xs = _.map($scope.data, function(datum) {
              return datum.x;
            });
            return Math.min.apply(Math, xs);
          };

          function drawPoint(d, data) {
            var new_X, new_Y, y_diff;
            new_X = width * (d.x- minX) / (maxX-minX) ;
            new_Y = height * (margin+d.y) / maxY;

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
            ctx.stroke();
            x_index ++;
          };

          function makeChart(data) {
            var dpt, i, len, results;
            prev_X = 0;
            prev_Y = 0;
            maxY = getMax_Y(data);
            maxY = maxY > 130 ? maxY : 130;
            maxX = $scope.maxX;
            minX = $scope.minX;
            x_index = 0;
            rainbow.setNumberRange(0, maxY);
            ctx.clearRect(0, 0, width, height);
            for (i = 0, len = data.length; i < len; i += 1) {
              dpt = data[i];
              drawPoint(dpt, data);
            }
          };

          $scope.$on('update:rainbow:chart', function () {
            if (!$scope.data) return;
            if ($scope.data.length === 0) return;
            makeChart($scope.data)
            old_data = angular.copy($scope.data);
          });

        }
      };
    }
  ]);

})();