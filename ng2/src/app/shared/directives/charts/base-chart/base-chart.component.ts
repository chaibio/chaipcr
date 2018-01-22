import {
  Directive,
  ElementRef,
  Input,
  OnInit,
  OnChanges
} from '@angular/core';

import * as d3 from 'd3';
import { WindowRef } from '../../../services/windowref/windowref.service';

@Directive({
  selector: '[chai-base-chart]'
})
export class BaseChartDirective implements OnChanges {

  protected NORMAL_PATH_STROKE_WIDTH = 2;
  protected HOVERED_PATH_STROKE_WIDTH = 3;
  protected ACTIVE_PATH_STROKE_WIDTH = 5;
  protected CIRCLE_STROKE_WIDTH = 2;
  protected CIRCLE_RADIUS = 7;
  protected AXIS_LABEL_FONT_SIZE = 10;
  protected AXES_TICKS_FONT_SIZE = 10;
  protected DEFAULT_MAX_Y = 1;
  protected DEFAULT_MAX_X = 1;
  protected DEFAULT_MIN_Y = 0;
  protected DEFAULT_MIN_X = 0;
  protected INPUT_PADDING = 5;
  protected MARGIN = {
    left: 0,
    top: 0,
    right: 0,
    bottom: 0
  };

  protected initialized = false;
  protected elem: HTMLDivElement;
  protected zoomTransform: any = {x: 0, y: 0, k: 1};
  protected isZooming = false;

  protected circle: any;
  protected activePathConfig: any;
  protected guidingLines: Array<any>;
  protected lines: Array<any>;
  protected hoveredLine: any;
  protected whiteBorderLine: any;
  protected hovering:boolean;
  protected activePath: any;
  protected chartSVG: any;
  protected viewSVG: any;
  protected mouseOverlay: any;
  protected box: any;
  protected xScale: any;
  protected lastXScale: any;
  protected yScale: any;
  protected lastYScale: any;
  protected yAxisLabel: any;
  protected editingYAxis: boolean;
  protected prevMousePosition: any;
  protected prevClosestLineIndex: any;
  protected onSelectLinceCb: any;
  protected onUnselectLinceCb: any;
  protected onZoomAndPanCb: any;
  protected height: number;
  protected width: number;
  protected xAxisLabel: any;
  protected yAxisUpperExtremeValue: any;
  protected yAxisLowerExtremeValue: any;
  protected xAxisLeftExtremeValue: any;
  protected xAxisRightExtremeValue: any;
  protected yAxisUpperExtremeValueContainer: any;
  protected yAxisLowerExtremeValueContainer: any;
  protected xAxisLeftExtremeValueContainer: any;
  protected xAxisRightExtremeValueContainer: any;
  protected gY: any;
  protected gX: any;
  protected yAxis: any;
  protected xAxis: any;
  protected zoomBehavior: any;

  constructor(protected el: ElementRef, protected wref: WindowRef) {
    this.elem = el.nativeElement;
  }

  @Input('data') data: any;
  @Input('config') config: any;

  ngOnInit() {
    this.initChart();
  }

  protected getLineCurve() {
    return d3.curveBasis;
  }

  protected isNumber(val) {
    if(Number.isNaN(val))
      return false;
    if(typeof val !== 'number')
      return false;
    return true;
  }

  protected hasData() {
    if(this.data && this.config) {
      if(this.config.series ? this.config.series.length > 0 : false) {
        if(this.data[this.config.series[0].dataset]? this.data[this.config.series[0].dataset].length > 1 : false)
          return true;
        else
          return false;
      } else
        return false;
    } else
      return false;
  }

  protected computedMaxY() {
    if(this.config.axes.y.max)
      return this.config.axes.y.max
    else if(this.hasData())
      return this.getMaxY()
    else
      return this.DEFAULT_MAX_Y
  }

  protected computedMinY() {
    if(this.config.axes.y.min)
      return this.config.axes.y.min
    else if(this.hasData())
      return this.getMinY()
    else
      return this.DEFAULT_MIN_Y
  }

  protected roundUpExtremeValue(val: number): number {
    return Math.ceil(val)
  }

  protected roundDownExtremeValue(val: number): number {
    return Math.floor(val)
  }

  protected xAxisTickFormat (x: number): string {
    let result: string;
    if(this.config.axes.x.tickFormat)
      result = this.config.axes.x.tickFormat(x);
    if(this.config.axes.x.unit)
      result = `${result}${this.config.axes.x.unit}`
    return result;
  }

  protected yAxisTickFormat (y:any) {
    if(this.config.axes.y.tickFormat && !isNaN(y))
      y = this.config.axes.y.tickFormat(y)
    if(this.config.axes.y.unit)
      y = isNaN(y) ? '' : y
    y = `${y}${this.config.axes.y.unit}`
    return y
  }

  protected bisectX(line_config) {
    return d3.bisector(d => {
      return d[line_config.x]
    }).left
  }

  protected getMousePosition(node) {
    let mouse = null
    try {
      mouse = d3.mouse(node)
    } catch(e) {
      if(this.activePathConfig && this.circle) {
        this.circle.attr('transform', 'translate(0,0) scale(1)')
        mouse = [this.circle.attr('cx'), this.circle.attr('cy')]
      } else {
        mouse = [0,0]
      }
    }

    return mouse;
  }

  protected setCaretPosition (input, caretPos) {
    if(input.createTextRange) {
      let range = input.createTextRange()
      range.collapse(true)
      range.moveEnd('character', caretPos)
      range.moveStart('character', caretPos)
      range.select()
    } else {
      input.focus()
      input.setSelectionRange(caretPos, caretPos)
    }
  }

  protected getPathConfig (path) {
    let activePathConfig: any;
    let activePathIndex: any;

    for (let i=0; i < this.lines.length; i ++) {
      let line = this.lines[i];
      if(line === path) {
        activePathConfig = this.config.series[i];
        activePathIndex = i;
        break;
      }
    }

    return {
      config: activePathConfig,
      index: activePathIndex
    }

  }

  protected hideMouseIndicators() {
    if(this.circle)
      this.circle.attr('opacity', 0)
  }

  protected showMouseIndicators() {
    if(this.circle)
      this.circle.attr('opacity', 1)
  }

  protected setActivePath (path, mouse) {
    if(this.activePath)
      this.activePath.attr('stroke-width', this.NORMAL_PATH_STROKE_WIDTH)

    this.activePathConfig = this.getPathConfig(path)
    if(!this.activePathConfig.config)
      return

    let lineConfig = this.activePathConfig.config;
    let lineIndex = this.activePathConfig.index;

    this.makeWhiteBorderLine(lineConfig);
    let newLine = this.makeColoredLine(lineConfig).attr('stroke-width', this.ACTIVE_PATH_STROKE_WIDTH);
    this.lines[lineIndex] = newLine;
    this.activePath = newLine;
    this.makeCircle();
    path.remove();
    this.drawBox(lineConfig);

    if(mouse) {
      this.showMouseIndicators();
      this.setBoxRFYAndCycleTexts(mouse[0]);
      this.mouseMoveCb();
    } else {
      this.hideMouseIndicators();
    }

    if(typeof this.onSelectLinceCb === 'function')
      this.onSelectLinceCb(this.activePathConfig);

    this.prevMousePosition = mouse;
  }

  protected unsetActivePath() {
    if(this.activePath) {
      this.hideMouseIndicators();
      this.activePath.attr('stroke-width', this.NORMAL_PATH_STROKE_WIDTH);
      this.whiteBorderLine.remove();
      this.activePathConfig = null;
      this.activePath = null;
      if(this.box)
        this.box.container.remove();
      if(typeof this.onUnselectLinceCb === 'function')
        this.onUnselectLinceCb()
    }
  }

