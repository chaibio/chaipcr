class AmplificationChart extends window.ChaiBioCharts.BaseChart

  DEFAULT_MIN_Y: 0
  DEFAULT_MAX_Y: 10000
  DEFAULT_MIN_X: 1
  DEFAULT_MAX_X: 40

  formatPower: (d) ->
    superscript = "⁰¹²³⁴⁵⁶⁷⁸⁹"
    (d + "").split("").map((c) -> superscript[c]).join("")

  getLineCurve: ->
    if @config.axes.y.scale is 'log' then d3.curveMonotoneX else d3.curveCardinal

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
          @setActivePath(_path, @getMousePosition(el))
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

  roundUpExtremeValue: (val) ->
    if @config.axes.y.scale is 'linear'
      val += @getYExtremeValuesAllowance()
      val = val / 1000
      if Math.abs(val) >= 10
        Math.ceil(val / 5) * 5 * 1000
      else
        Math.ceil(val) * 1000
    else
      if val % 10 > 0
        num_length = val.toString().length
        roundup = '1'
        for i in [0...num_length] by 1
          roundup = roundup + "0"
        roundup = roundup * 1
      else
        val

  roundDownExtremeValue: (val) ->
    if @config.axes.y.scale is 'linear'
      val = val - @getYExtremeValuesAllowance()
      val = val / 1000
      if Math.abs(val) >= 10
        Math.floor(val / 5) * 5 * 1000
      else
        Math.floor(val) * 1000
    else
      if val % 10 > 0      
        num_length = val.toString().length
        rounddown = '1'
        for i in [0...num_length - 1] by 1
          rounddown = rounddown + "0"
        rounddown = rounddown * 1
        rounddown
      else
        val

  getYLogTicks: (min, max) ->
    min = if min < 10 then 10 else min
    min_num_length = min.toString().length
    max_num_length = max.toString().length

    min = '1'
    for i in [0...min_num_length - 1] by 1
      min = "#{min}0"
    min = min * 1

    max = '1'
    for i in [0...max_num_length] by 1
      max = "#{max}0"      
    max = max * 1

    calibs = []
    calib = min
    while calib <= max
      calibs.push(calib)
      calib = calib * 10

    return calibs

  yAxisTickFormat: (y) ->
    if @config.axes.y.scale is 'log'
      y = '10' + @formatPower(Math.round(Math.log(y) / Math.LN10))
      return y
    else
      super

  yAxisLogInputFormat: (val) ->
    val = Math.round(val)
    while (/(\d+)(\d{3})/.test(val.toString()))
      val = val.toString().replace(/(\d+)(\d{3})/, '$1'+','+'$2')
    return val

  setYAxis: ->
    @chartSVG.selectAll('g.axis.y-axis').remove()
    @chartSVG.selectAll('.g-y-axis-text').remove()
    svg = @chartSVG.select('.chart-g')

    max = if angular.isNumber(@config.axes.y.max) then @config.axes.y.max else if @hasData() then @getMaxY() else @DEFAULT_MAX_Y
    min = if angular.isNumber(@config.axes.y.min) then @config.axes.y.min else if @hasData() then @getMinY() else @DEFAULT_MIN_Y
    # add allowance for interpolation curves
    max = if @config.axes.y.scale is 'linear' then @roundUpExtremeValue(max) else max
    min = if @config.axes.y.scale is 'linear' then @roundDownExtremeValue(min) else min

    @yScale = if @config.axes.y.scale is 'log' then d3.scaleLog() else d3.scaleLinear()

    if @config.axes.y.scale is 'log'
      ticks = @getYLogTicks(min, max)
      @yScale.range([@height, 0]).domain([ticks[0], ticks[ticks.length - 1]])
      @yAxis = d3.axisLeft(@yScale)
      @yAxis.tickValues(ticks)
    else
      @yScale.range([@height, 0]).domain([min, max])
      @yAxis = d3.axisLeft(@yScale)
    
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

  hideLastAxesTicks: ->
    spacingX = 20
    spacingY = 1
    xAxisLeftExtremeValueText = @xAxisLeftExtremeValue.text
    xAxisRightExtremeValueText = @xAxisRightExtremeValue.text
    yAxisLowerExtremeValueText = @yAxisLowerExtremeValue.text
    yAxisUpperExtremeValueText = @yAxisUpperExtremeValue.text

    config = @config

    # x ticks
    ticks = @chartSVG.selectAll('g.axis.x-axis > g.tick')


    width = @width
    num_ticks = ticks.size()
    ticks.each (d, i) ->

      if config.axes.y.scale is 'log'
        return "xtick_#{i}"

      if (i is 0)
        textWidth = xAxisLeftExtremeValueText.node().getBBox().width
        x = this.transform.baseVal[0].matrix.e
        if x < textWidth + spacingX
          d3.select(this).attr('opacity', 0)
      if (i is num_ticks - 1)
        textWidth = xAxisRightExtremeValueText.node().getBBox().width
        x = this.transform.baseVal[0].matrix.e
        if x >  width - (textWidth + spacingX)
          d3.select(this).attr('opacity', 0)
    # y ticks
    ticks = @chartSVG.selectAll('g.axis.y-axis > g.tick')
    num_ticks = ticks.size()
    height = @height
    ticks.each (d, i) ->

      if config.axes.y.scale is 'log'
        return "ytick_#{i}"

      if (i is 0)
        textHeight = yAxisLowerExtremeValueText.node().getBBox().height
        y = this.transform.baseVal[0].matrix.f
        if y >  height - (textHeight + spacingY)
          d3.select(this).attr('opacity', 0)
      if (i is num_ticks - 1)
        textHeight = yAxisUpperExtremeValueText.node().getBBox().height
        y = this.transform.baseVal[0].matrix.f
        if y < textHeight + spacingY
          d3.select(this).attr('opacity', 0)

  onClickAxisInput: (loc, extremeValue) ->
    # val = extremeValue.text.text()
    if loc is 'x:min'
      val = @getXScale().invert(0).toString()
      conWidth = extremeValue.text.node().getBBox().width + @INPUT_PADDING
      extremeValue.inputContainer
        .attr('width', conWidth)
        .attr('x', @config.margin.left - (conWidth / 2))
      extremeValue.input
        .style('opacity', 1)
        .style('width', "#{conWidth}px")
      xScale = @getXScale()
      val = extremeValue.text.text()
      extremeValue.input.node().value = val
      
      val = val.replace(@config.axes.x.unit, '') if @config.axes.x.unit
      val = val.trim()
      @setCaretPosition(extremeValue.input.node(), val.length)
    if loc is 'x:max'
      val = @getXScale().invert(@width).toString()
      conWidth = extremeValue.text.node().getBBox().width + @INPUT_PADDING

      extremeValue.inputContainer
        .attr('width', conWidth)
        .attr('x', @config.margin.left + @width - (conWidth / 2))

      extremeValue.input.node().value = val
      extremeValue.input
        .style('opacity', 1)
        .style('width', "#{conWidth}px")

      val = val.replace(@config.axes.x.unit, '') if @config.axes.x.unit
      val = val.trim()
      @setCaretPosition(extremeValue.input.node(), val.length)

    if loc is 'y:max'
      val = @getYScale().invert(0)
      if @config.axes.y.scale is 'log'
        val = @yAxisLogInputFormat(val)
      else
        val = @yAxisTickFormat(val)
      val = val.toString()
      extremeValue.input.node().value = val
      extremeValue.text.text(val)
      val = val.replace(@config.axes.y.unit, '') if @config.axes.y.unit and @config.axes.y.scale isnt 'log'
      val = val.trim()
      @setCaretPosition(extremeValue.input.node(), val.length)

      inputWidth = extremeValue.text.node().getBBox().width

      extremeValue.inputContainer
        .attr('width', inputWidth + @INPUT_PADDING )
        .attr('x', @config.margin.left - (inputWidth + extremeValue.config.offsetRight) - (@INPUT_PADDING / 2))
      extremeValue.input
        .style('width', "#{inputWidth + @INPUT_PADDING}px")
        .style('opacity', 1)

    if loc is 'y:min'
      val = @getYScale().invert(@height)
      if @config.axes.y.scale is 'log'
        val = @yAxisLogInputFormat(val)
      else
        val = @yAxisTickFormat(val)
      val = val.toString()
      extremeValue.input.node().value = val
      extremeValue.text.text(val)

      conWidth = extremeValue.text.node().getBBox().width

      val = val.replace(@config.axes.y.unit, '') if @config.axes.y.unit and @config.axes.y.scale isnt 'log'
      val = val.trim()
      @setCaretPosition(extremeValue.input.node(), val.length)

      extremeValue.inputContainer
        .attr('width', conWidth)
        .attr('y', @height + @config.margin.top - (extremeValue.config.conHeight / 2))
        .attr('x', @config.margin.left - (conWidth + extremeValue.config.offsetRight) - (@INPUT_PADDING / 2))
      extremeValue.input
        .style('opacity', 1)
        .style('width', "#{conWidth + @INPUT_PADDING}px")

  onAxisInput: (loc, input, val) ->
    val = val.replace(/[^0-9\.\-]/g, '')
    if (loc is 'y:max' or loc is 'y:min')
      if @config.axes.y.scale is 'linear'
        unit = if @config.axes.y.unit then @config.axes.y.unit else ''
        input.value = val + unit
        @setCaretPosition(input, input.value.length - unit.length)
      else
        input.value = @yAxisLogInputFormat(val)
        @setCaretPosition(input, input.value.length)
    else
      input.value = val
      @setCaretPosition(input, val.length)


  onEnterAxisInput: (loc, input, val) ->
    if loc is 'y:max'
      val = if @config.axes.y.scale is 'linear'
              val.replace(@config.axes.y.unit, '') * 1000
            else
              newval = val.replace(/\D/g, '') * 1
              @roundUpExtremeValue(newval)

      maxY = if angular.isNumber(val) and !window.isNaN(val) then val else @roundUpExtremeValue(@getMaxY())
      y = @yScale
      lastYScale = @lastYScale || y
      minY = lastYScale.invert(@height)

      if minY >= maxY
        return false

      max = @roundUpExtremeValue(@getMaxY())
      maxY = if maxY > max then max else maxY
      k = @height / (y(minY) - y(maxY))

      @editingYAxis = true
      lastK = @getTransform().k
      @chartSVG.call(@zooomBehavior.transform, d3.zoomIdentity.scale(k).translate(0, -y(maxY)))
      @editingYAxis = false
      @chartSVG.call(@zooomBehavior.transform, d3.zoomIdentity.scale(lastK))

    if loc is 'y:min'
      val = if @config.axes.y.scale is 'linear'
              val.replace(@config.axes.y.unit, '') * 1000
            else
              newval = val.replace(/\D/g, '') * 1
              @roundDownExtremeValue(newval)
      y = @yScale
      lastYScale = @lastYScale || y
      minY = if angular.isNumber(val) and !window.isNaN(val) then val else @roundDownExtremeValue(@getMinY())
      maxY = lastYScale.invert(0)
      if (minY >= maxY)
        return false

      min = @roundDownExtremeValue(@getMinY())
      minY = if minY < min then min else minY

      k = @height / (y(minY) - y(maxY))
      lastK = @getTransform().k
      @editingYAxis = true
      @chartSVG.call(@zooomBehavior.transform, d3.zoomIdentity.scale(k).translate(0, -y(maxY)))
      @editingYAxis = false
      @chartSVG.call(@zooomBehavior.transform, d3.zoomIdentity.scale(lastK))

    if loc is 'x:min'
      extent = @getScaleExtent() - @getMinX()
      x = @xScale
      lastXScale = @lastXScale || x
      minX = val * 1
      maxX = lastXScale.invert(@width)
      if (minX >= maxX)
        return false
      if (val is '' || minX < @getMinX())
        minX = @getMinX()
      k = @width / (x(maxX) - x(minX))
      width_percent = 1 / k
      w = extent - (width_percent * extent)
      @chartSVG.call(@zooomBehavior.scaleTo, k)
      @scroll((minX - @getMinX()) / w)

    if loc is 'x:max'
      extent = @getScaleExtent() - @getMinX()
      x = @xScale
      lastXScale = @lastXScale || x
      minX = lastXScale.invert(0)
      maxX = val * 1
      if (minX >= maxX)
        return false
      if val is ''
        maxX = @roundUpExtremeValue(@getMaxX())
      if (maxX > @getScaleExtent())
        maxX = @getScaleExtent()
      k = @width / (x(maxX) - x(minX))
      width_percent = 1 / k
      w = extent - (width_percent * extent)
      @chartSVG.call(@zooomBehavior.scaleTo, k)
      @scroll((minX - @getMinX()) / w)

    # update input state
    extremeValue =  if loc is 'x:min'
                      @xAxisLeftExtremeValue
                    else if loc is 'x:max'
                      @xAxisRightExtremeValue
                    else if loc is 'y:min'
                      @yAxisLowerExtremeValue
                    else
                      @yAxisUpperExtremeValue

    @onClickAxisInput(loc, extremeValue)

window.ChaiBioCharts = window.ChaiBioCharts || {}
window.ChaiBioCharts.AmplificationChart = AmplificationChart