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

  getYExtremeValuesAllowance: ->
    max = @getMaxY()
    min = @getMinY()
    diff = max - min
    diff * (if @config.axes.y.scale is 'log' then 0.2 else 0.05)


  roundUpExtremeValue: (val) ->
    val += @getYExtremeValuesAllowance()
    val = val / 1000
    if Math.abs(val) >= 10
      Math.ceil(val / 5) * 5 * 1000
    else
      Math.ceil(val) * 1000

  roundDownExtremeValue: (val) ->
    return 5 if @config.axes.y.scale is 'log'
    val = val - @getYExtremeValuesAllowance()
    val = val / 1000
    if Math.abs(val) >= 10
      Math.floor(val / 5) * 5 * 1000
    else
      Math.floor(val) * 1000

  yAxisTickFormat: (y) ->
    if @config.axes.y.scale is 'log'
      '10' + @formatPower(Math.round(Math.log(y) / Math.LN10))
    else
      super

  # setYInputCaret: (input, val) ->
  #   @setCaretPosition(input, val.toString().replace(@config.axes.y.unit, '').length)

  onClickAxisInput: (loc, extremeVAlue) ->
    val = extremeVAlue.text.text()
    if loc is 'x:min'
      conWidth = extremeVAlue.text.node().getBBox().width + @INPUT_PADDING
      extremeVAlue.inputContainer
        .attr('width', conWidth)
        .attr('x', @config.margin.left - (conWidth / 2))
      extremeVAlue.input
        .style('opacity', 1)
        .style('width', "#{conWidth}px")
      xScale = @getXScale()
      val = extremeVAlue.text.text()
      extremeVAlue.input.node().value = val
      
      val = val.replace(@config.axes.x.unit, '') if @config.axes.x.unit
      val = val.trim()
      @setCaretPosition(extremeVAlue.input.node(), val.length)
    else if loc is 'x:max'
      xScale = @getXScale()
      conWidth = extremeVAlue.text.node().getBBox().width + @INPUT_PADDING

      extremeVAlue.inputContainer
        .attr('width', conWidth)
        .attr('x', @config.margin.left + @width - (conWidth / 2))

      extremeVAlue.input.node().value = val
      extremeVAlue.input
        .style('opacity', 1)
        .style('width', "#{conWidth}px")

      val = val.replace(@config.axes.x.unit, '') if @config.axes.x.unit
      val = val.trim()
      @setCaretPosition(extremeVAlue.input.node(), val.length)

    else if loc is 'y:max'
      # val = @yAxisTickFormat(Math.round(@getYScale().invert(0) * 10) / 10).toString()
      extremeVAlue.input.node().value = val
      val = val.replace(@config.axes.y.unit, '') if @config.axes.y.unit
      val = val.trim()
      @setCaretPosition(extremeVAlue.input.node(), val.length)

      inputWidth = extremeVAlue.text.node().getBBox().width

      extremeVAlue.inputContainer
        .attr('width', inputWidth + @INPUT_PADDING )
        .attr('x', @config.margin.left - (inputWidth + extremeVAlue.config.offsetRight) - (@INPUT_PADDING / 2))
      extremeVAlue.input
        .style('width', "#{inputWidth + @INPUT_PADDING}px")
        .style('opacity', 1)

    else # y:min
      conWidth = extremeVAlue.text.node().getBBox().width
      extremeVAlue.input.node().value = val

      val = val.replace(@config.axes.y.unit, '') if @config.axes.y.unit
      val = val.trim()
      @setCaretPosition(extremeVAlue.input.node(), val.length)

      extremeVAlue.inputContainer
        .attr('width', conWidth)
        .attr('y', @height + @config.margin.top - (extremeVAlue.config.conHeight / 2))
        .attr('x', @config.margin.left - (conWidth + extremeVAlue.config.offsetRight))
      extremeVAlue.input
        .style('opacity', 1)
        .style('width', "#{conWidth + @INPUT_PADDING}px")

  onAxisInput: (loc, input, val) ->
    val = val.replace(/[^0-9\.\-]/g, '')
    if (loc is 'y:max' or loc is 'y:min')
      input.value = val + @config.axes.y.unit
      @setCaretPosition(input, val.length)
    else
      input.value = val
      @setCaretPosition(input, val.length)


  onEnterAxisInput: (loc, input, val) ->
    if loc is 'y:max'
      val = val.replace(@config.axes.y.unit, '') * 1000
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
      val = val.replace(@config.axes.y.unit, '') * 1000
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