  protected drawBox(line_config) {
    if(this.box)
      this.box.container.remove()

    let headerHeight = 25;
    let headerTextSize = 15;
    let valuesTextSize = 12;
    let boxWidth = 130;
    let bodyHeight = 70;
    let boxBorderWidth = 1;
    let boxMargin = {
      top: 0,
      left: 10
    };

    this.box = {}
    this.box.container = this.chartSVG.append('g')
      .attr('stroke-width', 0)
      .attr('transform', `translate(${boxMargin.left + this.MARGIN.left},${boxMargin.top + this.MARGIN.top})`)
      .attr('fill', '#fff')
      .on('mousemove', () => {
        this.mouseMoveCb();
      })

    this.box.container.append('rect')
      .attr('fill', "#ccc")
      .attr('width', boxWidth + boxBorderWidth * 2)
      .attr('height', bodyHeight + headerHeight + boxBorderWidth * 2);

    this.box.header = this.box.container.append('rect')
      .attr('x', boxBorderWidth)
      .attr('y', boxBorderWidth)
      .attr('fill', line_config.color)
      .attr('width', boxWidth)
      .attr('height', headerHeight);

    this.box.headerText = this.box.container.append('text')
      .attr('x', (boxWidth + boxBorderWidth * 2) / 2)
      .attr('text-anchor', 'middle')
      .attr('alignment-baseline', 'middle')
      .attr('font-size', headerTextSize + 'px')
      .attr('fill', '#fff')
      .attr('stroke-width', 0)
      .text(() => {
        let wells = ['A1', 'A2', 'A3', 'A4', 'A5', 'A6', 'A7', 'A8', 'B1', 'B2', 'B3', 'B4', 'B5', 'B6', 'B7', 'B8'];
        return wells[line_config.well] + ', ' + (line_config.dataset === 'channel_1' ? 'Ch1' : 'Ch2')
      })
      .attr('font-weight', 700)
      .attr('class', 'header-text');

    this.box.headerText.attr('y', () => {
      let textDims = this.box.headerText.node().getBBox()
      return (headerHeight / 2 + (headerHeight - textDims.height) / 2) + boxWidth;
    });

    this.box.body = this.box.container.append('rect')
      .attr('x', boxBorderWidth)
      .attr('y', headerHeight + boxBorderWidth)
      .attr('fill', '#fff')
      .attr('width', boxWidth)
      .attr('height', bodyHeight);

    this.box.CqText = this.box.container.append('text')
      .attr('font-size', headerTextSize + 'px')
      .attr('fill', '#000')
      .attr('font-weight', 700)
      .attr('x', 10 + boxBorderWidth)
      .attr('y', headerHeight + 20 + boxBorderWidth)
      .text('Cq');

    let ctTextDims = this.box.CqText.node().getBBox();

    this.box.RFYTextLabel = this.box.container.append('text')
      .attr('font-weight', 700)
      .attr('font-size', valuesTextSize + 'px')
      .attr('fill', '#000')
      .attr('x', 10 + boxBorderWidth)
      .attr('y', headerHeight + ctTextDims.height + 20 + boxBorderWidth)
      .text(() => {
        let defaultText = 'RFU';
        return this.config.box ? (this.config.box.label? (this.config.box.label.y || defaultText) : defaultText) : defaultText
      })

    let rfyLabelDims = this.box.RFYTextLabel.node().getBBox();

    this.box.RFYTextValue = this.box.container.append('text')
      .attr("font-size", valuesTextSize + 'px')
      .attr('fill', "#000")
      .attr('x', 10 + boxBorderWidth)
      .attr('y', headerHeight + ctTextDims.height + rfyLabelDims.height + 20 + boxBorderWidth)

    this.box.cycleTextLabel = this.box.container.append('text')
      .attr('font-weight', 700)
      .attr('font-size', valuesTextSize + 'px')
      .attr('fill', '#000')
      .attr('x', 70 + boxBorderWidth)
      .attr('y', headerHeight + ctTextDims.height + 20 + boxBorderWidth)
      .text(() => {
        let defaultText = 'Cycle';
        return this.config.box ? (this.config.box.label? (this.config.box.label.y || defaultText) : defaultText) : defaultText
      })

    let cycleLabelDims = this.box.cycleTextLabel.node().getBBox();
    this.box.cycleTextValue = this.box.container.append('text')
      .attr("font-size", valuesTextSize + 'px')
      .attr('fill', "#000")
      .attr('x', 70 + boxBorderWidth)
      .attr('y', headerHeight + cycleLabelDims.height + ctTextDims.height + 20 + boxBorderWidth)
  }

  protected setBoxRFYAndCycleTexts(x) {
    let line_config = this.activePathConfig.config;
    let x0 = this.zoomTransform.k > 1 ? this.zoomTransform.rescaleX(this.xScale).invert(x) : this.xScale.invert(x);
    let i = this.bisectX(line_config)(this.data[line_config.dataset], x0, 1)
    let d0 = this.data[line_config.dataset][i - 1]
    if(!d0) return
    let d1 = this.data[line_config.dataset][i]
    if(!d1) return
    let d =  x0 - d0[line_config.x] > d1[line_config.x] - x0 ? d1 : d0

    if(this.box && this.activePath) {
      let conf = this.activePathConfig
      if(this.box.RFYTextValue)
        this.box.RFYTextValue.text(d[this.config.series[conf.index].y]);
      if(this.box.cycleTextValue)
        this.box.cycleTextValue.text(d[this.config.series[conf.index].x]);
      if(this.box.CqText && this.activePathConfig.config.q) {
        conf = this.activePathConfig.config
        let cqText = 'Cq: ' + (conf.cq[conf.channel - 1] || '')
        this.box.CqText.text(cqText);
      }
    }
  }

  protected getXScale() {
    let xScale = this.zoomTransform.k > 1 && !this.editingYAxis ? this.lastXScale : this.xScale;
    return xScale || this.xScale;
  }

  protected getYScale() {
    let yScale = this.lastYScale || this.yScale;
    if(this.editingYAxis)
      return yScale;
    if(yScale.invert(0) < this.getMaxY() || yScale.invert(this.height) > this.getMinY())
      return yScale;
    return this.yScale;
  }

  protected makeGuidingLine(line_config) {
    let xScale = this.getXScale();
    let yScale = this.getYScale();
    let line = d3.line();
    line.curve(this.getLineCurve());
    line.x(d => {
      return xScale(d[line_config.x])
    })
    line.y(d => {
      return yScale(d[line_config.y])
    })

    return this.viewSVG.append("path")
      .datum(this.data[line_config.dataset])
      .attr("class", "guiding-line")
      .attr("stroke", 'transparent')
      .attr('fill', 'none')
      .attr("d", line)
      .attr('stroke-width', this.NORMAL_PATH_STROKE_WIDTH)
      .on('mousemove', () =>  { return this.mouseMoveCb(); })
      .on('click', () => { return this.unsetActivePath(); })
  }

  protected makeColoredLine (line_config) {
    let xScale = this.getXScale()
    let yScale = this.getYScale()
    let  line = d3.line()
    line.curve(this.getLineCurve())
    line.x(d => {
      return xScale(d[line_config.x]);
    });
    line.y(d => {
      return yScale(d[line_config.y]);
    });

    let _path = this.viewSVG.append("path")

    _path.datum(this.data[line_config.dataset])
      .attr("class", "colored-line")
      .attr("stroke", line_config.color)
      .attr('fill', 'none')
      .attr("d", line)
      .attr('stroke-width', this.NORMAL_PATH_STROKE_WIDTH)
      .on('click', (e, a, path) => {
        let el = _path.node()
        this.setActivePath(_path, this.getMousePosition(el))
        this.mouseMoveCb()
      })
      .on('mousemove', (e, a, path) => {
        if(_path !== this.activePath) {
          _path.attr('stroke-width', this.HOVERED_PATH_STROKE_WIDTH)
          this.hoveredLine = _path;
          this.hovering = true;
        }
        this.mouseMoveCb()
      })
      .on('mouseout', (e, a, path) => {
        if(_path !== this.activePath) {
          _path.attr('stroke-width', this.NORMAL_PATH_STROKE_WIDTH);
          this.hovering = false;
        }
      })

    return _path;
  }

  protected makeWhiteBorderLine (line_config) {
    let xScale = this.getXScale()
    let yScale = this.getYScale()
    let line = d3.line()

    if(this.whiteBorderLine)
      this.whiteBorderLine.remove()

    line.curve(this.getLineCurve())
    line.x(d => { return xScale(d[line_config.x]) } )
    line.y(d => { return yScale(d[line_config.y]) })

    if(this.config.axes.y.scale === 'log')
      line.defined(d => { return d[line_config.y] > 10 })

    return this.whiteBorderLine = this.viewSVG.append("path")
      .datum(this.data[line_config.dataset])
      .attr("class", "white-border-line")
      .attr("stroke", "#fff")
      .attr('fill', 'none')
      .attr("d", line)
      .attr('stroke-width', this.ACTIVE_PATH_STROKE_WIDTH + 3)
  }

