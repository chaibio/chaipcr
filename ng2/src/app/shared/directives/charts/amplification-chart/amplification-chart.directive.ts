import {
  Directive,
  ElementRef,
  Input,
  OnChanges
} from '@angular/core';

import * as d3 from 'd3';
import { WindowRef } from '../../../../services/windowref/windowref.service';
import { BaseChartDirective } from '../base-chart/base-chart.directive';

@Directive({
  selector: '[chai-amplification-chart]'
})
export class AmplificationChartDirective extends BaseChartDirective {

  protected MARGIN = {
    top: 10,
    left: 80,
    right: 15,
    bottom: 50
  }

  protected DEFAULT_MIN_Y = 0
  protected DEFAULT_MAX_Y =  10000
  protected DEFAULT_MIN_X = 1
  protected DEFAULT_MAX_X = 40

  constructor(protected el: ElementRef, protected wref: WindowRef) {
    super(el, wref)
  }

  protected inK() {
    return this.getMaxY() - this.getMinY() > 20000
  }

  protected getYUnit () {
    return this.inK() ? 'k' : ''
  }

  protected formatPower(d) {
    let superscript = "⁰¹²³⁴⁵⁶⁷⁸⁹";
    return (d + "").split("")
      .map(c => {
        return superscript[c]
      })
      .join("")
  }


  protected getLineCurve() {
    return this.config.axes.y.scale === 'log'
      ? d3.curveMonotoneX
      : d3.curveBasis
  }

