(function() {

  "use strict";

  function AmplificationChart(elem, data, config) {

    // Global vars
    var Globals = null;
    // current supported axis interpolations
    var INTERPOLATIONS = {
      log: d3.scaleLog,
      linear: d3.scaleLinear
    };
    var bisectX = function(line_config) {
      return d3.bisector(function(d) {
        return d[line_config.x];
      }).left;
    };

    function initGlobalVars() {
      Globals = {
        width: 0,
        height: 0,
        data: null,
        config: null,
        chartSVG: null,
        viewSVG: null,
        box: null,
        gX: null,
        gY: null,
        xAxis: null,
        yAxis: null,
        mouseOverlay: null,
        activePath: null,
        activePathConfig: null,
        lines: null,
        // lineIndexes: null,
        circle: null,
        xScale: null,
        yScale: null,
        zooomBehavior: null,
        zoomTransform: {
          k: 1,
          x: 0,
          y: 0
        },
        onZoomAndPan: null,
        normalPathStrokeWidth: 2,
        activePathStrokeWidth: 3,
        circleRadius: 5,
        circleStrokeWidth: 2
      };
    }

    var superscript = "⁰¹²³⁴⁵⁶⁷⁸⁹",
      formatPower = function(d) {
        return (d + "").split("").map(function(c) {
          return superscript[c];
        }).join("");
      };
    // end global vars

    function hideCircle() {
      if (Globals.circle) {
        Globals.circle.attr('opacity', 0);
      }
    }

    function getActivePathConfig(path) {
      var activePathConfig, activePathIndex;
      for (var i = Globals.lines.length - 1; i >= 0; i--) {
        var l = Globals.lines[i];
        if (l === path) {
          activePathConfig = Globals.config.series[i];
          activePathIndex = i;
          break;
        }
      }
      return {
        config: activePathConfig,
        index: activePathIndex,
      };
    }

    function setActivePath(path, mouse) {
      if (Globals.activePath) {
        // Globals.activePath.attr('stroke-width', Globals.normalPathStrokeWidth / Globals.zoomTransform.k);
        Globals.activePath.attr('stroke-width', Globals.normalPathStrokeWidth);
      }
      Globals.activePathConfig = getActivePathConfig(path);
      var activePathConfig = Globals.activePathConfig.config;
      var activePathIndex = Globals.activePathConfig.index;
      // var newLine = makeLine(activePathConfig).attr('stroke-width', Globals.activePathStrokeWidth / Globals.zoomTransform.k);
      var newLine = makeLine(activePathConfig).attr('stroke-width', Globals.activePathStrokeWidth);
      Globals.lines[activePathIndex] = newLine;
      Globals.activePath = newLine;
      makeCircle();
      path.remove();

      if (Globals.circle) {
        Globals.circle
          .attr("opacity", 1)
          .attr("cx", mouse[0])
          .attr("cy", mouse[1])
          .attr('transform', 'translate(0,0) scale(1)')
          .attr('fill', activePathConfig.color);
      }

      // if (Globals.box) {
      //   if (Globals.box.CqText && Globals.activePathConfig.config.cq) {
      //     Globals.box.CqText.text('Cq: ' + Globals.activePathConfig.config.cq[activePathConfig.channel - 1]);
      //   }
      // }

      makeBox(Globals.activePathConfig.config);
      setBoxRFYAndCycleTexts(mouse[0]);

    }

    function unsetActivePath() {
      if (!Globals.activePath) {
        return;
      }
      hideCircle();
      Globals.activePath.attr('stroke-width', Globals.normalPathStrokeWidth);
      Globals.activePathConfig = null;
      Globals.activePath = null;
      // Globals.box.container.attr('opacity', 0);
      if (Globals.box) {
        Globals.box.container.remove();
      }
    }

    function makeBox(line_config) {

      if (Globals.box) {
        Globals.box.container.remove();
      }

      var headerHeight = 25;
      var headerTextSize = 15;
      var valuesTextSize = 12;
      var boxWidth = 150;
      var bodyHeight = 70;
      var boxMargin = {
        top: 10,
        left: 10
      }

      Globals.box = {};

      Globals.box.container = Globals.chartSVG.append('g')
        .attr('stroke', '#333')
        .attr('stroke-width', 0.2)
        .attr('transform', 'translate(' + (boxMargin.left + Globals.config.margin.left) + ',' + (boxMargin.top + Globals.config.margin.top) + ')')
        .attr('fill', '#fff')
        .attr('width', boxWidth)
        .attr('height', headerHeight + bodyHeight)
        .on('mousemove', circleFollowsMouse);

      Globals.box.header = Globals.box.container.append('rect')
        // .attr('x', 0)
        // .attr('y', 0)
        .attr('fill', line_config.color)
        .attr('width', boxWidth)
        .attr('height', headerHeight);

      Globals.box.headerText = Globals.box.container.append('text')
        .attr('x', function() {
          return boxWidth / 2;
        })
        .attr("text-anchor", "middle")
        .attr("alignment-baseline", "middle")
        .attr("font-size", headerTextSize + 'px')
        .attr("fill", "#fff")
        .attr("stroke-width", 0)
        .text(function() {
          var wells = ['A1', 'A2', 'A3', 'A4', 'A5', 'A6', 'A7', 'A8', 'B1', 'B2', 'B3', 'B4', 'B5', 'B6', 'B7', 'B8'];
          return wells[line_config.well] + ', ' + (line_config.dataset === 'channel_1' ? 'Ch1' : 'Ch2');
        })
        .attr('font-weight', 700)
        .attr('class', 'header-text');

      Globals.box.headerText.attr('y', function() {
        var textDims = Globals.box.headerText.node().getBBox();
        return headerHeight / 2 + (headerHeight - textDims.height) / 2;
      });

      Globals.box.body = Globals.box.container.append('rect')
        .attr('y', headerHeight)
        .attr('fill', '#fff')
        .attr('width', boxWidth)
        .attr('height', bodyHeight);

      Globals.box.CqText = Globals.box.container.append('text')
        // .attr("text-anchor", "middle")
        // .attr("alignment-baseline", "middle")
        .attr("font-size", headerTextSize + 'px')
        .attr('fill', "#000")
        .attr("font-weight", 700)
        .attr('x', 10)
        .attr('y', boxMargin.top + headerHeight + 10)
        .text('Cq');

      var ctTextDims = Globals.box.CqText.node().getBBox();

      Globals.box.RFYTextLabel = Globals.box.container.append('text')
        .attr("font-weight", 700)
        .attr("font-size", valuesTextSize + 'px')
        .attr('fill', "#000")
        .attr('x', 10)
        .attr('y', boxMargin.top + headerHeight + ctTextDims.height + 10)
        .text('RFY');

      var rfyLabelDims = Globals.box.RFYTextLabel.node().getBBox();

      Globals.box.RFYTextValue = Globals.box.container.append('text')
        .attr("font-size", valuesTextSize + 'px')
        .attr('fill', "#000")
        .attr('x', 10)
        .attr('y', boxMargin.top + headerHeight + ctTextDims.height + rfyLabelDims.height + 10);

      Globals.box.cycleTextLabel = Globals.box.container.append('text')
        .attr("font-weight", 700)
        .attr("font-size", valuesTextSize + 'px')
        .attr('fill', "#000")
        .attr('x', 70)
        .attr('y', boxMargin.top + headerHeight + ctTextDims.height + 10)
        .text('Cycle');

      var cycleLabelDims = Globals.box.cycleTextLabel.node().getBBox();

      Globals.box.cycleTextValue = Globals.box.container.append('text')
        .attr("font-size", valuesTextSize + 'px')
        .attr('fill', "#000")
        .attr('x', 70)
        .attr('y', boxMargin.top + headerHeight + cycleLabelDims.height + ctTextDims.height + 10);

    }

    function setBoxRFYAndCycleTexts(x) {
      // get data point at point x
      var line_config = Globals.activePathConfig.config;
      var x0 = Globals.xScale.invert(x);
      var i = bisectX(line_config)(Globals.data[line_config.dataset], x0, 1);
      var d0 = Globals.data[line_config.dataset][i - 1];
      if (!d0) {
        return;
      }

      var d1 = Globals.data[line_config.dataset][i];
      if (!d1) {
        return;
      }

      var d = x0 - d0[line_config.x] > d1[line_config.x] - x0 ? d1 : d0;

      if (Globals.box && Globals.activePath) {
        var conf = Globals.activePathConfig;
        if (Globals.box.RFYTextValue) {
          Globals.box.RFYTextValue.text(d[Globals.config.series[conf.index].y]);
        }
        if (Globals.box.cycleTextValue) {
          Globals.box.cycleTextValue.text(d[Globals.config.series[conf.index].x]);
        }
        if (Globals.box.CqText && Globals.activePathConfig.config.cq) {
          var conf = Globals.activePathConfig.config;
          var cqText = 'Cq: ' + (conf.cq[conf.channel - 1] || '');
          Globals.box.CqText.text(cqText);
        }
      }
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
        .attr("d", line)
        .attr('stroke-width', Globals.normalPathStrokeWidth)
        .on('click', function(e, a, path) {
          setActivePath.call(this, _path, d3.mouse(this));
        })
        .on('mousemove', circleFollowsMouse);

      return _path;
    }

    function drawLines() {
      var series = Globals.config.series;
      if (!series) {
        return;
      }
      Globals.lines = Globals.lines || [];
      // Globals.chartSVG.selectAll('.line').remove();
      Globals.lines.forEach(function(line) {
        line.remove();
      });
      Globals.lines = [];
      Globals.activePath = null;

      series.forEach(function(s, i) {
        Globals.lines.push(makeLine(s));
      });

      makeCircle();
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
      if (Globals.circle) {
        Globals.circle.remove();
      }
      Globals.circle = Globals.viewSVG.append('circle')
        .attr('opacity', 0)
        // .attr('r', Globals.circleRadius / Globals.zoomTransform.k)
        .attr('r', Globals.circleRadius)
        .attr('fill', 'red')
        .attr('stroke', '#fff')
        // .attr('stroke-width', Globals.circleStrokeWidth / Globals.zoomTransform.k)
        .attr('stroke-width', Globals.circleStrokeWidth)
        .attr('transform', 'translate (50,50)')
        .on('mousemove', circleFollowsMouse);
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

      Globals.chartSVG.selectAll('g.axis.y-axis').remove();

      var svg = Globals.chartSVG.select('.chart-g');

      // add allowance for interpolation curves
      var max = getMaxY();
      var min = getMinY();
      var diff = max - min;
      var allowance = diff * (Globals.config.axes.y.scale === 'log' ? 0.2 : 0.05);
      max += allowance;
      min -= allowance;

      Globals.yScale = d3.scaleLinear()
        .range([Globals.height, 0])
        .domain([min, max]);

      Globals.yAxis = d3.axisLeft(Globals.yScale);

      if (Globals.config.axes.y.tickFormat) {
        Globals.yAxis.tickFormat(Globals.config.axes.y.tickFormat);
      }

      if (Globals.config.axes.y.scale === 'log') {
        Globals.yAxis
          .tickValues(getYLogticks())
          .tickFormat(function(d) {
            return '10' + formatPower(Math.round(Math.log(d) / Math.LN10));
          });
      }
      Globals.gY = svg.append("g")
        .attr("class", "axis y-axis")
        .attr('fill', 'none')
        .call(Globals.yAxis);
    }

    function setXAxis() {

      Globals.chartSVG.selectAll('g.axis.x-axis').remove();

      var svg = Globals.chartSVG.select('.chart-g');

      Globals.xScale = d3.scaleLinear()
        .range([0, Globals.width]);

      var min = Globals.config.axes.x.min || getMinX() || 0;
      var max = Globals.config.axes.x.max || getMaxX() || 1;
      Globals.xScale.domain([min, max]);

      Globals.xAxis = d3.axisBottom(Globals.xScale);
      if (Globals.config.axes.x.ticks) {
        Globals.xAxis.tickValues = Globals.config.axes.x.ticks;
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
    }

    function updateZoomScaleExtent() {
      if (!Globals.zooomBehavior) {
        return;
      }
      Globals.zooomBehavior.scaleExtent([1, getScaleExtent()]);
    }

    function initChart(elem, data, config) {

      console.log(data);
      console.log(config);

      initGlobalVars();
      Globals.data = data;
      Globals.config = config;
      Globals.zooomBehavior = d3.zoom().on("zoom", zoomed);

      d3.select(elem).selectAll("*").remove();

      var width = Globals.width = elem.parentElement.offsetWidth - config.margin.left - config.margin.right;
      var height = Globals.height = elem.parentElement.offsetHeight - config.margin.top - config.margin.bottom;

      console.log(width, height);

      var chartSVG = Globals.chartSVG = d3.select(elem).append("svg")
        .attr("width", width + config.margin.left + config.margin.right)
        .attr("height", height + config.margin.top + config.margin.bottom)
        .call(Globals.zooomBehavior)

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

      Globals.mouseOverlay = Globals.viewSVG.append('rect')
        .attr('width', width)
        .attr('height', height)
        .attr('fill', 'transparent')
        .on('mousemove', circleFollowsMouse)
        .on('mouseout', hideCircle)
        .on('click', unsetActivePath);

      setYAxis();
      setXAxis();
      drawLines(config.series);
      makeCircle();
      Globals.activePath = null;
      updateZoomScaleExtent()

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

      Globals.circle
        .attr("opacity", 1)
        .attr("cx", x)
        .attr("cy", pos.y)
        .attr('transform', 'translate(0,0) scale(1)');

      setBoxRFYAndCycleTexts(x);
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

    this.updateSeries = function(series) {
      Globals.config.series = series;
    };

    this.updateData = function(data) {
      console.log('update data');
      console.log(data);
      Globals.data = data;
      updateZoomScaleExtent();
    };

    this.updateConfig = function(config) {
      console.log('set config:');
      console.log(config);
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
  window.ChaiBioCharts.AmplificationChart = AmplificationChart;

})();