  protected drawLines() {
    let series = this.config.series
    if(!series) return

    this.guidingLines = this.guidingLines || []
    for (let i = 0; i < this.guidingLines.length; i ++) {
      let l = this.guidingLines[i];
      l.remove();
    }
    this.guidingLines = []

    this.lines = this.lines || []
    for (let i = 0; i < this.lines.length; i ++) {
      let l = this.guidingLines[i];
      l.remove();
    }
    this.lines = []

    this.activePath = null

    for (let i = 0; i < series.length; i ++) {
      let s = series[i];
      this.guidingLines.push(this.makeGuidingLine(s))
    }
    for (let i = 0; i < series.length; i ++) {
      let s = series[i];
      this.lines.push(this.makeColoredLine(s))
    }

    if(this.activePathConfig) {
      this.makeCircle()
      let m = this.prevMousePosition
      let p = null
      for (let i = 0; i < series.length; i ++) {
        let s = series[i];

        if(s.well === this.activePathConfig.config.well && s.channel === this.activePathConfig.config.channel) {
          p = this.lines[i]
          break
        }
      }

      if(p) {
        this.setActivePath(p, null)
        this.showMouseIndicators()
      }

    }
  }

  protected makeCircle () {
    let lastPos = null
    if(this.circle) {
      lastPos = {
        cx: this.circle.attr('cx'),
        cy: this.circle.attr('cy')
      }
      this.circle.remove()
    }

    this.circle = this.viewSVG.append('circle')
      .attr('opacity', 0)
      .attr('r', this.CIRCLE_RADIUS)
      .attr('stroke', '#fff')
      .attr('stroke-width', this.CIRCLE_STROKE_WIDTH)
      .attr('transform', 'translate (50,50)')
      .on('mouseout', () => {
        return this.hideMouseIndicators()
      })
      .on('mousemove', () => {
        return this.mouseMoveCb()
      })
      .on('click', () => {
        this.circle.remove()
        this.unsetActivePath()
        if(this.hoveredLine) {
          let mouse = this.getMousePosition(this.mouseOverlay.node())
          this.setActivePath(this.hoveredLine, mouse)
        }
      })

    if(this.activePathConfig)
      this.circle.attr('fill', this.activePathConfig.config.color)
    if(lastPos) {
      this.circle.attr('cx', lastPos.cx)
      this.circle.attr('cy', lastPos.cy)
    }
  }

  protected zoomed() {

    if(d3.event) return
    if(!d3.event.sourceEvent)
      d3.event.sourceEvent = {};

    if(d3.event.sourceEvent.srcElement === this.xAxisLeftExtremeValue.input.node())
      this.onClickLeftXAxisInput()

    if(d3.event.sourceEvent.srcElement === this.xAxisRightExtremeValue.input.node())
      this.onClickRightXAxisInput()
    if(d3.event.sourceEvent.srcElement === this.yAxisUpperExtremeValue.input.node())
      this.onClickUpperYAxisInput()
    if(d3.event.sourceEvent.srcElement === this.yAxisLowerExtremeValue.input.node())
      this.onClickLowerYAxisInput()

    let transform: any;
    transform = d3.event.transform
    transform.x = transform.x || 0
    transform.y = transform.y || 0
    transform.k = transform.k || 0

    if(transform.x > 0)
      transform.x = 0

    if(transform.x + (this.width * transform.k) < this.width)
      transform.x = -(this.width * transform.k - this.width)

    if(transform.y > 0)
      transform.y = 0

    if(transform.y + (this.height * transform.k) < this.height)
      transform.y = -(this.height * transform.k - this.height)

    if(transform.k < 1)
      transform.k = 1

    if(this.editingYAxis) {
      this.lastYScale = transform.rescaleY(this.yScale)
      this.gY.call(this.yAxis.scale(this.lastYScale))
    } else {
      this.lastXScale = transform.rescaleX(this.xScale)
      this.gX.call(this.xAxis.scale(this.lastXScale))
    }

    this.zoomTransform = transform
    this.updateAxesExtremeValues()

    if(this.onZoomAndPanCb && !this.editingYAxis) {
      this.onZoomAndPanCb(this.zoomTransform, this.width, this.height, this.getScaleExtent() - this.getMinX() )
    }

    this.drawLines()
  }

  protected getMinX() {
    if(this.config.axes.x.min)
      return this.config.axes.x.min
    let min = d3.min(this.config.series, (s:any) => {
      return d3.min(this.data[s.dataset], (d:any) => {
        return d[s.x];
      })
    })
    return min || 0;
  }

  getMaxX() {
    if(this.config.axes.x.max)
      return this.config.axes.x.max
    let max = d3.max(this.config.series, (s:any) => {
      return d3.max(this.data[s.dataset], (d:any) => {
        return d[s.x];
      })
    })
    return max || 0;
  }

  getMinY() {
    if(this.config.axes.y.min)
      return this.config.axes.y.min

    let min_y = d3.min(this.config.series, (s: any) => {
      return d3.min(this.data[s.dataset], (d: any) => {
        return d[s.y];
      })
    })
    return min_y || 0;
  }

  getMaxY() {
    if(this.config.axes.y.max)
      return this.config.axes.y.max
    let max_y = d3.max(this.config.series, (s:any) => {
      return d3.max(this.data[s.dataset], (d: any) => {
        return d[s.y]
      })
    })
    return max_y || 0
  }

  getScaleExtent() {
    return this.config.axes.x.max || this.getMaxX()
  }

  getYLinearTicks() {
    let max = this.getMaxY()
    let min = this.getMinY()
    min = Math.floor(min / 5000) * 5000 // ROUND(A2/5,0)*5
    max = Math.ceil(max / 5000) * 5000

    let ticks = []
    for (let i=min; i <= max; i+=5000 ) {
      ticks.push(i)
    }

    return ticks
  }

  setYAxis() {
    this.chartSVG.selectAll('g.axis.y-axis').remove()
    this.chartSVG.selectAll('.g-y-axis-text').remove()
    let svg = this.chartSVG.select('.chart-g')

    let max = this.computedMaxY()
    let min = this.computedMinY()

    this.yScale = d3.scaleLinear()
    this.yScale.range([this.height, 0]).domain([min, max])
    this.yAxis = d3.axisLeft(this.yScale)

    this.yAxis.tickFormat(y => {
      return this.yAxisTickFormat(y)
    })

    this.gY = svg.append("g")
      .attr("class", "axis y-axis")
      .attr('fill', 'none')
      .call(this.yAxis)
      .on('mouseenter', () => {
        this.hideMouseIndicators()
      })

    if(this.zoomTransform.rescaleY)
      this.gY.call(this.yAxis.scale(this.zoomTransform.rescaleY(this.yScale)))
    // text label for the y axis
    this.setYAxisLabel();
    this.lastYScale = this.yScale;
  }

  setYAxisLabel() {
    if(this.config.axes.y.label) return
    let svg = this.chartSVG.select('.chart-g')
    this.yAxisLabel = svg.append("text")
      .attr("class", "g-y-axis-text")
      .attr("transform", "rotate(-90)")
      .attr("y", 0 - this.MARGIN.left)
      .attr("x", 0 - (this.height / 2))
      .attr("dy", "1em")
      .attr("font-family", "dinot-bold")
      .attr("font-size", "#{this.AXIS_LABEL_FONT_SIZE}px")
      .attr("fill", "#333")
      .style("text-anchor", "middle")
      .text(this.config.axes.y.label)
  }


  setXAxis() {
    this.chartSVG.selectAll('g.axis.x-axis').remove()
    this.chartSVG.selectAll('.g-x-axis-text').remove()
    let svg = this.chartSVG.select('.chart-g')
    this.xScale = d3.scaleLinear().range([0, this.width])

    let min = !isNaN(parseInt(this.config.axes.x.min))
      ? this.config.axes.x.min
      : (this.hasData() ? this.getMinX() : this.DEFAULT_MIN_X);

    let max = !isNaN(parseInt(this.config.axes.x.max))
      ? this.config.axes.x.max
      : (this.hasData() ? this.getMaxX() : this.DEFAULT_MAX_X);

    this.xScale.domain([min, max])

    this.xAxis = d3.axisBottom(this.xScale)
    if(typeof this.config.axes.x.tickFormat === 'function') {
      this.xAxis.tickFormat((x) =>  {
        return this.xAxisTickFormat(x)
      })
    }
    this.gX = svg.append("g")
      .attr("class", "axis x-axis")
      .attr('fill', 'none')
      .attr("transform", "translate(0," + this.height + ")")
      .call(this.xAxis)
      .on('mouseenter', () => {
        this.hideMouseIndicators()
      })
    if(this.zoomTransform.rescaleX)
      this.gX.call(this.xAxis.scale(this.zoomTransform.rescaleX(this.xScale)));
    // text label for the x axis
    this.setXAxisLabel()
  }

