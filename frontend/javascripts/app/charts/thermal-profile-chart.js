(function() {

  "use strict";

  function ThermalProfileChart($scope, elem, data, config) {

    // Global vars
    var Globals = null;
    var bisectX = function(line_config) {
      return d3.bisector(function(d) {
        return d[line_config.x];
      }).left;
    };
    var isZooming = false;

    function initGlobalVars() {
      Globals = {
        width: 0,
        height: 0,
        data: null,
        config: null,
        chartSVG: null,
        viewSVG: null,
        gX: null,
        gY: null,
        xAxis: null,
        yAxis: null,
        mouseOverlay: null,
        lineStrokeWidth: 5,
        circleStrokeWidth: 2,
        dashedLineStrokeWidth: 2,
        circleRadius: 7,
        circles: [],
        dashedLine: null,
        lines: null,
        xScale: null,
        yScale: null,
        zooomBehavior: null,
        zoomTransform: {
          k: 1,
          x: 0,
          y: 0
        },
        onZoomAndPan: null,
        mouse: null
      };
    }

    function makeCircleForLine(line_config) {
      var c = Globals.viewSVG.append('circle')
        .style('box-shadow', '10px 10px 5px #333')
        .attr('opacity', 0)
        .attr('r', Globals.circleRadius / Globals.zoomTransform.k)
        .attr('fill', line_config.color)
        .attr('stroke', '#fff')
        .attr('stroke-width', Globals.circleStrokeWidth / Globals.zoomTransform.k)
        .attr('class', 'mouse-indicator-circle');

      Globals.circles.push(c);
    }

    function makeDashedLine() {
      if (Globals.dashedLine) {
        Globals.dashedLine.remove();
      }
      var dashStrokeWidth = Globals.dashedLineStrokeWidth / Globals.zoomTransform.k;

      return Globals.viewSVG
        .append("line")
        .attr("opacity", 0)
        .attr("y1", 0)
        .attr("y2", Globals.height)
        .attr("stroke-dasharray", dashStrokeWidth + ',' + dashStrokeWidth)
        .attr("stroke-width", Globals.dashedLineStrokeWidth / Globals.zoomTransform.k)
        .attr("stroke", "#333")
        .attr("fill", "none");
    }

    function makeLine(line_config) {
      var line = d3.line()
        .curve(d3.curveCardinal)
        .x(function(d) {
          return Globals.xScale(d[line_config.x]);
        })
        .y(function(d) {
          return Globals.yScale(d[line_config.y]);
        });
      var _path = Globals.viewSVG.append("path")
        .datum(Globals.data[line_config.dataset])
        .attr("class", "line")
        .attr("stroke", line_config.color)
        .attr('fill', 'none')
        // .attr('stroke-width', Globals.lineStrokeWidth / Globals.zoomTransform.k)
        .attr('stroke-width', Globals.lineStrokeWidth)
        .attr("d", line);

      Globals.lines.push(_path);
      return _path;
    }

    function drawLines() {
      var series = Globals.config.series;
      if (!series) {
        return;
      }
      Globals.lines = Globals.lines || [];
      Globals.lines.forEach(function(line) {
        line.remove();
      });
      Globals.lines = [];
      Globals.lines = [];

      series.forEach(function(line_config, i) {
        makeLine(line_config);
      });

      Globals.dashedLine = makeDashedLine();
      drawCircleTooltips();
      setMouseOverlay();
    }

    function drawCircleTooltips() {
      if (!Globals.config.series) {
        return;
      }
      Globals.circles = Globals.circles || [];
      Globals.circles.forEach(function(circle) {
        circle.remove();
      });
      Globals.circles = [];
      for (var i = 0; i < Globals.config.series.length; i++) {
        var config = Globals.config.series[i];
        makeCircleForLine(config);
      }

    }

    function getDataLength() {
      if (!Globals.config) return 0;
      if (!Globals.config.series) return 0;
      if (!Globals.data) return 0;
      var total = 0;
      Globals.config.series.forEach(function(s) {
        total += Globals.data[s.dataset].length;
      });
      return total / Globals.config.series.length;
    }

    function updateElementSizesOnZoom(transform) {
      Globals.lines.forEach(function(l) {
        l.attr('stroke-width', (Globals.lineStrokeWidth / transform.k) + 'px');
      });

      Globals.circles.forEach(function(circle) {
        circle
          .attr('stroke-width', Globals.circleStrokeWidth / transform.k + 'px')
          .attr('r', Globals.circleRadius / transform.k + 'px');
      });

      Globals.dashedLine
        .attr('stroke-dasharray', 5 / transform.k + "," + 5 / transform.k)
        .attr('stroke-width', (Globals.dashedLineStrokeWidth / transform.k) + 'px');
    }

    function zoomed() {
      var transform = d3.event.transform;
      transform.x = transform.x || 0;
      transform.y = transform.y || 0;
      transform.k = transform.k || 0;

      if (transform.x > 0) {
        transform.x = 0;
      }

      if (transform.x + (Globals.width * transform.k) < Globals.width) {
        transform.x = -(Globals.width * transform.k - Globals.width);
      }

      if (transform.y > 0) {
        transform.y = 0;
      }

      if (transform.y + (Globals.height * transform.k) < Globals.height) {
        transform.y = -(Globals.height * transform.k - Globals.height);
      }

      Globals.viewSVG.attr("transform", transform);
      Globals.gX.call(Globals.xAxis.scale(transform.rescaleX(Globals.xScale)));
      Globals.gY.call(Globals.yAxis.scale(transform.rescaleY(Globals.yScale)));
      Globals.zoomTransform = transform;

      updateElementSizesOnZoom(transform);

      if (Globals.onZoomAndPan) {
        Globals.onZoomAndPan(Globals.zoomTransform, Globals.width, Globals.height, getScaleExtent());
      }
    }

    function getMinX() {
      var min = d3.min(Globals.config.series, function(s) {
        return d3.min(Globals.data[s.dataset], function(d) {
          return d[s.x];
        });
      });
      return min || 0;
    }

    function getMaxX() {
      var max = d3.max(Globals.config.series, function(s) {
        return d3.max(Globals.data[s.dataset], function(d) {
          return d[s.x];
        });
      });
      return max || 1;
    }

    function getMinY() {
      if (Globals.config.axes.y.min) {
        return Globals.config.axes.y.min;
      }
      var min_y = d3.min(Globals.config.series, function(s) {
        return d3.min(Globals.data[s.dataset], function(d) {
          return d[s.y];
        });
      });
      return min_y || 0;
    }

    function getMaxY() {
      if (Globals.config.axes.y.max) {
        return Globals.config.axes.y.max;
      }
      var max_y = d3.max(Globals.config.series, function(s) {
        return d3.max(Globals.data[s.dataset], function(d) {
          return d[s.y];
        });
      });
      return max_y || 1;
    }

    function getScaleExtent() {
      return getMaxX();
    }

    function getYLogticks() {
      var num = getMaxY();
      num = num + num * 0.2;
      var calib, calibs, i, j, num_length, ref, roundup;
      num_length = num.toString().length;
      roundup = '1';
      for (i = j = 0, ref = num_length; j < ref; i = j += 1) {
        roundup = roundup + "0";
      }
      roundup = roundup * 1;
      calibs = [];
      calib = 10;
      while (calib <= roundup) {
        calibs.push(calib);
        calib = calib * 10;
      }
      return calibs;
    };

    function setYAxis() {

      if (Globals.gY) {
        Globals.gY.remove();
      }

      var svg = Globals.chartSVG.select('.chart-g');

      // add allowance for interpolation curves
      var max = getMaxY();
      var min = getMinY();
      var diff = max - min;
      var allowance = diff * 0.05;
      max += allowance;
      min -= allowance;

      // var y_scale = Globals.config.axes.y.scale || 'linear';
      Globals.yScale = d3.scaleLinear()
        .range([Globals.height, 0])
        .domain([min, max]);

      Globals.yAxis = d3.axisLeft(Globals.yScale);

      if (Globals.config.axes.y.tickFormat) {
        Globals.yAxis.tickFormat(Globals.config.axes.y.tickFormat);
      }

      Globals.gY = svg.append("g")
        .attr("class", "axis y-axis")
        .attr('fill', 'none')
        .call(Globals.yAxis);
    }

    function setXAxis() {

      if (Globals.gX) {
        Globals.gX.remove();
      }
      if (Globals.xAxisCircle) {
        Globals.xAxisCircle.remove();
      }

      var svg = Globals.chartSVG.select('.chart-g');

      Globals.xScale = d3.scaleLinear()
        .range([0, Globals.width]);

      var min = Globals.config.axes.x.min || getMinX() || 0;
      var max = Globals.config.axes.x.max || getMaxX() || 1;
      Globals.xScale.domain([min, max]);

      Globals.xAxis = d3.axisBottom(Globals.xScale);
      if (Globals.config.axes.x.ticks) {
        Globals.xAxis.ticks(Globals.config.axes.x.ticks);
      }
      if (Globals.config.axes.x.tickFormat) {
        console.log(Globals.config.axes.x);
        Globals.xAxis.tickFormat(Globals.config.axes.x.tickFormat);
      }
      Globals.gX = svg.append("g")
        .attr("class", "axis x-axis")
        .attr('fill', 'none')
        .attr("transform", "translate(0," + (Globals.height) + ")")
        .call(Globals.xAxis);

      Globals.xAxisCircle = Globals.chartSVG.append('circle')
        .style('box-shadow', '10px 10px 5px #333')
        .attr('opacity', 0)
        .attr('r', Globals.circleRadius)
        .attr('fill', "#333")
        .attr('stroke', '#fff')
        .attr('stroke-width', Globals.circleStrokeWidth)
        .attr('class', 'mouse-indicator-circle');
    }

    function updateZoomScaleExtent() {
      if (!Globals.zooomBehavior) {
        return;
      }
      Globals.zooomBehavior.scaleExtent([1, getScaleExtent()]);
    }

    function setMouseOverlay() {

      if (Globals.mouseOverlay) {
        Globals.mouseOverlay.remove();
      }

      Globals.mouseOverlay = Globals.viewSVG.append('rect')
        .attr('width', Globals.width)
        .attr('height', Globals.height)
        .attr('fill', 'transparent')
        .on('mouseenter', function() {
          toggleCirclesVisibility(true);
        })
        .on('mouseout', function() {
          toggleCirclesVisibility(false);
        })
        .on('mousemove', followTheMouse);
    }

    function initChart(elem, data, config) {

      initGlobalVars();
      Globals.data = data;
      Globals.config = config;
      Globals.zooomBehavior = d3.zoom()
        .on("start", function() {
          isZooming = true;
          toggleCirclesVisibility(false);
        })
        .on("end", function() {
          isZooming = false;
        })
        .on("zoom", zoomed);

      d3.select(elem).selectAll("*").remove();

      var width = Globals.width = elem.parentElement.offsetWidth - config.margin.left - config.margin.right;
      var height = Globals.height = elem.parentElement.offsetHeight - config.margin.top - config.margin.bottom;

      var chartSVG = Globals.chartSVG = d3.select(elem).append("svg")
        .attr("width", width + config.margin.left + config.margin.right)
        .attr("height", height + config.margin.top + config.margin.bottom)
        .call(Globals.zooomBehavior)
        .on("mousemove", followMouseOnXAxis);

      var svg = chartSVG.append("g")
        .attr("transform", "translate(" + config.margin.left + "," + config.margin.top + ")")
        .attr('class', 'chart-g');


      Globals.viewSVG = svg.append('svg')
        .attr('width', width)
        .attr('height', height)
        .append('g')
        .attr('width', width)
        .attr('height', height)
        .attr('class', 'viewSVG');

      setYAxis();
      setXAxis();
      drawLines();
      updateZoomScaleExtent();
      setMouseOverlay();

    }

    function followMouseOnXAxis() {

      var x = d3.mouse(this)[0];

      Globals.xAxisCircle
        .attr("cx", x)
        .attr("cy", Globals.height + Globals.config.margin.top);
    }

    function followTheMouse() {
      if (isZooming) {
        return;
      }
      toggleCirclesVisibility(true);
      var x = d3.mouse(this)[0];

      Globals.lines.forEach(function(path, i) {
        var pathEl = path.node();
        var pathLength = pathEl.getTotalLength();
        var beginning = x,
          end = pathLength,
          target,
          pos;

        while (true) {
          target = Math.floor(((beginning + end) / 2) * 100) / 100;
          pos = pathEl.getPointAtLength(target);
          if ((target === end || target === beginning) && pos.x !== x) {
            break;
          }
          if (pos.x > x) {
            end = target;
          } else if (pos.x < x) {
            beginning = target;
          } else {
            break; //position found
          }
        }

        Globals.circles[i]
          .attr("cx", x)
          .attr("cy", pos.y);
      });

      Globals.dashedLine
        .attr("opacity", 1)
        .attr('x1', x)
        .attr('x2', x);

      // get data point at point x
      var line_config = Globals.config.series[0];
      var x0 = Globals.xScale.invert(x);
      var i = bisectX(line_config)(Globals.data[line_config.dataset], x0, 1);
      var d0 = Globals.data[line_config.dataset][i - 1];

      if (!d0) {
        return;
      }

      var d1 = Globals.data[line_config.dataset][i];
      var d = x0 - d0[line_config.x] > d1[line_config.x] - x0 ? d1 : d0;

      if (Globals.onMouseMove) {
        Globals.onMouseMove(d);
        $scope.$apply();
      }

    }

    function toggleCirclesVisibility(show) {
      var opacity = show ? 1 : 0;
      Globals.dashedLine.attr('opacity', opacity);
      Globals.circles.forEach(function(circle) {
        circle.attr('opacity', opacity);
      });
      Globals.xAxisCircle.attr('opacity', opacity);
    }

    this._getTransformXFromScroll = function(scroll) {
      scroll = scroll < 0 ? 0 : (scroll > 1 ? 1 : scroll);
      var transform = this.getTransform();
      var new_width = Globals.width * transform.k;
      var transform_x = -((new_width - Globals.width) * scroll);
      return transform_x;
    }

    this.scroll = function scroll(s) { // s = {0..1}
      var transform = this.getTransform();
      var transform_x = this._getTransformXFromScroll(s);
      var new_transform = d3.zoomIdentity.translate(transform_x, transform.y).scale(transform.k);
      Globals.chartSVG.call(Globals.zooomBehavior.transform, new_transform);
    };

    this.onZoomAndPan = function(fn) {
      // fn will receive (transform, width, height)
      Globals.onZoomAndPan = fn;
    };

    this.getDimensions = function() {
      return {
        width: Globals.width,
        height: Globals.height
      };
    };

    this.getTransform = function() {
      return d3.zoomTransform(Globals.chartSVG.node());
    };

    this.reset = function() {
      Globals.chartSVG.call(Globals.zooomBehavior.transform, d3.zoomIdentity);
    };

    this.zoomTo = function(zoom_percent) { // zoom_percent = {0..1}
      zoom_percent = zoom_percent || 0;
      zoom_percent = zoom_percent < 0 ? 0 : (zoom_percent > 1 ? 1 : zoom_percent);
      var k = ((getScaleExtent() - 1) * zoom_percent) + 1;
      Globals.chartSVG.call(Globals.zooomBehavior.scaleTo, k);
    };

    this.setMouseMoveListener = function(fn) {
      Globals.onMouseMove = fn;
    }

    this.updateSeries = function(series) {
      Globals.config.series = series;
    };

    this.updateData = function(data) {
      Globals.data = data;
      updateZoomScaleExtent();
    };

    this.updateConfig = function(config) {
      Globals.config = config;
    };

    this.updateInterpolation = function(i) {
      Globals.config.axes.y.scale = i;
    };

    this.getScaleExtent = function() {
      return getScaleExtent() || 1;
    };

    this.empty = function() {
      console.log('empty');
      d3.select(elem).selectAll('*').remove();
    };

    this.setYAxis = setYAxis;
    this.setXAxis = setXAxis;
    this.drawLines = drawLines;

    initChart(elem, data, config);

  }

  window.ChaiBioCharts = window.ChaiBioCharts || {};
  window.ChaiBioCharts.ThermalProfileChart = ThermalProfileChart;

})();
