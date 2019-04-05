class BaseChart

  Y_AXIS_NUM_TICKS: 5

  NORMAL_PATH_STROKE_WIDTH: 2
  HOVERED_PATH_STROKE_WIDTH: 3
  ACTIVE_PATH_STROKE_WIDTH: 5
  CIRCLE_STROKE_WIDTH: 2
  CIRCLE_RADIUS: 7
  
  DEFAULT_MAX_Y: 1
  DEFAULT_MAX_X: 1
  DEFAULT_MIN_Y: 0
  DEFAULT_MIN_X: 0
  zoomTransform: {x: 0, y: 0, k: 1}
  isZooming: false
  INPUT_PADDING: 5
  EXTREME_PADDING: 10

  MARGIN:
    left: 0
    top: 0
    right: 0
    bottom: 0

  constructor: (@elem, @data, @config) ->
    # console.log('@data')
    # console.log(@data)
    # setTimeout(@initChart, 100)
    @initChart()

  getLineCurve: ->
    d3.curveBasis

  hasData: ->
    return false if !@data
    if @data and @config
      if @config.series?.length > 0
        if (@data[@config.series[0].dataset]?.length > 1)
          true
        else
          false
      else
        false
    else
      false

  computedMaxY: ->
    if angular.isNumber(@config.axes.y.max) then @config.axes.y.max else if @hasData() then @getMaxY() else @DEFAULT_MAX_Y

  computedMinY: ->
    if angular.isNumber(@config.axes.y.min) then @config.axes.y.min else if @hasData() then @getMinY() else @DEFAULT_MIN_Y

  roundUpExtremeValue: (val) ->
    Math.ceil(val)

  roundDownExtremeValue: (val) ->
    Math.floor(val)

  xAxisTickFormat: (x) ->
    if @config.axes.x.tickFormat
      x = @config.axes.x.tickFormat(x)
    if @config.axes.x.unit
      x = "#{x}#{@config.axes.x.unit}"
    return x

  yAxisTickFormat: (y) ->
    if @config.axes.y.tickFormat and angular.isNumber(y)
      y = @config.axes.y.tickFormat(y)
    if @config.axes.y.unit
      y = if !angular.isNumber(y) then '' else y
      y = "#{y}#{@config.axes.y.unit}"
    return y

  bisectX: (line_config) ->
    return d3.bisector((d) ->
      return d[line_config.x]
    ).left

  getMousePosition: (node) ->
    mouse = null
    try
      mouse = d3.mouse(node)
    catch e
      if (@activePathConfig and @circle)
        @circle.attr('transform', 'translate(0,0) scale(1)')
        mouse = [@circle.attr('cx'), @circle.attr('cy')]
      else
        mouse = [0, 0]

    return mouse

  setCaretPosition: (input, caretPos) ->
    if input.createTextRange
      range = ctrl.createTextRange()
      range.collapse(true)
      range.moveEnd('character', caretPos)
      range.moveStart('character', caretPos)
      range.select()
    else
      input.focus()
      input.setSelectionRange(caretPos, caretPos)

  getPathConfig: (path) ->
    activePathConfig = null
    activePathIndex = null

    for line, i in @lines by 1
      if line is path
        activePathConfig = @config.series[i]
        activePathIndex = i
        break
    return {
      config: activePathConfig,
      index: activePathIndex,
    }

  hideMouseIndicators: ->
    @circle.attr('opacity', 0) if @circle

  showMouseIndicators: ->
    @circle.attr('opacity', 1) if (@circle and @activePath)

  setActivePath: (path, mouse) ->
    if (@activePath)
      @activePath.attr('stroke-width', @NORMAL_PATH_STROKE_WIDTH)

    @activePathConfig = @getPathConfig(path)
    return if !@activePathConfig.config
    lineConfig = @activePathConfig.config
    lineIndex = @activePathConfig.index
    @makeWhiteBorderLine(lineConfig)
    newLine = @makeColoredLine(lineConfig).attr('stroke-width', @ACTIVE_PATH_STROKE_WIDTH)
    @lines[lineIndex] = newLine
    @activePath = newLine
    @makeCircle()
    path.remove()
    # @drawBox(lineConfig)

    if mouse
      @showMouseIndicators()
      @setBoxRFYAndCycleTexts(mouse[0])
      @mouseMoveCb()
    else
      @hideMouseIndicators

    if typeof @onSelectLine is 'function'
      @onSelectLine(@activePathConfig)

    @prevMousePosition = mouse

  unsetActivePath: ->
    return if not @activePath

    @hideMouseIndicators()
    @activePath.attr('stroke-width', @NORMAL_PATH_STROKE_WIDTH)
    @whiteBorderLine.remove()
    @activePathConfig = null
    @activePath = null
    @box.container.remove() if @box
    @onUnselectLine() if @onUnselectLine

  drawBox: (line_config) ->
    @box.container.remove() if @box
    headerHeight = 25
    headerTextSize = 15
    valuesTextSize = 12
    boxWidth = 130
    bodyHeight = 70
    boxBorderWidth = 1
    boxMargin = {
      top: 0,
      left: 10
    }

    @box = {}
    @box.container = @chartSVG.append('g')
        .attr('stroke-width', 0)
        .attr('transform', 'translate(' + (boxMargin.left + @MARGIN.left) + ',' + (boxMargin.top + @MARGIN.top) + ')')
        .attr('fill', '#fff')
        .on 'mousemove', => @mouseMoveCb()

    @box.container.append('rect')
        .attr('fill', "#ccc")
        .attr('width', boxWidth + boxBorderWidth * 2)
        .attr('height', bodyHeight + headerHeight + boxBorderWidth * 2)

    @box.header = @box.container.append('rect')
        .attr('x', boxBorderWidth)
        .attr('y', boxBorderWidth)
        .attr('fill', line_config.color)
        .attr('width', boxWidth)
        .attr('height', headerHeight)

    @box.headerText = @box.container.append('text')
        .attr 'x', -> (boxWidth + boxBorderWidth * 2) / 2
        .attr("text-anchor", "middle")
        .attr("alignment-baseline", "middle")
        .attr("font-size", headerTextSize + 'px')
        .attr("fill", "#fff")
        .attr("stroke-width", 0)
        .text ->
          wells = ['A1', 'A2', 'A3', 'A4', 'A5', 'A6', 'A7', 'A8', 'B1', 'B2', 'B3', 'B4', 'B5', 'B6', 'B7', 'B8']
          wells[line_config.well] + ', ' + (if line_config.dataset is 'channel_1' then 'Ch1' else 'Ch2')
        .attr('font-weight', 700)
        .attr('class', 'header-text')

    @box.headerText.attr 'y', =>
      textDims = @box.headerText.node().getBBox()
      return (headerHeight / 2 + (headerHeight - textDims.height) / 2) + boxBorderWidth

    @box.body = @box.container.append('rect')
        .attr('x', boxBorderWidth)
        .attr('y', headerHeight + boxBorderWidth)
        .attr('fill', '#fff')
        .attr('width', boxWidth)
        .attr('height', bodyHeight)

    @box.CqText = @box.container.append('text')
        .attr("font-size", headerTextSize + 'px')
        .attr('fill', "#000")
        .attr("font-weight", 700)
        .attr('x', 10 + boxBorderWidth)
        .attr('y', headerHeight + 20 + boxBorderWidth)
        .text('Cq')

    ctTextDims = @box.CqText.node().getBBox()

    @box.RFYTextLabel = @box.container.append('text')
        .attr("font-weight", 700)
        .attr("font-size", valuesTextSize + 'px')
        .attr('fill', "#000")
        .attr('x', 10 + boxBorderWidth)
        .attr('y', headerHeight + ctTextDims.height + 20 + boxBorderWidth)
        .text(@config.box?.label?.y || 'RFU')

    rfyLabelDims = @box.RFYTextLabel.node().getBBox()

    @box.RFYTextValue = @box.container.append('text')
        .attr("font-size", valuesTextSize + 'px')
        .attr('fill', "#000")
        .attr('x', 10 + boxBorderWidth)
        .attr('y', headerHeight + ctTextDims.height + rfyLabelDims.height + 20 + boxBorderWidth)

    @box.cycleTextLabel = @box.container.append('text')
        .attr("font-weight", 700)
        .attr("font-size", valuesTextSize + 'px')
        .attr('fill', "#000")
        .attr('x', 70 + boxBorderWidth)
        .attr('y', headerHeight + ctTextDims.height + 20 + boxBorderWidth)
        .text(@config.box?.label?.x || 'Cycle')

    cycleLabelDims = @box.cycleTextLabel.node().getBBox()

    @box.cycleTextValue = @box.container.append('text')
        .attr("font-size", valuesTextSize + 'px')
        .attr('fill', "#000")
        .attr('x', 70 + boxBorderWidth)
        .attr('y', headerHeight + cycleLabelDims.height + ctTextDims.height + 20 + boxBorderWidth)

  setBoxRFYAndCycleTexts: (x) ->
    line_config = @activePathConfig.config
    x0 = if @zoomTransform.k > 1 then @zoomTransform.rescaleX(@xScale).invert(x) else @xScale.invert(x)
    i = @bisectX(line_config)(@data[line_config.dataset], x0, 1)
    d0 = @data[line_config.dataset][i - 1]
    return if not d0
    d1 = @data[line_config.dataset][i]
    return if not d1
    d = if x0 - d0[line_config.x] > d1[line_config.x] - x0 then d1 else d0

    if @activePath

      conf = @activePathConfig

      if (@onUpdateProperties)
        @onUpdateProperties(d[@config.series[conf.index].x], d[@config.series[conf.index].y], d[@config.series[conf.index].dr1_pred], d[@config.series[conf.index].dr2_pred])

      # @box.RFYTextValue.text(d[@config.series[conf.index].y]) if @box.RFYTextValue
      # @box.cycleTextValue.text(d[@config.series[conf.index].x]) if @box.cycleTextValue
      # if @box.CqText and @activePathConfig.config.cq
      #   conf = @activePathConfig.config
      #   cqText = 'Cq: ' + (conf.cq[conf.channel - 1] || '')
      #   @box.CqText.text(cqText)

    # alert(@onUpdateProperties)
    

  getXScale: ->
      xScale = if @zoomTransform.k > 1 and !@editingYAxis then @lastXScale else @xScale
      return xScale || @xScale

  getYScale: ->
      yScale = @lastYScale || @yScale
      if (@editingYAxis)
        return yScale
      if (yScale.invert(0) < @getMaxY() || yScale.invert(@height) > @getMinY())
        return yScale
      return @yScale

  makeGuidingLine: (line_config) ->
    xScale = @getXScale()
    yScale = @getYScale()
    line = d3.line()
    line.curve(@getLineCurve())
    line.x (d) -> xScale(d[line_config.x])
    line.y (d) -> yScale(d[line_config.y])
   
    @viewSVG.append("path")
        .datum(@data[line_config.dataset])
        .attr("class", "guiding-line")
        .attr("stroke", 'transparent')
        .attr('fill', 'none')
        .attr("d", line)
        .attr('stroke-width', @NORMAL_PATH_STROKE_WIDTH)
        .on 'mousemove', => @mouseMoveCb()
        .on 'click', => @unsetActivePath()

  makeColoredLine: (line_config) ->
    # alert('makeColoredLine')
    xScale = @getXScale()
    yScale = @getYScale()

    line = d3.line()
    line.curve(@getLineCurve())

    line.x (d) -> xScale(d[line_config.x])
    line.y (d) -> yScale(d[line_config.y])

    if (@config.axes.y.scale is 'log') then line.defined (d) -> d[line_config.y] > 10

    # console.log('@data')
    # console.log(@data)

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

  makeWhiteBorderLine: (line_config) ->
    xScale = @getXScale()
    yScale = @getYScale()
    line = d3.line()
    if @whiteBorderLine then @whiteBorderLine.remove()
    line.curve(@getLineCurve())
    line.x (d) -> xScale(d[line_config.x])
    line.y (d) -> yScale(d[line_config.y])
    if (@config.axes.y.scale is 'log') then line.defined (d) -> d[line_config.y] > 10
    @whiteBorderLine = @viewSVG.append("path")
        .datum(@data[line_config.dataset])
        .attr("class", "white-border-line")
        .attr("stroke", "#fff")
        .attr('fill', 'none')
        .attr("d", line)
        .attr('stroke-width', @ACTIVE_PATH_STROKE_WIDTH + 3)

  drawLines: ->
    
    series = @config.series
    return if not series
    
    @guidingLines = @guidingLines || []
    for l in @guidingLines by 1
      l.remove()
    @guidingLines = []
    @lines = @lines || []
    for l in @lines by 1
      l.remove()
    @lines = []
    @activePath = null
    
    for s in series by 1
    #  console.log(s)
      @guidingLines.push(@makeGuidingLine(s))
    for s in series by 1
      @lines.push(@makeColoredLine(s))

    # console.log('strange haha')
    # console.log(@lines)

    if @activePathConfig
      @makeCircle()
      m = @prevMousePosition
      p = null

      for s, i in series by 1
        if (s.well is @activePathConfig.config.well and s.channel is @activePathConfig.config.channel)
          p = @lines[i]
          break
        
      if p
        @setActivePath(p)
        @showMouseIndicators()

  makeCircle: ->
    lastPos = null
    if @circle
      lastPos =
        cx: @circle.attr('cx')
        cy: @circle.attr('cy')
      @circle.remove()

    @circle = @viewSVG.append('circle')
        .attr('opacity', 0)
        .attr('r', @CIRCLE_RADIUS)
        .attr('stroke', '#fff')
        .attr('stroke-width', @CIRCLE_STROKE_WIDTH)
        .attr('transform', 'translate (0,0)')
        .on('mouseout', =>           
          @hideMouseIndicators())
        .on('mousemove', =>           
          @mouseMoveCb())
        .on('click', =>
          @circle.remove()
          @unsetActivePath()
          if @hoveredLine
            mouse = @getMousePosition(@mouseOverlay.node())
            @setActivePath(@hoveredLine, mouse)          
        )

    if @activePathConfig
      @circle.attr('fill', @activePathConfig.config.color)
    if lastPos
      @circle.attr('cx', lastPos.cx)
      @circle.attr('cy', lastPos.cy)

  zoomed: ->
    return if not d3.event
    if d3.event.sourceEvent?.srcElement
      if d3.event.sourceEvent.srcElement is @xAxisLeftExtremeValue.input.node()
        @onClickLeftXAxisInput()
      if d3.event.sourceEvent.srcElement is @xAxisRightExtremeValue.input.node()
        @onClickRightXAxisInput()
      if d3.event.sourceEvent.srcElement is @yAxisUpperExtremeValue.input.node()
        @onClickUpperYAxisInput()
      if d3.event.sourceEvent.srcElement is @yAxisLowerExtremeValue.input.node()
        @onClickLowerYAxisInput()

    transform = d3.event.transform
    transform.x = transform.x || 0
    transform.y = transform.y || 0
    transform.k = transform.k || 0

    if (transform.x > 0)
      transform.x = 0

    if (transform.x + (@width * transform.k) < @width)
      transform.x = -(@width * transform.k - @width)

    if (transform.y > 0)
      transform.y = 0

    if (transform.y + (@height * transform.k) < @height)
      transform.y = -(@height * transform.k - @height)

    if (transform.k < 1)
      transform.k = 1

    if (@editingYAxis)
      @lastYScale = transform.rescaleY(@yScale)
      @gY.call(@yAxis.scale(@lastYScale))
    else
      @lastXScale = transform.rescaleX(@xScale)
      @gX.call(@xAxis.scale(@lastXScale))

    @zoomTransform = transform
    @updateAxesExtremeValues()

    if (@onZoomAndPan and !@editingYAxis)
      @onZoomAndPan(@zoomTransform, @width, @height, @getScaleExtent() - @getMinX() )

    @drawLines()

  getMinX: ->
    return @config.axes.x.min if @config.axes.x.min
    min = d3.min @config.series, (s) =>
      d3.min @data[s.dataset], (d) => d[s.x]
    return min || 0

  getMaxX: ->
    return @config.axes.x.max if @config.axes.x.max
    max = d3.max @config.series, (s) =>
      d3.max @data[s.dataset], (d) => d[s.x]
    return max || 0

  getMinY: ->
    return @config.axes.y.min if @config.axes.y.min
    min_y = d3.min @config.series, (s) =>
      d3.min @data[s.dataset], (d) => d[s.y]
    return min_y || 0

  getMaxY: ->
    return @config.axes.y.max if @config.axes.y.max
    max_y = d3.max @config.series, (s) =>
        d3.max @data[s.dataset], (d) => d[s.y]
    return max_y || 0

  getScaleExtent: ->
    return @config.axes.x.max || @getMaxX()

  getYLinearTicks: ->
    max = @getMaxY()
    min = @getMinY()

    # min = Math.floor(min / 5000) * 5000 # ROUND(A2/5,0)*5
    # max = Math.ceil(max / 5000) * 5000
    # ticks = []
    # for y in [min..max] by 5000
    #   ticks.push(y)

    #append for Y_AXIS_NUM_TICKS start
    intv = (max - min) / @Y_AXIS_NUM_TICKS
    intv = Math.ceil(intv / 5000) * 5000

    min = Math.floor(min / intv) * intv # ROUND(A2/5,0)*5
    max = Math.ceil(max / intv) * intv

    ticks = []
    for y in [min..max] by intv
      ticks.push(y)
    #append for Y_AXIS_NUM_TICKS end
    return ticks

  setYAxis: ->
    @chartSVG.selectAll('g.axis.y-axis').remove()
    @chartSVG.selectAll('.g-y-axis-text').remove()
    svg = @chartSVG.select('.chart-g')

    max = @computedMaxY()
    min = @computedMinY()

    @yScale = d3.scaleLinear()
    @yScale.range([@height, 0]).domain([min, max])
    @yAxis = d3.axisLeft(@yScale)
    
    @yAxis.tickFormat (y) =>
      @yAxisTickFormat(y)

    @gY = svg.append("g")
        .attr("class", "axis y-axis")
        .attr('fill', 'none')
        .call(@yAxis)
        .on('mouseenter', => @hideMouseIndicators())

    svg.append("line")
    .attr("shape-rendering", "crispEdges")
    .attr("class", "long-axis")
    .attr("x1", 0)
    .attr("y1", 0 - @height * 0.2)
    .attr("x2", 0)
    .attr("y2", @height * 1.2)
    .style("stroke-width", 1)
    .style("fill", "none");

    if @zoomTransform.rescaleY
      @gY.call(@yAxis.scale(@zoomTransform.rescaleY(@yScale)))
    #text label for the y axis
    @setYAxisLabel()
    @lastYScale = @yScale

  setYAxisLabel: ->
    return if not @config.axes.y.label
    svg = @chartSVG.select('.chart-g')
    @yAxisLabel = svg.append("text")
      .attr("class", "G1M")
      .attr("transform", "rotate(-90)")
      .attr("y", 0 - @MARGIN.left + 10)
      .attr("x", 0 - (@height / 2))
      .attr("dy", "1em")
      .attr("fill", "#333")
      .style("text-anchor", "middle")
      .text(@config.axes.y.label)


  setXAxis: (showLabel = true)->
    @chartSVG.selectAll('g.axis.x-axis').remove()
    @chartSVG.selectAll('.g-x-axis-text').remove()
    svg = @chartSVG.select('.chart-g')
    @xScale = d3.scaleLinear().range([0, @width])

    min = if angular.isNumber(@config.axes.x.min) then @config.axes.x.min else if @hasData() then @getMinX() else @DEFAULT_MIN_X
    max = if angular.isNumber(@config.axes.x.max) then @config.axes.x.max else if @hasData() then @getMaxX() else @DEFAULT_MAX_X
    
    @xScale.domain([min, max])

    @xAxis = d3.axisBottom(@xScale)
    if typeof @config.axes.x.tickFormat is 'function'
      @xAxis.tickFormat (x) => @xAxisTickFormat(x)
    @gX = svg.append("g")
        .attr("class", "axis x-axis")
        .attr('fill', 'none')
        .attr("transform", "translate(0," + @height + ")")
        .call(@xAxis)
        .on('mouseenter', => @hideMouseIndicators())

    svg.append("line")
    .attr("shape-rendering", "crispEdges")
    .attr("class", "long-axis")
    .attr("x1", 0 - @width * 0.2)
    .attr("y1", @height)
    .attr("x2", @width * 1.2)
    .attr("y2", @height)
    .style("stroke-width", 1)
    .style("fill", "none");

    if @zoomTransform.rescaleX
      @gX.call(@xAxis.scale(@zoomTransform.rescaleX(@xScale)))

    # text label for the x axis
    if showLabel
      @setXAxisLabel()

  setXAxisLabel: ->
    return if not (@config.axes.x.label)
    svg = @chartSVG.select('.chart-g')
    @xAxisLabel = svg.append("text")
      .attr('class', 'G1M')
      .attr("transform",
        "translate(" + (@width / 2) + " ," +
        (@height + @MARGIN.top + @MARGIN.bottom - 40) + ")")
      .style("text-anchor", "middle")
      .attr("fill", "#333")
      .text(@config.axes.x.label)

  updateZoomScaleExtent: ->
    return if !@zooomBehavior
    @zooomBehavior.scaleExtent([1, @getScaleExtent()])

  onAxisInputBaseFunc: (loc, input, val) ->
    charCode = d3.event.keyCode
    if charCode > 36 and charCode < 41
      # arrow keys
      return true
    else
      # remove units before passing value to @onAxisInput()
      axis = if loc is 'x:min' or loc is 'x:max' then 'x' else 'y'
      val = val.toString().replace(@config.axes[axis].unit, '') if @config.axes[axis].unit
      @onAxisInput(loc, input, val) if typeof @onAxisInput is 'function'

      # update the input width after value is updated
      extremeValue = null
      if loc is 'x:min'
        extremeValue = @xAxisLeftExtremeValue
      if loc is 'x:max'
        extremeValue = @xAxisRightExtremeValue
      if loc is 'y:min'
        extremeValue = @yAxisLowerExtremeValue
      if loc is 'y:max'
        extremeValue = @yAxisUpperExtremeValue

      extremeValue.text.text(extremeValue.input.node().value)
      textWidth = extremeValue.text.node().getBBox().width

      if loc is 'x:min'
        conWidth = textWidth + @INPUT_PADDING
        extremeValue.inputContainer
          .attr('width', conWidth)
          .attr('x', @MARGIN.left + @EXTREME_PADDING)
        extremeValue.text
          .attr('x', @MARGIN.left - (textWidth / 2))
        extremeValue.input
          .style('width', "#{conWidth}px")

      if loc is 'x:max'
        conWidth = textWidth + @INPUT_PADDING
        extremeValue.inputContainer
          .attr('width', conWidth)
          .attr('x', @MARGIN.left + @width - (conWidth / 2))
        extremeValue.text
          .attr('x', @MARGIN.left + @width - (textWidth / 2))
        extremeValue.input
          .style('width', "#{conWidth}px")

      if (loc is 'y:min') or (loc is 'y:max')
        conWidth = textWidth
        extremeValue.inputContainer
          .attr('width', conWidth + @INPUT_PADDING)
          .attr('x', @MARGIN.left - (conWidth + extremeValue.config.offsetRight + @INPUT_PADDING / 2))
        extremeValue.input
          .style('width', "#{conWidth + @INPUT_PADDING}px")
        extremeValue.text.attr('x', @MARGIN.left - (extremeValue.config.offsetRight + conWidth + @INPUT_PADDING / 2))

  onClickAxisInput: (loc, extremeValue) ->
    axis = if loc is 'x:min' or loc is 'x:max' then 'x' else 'y'
    if axis is 'x'
      val = if loc is 'x:min' then @getXScale().invert(0) else @getXScale().invert(@width)
      val = @xAxisTickFormat(val)
      conWidth = extremeValue.text.node().getBBox().width + @INPUT_PADDING
      extremeValue.inputContainer
        .attr('width', conWidth)
        .attr('x', @MARGIN.left + (if loc is 'x:min' then (conWidth / 2) + @EXTREME_PADDING else @width) - (conWidth / 2))
      extremeValue.input
        .style('opacity', 1)
        .style('width', "#{conWidth}px")
      val = extremeValue.text.text()
      extremeValue.input.node().value = val
      
      val = val.replace(@config.axes.x.unit, '') if @config.axes.x.unit
      val = val.trim()
      @setCaretPosition(extremeValue.input.node(), val.length)
        
    else
      yScale = @lastYScale or @yScale
      val= if loc is 'y:max' then yScale.invert(0) else yScale.invert(@height)
      val = @yAxisTickFormat(val)
      val = val.toString()
      extremeValue.input.node().value = val
      extremeValue.text.text(val)
      val = val.replace(@config.axes.y.unit, '') if @config.axes.y.unit
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
    val = val.replace(/[^0-9\.\-]/g, '')
    axis = if loc is 'y:max' or loc is 'y:min' then 'y' else 'x'
    unit = @config.axes[axis].unit || ''
    input.value = val + unit
    @setCaretPosition(input, input.value.length - unit.length)
    
  drawAxesExtremeValues: ->
    @chartSVG.selectAll('.axes-extreme-value').remove()
    @drawXAxisLeftExtremeValue()
    @drawXAxisRightExtremeValue()
    @drawYAxisUpperExtremeValue()
    @drawYAxisLowerExtremeValue()
    @updateAxesExtremeValues()
    @updateBottomXYLabel()

  drawXAxisLeftExtremeValue: ->
    textContainer = @chartSVG.append('g')
        .attr('class', 'axes-extreme-value tick')
    @xAxisLeftExtremeValueContainer = textContainer

    conWidth = 30
    conHeight = 12
    offsetTop = 8.5
    underlineStroke = 1
    lineWidth = 15

    rect = textContainer.append('rect')
      .attr('fill', '#fff')
      .attr('width', conWidth)
      .attr('height', conHeight)
      .attr('y', @height + @MARGIN.top + offsetTop)
      .attr('x', @MARGIN.left - (conWidth / 2))
      .on 'click', => @onClickLeftXAxisInput()

    line = textContainer.append('line')
        .attr("shape-rendering", "crispEdges")
        .attr('stroke', '#000')
        .attr('stroke-width', underlineStroke)
        .attr('opacity', 1)
        .on 'click', => @onClickLeftXAxisInput()

    text = textContainer.append('text')
        .attr('class', 'g-axis-limit-text')
        .attr('fill', '#000')
        .attr('y', @height + @MARGIN.top + offsetTop)
        .attr('dy', '0.71em')
        .style('font-weight', 'bold')
        # .style('text-decoration', 'underline')
        .on 'click', => @onClickLeftXAxisInput()

    inputContainer = textContainer.append('foreignObject')
        .attr('width', conWidth)
        .attr('height', conHeight)
        .attr('y', @height + @MARGIN.top + offsetTop - 4)
        .attr('x', @MARGIN.left + @EXTREME_PADDING)
        .on 'click', => @onClickLeftXAxisInput()

    form = inputContainer.append('xhtml:form')
        .style('margin', 0)
        .style('padding', 0)
        .on 'click', => @onClickLeftXAxisInput()

    input = form.append('xhtml:input').attr('type', 'text')
      .attr('class', 'g-axis-limit-text')
      .style('display', 'block')
      .style('opacity', 0)
      .style('width', conWidth + 'px')
      .style('height', conHeight + 'px')
      .style('padding', 0)
      .style('margin', 0)
      .style('text-align', 'center')
      .style('font-weight', 'bold')
      # .style('text-decoration', 'underline')
      .attr('type', 'text')
      .on('mouseout', ->
        line.attr('opacity', 1)
      )
      .on('click', =>
        @onClickLeftXAxisInput()
      )
      .on('focusout', =>
        input.style('opacity', 0)
        text.attr('opacity', 1)
        #@xAxisLeftExtremeValue.focused = false
        @updateAxesExtremeValues()
      )
      .on('keydown', =>
        if d3.event.keyCode is 39
          @validateArrowInput('x:min', input.node(), input.node().value.trim())
        if d3.event.keyCode is 13 and typeof @onEnterAxisInput is 'function'
          @onEnterAxisInput('x:min', input.node(), input.node().value.trim())
          d3.event.preventDefault()
        if d3.event.keyCode is 8
          @validateBackSpace('x:min', input.node())
      )
      .on('keyup', =>
        if d3.event.keyCode isnt 13 and typeof @onAxisInputBaseFunc is 'function'
          @onAxisInputBaseFunc('x:min', input.node(), input.node().value.trim())
      )

    @xAxisLeftExtremeValue =
      rect: rect
      text: text
      line: line
      inputContainer: inputContainer
      form: form
      input: input
      config:
        offsetTop: offsetTop
        underlineStroke: underlineStroke
        conHeight: conHeight

  onClickLeftXAxisInput: ->
    #return if @xAxisLeftExtremeValue.focused
    #@xAxisLeftExtremeValue.focused = true
    @xAxisLeftExtremeValue.text.attr('opacity', 0)

    if typeof @onClickAxisInput is 'function'
      @onClickAxisInput('x:min', @xAxisLeftExtremeValue)

  validateBackSpace: (loc, input) ->
    axis = if loc is 'y:min' or loc is 'y:max' then 'y' else 'x'
    value = input.value
    selection = input.selectionStart
    unit = @config.axes[axis].unit || ''
    if selection > value.length - unit.length
      d3.event.preventDefault()
      return true
    else
      return false

  validateArrowInput: (loc, input, val) ->
    axis = if loc is 'y:min' or loc is 'y:max' then 'y' else 'x'
    unit = @config.axes[axis].unit or ''
    caret = input.selectionStart + 1
    if val.length - unit.length < caret
      d3.event.preventDefault()

  cleanAxisInput: (loc, input, val) ->
    axis = if loc is 'x:min' or loc is 'x:max' then 'x' else 'y'
    val = val.replace(/[^0-9\.\-]/g, '')
    val = val.replace(@config.axes[axis].unit, '')
    if val is ''
      if loc is 'x:min'
        val = @getMinX()
      if loc is 'x:max'
        val = @getMaxX()
      if loc is 'y:min'
        val = @computedMinY()
      if loc is 'y:max'
        val = @computedMaxY()
    return +val

  onEnterAxisInput: (loc, input, val) ->
    #axis = if loc is 'x:min' or loc is 'x:max' then 'x' else 'y'
    val = @cleanAxisInput(loc, input, val)
    
    if loc is 'y:max'
      max = @computedMaxY()
      maxY = if angular.isNumber(val) and !window.isNaN(val) then val else max
      y = @yScale
      lastYScale = @lastYScale || y
      minY = lastYScale.invert(@height)

      if minY >= maxY
        return false

      maxY = if maxY > max then max else maxY
      k = @height / (y(minY) - y(maxY))

      @editingYAxis = true
      lastK = @getTransform().k
      @chartSVG.call(@zooomBehavior.transform, d3.zoomIdentity.scale(k).translate(0, -y(maxY)))
      @editingYAxis = false
      @chartSVG.call(@zooomBehavior.transform, d3.zoomIdentity.scale(lastK))

    if loc is 'y:min'
      y = @yScale
      lastYScale = @lastYScale || y
      min = @computedMinY()

      minY = if angular.isNumber(val) and !window.isNaN(val) then val else min
      maxY = lastYScale.invert(0)
      if (minY >= maxY)
        return false

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
        maxX = @getMaxX()
      if (maxX > @getScaleExtent())
        maxX = @getScaleExtent()
      k = @width / (x(maxX) - x(minX))
      width_percent = 1 / k
      w = extent - (width_percent * extent)
      @chartSVG.call(@zooomBehavior.scaleTo, k)
      @scroll((minX - @getMinX()) / w)

    # update input state
    extremeValue = null
    
    if loc is 'x:min'
      extremeValue =  @xAxisLeftExtremeValue
    else if loc is 'x:max'
      extremeValue =  @xAxisRightExtremeValue
    else if loc is 'y:min'
      extremeValue = @yAxisLowerExtremeValue
    else
      extremeValue = @yAxisUpperExtremeValue

    @onClickAxisInput(loc, extremeValue)
    setTimeout =>
      input.blur()
    , 100
    
  drawXAxisRightExtremeValue: ->
    textContainer = @chartSVG.append('g')
        .attr('class', 'axes-extreme-value tick')

    @xAxisLeftExtremeValueContainer = textContainer

    conWidth = 30
    conHeight = 12
    offsetTop = 8.5
    underlineStroke = 1
    lineWidth = 20

    rect = textContainer.append('rect')
        .attr('fill', '#fff')
        .attr('width', conWidth)
        .attr('height', conHeight)
        .attr('y', @height + @MARGIN.top + offsetTop)
        .attr('x', @MARGIN.left + @width - (conWidth / 2))
        .on 'click', => @onClickRightXAxisInput()

    line = textContainer.append('line')
        .attr("shape-rendering", "crispEdges")
        .attr('stroke', '#000')
        .attr('stroke-width', underlineStroke)
        .attr('opacity', 0)
        .on 'click', => @onClickRightXAxisInput()

    text = textContainer.append('text')
        .attr('class', 'g-axis-limit-text')
        .attr('fill', '#000')
        .attr('y', @height + @MARGIN.top + offsetTop)
        .attr('dy', '0.71em')
        .style('font-weight', 'bold')
        # .style('text-decoration', 'underline')
        .text(@getMaxX())
        .on 'click', => @onClickRightXAxisInput()

    inputContainer = textContainer.append('foreignObject')
        .attr('width', conWidth)
        .attr('height', conHeight)
        .attr('y', @height + @MARGIN.top + offsetTop - 4)
        .attr('x', @MARGIN.left + @width - (conWidth / 2))
        .on 'click', => @onClickRightXAxisInput()

    form = inputContainer.append('xhtml:form')
        .on 'click', => @onClickRightXAxisInput()

    input = form.append('xhtml:input').attr('type', 'text')
      .attr('class', 'g-axis-limit-text')
      .style('display', 'block')
      .style('opacity', '0')
      .style('width', conWidth + 'px')
      .style('height', conHeight + 'px')
      .style('padding', '0px')
      .style('margin', '0px')
      .style('text-align', 'center')
      .style('font-weight', 'bold')
      .style('text-decoration', 'underline')
      .attr('type', 'text')
      .on('mouseenter', =>
        lineWidth = text.node().getBBox().width
        line.attr('opacity', 1)
          .attr('x1', @MARGIN.left + @width - (lineWidth / 2))
          .attr('y1', @height + @MARGIN.top + offsetTop + conHeight - underlineStroke)
          .attr('x2', @MARGIN.left + @width - (lineWidth / 2) + lineWidth)
          .attr('y2', @height + @MARGIN.top + offsetTop + conHeight - underlineStroke)
      )
      .on('mouseout', =>
        line.attr('opacity', 1)
      )
      .on('click', =>
        @onClickRightXAxisInput()
      )
      .on('focusout', =>
        input.style('opacity', 0)
        text.attr('opacity', 1)
        #@xAxisRightExtremeValue.focused = false
        @updateAxesExtremeValues()
      )
      .on('keydown', =>
        if d3.event.keyCode is 39
          @validateArrowInput('x:max', input.node(), input.node().value)
        if d3.event.keyCode is 13 and typeof @onEnterAxisInput is 'function'
          @onEnterAxisInput('x:max', input.node(), input.node().value.trim())
          d3.event.preventDefault()
        if d3.event.keyCode is 8
          @validateBackSpace('x:max', input.node())
      )
      .on('keyup', =>
        if d3.event.keyCode isnt 13 and typeof @onAxisInputBaseFunc is 'function'
          @onAxisInputBaseFunc('x:max', input.node(), input.node().value.trim())
      )

    @xAxisRightExtremeValue =
      rect: rect
      text: text
      line: line
      inputContainer: inputContainer
      form: form
      input: input
      config:
        offsetTop: offsetTop
        underlineStroke: underlineStroke
        conHeight: conHeight

  onClickRightXAxisInput: ->
    #return if @xAxisRightExtremeValue.focused
    #@xAxisRightExtremeValue.focused = true
    @xAxisRightExtremeValue.text.attr 'opacity', 0
    
    if typeof @onClickAxisInput is 'function'
      @onClickAxisInput('x:max', @xAxisRightExtremeValue)

  drawYAxisUpperExtremeValue: ->
    textContainer = @chartSVG.append('g')
      .attr('class', 'axes-extreme-value tick')

    @yAxisUpperExtremeValueContainer = textContainer

    conWidth = 30
    conHeight = 12
    offsetRight = 9
    offsetTop = 2
    underlineStroke = 1
    lineWidth = 15
    inputContainerOffset = 5

    rect = textContainer.append('rect')
      .attr('fill', '#fff')
      .attr('width', conWidth)
      .attr('y', @MARGIN.top - ((conHeight) / 2))
      .attr('x', @MARGIN.left - (conWidth + offsetRight))
      .on 'click', => @onClickUpperYAxisInput()

    line = textContainer.append('line')
      .attr("shape-rendering", "crispEdges")
      .attr('opacity', 0)
      .attr('stroke', '#000')
      .attr('stroke-width', underlineStroke)
      .on 'click', => @onClickUpperYAxisInput()

    text = textContainer.append('text')
      .attr('class', 'g-axis-limit-text') 
      .attr('fill', '#000')
      .attr('x', @MARGIN.left - (offsetRight + conWidth))
      .attr('y', @MARGIN.top - underlineStroke * 2)
      .attr('dy', '0.71em')
      .style('font-weight', 'bold')
      # .style('text-decoration', 'underline')
      .text(@getMaxY())
      .on 'click', => @onClickUpperYAxisInput()

    text.attr('x', @MARGIN.left - (offsetRight + text.node().getBBox().width))

    inputContainer = textContainer.append('foreignObject')
      .attr('width', conWidth)
      .attr('height', conHeight - offsetTop)
      .attr('y', @MARGIN.top - (conHeight / 2))
      .attr('x', @MARGIN.left - (conWidth + offsetRight))
      .on 'click', => @onClickUpperYAxisInput()

    form = inputContainer.append('xhtml:form')
      .on 'click', => @onClickUpperYAxisInput()

    input = form.append('xhtml:input').attr('type', 'text')
      .attr('class', 'g-axis-limit-text')
      .style('display', 'block')
      .style('opacity', 0)
      .style('width', conWidth + 'px')
      .style('height', conHeight + 'px')
      .style('padding', '0px')
      .style('margin', '0px')
      .style('margin-top', '-1px')
      .style('text-align', 'center')
      .style('font-weight', 'bold')
      .style('text-decoration', 'underline')
      .attr('type', 'text')
      .on('mouseenter', =>
        textWidth = text.node().getBBox().width
        line.attr('x1', @MARGIN.left - (textWidth + offsetRight))
          .attr('y1', @MARGIN.top + conHeight - underlineStroke - offsetTop)
          .attr('x2', @MARGIN.left - (textWidth + offsetRight) + textWidth)
          .attr('y2', @MARGIN.top + conHeight - underlineStroke - offsetTop)
          .attr('opacity', 1)
      )
      .on('mouseout', ->
        line.attr('opacity', 1)
      )
      .on('click', =>
        @onClickUpperYAxisInput()
      )
      .on('focusout', =>
        input.style('opacity', 0)
        text.attr('opacity', 1)
        #@yAxisUpperExtremeValue.focused = false
        @updateAxesExtremeValues()
      )
      .on('keyup', =>
        if d3.event.keyCode isnt 13 and typeof @onAxisInputBaseFunc is 'function'
          @onAxisInputBaseFunc('y:max', input.node(), input.node().value.trim())
      )
      .on('keydown', =>
        if d3.event.keyCode is 39
          @validateArrowInput('y:max', input.node(), input.node(). value)
        if d3.event.keyCode is 13 and typeof @onEnterAxisInput is 'function'
          @onEnterAxisInput('y:max', input.node(), input.node().value.trim())
          d3.event.preventDefault()
        if d3.event.keyCode is 8
          @validateBackSpace('y:max', input.node())
      )

    @yAxisUpperExtremeValue =
      rect: rect
      text: text
      line: line
      inputContainer: inputContainer
      form: form
      input: input
      config:
        offsetTop: offsetTop
        offsetRight: offsetRight
        underlineStroke: underlineStroke
        conHeight: conHeight
        inputContainerOffset: inputContainerOffset

  onClickUpperYAxisInput: ->
    #return if @yAxisUpperExtremeValue.focused
    #@yAxisUpperExtremeValue.focused = true
    @yAxisUpperExtremeValue.text.attr('opacity', 0)

    if typeof @onClickAxisInput is 'function'
      @onClickAxisInput 'y:max', @yAxisUpperExtremeValue

  drawYAxisLowerExtremeValue: ->

    textContainer = @chartSVG.append('g')
      .attr('class', 'axes-extreme-value tick')

    @yAxisLowerExtremeValueContainer = textContainer
    @AXES_TICKS_FONT_SIZE = 8

    conWidth = 30
    conHeight = 14
    offsetRight = 9
    offsetTop = 0
    underlineStroke = 1
    lineWidth = 15

    rect = textContainer.append('rect')
      .attr('fill', '#fff')
      .attr('width', conWidth)
      .attr('height', @AXES_TICKS_FONT_SIZE + offsetTop)
      .attr('y', @height + @MARGIN.top - conHeight)
      .attr('x', @MARGIN.left - (conWidth + offsetRight))
      .on 'click', => @onClickLowerYAxisInput()

    line = textContainer.append('line')
      .attr("shape-rendering", "crispEdges")
      .attr('opacity', 0)
      .attr('stroke', '#000')
      .attr('stroke-width', underlineStroke)
      .on 'click', => @onClickLowerYAxisInput()

    text = textContainer.append('text')
      .attr('class', 'g-axis-limit-text')
      .attr('fill', '#000')
      .attr('x', @MARGIN.left - (offsetRight + conWidth))
      .attr('y', @height + @MARGIN.top - @EXTREME_PADDING - conHeight)
      .attr('dy', '0.71em')
      # .attr('font-size', "#{@AXES_TICKS_FONT_SIZE}px")
      # .attr('font-family', 'dinot-regular')
      .style('font-weight', 'bold')
      # .style('text-decoration', 'underline')
      .text(@getMaxY())
      .on 'click', => @onClickLowerYAxisInput()

    text.attr('x', @MARGIN.left - (offsetRight + text.node().getBBox().width))

    inputContainer = textContainer.append('foreignObject')
      .attr('width', conWidth)
      .attr('x', @MARGIN.left - (conWidth + offsetRight))
      .attr('height', conHeight - offsetTop)
      .attr('y', @height + @MARGIN.top - conHeight - @EXTREME_PADDING)
      .on 'click', => @onClickLowerYAxisInput()

    form = inputContainer.append('xhtml:form')
      .style('margin', 0)
      .style('padding', 0)

    input = form.append('xhtml:input').attr('type', 'text')
      .attr('class', 'g-axis-limit-text')
      .style('display', 'block')
      .style('opacity', 0)
      .style('width', conWidth + 'px')
      .style('height', conHeight + 'px')
      .style('padding', 0)
      .style('margin', 0)
      .style('margin-top', '-1px')
      .style('text-align', 'center')
      # .style('font-size', "#{@AXES_TICKS_FONT_SIZE}px")
      # .style('font-family', 'dinot-regular')
      .style('font-weight', 'bold')
      .style('text-decoration', 'underline')
      .attr('type', 'text')
      .on('mouseout', ->
        line.attr('opacity', 1)
      )
      .on('click', =>
        @onClickLowerYAxisInput()
      )
      .on('focusout', =>
        input.style('opacity', 0)
        text.attr('opacity', 1)
        #@yAxisLowerExtremeValue.focused = false
        @updateAxesExtremeValues()
      )
      .on('keyup', =>
        if d3.event.keyCode isnt 13 and typeof @onAxisInputBaseFunc is 'function'
          @onAxisInputBaseFunc('y:min', input.node(), input.node().value.trim())
      )
      .on('keydown', =>
        if d3.event.keyCode is 39
          @validateArrowInput('y:min', input.node(), input.node().value)
        if d3.event.keyCode is 13 and typeof @onEnterAxisInput is 'function'
          @onEnterAxisInput('y:min', input.node(), input.node().value.trim())
          d3.event.preventDefault()
        if d3.event.keyCode is 8
          @validateBackSpace('y:min', input.node())
      )

    @yAxisLowerExtremeValue = 
      rect: rect
      text: text
      line: line
      inputContainer: inputContainer
      form: form
      input: input
      config:
        offsetTop: offsetTop
        offsetRight: offsetRight
        underlineStroke: underlineStroke
        conHeight: conHeight

  onClickLowerYAxisInput: ->
    #return if @yAxisLowerExtremeValue.focused
    #@yAxisLowerExtremeValue.focused = true
    @yAxisLowerExtremeValue.text.attr('opacity', 0)

    if typeof @onClickAxisInput is 'function'
      @onClickAxisInput 'y:min', @yAxisLowerExtremeValue

  updateAxesExtremeValues: ->
    xScale = @getXScale()
    yScale = @getYScale()
    minWidth = 10
    if @xAxisLeftExtremeValue.text
      line = @xAxisLeftExtremeValue.line
      text = @xAxisLeftExtremeValue.text
      rect = @xAxisLeftExtremeValue.rect
      minX = if @hasData() then Math.round(xScale.invert(0) * 10) / 10 else @DEFAULT_MIN_X
      text.text(@xAxisTickFormat(minX))
      textWidth = text.node().getBBox().width
      text.attr('x', @MARGIN.left + @EXTREME_PADDING)
      rect.attr('x', @MARGIN.left + @EXTREME_PADDING)
        .attr('width', textWidth)

      line.attr('opacity', 1)
        .attr('x1', @MARGIN.left + @EXTREME_PADDING)
        .attr('y1', @height + @MARGIN.top + @xAxisLeftExtremeValue.config.offsetTop + @xAxisLeftExtremeValue.config.conHeight - @xAxisLeftExtremeValue.config.underlineStroke)
        .attr('x2', @MARGIN.left + @EXTREME_PADDING + textWidth)
        .attr('y2', @height + @MARGIN.top + @xAxisLeftExtremeValue.config.offsetTop + @xAxisLeftExtremeValue.config.conHeight - @xAxisLeftExtremeValue.config.underlineStroke)

    if @xAxisRightExtremeValue.text
      maxX = if @hasData() then Math.round(xScale.invert(@width) * 10) / 10 else @DEFAULT_MAX_X
      @xAxisRightExtremeValue.text.text(@xAxisTickFormat(maxX))
      textWidth = @xAxisRightExtremeValue.text.node().getBBox().width
      @xAxisRightExtremeValue.text.attr('x', @width + @MARGIN.left - (textWidth / 2))
      @xAxisRightExtremeValue.rect.attr('x', @width + @MARGIN.left - (textWidth / 2))
        .attr('width', textWidth)

      line = @xAxisRightExtremeValue.line
      text = @xAxisRightExtremeValue.text
      textWidth = text.node().getBBox().width
      line.attr('opacity', 1)
        .attr('x1', @MARGIN.left + @width - (textWidth / 2))
        .attr('y1', @height + @MARGIN.top + @xAxisRightExtremeValue.config.offsetTop + @xAxisRightExtremeValue.config.conHeight - @xAxisRightExtremeValue.config.underlineStroke)
        .attr('x2', @MARGIN.left + @width + (textWidth / 2))
        .attr('y2', @height + @MARGIN.top + @xAxisRightExtremeValue.config.offsetTop + @xAxisRightExtremeValue.config.conHeight - @xAxisRightExtremeValue.config.underlineStroke)

    if @yAxisUpperExtremeValue.text
      text = @yAxisUpperExtremeValue.text
      rect = @yAxisUpperExtremeValue.rect
      maxY = if @hasData() then Math.round(yScale.invert(0) * 10) / 10 else @DEFAULT_MAX_Y
      text.text(@yAxisTickFormat(maxY))
      textWidth = text.node().getBBox().width
      text.attr('x', @MARGIN.left - (@yAxisUpperExtremeValue.config.offsetRight + textWidth))
      rect.attr('x', @MARGIN.left - (@yAxisUpperExtremeValue.config.offsetRight + textWidth))
        .attr('width', textWidth)

      line = @yAxisUpperExtremeValue.line
      textWidth = text.node().getBBox().width
      line.attr('x1', @MARGIN.left - (textWidth + @yAxisUpperExtremeValue.config.offsetRight))
        .attr('y1', @MARGIN.top + @yAxisUpperExtremeValue.config.conHeight - @yAxisUpperExtremeValue.config.underlineStroke - @yAxisUpperExtremeValue.config.offsetTop)
        .attr('x2', @MARGIN.left - (textWidth + @yAxisUpperExtremeValue.config.offsetRight) + textWidth)
        .attr('y2', @MARGIN.top + @yAxisUpperExtremeValue.config.conHeight - @yAxisUpperExtremeValue.config.underlineStroke - @yAxisUpperExtremeValue.config.offsetTop)
        .attr('opacity', 1)

    if @yAxisLowerExtremeValue.text
      line = @yAxisLowerExtremeValue.line
      rect = @yAxisLowerExtremeValue.rect
      text = @yAxisLowerExtremeValue.text
      minY = if @hasData() then Math.round(yScale.invert(@height) * 10) / 10 else @DEFAULT_MIN_Y
      text.text(@yAxisTickFormat(minY))
      textWidth = text.node().getBBox().width
      text.attr('x', @MARGIN.left - (@yAxisLowerExtremeValue.config.offsetRight + textWidth))
      rect.attr('x', @MARGIN.left - (@yAxisLowerExtremeValue.config.offsetRight + textWidth))
        .attr('width', textWidth)

      line.attr('x1', @MARGIN.left - (textWidth + @yAxisLowerExtremeValue.config.offsetRight))
        .attr('y1', @height + @MARGIN.top - @EXTREME_PADDING * 1.5)
        .attr('x2', @MARGIN.left - (textWidth + @yAxisLowerExtremeValue.config.offsetRight) + textWidth)
        .attr('y2', @height + @MARGIN.top - @EXTREME_PADDING * 1.5)
        .attr('opacity', 1)

    @hideLastAxesTicks()

  updateBottomXYLabel: ->
    # divRoot = document.getElementById('label-graph-xy')
    # svgElement = divRoot.append('svg')
    # gElement = svgElement.append('g')
    #     .attr('stroke-width', 0)
    #     .attr('fill', '#fff')
    # crossLine = gElement.append('line')
    #     .attr('x1', 100)
    #     .attr('y1', 0)
    #     .attr('x2', 0)
    #     .attr('y2', 100)

    

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
      x = this.transform.baseVal.consolidate().matrix.e
      textWidth = xAxisLeftExtremeValueText.node().getBBox().width
      if x < textWidth + spacingX or x >  width - (textWidth + spacingX)
        d3.select(this).attr('opacity', 0)
      d3.select(this).select('line').attr('opacity', 0)

    # y ticks
    ticks = @chartSVG.selectAll('g.axis.y-axis > g.tick')
    num_ticks = ticks.size()
    height = @height

    ticks.each (d, i) ->
      y = this.transform.baseVal.consolidate().matrix.f
      textHeight = yAxisLowerExtremeValueText.node().getBBox().height
      if y >  height - textHeight - spacingY - 20 or y < textHeight + spacingY
        d3.select(this).attr('opacity', 0)
      d3.select(this).select('line').attr('opacity', 0)

    @chartSVG.selectAll('g.axis.x-axis > path.domain').attr('opacity', 0)
    @chartSVG.selectAll('g.axis.y-axis > path.domain').attr('opacity', 0)

  initChart: ->

    d3.select(@elem).selectAll("*").remove()
    @width = @elem.parentElement.offsetWidth - @MARGIN.left - @MARGIN.right
    @height = @elem.parentElement.offsetHeight - @MARGIN.top - @MARGIN.bottom

    @zooomBehavior = d3.zoom()
      .on 'start', => @isZooming = true
      .on 'end', => @isZooming = false
      .on 'zoom', => @zoomed()

    @chartSVG = d3.select(@elem).append("svg")
        .attr("width", @width + @MARGIN.left + @MARGIN.right)
        .attr("height", @height + @MARGIN.top + @MARGIN.bottom)
        .call(@zooomBehavior)

    svg = @chartSVG.append("g")
        .attr("transform", "translate(" + @MARGIN.left + "," + @MARGIN.top + ")")
        .attr('class', 'chart-g')

    @viewSVG = svg.append('svg')
        .attr('width', @width)
        .attr('height', @height)
        .append('g')
        .attr('width', @width)
        .attr('height', @height)
        .attr('class', 'viewSVG')

    @setMouseOverlay()
    @setYAxis()
    @setXAxis()
    @drawLines()
    @makeCircle()
    @updateZoomScaleExtent()
    @drawAxesExtremeValues()

  setMouseOverlay: ->
    @mouseOverlay = @viewSVG.append('rect')
        .attr('width', @width)
        .attr('height', @height)
        .attr('fill', 'transparent')
        .on('mousemove', => @mouseMoveCb())
        .on('mouseenter', => @showMouseIndicators())
        .on('mouseout', => 
          @hideMouseIndicators()
          @mouseMoveCb(false)
        )
        .on 'click', =>
          @unsetActivePath()
          if @hoveredLine
            mouse = @getMousePosition(@mouseOverlay.node())
            @setActivePath(@hoveredLine, mouse)

  getPathPositionByX: (path, x) ->
    return if not path
    pathEl = path.node()
    pathLength = pathEl.getTotalLength()
    beginning = x
    end = pathLength
    target = null
    pos = null

    while true
      target = Math.floor(((beginning + end) / 2) * 100) / 100
      target = if window.isFinite(target) then target else 1
      pos = pathEl.getPointAtLength(target)
      if ((target is end || target is beginning) and pos.x isnt x)
        break
      if (pos.x > x)
        end = target
      else if (pos.x < x)
        beginning = target
      else
        break # position found

    return { x: x, y: pos.y }

  mouseMoveCb: (isHover = true)->

      if isHover
        @setHoveredLine()
      else
        if @hoveredLine
          @hoveredLine.attr('stroke-width', @NORMAL_PATH_STROKE_WIDTH)
          @hoveredLine = null

      if !@activePath
        @hideMouseIndicators()
        return
      x = @getMousePosition(@mouseOverlay.node())[0]
      pos = @getPathPositionByX(@guidingLines[@activePathConfig.index], x)
      max_x = ((@getMaxX() - @getMinX()) / (@config.axes.x.max - @getMinX())) * @width

      if x > max_x
        @hideMouseIndicators()
      else
        if window.isFinite(x)
          @circle
            .attr("cx", x)
        else
          @hideMouseIndicators()
        @circle
          .attr("cy", pos.y)
          .attr('transform', 'translate(0,0) scale(1)')

        @setBoxRFYAndCycleTexts(x)
        @showMouseIndicators()

      @prevMousePosition = [pos.x, pos.y]

  setHoveredLine: ->
    mouse = @getMousePosition(@mouseOverlay.node())
    mouseX = mouse[0]
    mouseY = mouse[1]
    closestLineIndex
    distances = []
    lineIndex = null
    maxDistance = 20 * @zoomTransform.k

    for l, lineIndex in @lines by 1
      pos = @getPathPositionByX(@lines[lineIndex], mouseX)
      distance = Math.abs(pos.y - mouseY)
      distances.push(distance)

      if closestLineIndex is undefined
        closestLineIndex = lineIndex
      if distance < distances[closestLineIndex]
        closestLineIndex = lineIndex
      if distances[closestLineIndex] > maxDistance
        closestLineIndex = undefined
        @hoveredLine = null
      if @prevClosestLineIndex isnt closestLineIndex
        if @prevClosestLineIndex isnt undefined and @lines[@prevClosestLineIndex]
          @lines.forEach (line) =>
            if line isnt @activePath and line isnt @hoveredLine and !@hovering
              line.attr('stroke-width', @NORMAL_PATH_STROKE_WIDTH)
          if !@hovering and @hoveredLine
            @hoveredLine.attr('stroke-width', @NORMAL_PATH_STROKE_WIDTH)
            @hoveredLine = null
        if (closestLineIndex isnt undefined) and !@hovering and (@lines[closestLineIndex] isnt @activePath)
          @lines[closestLineIndex].attr('stroke-width', @HOVERED_PATH_STROKE_WIDTH)
          @hoveredLine = @lines[closestLineIndex]
        @prevClosestLineIndex = closestLineIndex

  _getTransformXFromScroll: (scroll) ->
    scroll = if scroll < 0 then 0 else (if scroll > 1 then 1 else scroll)
    transform = @getTransform()
    new_width = @width * transform.k
    transform_x = -((new_width - @width) * scroll)
    return transform_x

  scroll: (s) -> # s = {0..1}
    transform = @getTransform()
    transform_x = @_getTransformXFromScroll(s)
    new_transform = d3.zoomIdentity.translate(transform_x, transform.y).scale(transform.k)
    @chartSVG.call(@zooomBehavior.transform, new_transform)


  onZoomAndPan: (fn) ->
    # fn will receive (transform, width, height)
    @onZoomAndPan = fn

  onSelectLine: (fn) ->
    @onSelectLine = fn

  onUnselectLine: (fn) ->
    @onUnselectLine = fn

  onUpdateProperties: (fn) ->
    @onUpdateProperties = fn

  getDimensions: ->
    width: @width
    height: @height

  getTransform: ->
    return if not @chartSVG
    d3.zoomTransform(@chartSVG.node())

  reset: -> @chartSVG.call(@zooomBehavior.transform, d3.zoomIdentity)

  zoomTo: (zoom_percent) -> # zoom_percent = {0..1}
    zoom_percent = zoom_percent || 0
    zoom_percent = if zoom_percent < 0 then 0 else ( if zoom_percent > 1 then 1 else zoom_percent)
    k = ((@getScaleExtent() - @getMinX()) * zoom_percent) + 1
    @chartSVG.call(@zooomBehavior.scaleTo, k)

  updateSeries: (series) ->
    @config.series = series
    @updateAxesExtremeValues()

  updateData: (data) ->
    @data = data
    @updateZoomScaleExtent()
    setTimeout =>
      @updateAxesExtremeValues()
    , 500

  updateConfig: (config) ->
    @config = config
    setTimeout =>
      @updateAxesExtremeValues()
    , 500

  empty: -> d3.select(@elem).selectAll('*').remove()

  resize: -> @initChart()


window.ChaiBioCharts = window.ChaiBioCharts || {}
window.ChaiBioCharts.BaseChart = BaseChart