  protected setXAxisLabel() {
    if(!this.config.axes.x.label)
      return
    let svg = this.chartSVG.select('.chart-g')
    this.xAxisLabel = svg.append("text")
      .attr('class', 'g-x-axis-text')
      .attr("transform",
        "translate(" + (this.width / 2) + " ," +
        (this.height + this.MARGIN.top + this.MARGIN.bottom - 20) + ")")
      .style("text-anchor", "middle")
      .attr("font-family", "dinot-bold")
      .attr("font-size", "#{this.AXIS_LABEL_FONT_SIZE}px")
      .attr("fill", "#333")
      .text(this.config.axes.x.label)
  }

  protected updateZoomScaleExtent () {
    if(!this.zoomBehavior)
      return
    this.zoomBehavior.scaleExtent([1, this.getScaleExtent()])
  }

  protected onAxisInputBaseFunc(loc, input, val) {
    let charCode = d3.event.keyCode
    if(charCode > 36 && charCode < 41)
      // arrow keys
      return true

    // remove units before passing value to this.onAxisInput()
    let axis = loc === 'x:min' || loc === 'x:max' ? 'x' : 'y'
    if(this.config.axes[axis].unit)
      val = val.toString().replace(this.config.axes[axis].unit, '')
    if(typeof this.onAxisInput === 'function')
      this.onAxisInput(loc, input, val)

    //update the input width after value is updated
    let extremeValue = null
    if(loc === 'x:min')
      extremeValue = this.xAxisLeftExtremeValue
    if(loc === 'x:max')
      extremeValue = this.xAxisRightExtremeValue
    if(loc === 'y:min')
      extremeValue = this.yAxisLowerExtremeValue
    if(loc === 'y:max')
      extremeValue = this.yAxisUpperExtremeValue

    extremeValue.text.text(extremeValue.input.node().value)
    let textWidth = extremeValue.text.node().getBBox().width

    if(loc === 'x:min') {
      let conWidth = textWidth + this.INPUT_PADDING
      extremeValue.inputContainer
        .attr('width', conWidth)
        .attr('x', this.MARGIN.left - (conWidth / 2))
      extremeValue.text
        .attr('x', this.MARGIN.left - (textWidth / 2))
      extremeValue.input
        .style('width', "#{conWidth}px")
    }
    if(loc === 'x:max') {
      let conWidth = textWidth + this.INPUT_PADDING
      extremeValue.inputContainer
        .attr('width', conWidth)
        .attr('x', this.MARGIN.left + this.width - (conWidth / 2))
      extremeValue.text
        .attr('x', this.MARGIN.left + this.width - (textWidth / 2))
      extremeValue.input
        .style('width', "#{conWidth}px")
    }

    if(loc === 'y:min' || loc === 'y:max') {
      let conWidth = textWidth
      extremeValue.inputContainer
        .attr('width', conWidth + this.INPUT_PADDING)
        .attr('x', this.MARGIN.left - (conWidth + extremeValue.config.offsetRight + this.INPUT_PADDING / 2))
      extremeValue.input
        .style('width', "#{conWidth + this.INPUT_PADDING}px")
      extremeValue.text.attr('x', this.MARGIN.left - (extremeValue.config.offsetRight + conWidth + this.INPUT_PADDING / 2))
    }

  }

  protected onClickAxisInput (loc, extremeValue) {
    let val: any,
      conWidth: any,
      axis: any;

    axis = (loc === 'x:min' || loc === 'x:max') ? 'x' : 'y';
    if(axis === 'x') {
      val = (loc === 'x:min') ? this.getXScale().invert(0) : this.getXScale().invert(this.width)
      val = this.xAxisTickFormat(val)
      conWidth = extremeValue.text.node().getBBox().width + this.INPUT_PADDING
      extremeValue.inputContainer
        .attr('width', conWidth)
        .attr('x', this.MARGIN.left + (loc === 'x:min' ? 0 : this.width) - (conWidth / 2))
      extremeValue.input
        .style('opacity', 1)
        .style('width', "#{conWidth}px")
      val = extremeValue.text.text()
      extremeValue.input.node().value = val

      if(this.config.axes.x.unit)
        val = val.replace(this.config.axes.x.unit, '')

      val = val.trim()
      this.setCaretPosition(extremeValue.input.node(), val.length)

    } else {
      let yScale = this.lastYScale || this.yScale
      val= loc === 'y:max' ? yScale.invert(0) : yScale.invert(this.height)
      val = this.yAxisTickFormat(val)
      val = val.toString()
      extremeValue.input.node().value = val
      extremeValue.text.text(val)

      if(this.config.axes.y.unit)
        val = val.replace(this.config.axes.y.unit, '')
      val = val.trim()
      this.setCaretPosition(extremeValue.input.node(), val.length)

      let inputWidth = extremeValue.text.node().getBBox().width

      extremeValue.inputContainer
        .attr('width', inputWidth + this.INPUT_PADDING )
        .attr('x', this.MARGIN.left - (inputWidth + extremeValue.config.offsetRight) - (this.INPUT_PADDING / 2))
      extremeValue.input
        .style('width', "#{inputWidth + this.INPUT_PADDING}px")
        .style('opacity', 1)
    }
  }

  protected onAxisInput(loc, input, val) {
    val = val.replace(/[^0-9\.\-]/g, '')
    let axis = (loc === 'y:max' || loc === 'y:min') ? 'y' : 'x';
    let unit = this.config.axes[axis].unit || ''
    input.value = val + unit
    this.setCaretPosition(input, input.value.length - unit.length)
  }

  protected drawAxesExtremeValues () {
    this.chartSVG.selectAll('.axes-extreme-value').remove()
    this.drawXAxisLeftExtremeValue()
    this.drawXAxisRightExtremeValue()
    this.drawYAxisUpperExtremeValue()
    this.drawYAxisLowerExtremeValue()
    this.updateAxesExtremeValues()
  }

