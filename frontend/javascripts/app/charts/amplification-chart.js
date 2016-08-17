(function() {

  "use strict";

  function AmplificationChart(elem, data, config) {

    // Global vars
    var Globals = {
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
      activePath: null,
      lines: null,
      circle: null,
      xScale: null,
      yScale: null,
      zooomBehavior: null,
      zoomTransform: { k: 1, x: 0, y: 0 },
      onZoomAndPan: null
    };

    var superscript = "⁰¹²³⁴⁵⁶⁷⁸⁹",
      formatPower = function(d) {
        return (d + "").split("").map(function(c) {
          return superscript[c];
        }).join("");
      };
    // end global vars

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
        .attr("d", line)
        .attr('stroke-width', '3px')
        .on('click', function(e, a, path) {
          resetActivePath(Globals.zoomTransform.k);
          Globals.activePath = _path;
          _path.attr('stroke-width', 5 / Globals.zoomTransform.k + 'px');
          circleFollowsMouse.call(this);
        });

      Globals.lines.push(_path);
    }

    function drawLines() {
      var series = Globals.config.series;
      if (!series) {
        return;
      }
      if (!Globals.lines) { Globals.lines = []; }

      Globals.chartSVG.selectAll('.lines').remove()

      series.forEach(function(s, i) {
        makeLine(s);
      });

      makeCircle();
    }

    function resetActivePath(k) {
      if (!Globals.activePath) {
        return;
      }
      Globals.activePath.attr('stroke-width', 3 / k + 'px');
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

    function makeCircle() {
      if (Globals.circle) { Globals.circle.remove(); }
      Globals.circle = Globals.viewSVG.append('circle')
        .attr('opacity', 0)
        .attr('r', 7)
        .attr('fill', 'red')
        .attr('stroke', '#fff')
        .attr('stroke-width', '2px')
        .attr('transform', 'translate (50,50)');
    }

    function updateLineStrokeWidthOnZoom(k) {
      Globals.lines.forEach(function(l) {
        var strokeWidth = (l === Globals.activePath)? 5 : 3; //default stroke width
        var strokeDiff = (strokeWidth * k) - strokeWidth;
        var newStrokeWidth = strokeWidth / k;
        l.attr('stroke-width', newStrokeWidth + 'px');
      });
    }

    function zoomed() {
      var transform = d3.event.transform;
      transform.x = transform.x || 0;
      transform.y = transform.y || 0;
      transform.k = transform.k || 0;

      if (transform.x > 0) {
        transform.x = 0;
      }

      if (transform.x + (Globals.width*transform.k) < Globals.width) {
        transform.x = -(Globals.width*transform.k - Globals.width);
      }

      if (transform.y > 0) {
        transform.y = 0;
      }

      if (transform.y + (Globals.height*transform.k) < Globals.height) {
        transform.y = -(Globals.height*transform.k - Globals.height);
      }

      Globals.viewSVG.attr("transform", transform);
      Globals.gX.call(Globals.xAxis.scale(transform.rescaleX(Globals.xScale)));
      Globals.gY.call(Globals.yAxis.scale(transform.rescaleY(Globals.yScale)));
      Globals.zoomTransform = transform;
      updateLineStrokeWidthOnZoom(transform.k);
      circleFollowsMouse.call(this);

      if (Globals.onZoomAndPan) {
        Globals.onZoomAndPan(Globals.zoomTransform, Globals.width, Globals.height);
      }
    }

    function getMinX() {
      var xs = [];
      Globals.config.series.forEach(function(s) {
        var min_dataset_x = d3.min(Globals.data[s.dataset], function(d) {
          return d[s.x];
        });
        xs.push(min_dataset_x);
      });
      return d3.min(xs, function(d) {
        return d; });
    }

    function getMaxX() {
      var xs = [];
      Globals.config.series.forEach(function(s) {
        var max_dataset_x = d3.max(Globals.data[s.dataset], function(d) {
          return (d[s.x]);
        });
        xs.push(max_dataset_x);
      });
      return d3.max(xs, function(d) {
        return d; });
    }

    function getMinY() {
      var ys = [];
      Globals.config.series.forEach(function(s) {
        var min_dataset_y = d3.min(Globals.data[s.dataset], function(d) {
          return d[s.y];
        });
        ys.push(min_dataset_y);
      });
      return d3.min(ys, function(d) {
        return d; });
    }

    function getMaxY() {
      var ys = [];
      Globals.config.series.forEach(function(s) {
        var max_dataset_y = d3.max(Globals.data[s.dataset], function(d) {
          return d[s.y];
        });
        ys.push(max_dataset_y);
      });
      return d3.max(ys, function(d) {
        return d; });
    }

    function getScaleExtent () {
      return getMaxX();
    }

    function initChart(elem, data, config) {

      console.log(config);

      Globals.data = data;
      Globals.config = config;

      d3.select(elem).selectAll("*").remove();

      var width = Globals.width = elem.parentElement.offsetWidth - config.margin.left - config.margin.right;
      var height = Globals.height = elem.parentElement.offsetHeight - config.margin.top - config.margin.bottom;

      // current supported scales
      var scales = {
        log: d3.scaleLog,
        linear: d3.scaleLinear
      };

      var x_scale = config.axes.x.scale || 'linear';
      Globals.xScale = scales[x_scale]()
        .range([0, width]);

      var y_scale = config.axes.y.scale || 'linear';
      Globals.yScale = scales[y_scale]()
        .range([height, 0]);

      Globals.zooomBehavior = d3.zoom().on("zoom", zoomed);

      var chartSVG = Globals.chartSVG = d3.select(elem).append("svg")
        .attr("width", width + config.margin.left + config.margin.right)
        .attr("height", height + config.margin.top + config.margin.bottom)
        .call(Globals.zooomBehavior)

      var svg = chartSVG.append("g")
        .attr("transform", "translate(" + config.margin.left + "," + config.margin.top + ")")
        .attr('class', 'chart');

      Globals.xScale.domain([getMinX(), getMaxX()]);
      Globals.yScale.domain([getMinY(), getMaxY()]);

      Globals.xAxis = d3.axisBottom(Globals.xScale);
      Globals.gX = svg.append("g")
        .attr("class", "axis x-axis")
        .attr('fill', 'none')
        .attr("transform", "translate(0," + (height) + ")")
        .call(Globals.xAxis);

      Globals.yAxis = d3.axisLeft(Globals.yScale);

      if (config.axes.y.scale === 'log') {
        Globals.yAxis.ticks(10, function(d) {
          var length = d.toString().length;
          var dividend = '1';
          for (var i = 1; i < length; i++) {
            dividend = dividend + '0';
          }
          dividend = dividend * 1;
          var significant_number = d / dividend;
          return significant_number + 'x' + 10 + formatPower(Math.round(Math.log(d) / Math.LN10));
        });
      }
      Globals.gY = svg.append("g")
        .attr("class", "axis y-axis")
        .attr('fill', 'none')
        .call(Globals.yAxis);

      Globals.viewSVG = svg.append('svg')
        .attr('width', width)
        .attr('height', height)
        .append('g')
        .attr('width', width)
        .attr('height', height)
        .attr('class', 'viewSVG');

      Globals.mouseOverlay = Globals.viewSVG.append('rect')
        .attr('width', width)
        .attr('height', height)
        .attr('fill', 'transparent')
        .on('mousemove', circleFollowsMouse);

      drawLines(config.series);
      makeCircle();
      Globals.activePath = null;
      Globals.zooomBehavior.scaleExtent([1, getScaleExtent()]);

      // Globals.zooomBehavior.xExtent(getMinX(), getMaxX());

    }

    function circleFollowsMouse() {
      if (!Globals.activePath) {
        return;
      }
      var x = d3.mouse(this)[0];

      var pathEl = Globals.activePath.node();
      var pathLength = pathEl.getTotalLength();
      var beginning = x,
        end = pathLength,
        target,
        pos;

      while (true) {
        target = Math.floor((beginning + end) / 2);
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

      Globals.circle
        .attr("opacity", 1)
        .attr("cx", x)
        .attr("cy", pos.y)
        .attr('transform', 'translate(0,0) scale(1)')
        .attr('r', 7 / Globals.zoomTransform.k + 'px')
        .attr('stroke-width', 2 / Globals.zoomTransform.k + 'px')
        .attr('fill', Globals.activePath.attr('stroke'));
    }

    this._getTransformXFromScroll = function (scroll) {
      scroll = scroll < 0 ? 0 : (scroll > 1 ? 1 : scroll);
      var transform = this.getTransform();
      var new_width = Globals.width*transform.k;
      var transform_x = -((new_width-Globals.width)*scroll);
      return transform_x;
    }

    this.scroll = function scroll (scroll) { // scroll = {0..1}
      var transform = this.getTransform();
      var transform_x = this._getTransformXFromScroll(scroll);
      var new_transform = d3.zoomIdentity.translate(transform_x, transform.y).scale(transform.k);
      Globals.chartSVG.call(Globals.zooomBehavior.transform, new_transform);
    };

    this.onZoomAndPan = function (fn) {
      // fn will receive (transform, width, height)
      Globals.onZoomAndPan = fn;
    };

    this.getTransform = function () {
      return d3.zoomTransform(Globals.chartSVG.node());
    };

    this.reset = function () {
      Globals.chartSVG.call(Globals.zooomBehavior.transform, d3.zoomIdentity);
    };

    this.zoomTo = function (zoom_percent) { // zoom_percent = {0..1}
      zoom_percent = zoom_percent || 0;
      zoom_percent = zoom_percent < 0 ? 0 : (zoom_percent > 1 ? 1 : zoom_percent);
      var k = ((getScaleExtent() - 1)*zoom_percent) + 1;
      // var current_transform = this.getTransform();
      // var x = this._getTransformXFromScroll(scroll);
      // var center_point_y = current_transform.y - (Globals.height/2);
      // var end_point_y = -(current_transform.k*Globals.height);
      // var ratio = center_point_y/end_point_y
      // var new_end_point_y = -(k*Globals.height)
      // var new_center_point_y = new_end_point_y * ratio
      // var y = new_center_point_y + Globals.height/2;
      // console.log('ratio: ' + ratio);
      // console.log('new height: ' + new_end_point_y);
      // console.log('new center_point_y: ' + new_center_point_y);
      // console.log('new ratio: ' + new_center_point_y/new_end_point_y);
      // var transform = d3.zoomIdentity.scale(k).translate(x, y);
      // Globals.chartSVG.call(Globals.zooomBehavior.transform, transform);
      Globals.chartSVG.call(Globals.zooomBehavior.scaleTo, k);
    };

    this.getScaleExtent = function () {
      return getScaleExtent() || 1;
    };

    initChart(elem, data, config);

  }

  window.ChaiBioCharts = window.ChaiBioCharts || {};
  window.ChaiBioCharts.AmplificationChart = AmplificationChart;

})();
