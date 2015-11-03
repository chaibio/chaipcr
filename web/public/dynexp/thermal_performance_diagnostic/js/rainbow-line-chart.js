(function () {

  App.directive('rainbowLineChart', [
    '$interval',
    function ($interval) {
      return {
        restrict: 'EA',
        scope: {
          data: '='
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
          var margin = 10;
          var prev_data_points = [];

          var rainbow = new Rainbow;
          rainbow.setSpectrum('#00AEEF', 'blue', 'violet', 'red');

          function getMax_Y(data) {
            var ys;
            ys = _.map(data, function(datum) {
              return datum.y;
            });
            return margin * 2 + Math.max.apply(Math, ys);
          };

          function getMax_X(data) {
            var xs;
            xs = _.map(data, function(datum) {
              return datum.x;
            });
            return Math.max.apply(Math, xs);
          };

          function drawPoint(d) {
            var new_X, new_Y, y_diff;
            d.y = d.y + margin;
            d.x = d.x + margin;
            new_X = width * d.x / maxX;
            new_Y = height * d.y / maxY;

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
          };

          function makeChart(data) {
            var dpt, i, len, results;
            prev_X = 0;
            prev_Y = 0;
            maxY = getMax_Y(data);
            maxY = maxY > 100 ? maxY : 130;
            maxX = getMax_X(data);
            rainbow.setNumberRange(0, maxY);
            ctx.clearRect(0, 0, width, height);
            for (i = 0, len = data.length; i < len; i += 1) {
              dpt = data[i];
              drawPoint(dpt);
            }
          };

          var transitioning = false;
          var duration = 1000; //ms
          var dpt_calibration = 50; //move 100 datapoints during transition
          var dpt_index = 1;
          var transition_threads = [];
          var animation;
          function transition (old_data_points, new_data_points) {

            if (!old_data_points) {
              return;
            }
            if (old_data_points.length === 0) {
              return;
            }

            for (var i = 0; i < dpt_calibration; i++) {
              transition_threads[i] = [];
            }

            for (var i = 0; i < new_data_points.length; i++) {
              var prev_dpt = old_data_points[i] || old_data_points[old_data_points.length-1] || new_data_points[i];
              var new_dtp = new_data_points[i];
              var dpt_y_diff = new_dtp.y - prev_dpt.y;
              var dpt_x_diff = new_dtp.x - prev_dpt.x;

              for (var ii = 0; ii < dpt_calibration; ii ++) {
                var new_y = prev_dpt.y + (dpt_y_diff/dpt_calibration) * ii;
                var new_x = prev_dpt.x + (dpt_x_diff/dpt_calibration) * ii;

                transition_threads[ii][i] = {
                  y: new_y,
                  x: new_x
                };
              }

            }
            


            dpt_index = 0;
            animation = $interval( animate_transition, duration/dpt_calibration);
          }

          function animate_transition () {
            if (dpt_index === dpt_calibration) {
              cancelAnimation();
              return;
            }
            makeChart(transition_threads[dpt_index]);
            dpt_index ++;
          }

          function cancelAnimation () {
            if(!animation) return;
            $interval.cancel(animation);
            animation = null;
            prev_data_points = transition_threads[dpt_index];
          }

          $scope.$watch('data', function(data, oldVal) {
            if (!data) {
              return;
            }
            if (data.length === 0) {
              return;
            }
            if (data === oldVal) {
              return;
            }
            cancelAnimation();
            transition(prev_data_points, data);
            prev_data_points = data;

          }, false);
        }
      };
    }
  ]);

})();