  protected drawXAxisLeftExtremeValue () {
    let textContainer = this.chartSVG.append('g')
      .attr('class', 'axes-extreme-value tick')
    this.xAxisLeftExtremeValueContainer = textContainer

    let conWidth = 30
    let conHeight = 14
    let offsetTop = 8.5
    let underlineStroke = 2
    let lineWidth = 15

    let rect = textContainer.append('rect')
      .attr('fill', '#fff')
      .attr('width', conWidth)
      .attr('height', conHeight)
      .attr('y', this.height + this.MARGIN.top + offsetTop)
      .attr('x', this.MARGIN.left - (conWidth / 2))
      .on('click', () => {
        this.onClickLeftXAxisInput()
      })

    let line = textContainer.append('line')
      .attr('stroke', '#000')
      .attr('stroke-width', underlineStroke)
      .attr('opacity', 0)
      .on('click', () => {
        this.onClickLeftXAxisInput()
      })

    let text = textContainer.append('text')
      .attr('fill', '#000')
      .attr('y', this.height + this.MARGIN.top + offsetTop)
      .attr('dy', '0.71em')
      .attr('font-size', "#{this.AXES_TICKS_FONT_SIZE}px")
      .attr('font-family', 'dinot-regular')
      .on('click', () => {
        this.onClickLeftXAxisInput()
      })

    let inputContainer = textContainer.append('foreignObject')
      .attr('width', conWidth)
      .attr('height', conHeight)
      .attr('y', this.height + this.MARGIN.top + offsetTop - 4)
      .attr('x', this.MARGIN.left - (conWidth / 2))
      .on('click', () => {
        this.onClickLeftXAxisInput()
      })

    let form = inputContainer.append('xhtml:form')
      .style('margin', 0)
      .style('padding', 0)
      .on('click', () => {
        this.onClickLeftXAxisInput()
      })

    let input = form.append('xhtml:input').attr('type', 'text')
      .style('display', 'block')
      .style('opacity', 0)
      .style('width', conWidth + 'px')
      .style('height', conHeight + 'px')
      .style('padding', 0)
      .style('margin', 0)
      .style('text-align', 'center')
      .style('font-size', "#{this.AXES_TICKS_FONT_SIZE}px")
      .style('font-family', 'dinot-regular')
      .attr('type', 'text')
      .on('mouseenter', () => {
        lineWidth = text.node().getBBox().width
        line.attr('opacity', 1)
          .attr('x1', this.MARGIN.left - (lineWidth / 2))
          .attr('y1', this.height + this.MARGIN.top + offsetTop + conHeight - underlineStroke)
          .attr('x2', this.MARGIN.left - (lineWidth / 2) + lineWidth)
          .attr('y2', this.height + this.MARGIN.top + offsetTop + conHeight - underlineStroke)
      })
      .on('mouseout', () => {
        line.attr('opacity', 0)
      })
      .on('click', () => {
        this.onClickLeftXAxisInput()
      })
      .on('focusout', () => {
        input.style('opacity', 0)
        text.attr('opacity', 1)
        this.updateAxesExtremeValues()
      })
      .on('keydown', () => {
        if(d3.event.keyCode === 39)
          this.validateArrowInput('x:min', input.node(), input.node().value.trim())
        if(d3.event.keyCode === 13 && typeof this.onEnterAxisInput === 'function') {
          this.onEnterAxisInput('x:min', input.node(), input.node().value.trim())
          d3.event.preventDefault()
        }
        if(d3.event.keyCode === 8)
          this.validateBackSpace('x:min', input.node())
      })
      .on('keyup', () => {
        if(d3.event.keyCode !== 13 && typeof this.onAxisInputBaseFunc === 'function')
          return this.onAxisInputBaseFunc('x:min', input.node(), input.node().value.trim())
      })

    this.xAxisLeftExtremeValue = {
      rect: rect,
      text: text,
      line: line,
      inputContainer: inputContainer,
      form: form,
      input: input,
      config: {
        offsetTop: offsetTop,
        underlineStroke: underlineStroke,
        conHeight: conHeight
      }
    }

  }

  protected onClickLeftXAxisInput() {
    this.xAxisLeftExtremeValue.text.attr('opacity', 0)
    if(typeof this.onClickAxisInput === 'function')
      this.onClickAxisInput('x:min', this.xAxisLeftExtremeValue)
  }

  protected validateBackSpace(loc, input) {
    let axis = (loc === 'y:min' || loc === 'y:max') ? 'y' : 'x';
    let value = input.value
    let selection = input.selectionStart
    let unit = this.config.axes[axis].unit || ''
    if(selection > value.length - unit.length) {
      d3.event.preventDefault()
      return true
    } else
      return false
  }

  protected validateArrowInput(loc, input, val) {
    let axis = (loc === 'y:min' || loc === 'y:max') ? 'y' : 'x';
    let unit = this.config.axes[axis].unit || ''
    let caret = input.selectionStart + 1
    if(val.length - unit.length < caret)
      d3.event.preventDefault()
  }

  protected cleanAxisInput (loc, input, val) {
    let axis = (loc === 'x:min' || loc === 'x:max') ? 'x' : 'y';
    val = val.replace(/[^0-9\.\-]/g, '')
    val = val.replace(this.config.axes[axis].unit, '')
    if(val === '') {
      if(loc === 'x:min')
        val = this.getMinX()
      if(loc === 'x:max')
        val = this.getMaxX()
      if(loc === 'y:min')
        val = this.computedMinY()
      if(loc === 'y:max')
        val = this.computedMaxY()
    }
    return +val
  }

  protected onEnterAxisInput (loc, input, val) {
    let max: any,
      min:any,
      maxY: any,
      maxX: any,
      minY: any,
      minX: any,
      y: any,
      x: any,
      lastYScale: any,
      lastXScale: any,
      k: any,
      lastK: any,
      extent: any,
      width_percent: any

    val = this.cleanAxisInput(loc, input, val)

    if(loc === 'y:max') {
      max = this.computedMaxY()
      maxY = this.isNumber(val) && !this.isNumber(val) ? val : max;
      y = this.yScale
      lastYScale = this.lastYScale || y
      minY = lastYScale.invert(this.height)

      if(minY >= maxY)
        return false

      maxY = (maxY > max) ? max : maxY;
      let k = this.height / (y(minY) - y(maxY))

      this.editingYAxis = true
      lastK = this.getTransform().k
      this.chartSVG.call(this.zoomBehavior.transform, d3.zoomIdentity.scale(k).translate(0, -y(maxY)))
      this.editingYAxis = false
      this.chartSVG.call(this.zoomBehavior.transform, d3.zoomIdentity.scale(lastK))
    }
    if(loc === 'y:min') {
      y = this.yScale
      lastYScale = this.lastYScale || y
      min = this.computedMinY()

      minY = this.isNumber(val) && !this.isNumber(val) ? val : min;
      maxY = lastYScale.invert(0)
      if (minY >= maxY)
        return false

      minY = minY < min ? min : minY;

      k = this.height / (y(minY) - y(maxY))
      lastK = this.getTransform().k
      this.editingYAxis = true
      this.chartSVG.call(this.zoomBehavior.transform, d3.zoomIdentity.scale(k).translate(0, -y(maxY)))
      this.editingYAxis = false
      this.chartSVG.call(this.zoomBehavior.transform, d3.zoomIdentity.scale(lastK))
    }
    if(loc === 'x:min') {
      extent = this.getScaleExtent() - this.getMinX()
      x = this.xScale
      lastXScale = this.lastXScale || x
      minX = val * 1
      maxX = lastXScale.invert(this.width)
      if(minX >= maxX)
        return false
      if(val === '' || minX < this.getMinX())
        minX = this.getMinX()
      k = this.width / (x(maxX) - x(minX))
      width_percent = 1 / k
      let w = extent - (width_percent * extent)
      this.chartSVG.call(this.zoomBehavior.scaleTo, k)
      this.scroll((minX - this.getMinX()) / w)
    }
    if(loc === 'x:max') {
      extent = this.getScaleExtent() - this.getMinX()
      x = this.xScale
      lastXScale = this.lastXScale || x
      minX = lastXScale.invert(0)
      maxX = val * 1
      if(minX >= maxX)
        return false
      if(val === '')
        maxX = this.getMaxX()
      if(maxX > this.getScaleExtent())
        maxX = this.getScaleExtent()
      k = this.width / (x(maxX) - x(minX))
      width_percent = 1 / k
      let w = extent - (width_percent * extent)
      this.chartSVG.call(this.zoomBehavior.scaleTo, k)
      this.scroll((minX - this.getMinX()) / w)
    }

    // update input state
    let extremeValue = null

    if(loc === 'x:min')
      extremeValue =  this.xAxisLeftExtremeValue
    else if(loc === 'x:max')
      extremeValue =  this.xAxisRightExtremeValue
    else if(loc === 'y:min')
      extremeValue = this.yAxisLowerExtremeValue
    else
      extremeValue = this.yAxisUpperExtremeValue

    this.onClickAxisInput(loc, extremeValue)
    setTimeout(() => {
      input.blur()
    }, 100)
  }

