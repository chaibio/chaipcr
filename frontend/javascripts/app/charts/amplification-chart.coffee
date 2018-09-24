class AmplificationChart extends window.ChaiBioCharts.BaseChart

  DEFAULT_MIN_Y: 0
  DEFAULT_MAX_Y: 10000
  DEFAULT_MIN_X: 1
  DEFAULT_MAX_X: 40
  MARGIN:
    top: 10
    left: 80
    right: 10
    bottom: 20

  inK: ->
    @getMaxY() - @getMinY() > 20000

  getYUnit: -> if @inK() then 'k' else ''

  formatPower: (d) ->
    superscript = "⁰¹²³⁴⁵⁶⁷⁸⁹"
    (d + "").split("").map((c) -> superscript[c]).join("")

  getLineCurve: ->
    if @config.axes.y.scale is 'log' then d3.curveMonotoneX else d3.curveBasis

  makeColoredLine: (line_config) ->

    xScale = @getXScale()
    yScale = @getYScale()
    line = d3.line()
    line.curve(@getLineCurve())
    line.x (d) -> xScale(d[line_config.x])
    line.y (d) -> yScale(d[line_config.y])
    
    if (@config.axes.y.scale is 'log') then line.defined (d) -> d[line_config.y] > 10
    
    _path = @viewSVG.append("path")
        .datum(@data[line_config.dataset])
        .attr("class", "colored-line")
        .attr("stroke", line_config.color)
        .attr('fill', 'none')
        .attr("d", line)
        .attr('stroke-width', @NORMAL_PATH_STROKE_WIDTH)
        .on('click', (e, a, path) =>
          el = _path.node()
          # @setActivePath(_path, @getMousePosition(el))
          @mouseMoveCb()
        )
        .on('mousemove', (e, a, path) =>
          if (_path isnt @activePath)
            _path.attr('stroke-width', @HOVERED_PATH_STROKE_WIDTH)
            @hoveredLine = _path
            @hovering = true
          @mouseMoveCb()
        )
        .on('mouseout', (e, a, path) =>
          if (_path isnt @activePath)
            _path.attr('stroke-width', @NORMAL_PATH_STROKE_WIDTH)
            @hovering = false
        )

  getYExtremeValuesAllowance: ->
    max = @getMaxY()
    min = @getMinY()
    diff = max - min
    diff * 0.05

  computedMaxY: ->
    max = if angular.isNumber(@config.axes.y.max) then @config.axes.y.max else if @hasData() then @getMaxY() else @DEFAULT_MAX_Y
    if @config.axes.y.scale is 'linear'
      m = @roundUpExtremeValue( max + @getYExtremeValuesAllowance())
      return m
    else
      ticks = @getYLogTicks(@getMinY(), @getMaxY())
      return ticks[ticks.length - 1]

  computedMinY: ->
    min = if angular.isNumber(@config.axes.y.min) then @config.axes.y.min else if @hasData() then @getMinY() else @DEFAULT_MIN_Y
    if @config.axes.y.scale is 'linear'
      return @roundDownExtremeValue(min - @getYExtremeValuesAllowance())
    else
      ticks = @getYLogTicks(@getMinY(), @getMaxY())
      return ticks[0]

  roundUpExtremeValue: (val) ->
    if @config.axes.y.scale is 'linear'
      val = if @inK() then val / 1000 else val
      if @inK()
        Math.ceil(val / 5) * 5 * 1000
      else
        Math.ceil(val) * 1
    else
      num_length = val.toString().length - 1
      roundup = val.toString().charAt 0
      for i in [0...num_length] by 1
        roundup = roundup + "0"
      roundup * 1

  roundDownExtremeValue: (val) ->
    if @config.axes.y.scale is 'linear'
      val = if @inK() then val / 1000 else val
      if @inK()
        Math.floor(val / 5) * 5 * 1000
      else
        Math.floor(val) * 1
    else
      if val < 10
        return 10
      num_length = val.toString().length
      num_length = if val < 10 then 2 else num_length
      rounddown = val.toString().charAt(0)
      for i in [0...num_length - 1] by 1
        rounddown = rounddown + "0"
      rounddown * 1

  base10: (num) ->
    b = '1'
    num_length = num.toString().length
    while b.length < num_length
      b += '0'

    return b * 1

  getYLogTicks: (min, max) ->
    min = if min < 10 then 10 else min
    min_num_length = min.toString().length
    max_num_length = max.toString().length

    min = '1'
    for i in [0...min_num_length - 1] by 1
      min = "#{min}0"
    min = +min

    max = '1'
    for i in [0...max_num_length] by 1
      max = "#{max}0"
    max = +max

    calibs = []
    calib = min
    calibs.push(min)
    calib = @base10(calib)
    while calib < max
      calib = calib * 10
      calibs.push(calib)

    calibs.push max

    return calibs

  yAxisTickFormat: (y) ->
    if @config.axes.y.scale is 'log'
      y0 = y.toString().charAt(0)
      y = (if y0 is '1' then '10' else y0 + ' x 10') + @formatPower(Math.round(Math.log(y) / Math.LN10))
      return y
    else
      if @inK()
        return (Math.round(y / 1000)) + @getYUnit()
      else
        return Math.round(y * 10) / 10

  yAxisLogInputFormat: (val) ->
    val = Math.round(val)
    while (/(\d+)(\d{3})/.test(val.toString()))
      val = val.toString().replace(/(\d+)(\d{3})/, '$1'+','+'$2')
    return val

  setYAxis: ->
    @chartSVG.selectAll('g.axis.y-axis').remove()
    @chartSVG.selectAll('.g-y-axis-text').remove()
    svg = @chartSVG.select('.chart-g')

    min = @computedMinY()
    max = @computedMaxY()

    @yScale = if @config.axes.y.scale is 'log' then d3.scaleLog() else d3.scaleLinear()

    if @config.axes.y.scale is 'log'
      ticks = @getYLogTicks(@getMinY(), @getMaxY())
      @yScale.range([@height, 0]).domain([ticks[0], ticks[ticks.length - 1]])
      @yAxis = d3.axisLeft(@yScale)
      @yAxis.tickValues(ticks)
    else
      @yScale.range([@height, 0]).domain([min, max])
      @yAxis = d3.axisLeft(@yScale)
      @yAxis.ticks(8)
      if @inK()
        @yAxis.tickValues(@getYLinearTicks())
    
    @yAxis.tickFormat (y) =>
      @yAxisTickFormat(y)

    @gY = svg.append("g")
          .attr("class", "axis y-axis")
          .attr('fill', 'none')
          .call(@yAxis)
          .on('mouseenter', => @hideMouseIndicators())

    
    if @zoomTransform.rescaleY
      @gY.call(@yAxis.scale(@zoomTransform.rescaleY(@yScale)))
    #text label for the y axis
    @setYAxisLabel()
    @lastYScale = @yScale

  validateBackSpace: (loc, input) ->
    axis = if loc is 'y:min' or loc is 'y:max' then 'y' else 'x'
    value = input.value
    selection = input.selectionStart
    unit = if axis is 'y' then @getYUnit() else @config.axes[axis].unit or ''
    if @config.axes.y.scale is 'linear' and (selection > value.length - unit.length)
      d3.event.preventDefault()
      return true
    else
      return false

  onClickAxisInput: (loc, extremeValue) ->
    axis = if loc is 'x:min' or loc is 'x:max' then 'x' else 'y'
    if axis is 'x'
      super
    else
      if @config.axes.y.scale is 'linear'
        return super
      # log
      yScale = @lastYScale or @yScale
      val = if loc is 'y:max' then yScale.invert(0) else yScale.invert(@height)
      val = @yAxisLogInputFormat(val)
      val = val.toString()
      extremeValue.input.node().value = val
      extremeValue.text.text(val)
      val = val.trim()
      @setCaretPosition(extremeValue.input.node(), val.length)

      inputWidth = extremeValue.text.node().getBBox().width

      extremeValue.inputContainer
        .attr('width', inputWidth + @INPUT_PADDING )
        .attr('x', @MARGIN.left - (inputWidth + extremeValue.config.offsetRight) - (@INPUT_PADDING / 2))
      extremeValue.input
        .style('width', "#{inputWidth + @INPUT_PADDING}px")
        .style('opacity', 1)


  onAxisInput: (loc, input, val) ->
    if @config.axes.y.scale is 'log' and (loc is 'y:min' or loc is 'y:max')
      val = val.replace(/[^0-9\.\-]/g, '')
      if val.match(/0/g)?.length is val.length
        return val
      input.value = if val is '' then val else @yAxisLogInputFormat(val)
      @setCaretPosition(input, input.value.length)
    else
      val = val.replace(/[^0-9\.\-]/g, '')
      axis = if loc is 'y:max' or loc is 'y:min' then 'y' else 'x'
      unit = if axis is 'y' then @getYUnit() else @config.axes[axis].unit or ''
      input.value = val + unit
      @setCaretPosition(input, input.value.length - unit.length)

  onEnterAxisInput: (loc, input, val) ->
    axis = if loc is 'x:min' or loc is 'x:max' then 'x' else 'y'
    unit = if axis is 'y' then @getYUnit() else @config.axes[axis].unit or ''
    val = val.toString().replace(unit, '')

    return super if val is ''

    if axis is 'y'
      val = if @config.axes.y.scale is 'linear' and @inK()
              val.replace(/[^0-9\.\-]/g, '') * 1000
            else
              val.replace(/[^0-9\.\-]/g, '') * 1

      val = if loc is 'y:min' then @roundDownExtremeValue(val) else @roundUpExtremeValue(val)
      val = val + unit if @config.axes.y.scale is 'linear'
      val = val.toString()
      
    super
    
window.ChaiBioCharts = window.ChaiBioCharts || {}
window.ChaiBioCharts.AmplificationChart = AmplificationChart
