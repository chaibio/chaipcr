class MeltCurveChart extends window.ChaiBioCharts.BaseChart

  DEFAULT_MAX_Y: 10
  DEFAULT_MAX_X: 1
  DEFAULT_MIN_Y: 0
  DEFAULT_MIN_X: 0

  getScaleExtent: ->
    return @getMaxX()

  onClickAxisInput: (loc, extremeValue) ->
    if loc is 'x:min'
      val = @getXScale().invert(0)
      val = @xAxisTickFormat(val)
      conWidth = extremeValue.text.node().getBBox().width + @INPUT_PADDING
      extremeValue.inputContainer
        .attr('width', conWidth)
        .attr('x', @config.margin.left - (conWidth / 2))
      extremeValue.input
        .style('opacity', 1)
        .style('width', "#{conWidth}px")
      val = extremeValue.text.text()
      extremeValue.input.node().value = val
      
      val = val.replace(@config.axes.x.unit, '') if @config.axes.x.unit
      val = val.trim()
      @setCaretPosition(extremeValue.input.node(), val.length)
    if loc is 'x:max'
      val = @getXScale().invert(@width)
      val = @xAxisTickFormat(val)
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
      val = extremeValue.text.text() * 1
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
      val = extremeValue.text.text() * 1
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
      input.value = val
      @setCaretPosition(input, input.value.length)
    else
      input.value = val
      @setCaretPosition(input, val.length)

window.ChaiBioCharts = window.ChaiBioCharts || {}
window.ChaiBioCharts.MeltCurveChart = MeltCurveChart