  protected drawXAxisRightExtremeValue() {
    let textContainer = this.chartSVG.append('g')
      .attr('class', 'axes-extreme-value tick')

    this.xAxisLeftExtremeValueContainer = textContainer

    let conWidth = 30
    let conHeight = 14
    let offsetTop = 8.5
    let underlineStroke = 2
    let lineWidth = 20

    let rect = textContainer.append('rect')
      .attr('fill', '#fff')
      .attr('width', conWidth)
      .attr('height', conHeight)
      .attr('y', this.height + this.MARGIN.top + offsetTop)
      .attr('x', this.MARGIN.left + this.width - (conWidth / 2))
      .on('click',() => {
        this.onClickRightXAxisInput()
      })

    let line = textContainer.append('line')
      .attr('stroke', '#000')
      .attr('stroke-width', underlineStroke)
      .attr('opacity', 0)
      .on('click', () => {
        this.onClickRightXAxisInput()
      })

    let text = textContainer.append('text')
      .attr('fill', '#000')
      .attr('y', this.height + this.MARGIN.top + offsetTop)
      .attr('dy', '0.71em')
      .attr('font-size', "#{this.AXES_TICKS_FONT_SIZE}px")
      .attr('font-family', 'dinot-regular')
      .text(this.getMaxX())
      .on('click', () => {
        this.onClickRightXAxisInput()
      })

    let inputContainer = textContainer.append('foreignObject')
      .attr('width', conWidth)
      .attr('height', conHeight)
      .attr('y', this.height + this.MARGIN.top + offsetTop - 4)
      .attr('x', this.MARGIN.left + this.width - (conWidth / 2))
      .on('click', () => {
        this.onClickRightXAxisInput()
      })

    let form = inputContainer.append('xhtml:form')
      .on('click', () => {
        this.onClickRightXAxisInput()
      })

    let input = form.append('xhtml:input').attr('type', 'text')
      .style('display', 'block')
      .style('opacity', '0')
      .style('width', conWidth + 'px')
      .style('height', conHeight + 'px')
      .style('padding', '0px')
      .style('margin', '0px')
      .style('text-align', 'center')
      .style('font-size', "#{this.AXES_TICKS_FONT_SIZE}px")
      .style('font-family', 'dinot-regular')
      .attr('type', 'text')
      .on('mouseenter', () => {
        lineWidth = text.node().getBBox().width
        line.attr('opacity', 1)
          .attr('x1', this.MARGIN.left + this.width - (lineWidth / 2))
          .attr('y1', this.height + this.MARGIN.top + offsetTop + conHeight - underlineStroke)
          .attr('x2', this.MARGIN.left + this.width - (lineWidth / 2) + lineWidth)
          .attr('y2', this.height + this.MARGIN.top + offsetTop + conHeight - underlineStroke)
      })
      .on('mouseout', () => {
        line.attr('opacity', 0)
      })
      .on('click', () => {
        this.onClickRightXAxisInput()
      })
      .on('focusout', () => {
        input.style('opacity', 0)
        text.attr('opacity', 1)
        this.updateAxesExtremeValues()
      })
      .on('keydown', () => {
        if(d3.event.keyCode === 39)
          this.validateArrowInput('x:max', input.node(), input.node().value)
        if(d3.event.keyCode === 13 && typeof this.onEnterAxisInput === 'function') {
          this.onEnterAxisInput('x:max', input.node(), input.node().value.trim())
          d3.event.preventDefault()
        }
        if(d3.event.keyCode === 8)
          this.validateBackSpace('x:max', input.node())
      })
      .on('keyup', () => {
        if(d3.event.keyCode !== 13 && typeof this.onAxisInputBaseFunc === 'function')
          this.onAxisInputBaseFunc('x:max', input.node(), input.node().value.trim())
      })

    this.xAxisRightExtremeValue = {
      rect: rect,
      text: text,
      line: line,
      inputContainer: inputContainer,
      form: form,
      input: input,
      config: {
        offsetTop: offsetTop,
        underlineStroke: underlineStroke,
        conHeight: conHeight
      }
    }

  }

  protected onClickRightXAxisInput () {
    this.xAxisRightExtremeValue.text.attr('opacity', 0)
    if(typeof this.onClickAxisInput === 'function')
      this.onClickAxisInput('x:max', this.xAxisRightExtremeValue)
  }

  protected drawYAxisUpperExtremeValue() {
    let textContainer = this.chartSVG.append('g').attr('class', 'axes-extreme-value tick')

    this.yAxisUpperExtremeValueContainer = textContainer

    let conWidth = 30
    let conHeight = 14
    let offsetRight = 9
    let offsetTop = 2
    let underlineStroke = 2
    let lineWidth = 15
    let inputContainerOffset = 5

    let rect = textContainer.append('rect')
      .attr('fill', '#fff')
      .attr('width', conWidth)
      .attr('height', this.AXES_TICKS_FONT_SIZE + offsetTop)
      .attr('y', this.MARGIN.top - ((conHeight) / 2))
      .attr('x', this.MARGIN.left - (conWidth + offsetRight))
      .on('click', () => {
        this.onClickUpperYAxisInput()
      })

    let line = textContainer.append('line')
      .attr('opacity', 0)
      .attr('stroke', '#000')
      .attr('stroke-width', underlineStroke)
      .on('click', () => {
        this.onClickUpperYAxisInput()
      })

    let text = textContainer.append('text')
      .attr('fill', '#000')
      .attr('x', this.MARGIN.left - (offsetRight + conWidth))
      .attr('y', this.MARGIN.top - underlineStroke * 2)
      .attr('dy', '0.71em')
      .attr('font-size', "#{this.AXES_TICKS_FONT_SIZE}px")
      .attr('font-family', 'dinot-regular')
      .text(this.getMaxY())
      .on('click', () => {
        this.onClickUpperYAxisInput()
      })

    text.attr('x', this.MARGIN.left - (offsetRight + text.node().getBBox().width))

    let inputContainer = textContainer.append('foreignObject')
      .attr('width', conWidth)
      .attr('height', conHeight - offsetTop)
      .attr('y', this.MARGIN.top - (conHeight / 2))
      .attr('x', this.MARGIN.left - (conWidth + offsetRight))
      .on('click', () => {
        this.onClickUpperYAxisInput()
      })

    let form = inputContainer.append('xhtml:form')
      .on('click', () => {
        this.onClickUpperYAxisInput()
      })

    let input = form.append('xhtml:input').attr('type', 'text')
      .style('display', 'block')
      .style('opacity', 0)
      .style('width', conWidth + 'px')
      .style('height', conHeight + 'px')
      .style('padding', '0px')
      .style('margin', '0px')
      .style('margin-top', '-1px')
      .style('text-align', 'center')
      .style('font-size', "#{this.AXES_TICKS_FONT_SIZE}px")
      .style('font-family', 'dinot-regular')
      .attr('type', 'text')
      .on('mouseenter', () => {
        let textWidth = text.node().getBBox().width
        line.attr('x1', this.MARGIN.left - (textWidth + offsetRight))
          .attr('y1', this.MARGIN.top + (conHeight / 2) - (underlineStroke / 2))
          .attr('x2', this.MARGIN.left - (textWidth + offsetRight) + textWidth)
          .attr('y2', this.MARGIN.top + (conHeight / 2) - (underlineStroke / 2))
          .attr('opacity', 1)
      })
      .on('mouseout', () => {
        line.attr('opacity', 0)
      })
      .on('click', () => {
        this.onClickUpperYAxisInput()
      })
      .on('focusout', () => {
        input.style('opacity', 0)
        text.attr('opacity', 1)
        this.updateAxesExtremeValues()
      })
      .on('keyup', () => {
        if(d3.event.keyCode !== 13 && typeof this.onAxisInputBaseFunc === 'function')
          this.onAxisInputBaseFunc('y:max', input.node(), input.node().value.trim())
      })
      .on('keydown', () => {
        if(d3.event.keyCode === 39)
          this.validateArrowInput('y:max', input.node(), input.node(). value)
        if(d3.event.keyCode === 13 && typeof this.onEnterAxisInput === 'function') {
          this.onEnterAxisInput('y:max', input.node(), input.node().value.trim())
          d3.event.preventDefault()
        }
        if(d3.event.keyCode === 8)
          this.validateBackSpace('y:max', input.node())
      })

    this.yAxisUpperExtremeValue = {
      rect: rect,
      text: text,
      line: line,
      inputContainer: inputContainer,
      form: form,
      input: input,
      config: {
        offsetTop: offsetTop,
        offsetRight: offsetRight,
        underlineStroke: underlineStroke,
        conHeight: conHeight,
        inputContainerOffset: inputContainerOffset
      }
    }

  }

  protected onClickUpperYAxisInput() {
    this.yAxisUpperExtremeValue.text.attr('opacity', 0)
    if(typeof this.onClickAxisInput === 'function')
      this.onClickAxisInput('y:max', this.yAxisUpperExtremeValue)
  }