  protected makeColoredLine(line_config) {
    let xScale = this.getXScale()
    let yScale = this.getYScale()
    let line = d3.line()
    line.curve(this.getLineCurve())
    line.x((d) => {
      return xScale(d[line_config.x])
    })
    line.y((d) => {
      return yScale(d[line_config.y])
    })
    if(this.config.axes.y.scale === 'log') {
      line.defined((d) => {
        return d[line_config.y] > 10
      })
    }
    let _path = this.viewSVG.append("path")
      .datum(this.data[line_config.dataset])
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
        if (_path !== this.activePath)
          _path.attr('stroke-width', this.HOVERED_PATH_STROKE_WIDTH)
        this.hoveredLine = _path
        this.hovering = true
        this.mouseMoveCb()
      })
      .on('mouseout', (e, a, path) => {
        if (_path !== this.activePath)
          _path.attr('stroke-width', this.NORMAL_PATH_STROKE_WIDTH)
        this.hovering = false
      })

    return _path
  }

  protected getYExtremeValuesAllowance () {
    let max = this.getMaxY()
    let min = this.getMinY()
    let diff = max - min
    return diff * 0.05
  }


  protected computedMaxY () {
    let max = this.isNumber(this.config.axes.y.max)
      ? this.config.axes.y.max
      : (this.hasData()? this.getMaxY() : this.DEFAULT_MAX_Y)
    if(this.config.axes.y.scale === 'linear') {
      let m = this.roundUpExtremeValue( max + this.getYExtremeValuesAllowance())
      return m
    } else {
      let ticks = this.getYLogTicks(this.getMinY(), this.getMaxY())
      return ticks[ticks.length - 1]
    }
  }

  protected computedMinY() {
    let min = this.isNumber(this.config.axes.y.min)
      ? this.config.axes.y.min
      : (this.hasData()? this.getMinY() : this.DEFAULT_MIN_Y)
    if(this.config.axes.y.scale === 'linear')
      return this.roundDownExtremeValue(min - this.getYExtremeValuesAllowance())
    else {
      let ticks = this.getYLogTicks(this.getMinY(), this.getMaxY())
      return ticks[0]
    }
  }

  protected roundUpExtremeValue(val) {
    if(this.config.axes.y.scale === 'linear') {
      val = this.inK() ? val / 1000 : val
      if(this.inK())
        return Math.ceil(val / 5) * 5 * 1000
      else
        return Math.ceil(val) * 1
    } else {
      let num_length = val.toString().length - 1
      let roundup = val.toString().charAt(0)
      for(let i=0; i < num_length - 1; i++) {
        roundup = roundup + "0"
      }
      return roundup * 1
    }
  }

  protected roundDownExtremeValue(val) {
    if(this.config.axes.y.scale === 'linear') {
      val = this.inK() ? val / 1000 : val
      if(this.inK())
        return Math.floor(val / 5) * 5 * 1000
      else
        return Math.floor(val) * 1
    } else {
      if(val < 10)
        return 10
      let num_length = val.toString().length
      num_length = val < 10 ? 2 : num_length
      let rounddown = val.toString().charAt(0)
      for(let i=0; i < num_length - 1; i++) {
        rounddown = rounddown + "0"
      }
      return rounddown * 1
    }
  }

  protected base10(num) {
    let b:any = '1'
    let num_length = num.toString().length
    while(b.length < num_length)
      b += '0'
    return b * 1
  }


  protected getYLogTicks(min, max) {
    min = min < 10 ? 10 : min
    let min_num_length = min.toString().length
    let max_num_length = max.toString().length

    min = '1'
    for(let i=0; i < min_num_length - 1; i++) {
      min = `${min}0`
    }
    min = +min

    max = '1'
    for(let i=0; i < max_num_length - 1; i++) {
      max = `${max}0`
    }
    max = +max

    let calibs = []
    let calib = min
    calibs.push(min)
    calib = this.base10(calib)
    while(calib < max) {
      calib = calib * 10
      calibs.push(calib)
    }
    calibs.push(max)
    return calibs
  }

  protected yAxisTickFormat(y) {
    if(this.config.axes.y.scale === 'log') {
      let y0 = y.toString().charAt(0)
      y = (y0 === '1' ? '10' : y0 + ' x 10') + this.formatPower(Math.round(Math.log(y) / Math.LN10))
      return y
    } else {
      if(this.inK())
        return (Math.round(y / 1000)) + this.getYUnit()
      else
        return Math.round(y * 10) / 10
    }
  }


  protected yAxisLogInputFormat(val) {
    val = Math.round(val)
    while(/(\d+)(\d{3})/.test(val.toString()))
      val = val.toString().replace(/(\d+)(\d{3})/, '$1'+','+'$2')
    return val
  }

  protected setYAxis() {
    this.chartSVG.selectAll('g.axis.y-axis').remove()
    this.chartSVG.selectAll('.g-y-axis-text').remove()
    let svg = this.chartSVG.select('.chart-g')

    let min = this.computedMinY()
    let max = this.computedMaxY()

    this.yScale = this.config.axes.y.scale === 'log' ? d3.scaleLog() : d3.scaleLinear();

    if(this.config.axes.y.scale === 'log') {
      let ticks = this.getYLogTicks(this.getMinY(), this.getMaxY())
      this.yScale.range([this.height, 0]).domain([ticks[0], ticks[ticks.length - 1]])
      this.yAxis = d3.axisLeft(this.yScale)
      this.yAxis.tickValues(ticks)
    } else {
      this.yScale.range([this.height, 0]).domain([min, max])
      this.yAxis = d3.axisLeft(this.yScale)
      this.yAxis.ticks(8)
      if(this.inK())
        this.yAxis.tickValues(this.getYLinearTicks())
    }

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
    this.setYAxisLabel()
    this.lastYScale = this.yScale
  }

  protected validateBackSpace(loc, input) {
    let axis = loc === 'y:min' || loc === 'y:max' ? 'y' : 'x'
    let value = input.value
    let selection = input.selectionStart
    let unit = axis === 'y' ? this.getYUnit() : this.config.axes[axis].unit || ''
    if(this.config.axes.y.scale === 'linear' && (selection > value.length - unit.length)) {
      d3.event.preventDefault()
      return true
    } else
      return false
  }

  protected onClickAxisInput(loc, extremeValue) {
    let axis = loc === 'x:min' || loc === 'x:max' ? 'x' : 'y'
    if(axis === 'x')
      super.onClickAxisInput(loc, extremeValue)
    else {
      if(this.config.axes.y.scale === 'linear')
        return super.onClickAxisInput(loc, extremeValue)
      //log
      let yScale = this.lastYScale || this.yScale
      let val = loc === 'y:max' ? yScale.invert(0) : yScale.invert(this.height)
      val = this.yAxisLogInputFormat(val)
      val = val.toString()
      extremeValue.input.node().value = val
      extremeValue.text.text(val)
      val = val.trim()
      this.setCaretPosition(extremeValue.input.node(), val.length)

      let inputWidth = extremeValue.text.node().getBBox().width

      extremeValue.inputContainer
        .attr('width', inputWidth + this.INPUT_PADDING )
        .attr('x', this.MARGIN.left - (inputWidth + extremeValue.config.offsetRight) - (this.INPUT_PADDING / 2))
      extremeValue.input
        .style('width', `${inputWidth + this.INPUT_PADDING}px`)
        .style('opacity', 1)
    }
  }

  protected onAxisInput(loc, input, val) {
    if(this.config.axes.y.scale === 'log' && (loc === 'y:min' || loc === 'y:max')) {
      val = val.replace(/[^0-9\.\-]/g, '')
      let match = val.match(/0/g)
      if(match? val.match.length === val.length : false)
        return val
      input.value = val === '' ? val : this.yAxisLogInputFormat(val)
      this.setCaretPosition(input, input.value.length)
    } else {
      val = val.replace(/[^0-9\.\-]/g, '')
      let axis = loc === 'y:max' || loc === 'y:min' ? 'y' : 'x'
      let unit = axis === 'y' ? this.getYUnit() : this.config.axes[axis].unit || ''
      input.value = val + unit
      this.setCaretPosition(input, input.value.length - unit.length)
    }
  }

  protected onEnterAxisInput(loc, input, val) {
    let axis = (loc === 'x:min' || loc === 'x:max') ? 'x' : 'y'
    let unit = (axis === 'y') ? this.getYUnit() : this.config.axes[axis].unit || ''
    val = val.toString().replace(unit, '')

    if(val === '')
      return super.onEnterAxisInput(loc, input, val)

    if(axis === 'y') {
      val = this.config.axes.y.scale === 'linear' && this.inK()
        ? val.replace(/[^0-9\.\-]/g, '') * 1000
        : val.replace(/[^0-9\.\-]/g, '') * 1

      val = (loc === 'y:min') ? this.roundDownExtremeValue(val) : this.roundUpExtremeValue(val)
      if(this.config.axes.y.scale === 'linear')
        val = val + unit
      val = val.toString()
    }

    super.onEnterAxisInput(loc, input, val)
  }

}