  protected drawYAxisLowerExtremeValue () {

    let textContainer = this.chartSVG.append('g')
      .attr('class', 'axes-extreme-value tick')

    this.yAxisLowerExtremeValueContainer = textContainer

    let conWidth = 30
    let conHeight = 14
    let offsetRight = 9
    let offsetTop = 2
    let underlineStroke = 2
    let lineWidth = 15

    let rect = textContainer.append('rect')
      .attr('fill', '#fff')
      .attr('width', conWidth)
      .attr('height', this.AXES_TICKS_FONT_SIZE + offsetTop)
      .attr('y', this.height + this.MARGIN.top - (conHeight / 2))
      .attr('x', this.MARGIN.left - (conWidth + offsetRight))
      .on('click', () => {
        this.onClickLowerYAxisInput()
      })

    let line = textContainer.append('line')
      .attr('opacity', 0)
      .attr('stroke', '#000')
      .attr('stroke-width', underlineStroke)
      .on('click', () => {
        this.onClickLowerYAxisInput()
      })

    let text = textContainer.append('text')
      .attr('fill', '#000')
      .attr('x', this.MARGIN.left - (offsetRight + conWidth))
      .attr('y', this.height + this.MARGIN.top - underlineStroke * 2)
      .attr('dy', '0.71em')
      .attr('font-size', "#{this.AXES_TICKS_FONT_SIZE}px")
      .attr('font-family', 'dinot-regular')
      .text(this.getMaxY())
      .on('click', () => {
        this.onClickLowerYAxisInput()
      })

    text.attr('x', this.MARGIN.left - (offsetRight + text.node().getBBox().width))

    let inputContainer = textContainer.append('foreignObject')
      .attr('width', conWidth)
      .attr('x', this.MARGIN.left - (conWidth + offsetRight))
      .attr('height', conHeight - offsetTop)
      .attr('y', this.height + this.MARGIN.top - (conHeight / 2))
      .on('click', () => {
        this.onClickLowerYAxisInput()
      })

    let form = inputContainer.append('xhtml:form')
      .style('margin', 0)
      .style('padding', 0)

    let input = form.append('xhtml:input').attr('type', 'text')
      .style('display', 'block')
      .style('opacity', 0)
      .style('width', conWidth + 'px')
      .style('height', conHeight + 'px')
      .style('padding', 0)
      .style('margin', 0)
      .style('margin-top', '-1px')
      .style('text-align', 'center')
      .style('font-size', "#{this.AXES_TICKS_FONT_SIZE}px")
      .style('font-family', 'dinot-regular')
      .attr('type', 'text')
      .on('mouseenter', () => {
        let textWidth = text.node().getBBox().width
        line.attr('x1', this.MARGIN.left - (textWidth + offsetRight))
          .attr('y1', this.height + this.MARGIN.top + (conHeight / 2) - (underlineStroke / 2))
          .attr('x2', this.MARGIN.left - (textWidth + offsetRight) + textWidth)
          .attr('y2', this.height + this.MARGIN.top + (conHeight / 2) - (underlineStroke / 2))
          .attr('opacity', 1)
      })
      .on('mouseout', () => {
        line.attr('opacity', 0)
      })
      .on('click', () => {
        this.onClickLowerYAxisInput()
      })
      .on('focusout', () => {
        input.style('opacity', 0)
        text.attr('opacity', 1)
        this.updateAxesExtremeValues()
      })
      .on('keyup', () => {
        if(d3.event.keyCode !== 13 && typeof this.onAxisInputBaseFunc === 'function')
          this.onAxisInputBaseFunc('y:min', input.node(), input.node().value.trim())
      })
      .on('keydown', () => {
        if(d3.event.keyCode === 39)
          this.validateArrowInput('y:min', input.node(), input.node().value)
        if(d3.event.keyCode === 13 && typeof this.onEnterAxisInput === 'function') {
          this.onEnterAxisInput('y:min', input.node(), input.node().value.trim())
          d3.event.preventDefault()
        }
        if(d3.event.keyCode === 8)
          this.validateBackSpace('y:min', input.node())
      })

    this.yAxisLowerExtremeValue =  {
      rect: rect,
      text: text,
      line: line,
      inputContainer: inputContainer,
      form: form,
      input: input,
      config: {
        offsetTop: offsetTop,
        offsetRight: offsetRight,
        underlineStroke: underlineStroke,
        conHeight: conHeight
      }
    }

  }

  protected onClickLowerYAxisInput () {
    this.yAxisLowerExtremeValue.text.attr('opacity', 0)
    if(typeof this.onClickAxisInput === 'function')
      this.onClickAxisInput('y:min', this.yAxisLowerExtremeValue)
  }

  protected updateAxesExtremeValues () {
    let xScale = this.getXScale()
    let yScale = this.getYScale()
    let minWidth = 10
    if(this.xAxisLeftExtremeValue.text) {
      let text = this.xAxisLeftExtremeValue.text
      let rect = this.xAxisLeftExtremeValue.rect
      let minX = this.hasData() ? Math.round(xScale.invert(0) * 10) / 10 : this.DEFAULT_MIN_X;
      text.text(this.xAxisTickFormat(minX))
      let textWidth = text.node().getBBox().width
      text.attr('x', this.MARGIN.left - (textWidth / 2))
      rect.attr('x', this.MARGIN.left - (textWidth / 2))
        .attr('width', textWidth)
    }
    if(this.xAxisRightExtremeValue.text) {
      let maxX = this.hasData() ? Math.round(xScale.invert(this.width) * 10) / 10 : this.DEFAULT_MAX_X;
      this.xAxisRightExtremeValue.text.text(this.xAxisTickFormat(maxX))
      let textWidth = this.xAxisRightExtremeValue.text.node().getBBox().width
      this.xAxisRightExtremeValue.text.attr('x', this.width + this.MARGIN.left - (textWidth / 2))
      this.xAxisRightExtremeValue.rect.attr('x', this.width + this.MARGIN.left - (textWidth / 2))
        .attr('width', textWidth)
    }
    if(this.yAxisUpperExtremeValue.text) {
      let text = this.yAxisUpperExtremeValue.text
      let rect = this.yAxisUpperExtremeValue.rect
      let maxY = this.hasData() ? Math.round(yScale.invert(0) * 10) / 10 : this.DEFAULT_MAX_Y;
      text.text(this.yAxisTickFormat(maxY))
      let textWidth = text.node().getBBox().width
      text.attr('x', this.MARGIN.left - (this.yAxisUpperExtremeValue.config.offsetRight + textWidth))
      rect.attr('x', this.MARGIN.left - (this.yAxisUpperExtremeValue.config.offsetRight + textWidth))
        .attr('width', textWidth)
    }
    if(this.yAxisLowerExtremeValue.text) {
      let rect = this.yAxisLowerExtremeValue.rect
      let text = this.yAxisLowerExtremeValue.text
      let minY = this.hasData() ? Math.round(yScale.invert(this.height) * 10) / 10 : this.DEFAULT_MIN_Y
      text.text(this.yAxisTickFormat(minY))
      let textWidth = text.node().getBBox().width
      text.attr('x', this.MARGIN.left - (this.yAxisLowerExtremeValue.config.offsetRight + textWidth))
      rect.attr('x', this.MARGIN.left - (this.yAxisLowerExtremeValue.config.offsetRight + textWidth))
        .attr('width', textWidth)
    }

    this.hideLastAxesTicks()

  }

  protected hideLastAxesTicks () {
    let spacingX = 20
    let spacingY = 1
    let xAxisLeftExtremeValueText = this.xAxisLeftExtremeValue.text
    let xAxisRightExtremeValueText = this.xAxisRightExtremeValue.text
    let yAxisLowerExtremeValueText = this.yAxisLowerExtremeValue.text
    let yAxisUpperExtremeValueText = this.yAxisUpperExtremeValue.text

    let config = this.config

    // x ticks
    let ticks = this.chartSVG.selectAll('g.axis.x-axis > g.tick')

    let width = this.width
    let num_ticks = ticks.size()
    ticks.each(function (d, i) {
      let x = this.transform.baseVal.consolidate().matrix.e
      if (i === 0) {
        let textWidth = xAxisLeftExtremeValueText.node().getBBox().width
        if (x < textWidth + spacingX)
          d3.select(this).attr('opacity', 0)
      }
      if(i === num_ticks - 1) {
        let textWidth = xAxisRightExtremeValueText.node().getBBox().width
        if(x >  width - (textWidth + spacingX))
          d3.select(this).attr('opacity', 0)
      }
    })
    // y ticks
    ticks = this.chartSVG.selectAll('g.axis.y-axis > g.tick')
    num_ticks = ticks.size()
    let height = this.height
    ticks.each(function (d, i) {
      let y = this.transform.baseVal.consolidate().matrix.f
      if (i === 0) {
        let textHeight = yAxisLowerExtremeValueText.node().getBBox().height
        if (y >  height - (textHeight + spacingY))
          d3.select(this).attr('opacity', 0)
      }
      if (i === num_ticks - 1) {
        let textHeight = yAxisUpperExtremeValueText.node().getBBox().height
        if (y < textHeight + spacingY)
          d3.select(this).attr('opacity', 0)
      }
    })
  }

  protected initChart () {
    if(!this.data || !this.config) return;

    this.initialized = true;
    d3.select(this.elem).selectAll("*").remove()

    this.width = this.elem.parentElement.offsetWidth - this.MARGIN.left - this.MARGIN.right
    this.height = this.elem.parentElement.offsetHeight - this.MARGIN.top - this.MARGIN.bottom

    this.zoomBehavior = d3.zoom()
      .on('start', () => {
        this.isZooming = true
      })
      .on('end', () => {
        this.isZooming = false
      })
      .on('zoom', () => {
        this.zoomed()
      })

    this.chartSVG = d3.select(this.elem).append("svg")
      .attr("width", this.width + this.MARGIN.left + this.MARGIN.right)
      .attr("height", this.height + this.MARGIN.top + this.MARGIN.bottom)
      .call(this.zoomBehavior)

    let svg = this.chartSVG.append("g")
      .attr("transform", "translate(" + this.MARGIN.left + "," + this.MARGIN.top + ")")
      .attr('class', 'chart-g')

    this.viewSVG = svg.append('svg')
      .attr('width', this.width)
      .attr('height', this.height)
      .append('g')
      .attr('width', this.width)
      .attr('height', this.height)
      .attr('class', 'viewSVG')

    this.setMouseOverlay()
    this.setYAxis()
    this.setXAxis()
    this.drawLines()
    this.makeCircle()
    this.updateZoomScaleExtent()
    this.drawAxesExtremeValues()

  }

  protected setMouseOverlay () {
    this.mouseOverlay = this.viewSVG.append('rect');
    this.mouseOverlay
      .attr('width', this.width)
      .attr('height', this.height)
      .attr('fill', 'transparent')
      .on('mousemove', () => {
        this.mouseMoveCb()
      })
      .on('mouseenter', () => {
        this.showMouseIndicators()
      })
      .on('mouseout', () => {
        this.hideMouseIndicators()
      })
      .on('click', () => {
        this.unsetActivePath()
        if(this.hoveredLine) {
          let mouse = this.getMousePosition(this.mouseOverlay.node())
          this.setActivePath(this.hoveredLine, mouse)
        }
      });
  }

  protected getPathPositionByX(path, x) {
    if (!path)
      return
    let pathEl = path.node()
    let pathLength = pathEl.getTotalLength()
    let beginning = x
    let end = pathLength
    let target: any = null
    let pos: any = null

    while(true) {
      target = Math.floor(((beginning + end) / 2) * 100) / 100
      target = Number.isFinite(target) ? target : 1
      pos = pathEl.getPointAtLength(target)
      if ((target === end || target === beginning) && pos.x !== x)
        break
      if (pos.x > x)
        end = target
      else if (pos.x < x)
        beginning = target
      else
        break // position found

    }
    pos = { x: x, y: pos.y }
    return pos;
  }

  protected mouseMoveCb () {
    this.setHoveredLine()
    if(!this.activePath) {
      this.hideMouseIndicators()
      return
    }
    let x = this.getMousePosition(this.mouseOverlay.node())[0]
    let pos = this.getPathPositionByX(this.guidingLines[this.activePathConfig.index], x)
    let min_x = this.getMinX()
    let max_x = this.config.axes.x.max || this.getMaxX()
    max_x = ((this.getMaxX() - min_x) / (max_x - min_x)) * this.width

    if(x > max_x)
      this.hideMouseIndicators()
    else {
      if(Number.isFinite(x))
        this.circle.attr("cx", x)
      else
        this.hideMouseIndicators()

      this.circle
        .attr("cy", pos.y)
        .attr('transform', 'translate(0,0) scale(1)')

      this.setBoxRFYAndCycleTexts(x)
      this.showMouseIndicators()
    }
    this.prevMousePosition = [pos.x, pos.y]
  }

  protected setHoveredLine () {
    let mouse = this.getMousePosition(this.mouseOverlay.node())
    let mouseX = mouse[0]
    let mouseY = mouse[1]
    let closestLineIndex: any;
    let distances = []
    let lineIndex: any = null
    let maxDistance = 20 * this.zoomTransform.k

    for (let lineIndex = 0; lineIndex < this.lines.length; lineIndex++) {
      let l = this.lines[lineIndex]
      let pos = this.getPathPositionByX(this.lines[lineIndex], mouseX)
      let distance = Math.abs(pos.y - mouseY)
      distances.push(distance)

      if(closestLineIndex === undefined)
        closestLineIndex = lineIndex
      if(distance < distances[closestLineIndex])
        closestLineIndex = lineIndex
      if(distances[closestLineIndex] > maxDistance) {
        closestLineIndex = undefined
        this.hoveredLine = null
      }
      if(this.prevClosestLineIndex !== closestLineIndex)
        if(this.prevClosestLineIndex !== undefined && this.lines[this.prevClosestLineIndex]) {
          this.lines.forEach(line => {
            if(line !== this.activePath && line !== this.hoveredLine && !this.hovering)
              line.attr('stroke-width', this.NORMAL_PATH_STROKE_WIDTH)
          })
          if(!this.hovering && this.hoveredLine) {
            this.hoveredLine.attr('stroke-width', this.NORMAL_PATH_STROKE_WIDTH)
            this.hoveredLine = null
          }
        }
      if((closestLineIndex !== undefined) && !this.hovering && (this.lines[closestLineIndex] !== this.activePath)) {
        this.lines[closestLineIndex].attr('stroke-width', this.HOVERED_PATH_STROKE_WIDTH)
        this.hoveredLine = this.lines[closestLineIndex]
      }
      this.prevClosestLineIndex = closestLineIndex;
    }
  }

  protected _getTransformXFromScroll(scroll) {
    scroll = scroll < 0 ? 0 : (scroll > 1 ? 1 : scroll)
    let transform = this.getTransform()
    let new_width = this.width * transform.k
    let transform_x = -((new_width - this.width) * scroll)
    return transform_x
  }

  protected scroll(s) { // s = {0..1}
    let transform = this.getTransform()
    let transform_x = this._getTransformXFromScroll(s)
    let new_transform = d3.zoomIdentity.translate(transform_x, transform.y).scale(transform.k)
    this.chartSVG.call(this.zoomBehavior.transform, new_transform)
  }
  protected onZoomAndPan (fn) {
    //# fn will receive (transform, width, height)
    this.onZoomAndPanCb = fn;
  }

  protected onSelectLince (fn) {
    this.onSelectLinceCb = fn;
  }

  protected onUnselectLince (fn) {
    this.onUnselectLinceCb = fn;
  }

  protected getDimensions() {
    return {
      width: this.width,
      height: this.height
    }
  }

  protected getTransform() {
    if(!this.chartSVG)
      return
    return d3.zoomTransform(this.chartSVG.node())
  }

  protected reset() {
    this.chartSVG.call(this.zoomBehavior.transform, d3.zoomIdentity)
  }

  protected zoomTo(zoom_percent) { // # zoom_percent = {0..1}
    zoom_percent = zoom_percent || 0
    zoom_percent = zoom_percent < 0 ? 0 : (zoom_percent > 1 ? 1 : zoom_percent)
    let k = ((this.getScaleExtent() - this.getMinX()) * zoom_percent) + 1
    this.chartSVG.call(this.zoomBehavior.scaleTo, k)
  }

  protected updateSeries(series) {
    this.config.series = series
    this.updateAxesExtremeValues()
  }

  protected updateData(data) {
    this.data = data
    this.updateZoomScaleExtent()
    setTimeout(() => {
      this.updateAxesExtremeValues()
    }, 500)
  }

  protected updateConfig(config) {
    this.config = config
    setTimeout(() => {
      this.updateAxesExtremeValues()
    }, 500)
  }

  protected empty() {
    d3.select(this.elem).selectAll('*').remove()
  }

  protected resize() {
    this.initChart()
  }

  ngOnChanges(change: any) {
    if(change.data) {
      this.data = change.data.currentValue;
    }
    if(change.config) {
      this.config = change.config.currentValue;
    }
    if(!this.initialized) {
      this.initChart();
    }
  }

}
