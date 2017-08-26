class BaseChart

  NORMAL_PATH_STROKE_WIDTH: 2
  HOVERED_PATH_STROKE_WIDTH: 3
  ACTIVE_PATH_STROKE_WIDTH: 5
  CIRCLE_STROKE_WIDTH: 2
  CIRCLE_RADIUS: 7
  AXIS_LABEL_FONT_SIZE: 10
  zoomTransform: {x: 0, y: 0, k: 1}
  isZooming: false

  constructor: (@elem, @data, @config) ->
    @initChart()

  hasData: ->
    return false if !@data
    return false if !@data.dataset
    return false if @data.dataset.length is 0
    return true

  formatPower: (d) ->
    superscript = "⁰¹²³⁴⁵⁶⁷⁸⁹"
    (d + "").split("").map((c) -> superscript[c]).join("")

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
    @drawBox(lineConfig)

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
        .attr('transform', 'translate(' + (boxMargin.left + @config.margin.left) + ',' + (boxMargin.top + @config.margin.top) + ')')
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
        .text('RFU')

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
        .text('Cycle')

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

    if @box and @activePath
      conf = @activePathConfig
      @box.RFYTextValue.text(d[@config.series[conf.index].y]) if @box.RFYTextValue
      @box.cycleTextValue.text(d[@config.series[conf.index].x]) if @box.cycleTextValue
      if @box.CqText and @activePathConfig.config.cq
        conf = @activePathConfig.config
        cqText = 'Cq: ' + (conf.cq[conf.channel - 1] || '')
        @box.CqText.text(cqText)

  getDrawLineXScale: ->
      xScale = if @zoomTransform.k > 1 and !@editingYAxis then @lastXScale else @xScale
      return xScale || @xScale

  getDrawLineYScale: ->
      yScale = @lastYScale || @yScale
      if (@editingYAxis)
        return yScale
      if (yScale.invert(0) < @getMaxY() || yScale.invert(@height) > @getMinY())
        return yScale
      return @yScale

  makeGuidingLine: (line_config) ->
    xScale = @getDrawLineXScale()
    yScale = @getDrawLineYScale()
    line = d3.line()
    if @config.axes.y.scale is 'log'
      line.curve(d3.curveMonotoneX)
    else
      line.curve(d3.curveBasis)
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
    xScale = @getDrawLineXScale()
    yScale = @getDrawLineYScale()
    line = d3.line()
    if @config.axes.y.scale is 'log'
      line.curve(d3.curveMonotoneX)
    else
      line.curve(d3.curveBasis)
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

  makeWhiteBorderLine: (line_config) ->
    xScale = @getDrawLineXScale()
    yScale = @getDrawLineYScale()
    line = d3.line()
    if @whiteBorderLine then @whiteBorderLine.remove()
    if @config.axes.y.scale is 'log'
      line.curve(d3.curveMonotoneX)
    else
      line.curve(d3.curveBasis)
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
      @guidingLines.push(@makeGuidingLine(s))
    for s in series by 1
      @lines.push(@makeColoredLine(s))

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
        .attr('transform', 'translate (50,50)')
        .on('mouseout', => @hideMouseIndicators())
        .on('mousemove', => @mouseMoveCb())
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

    @updateXAxisExtremeValues()

    if (@onZoomAndPan and !@editingYAxis)
      @onZoomAndPan(@zoomTransform, @width, @height, @getScaleExtent() - @getMinX() )

    @drawLines()

  getMinX: ->
    min = d3.min @config.series, (s) =>
      d3.min @data[s.dataset], (d) => d[s.x]
    return min || 0

  getMaxX: ->
      max = d3.max @config.series, (s) =>
        d3.max @data[s.dataset], (d) => d[s.x]
      return max || 1

  getMinY: ->
    return @config.axes.y.min if @config.axes.y.min
    min_y = d3.min @config.series, (s) =>
      d3.min @data[s.dataset], (d) => d[s.y]
    return min_y || 0

  getMaxY: ->
    return @config.axes.y.max if @config.axes.y.max
    max_y = d3.max @config.series, (s) =>
        d3.max @data[s.dataset], (d) => d[s.y]
    return max_y || 1

  getScaleExtent: ->
    return @config.axes.x.max || @getMaxX()

  getYLogticks: ->
    num = @getMaxY()
    num = num + num * 0.2
    num_length = num.toString().length
    roundup = '1'
    for i in [0...num_length] by 1
      roundup = roundup + "0"
    roundup = roundup * 1
    calibs = []
    calib = 10
    while calib <= roundup
      calibs.push(calib)
      calib = calib * 10

    return calibs

  setYAxis: ->
    @chartSVG.selectAll('g.axis.y-axis').remove()
    @chartSVG.selectAll('.g-y-axis-text').remove()
    svg = @chartSVG.select('.chart-g')

    # add allowance for interpolation curves
    max = @getMaxY()
    min = @getMinY()
    diff = max - min
    allowance = diff * (if @config.axes.y.scale is 'log' then 0.2 else 0.05)
    max += allowance
    min = if @config.axes.y.scale is 'log' then 5 else min - allowance
    @yScale = if @config.axes.y.scale is 'log' then d3.scaleLog() else d3.scaleLinear()
    @yScale.range([@height, 0]).domain([min, max])
    @yAxis = d3.axisLeft(@yScale)
    @yAxis.tickFormat(@config.axes.y.tickFormat) if @config.axes.y.tickFormat
    if @config.axes.y.scale is 'log'
      @yAxis
        .tickValues(@getYLogticks())
        .tickFormat (d) => '10' + @formatPower(Math.round(Math.log(d) / Math.LN10))

    @gY = svg.append("g")
        .attr("class", "axis y-axis")
        .attr('fill', 'none')
        .call(@yAxis)
        .on('mouseenter', => @hideMouseIndicators())

    if @zoomTransform.rescaleY
      @gY.call(@yAxis.scale(@zoomTransform.rescaleY(@yScale)))
    #text label for the y axis
    @setYAxisLabel()

  setYAxisLabel: ->
    return if not @config.axes.y.label
    svg = @chartSVG.select('.chart-g')
    @yAxisLabel = svg.append("text")
      .attr("class", "g-y-axis-text")
      .attr("transform", "rotate(-90)")
      .attr("y", 0 - @config.margin.left)
      .attr("x", 0 - (@height / 2))
      .attr("dy", "1em")
      .attr("font-family", "dinot-bold")
      .attr("font-size", "#{@AXIS_LABEL_FONT_SIZE}px")
      .attr("fill", "#333")
      .style("text-anchor", "middle")
      .text(@config.axes.y.label)


  setXAxis: ->
    @chartSVG.selectAll('g.axis.x-axis').remove()
    @chartSVG.selectAll('.g-x-axis-text').remove()
    svg = @chartSVG.select('.chart-g')
    @xScale = d3.scaleLinear().range([0, @width])

    min = @config.axes.x.min || @getMinX() || 0
    max = @config.axes.x.max || @getMaxX() || 1
    @xScale.domain([min, max])

    @xAxis = d3.axisBottom(@xScale)
    @xAxis.tickFormat(@config.axes.x.tickFormat) if @config.axes.x.tickFormat
    @gX = svg.append("g")
        .attr("class", "axis x-axis")
        .attr('fill', 'none')
        .attr("transform", "translate(0," + (@height) + ")")
        .call(@xAxis)
    if @zoomTransform.rescaleX
      @gX.call(@xAxis.scale(@zoomTransform.rescaleX(@xScale)))

    # text label for the x axis
    @setXAxisLabel()

  setXAxisLabel: ->
    return if not (@config.axes.x.label)
    svg = @chartSVG.select('.chart-g')
    @xAxisLabel = svg.append("text")
      .attr('class', 'g-x-axis-text')
      .attr("transform",
        "translate(" + (@width / 2) + " ," +
        (@height + @config.margin.top + @config.margin.bottom - 20) + ")")
      .style("text-anchor", "middle")
      .attr("font-family", "dinot-bold")
      .attr("font-size", "#{@AXIS_LABEL_FONT_SIZE}px")
      .attr("fill", "#333")
      .text(@config.axes.x.label)

  updateZoomScaleExtent: ->
    return if !@zooomBehavior
    @zooomBehavior.scaleExtent([1, @getScaleExtent()])

  ensureNumeric: ->
    charCode = d3.event.keyCode
    if charCode > 36 and charCode < 41
      # arrow keys
      return true
    if charCode is 189 || charCode is 187 || charCode is 109 || charCode is 107
      # +/- key
      return true
    if charCode >= 96 and charCode <= 105
      # numpad number keys
      return true
    if charCode > 31 and (charCode < 48 || charCode > 57)
      d3.event.preventDefault()
      return false
    return true

  drawAxesExtremeValues: ->
    @chartSVG.selectAll('.axes-extreme-value').remove()
    @drawXAxisLeftExtremeValue()
    @drawXAxisRightExtremeValue()
    @drawYAxisUpperExtremeValue()
    @drawYAxisLowerExtremeValue()
    @updateXAxisExtremeValues()

  drawXAxisLeftExtremeValue: ->
    textContainer = @chartSVG.append('g')
        .attr('class', 'axes-extreme-value tick')
    @xAxisLeftExtremeValueContainer = textContainer

    conWidth = 30
    conHeight = 14
    offsetTop = 8.5
    underlineStroke = 2
    lineWidth = 15

    rect = textContainer.append('rect')
        .attr('fill', '#fff')
        .attr('width', conWidth)
        .attr('height', conHeight)
        .attr('y', @height + @config.margin.top + offsetTop)
        .attr('x', @config.margin.left - (conWidth / 2))

    line = textContainer.append('line')
        .attr('stroke', '#000')
        .attr('stroke-width', underlineStroke)
        .attr('x1', @config.margin.left - (lineWidth / 2))
        .attr('y1', @height + @config.margin.top + offsetTop + conHeight - underlineStroke)
        .attr('x2', @config.margin.left - (lineWidth / 2) + lineWidth)
        .attr('y2', @height + @config.margin.top + offsetTop + conHeight - underlineStroke)
        .attr('opacity', 0)

    text = textContainer.append('text')
        .attr('fill', '#000')
        .attr('y', @height + @config.margin.top + offsetTop)
        .attr('dy', '0.71em')
        .attr('font-size', '10px')

    inputContainer = textContainer.append('foreignObject')
        .attr('width', conWidth)
        .attr('height', conHeight)
        .attr('y', @height + @config.margin.top + offsetTop)
        .attr('x', @config.margin.left - (conWidth / 2))

    form = inputContainer.append('xhtml:form')
    input = form.append('xhtml:input').attr('type', 'text')
      .style('display', 'block')
      .style('opacity', '0')
      .style('width', conWidth + 'px')
      .style('height', conHeight + 'px')
      .style('padding', '0px')
      .style('margin', '0px')
      .style('margin-top', '-4px')
      .style('text-align', 'center')
      .style('font-size', '10px')
      .attr('type', 'text')
      .on('mousemove', ->
        line.attr('opacity', 1)
      )
      .on('mouseout', ->
        line.attr('opacity', 0)
      )
      .on('click', =>
        xScale = @lastXScale || @xScale
        val = Math.round(xScale.invert(0) * 10) / 10
        input.style('opacity', 1)
        input.node().value = val
      )
      .on('focusout', ->
        input.style('opacity', 0)
      )
      .on('keydown', =>
        if d3.event.keyCode is 13
          # enter
          d3.event.preventDefault()
          extent = @getScaleExtent() - @getMinX()
          x = @xScale
          lastXScale = @lastXScale || x
          minX = input.node().value * 1
          maxX = lastXScale.invert(@width)
          if (minX >= maxX)
            return false
          if (minX < 1)
            minX = 1
          k = @width / (x(maxX) - x(minX))
          width_percent = 1 / k
          w = extent - (width_percent * extent)
          @chartSVG.call(@zooomBehavior.scaleTo, k)
          @scroll((minX - @getMinX()) / w)
        else
          @ensureNumeric()
      )

    @xAxisLeftExtremeValueText = text

  drawXAxisRightExtremeValue: ->
    textContainer = @chartSVG.append('g')
        .attr('class', 'axes-extreme-value tick')

    @xAxisLeftExtremeValueContainer = textContainer

    conWidth = 30
    conHeight = 14
    offsetTop = 8.5
    underlineStroke = 2
    lineWidth = 20

    rect = textContainer.append('rect')
        .attr('fill', '#fff')
        .attr('width', conWidth)
        .attr('height', conHeight)
        .attr('y', @height + @config.margin.top + offsetTop)
        .attr('x', @config.margin.left + @width - (conWidth / 2))

    line = textContainer.append('line')
        .attr('stroke', '#000')
        .attr('stroke-width', underlineStroke)
        .attr('x1', @config.margin.left + @width - (lineWidth / 2))
        .attr('y1', @height + @config.margin.top + offsetTop + conHeight - underlineStroke)
        .attr('x2', @config.margin.left + @width - (lineWidth / 2) + lineWidth)
        .attr('y2', @height + @config.margin.top + offsetTop + conHeight - underlineStroke)
        .attr('opacity', 0)

    text = textContainer.append('text')
        .attr('fill', '#000')
        .attr('y', @height + @config.margin.top + offsetTop)
        .attr('dy', '0.71em')
        .attr('font-size', '10px')
        .text(@getMaxX())

    inputContainer = textContainer.append('foreignObject')
        .attr('width', conWidth)
        .attr('height', conHeight)
        .attr('y', @height + @config.margin.top + offsetTop)
        .attr('x', @config.margin.left + @width - (conWidth / 2))

    form = inputContainer.append('xhtml:form')

    input = form.append('xhtml:input').attr('type', 'text')
      .style('display', 'block')
      .style('opacity', '0')
      .style('width', conWidth + 'px')
      .style('height', conHeight + 'px')
      .style('padding', '0px')
      .style('margin', '0px')
      .style('margin-top', '-4px')
      .style('text-align', 'center')
      .style('font-size', '10px')
      .attr('type', 'text')
      .on('mousemove', =>
        line.attr 'opacity', 1
      )
      .on('mouseout', ->
        line.attr 'opacity', 0
      )
      .on('click', =>
        xScale = @lastXScale || @xScale
        input.style('opacity', 1)
        input.node().value = Math.round(xScale.invert(@width) * 10) / 10
      )
      .on('focusout', ->
        input.style('opacity', 0)
      )
      .on('keydown', =>
        if d3.event.keyCode is 13
          # enter
          d3.event.preventDefault()
          extent = @getScaleExtent() - @getMinX()
          x = @xScale
          lastXScale = @lastXScale || x
          minX = lastXScale.invert(0)
          maxX = input.node().value * 1
          if (minX >= maxX)
            return false
          if (maxX > @getScaleExtent())
            maxX = @getScaleExtent()
          k = @width / (x(maxX) - x(minX))
          width_percent = 1 / k
          w = extent - (width_percent * extent)
          @chartSVG.call(@zooomBehavior.scaleTo, k)
          @scroll((minX - @getMinX()) / w)
        else
          @ensureNumeric()
      )

    @xAxisRightExtremeValueText = text

  drawYAxisUpperExtremeValue: ->
      textContainer = @chartSVG.append('g')
        .attr('class', 'axes-extreme-value tick')

      @yAxisUpperExtremeValueContainer = textContainer

      conWidth = 30
      conHeight = 14
      offsetRight = 9
      offsetTop = 2
      underlineStroke = 2
      lineWidth = 15

      rect = textContainer.append('rect')
        .attr('fill', '#fff')
        .attr('width', conWidth)
        .attr('height', conHeight)
        .attr('y', @config.margin.top - (conHeight / 2) + offsetTop)
        .attr('x', @config.margin.left - (conWidth + offsetRight))

      line = textContainer.append('line')
        .attr('opacity', 0)
        .attr('stroke', '#000')
        .attr('stroke-width', underlineStroke)
        .attr('x1', @config.margin.left - (conWidth + offsetRight))
        .attr('y1', @config.margin.top + (conHeight / 2) - (underlineStroke / 2))
        .attr('x2', @config.margin.left - (conWidth + offsetRight) + conWidth)
        .attr('y2', @config.margin.top + (conHeight / 2) - (underlineStroke / 2))

      text = textContainer.append('text')
        .attr('fill', '#000')
        .attr('x', @config.margin.left - (offsetRight + conWidth))
        .attr('y', @config.margin.top - underlineStroke * 2)
        .attr('dy', '0.71em')
        .attr('font-size', '10px')
        .text(@getMaxY())

      text.attr('x', @config.margin.left - (offsetRight + text.node().getBBox().width))

      inputContainer = textContainer.append('foreignObject')
        .attr('width', conWidth)
        .attr('height', conHeight - offsetTop)
        .attr('y', @config.margin.top - (conHeight / 2))
        .attr('x', @config.margin.left - (conWidth + offsetRight))

      form = inputContainer.append('xhtml:form')

      input = form.append('xhtml:input').attr('type', 'text')
        .style('display', 'block')
        .style('opacity', 0)
        .style('width', conWidth + 'px')
        .style('height', conHeight + 'px')
        .style('padding', '0px')
        .style('margin', '0px')
        .style('margin-top', '-1px')
        .style('text-align', 'center')
        .style('font-size', '10px')
        .attr('type', 'text')
        .on('mousemove', =>

          input.node().value = Math.round(@getDrawLineYScale().invert(0) * 10) / 10

          textWidth = text.node().getBBox().width
          line.attr('x1', @config.margin.left - (textWidth + offsetRight))
            .attr('y1', @config.margin.top + (conHeight / 2) - (underlineStroke / 2))
            .attr('x2', @config.margin.left - (textWidth + offsetRight) + textWidth)
            .attr('y2', @config.margin.top + (conHeight / 2) - (underlineStroke / 2))
            .attr('opacity', 1)

          inputContainerOffset = 5
          inputWidth = 40

          inputContainer
            .attr('width', inputWidth + inputContainerOffset)
            .attr('x', @config.margin.left - (inputWidth + offsetRight) - (inputContainerOffset / 2))
          input.style('width', (inputWidth + inputContainerOffset) + 'px')

          rect
            .attr('width', inputWidth)
            .attr('x', @config.margin.left - (inputWidth + offsetRight))
        )
        .on('mouseout', ->
          line.attr('opacity', 0)
        )
        .on('click', =>
          val = Math.round(@yScale.invert(0) * 10) / 10
          input.style('opacity', 1)
          input.node().value = val
        )
        .on('focusout', ->
          input.style('opacity', 0)
        )
        .on('keydown', =>
          if d3.event.keyCode is 13
            # // enter
            d3.event.preventDefault()
            extent = @getMaxY()
            y = @yScale
            lastYScale = @lastYScale || y
            minY = lastYScale.invert(@height)
            maxY = input.node().value * 1
            if minY >= maxY
              return false

            max = @getMaxY()
            min = @getMinY()
            diff = max - min
            allowance = diff * (if @config.axes.y.scale is 'log' then 0.2 else 0.05)
            max += allowance

            if maxY > max
              maxY = max

            k = @height / (y(minY) - y(maxY))

            @editingYAxis = true
            lastK = @getTransform().k
            @chartSVG.call(@zooomBehavior.transform, d3.zoomIdentity.scale(k).translate(0, -y(maxY)))
            @editingYAxis = false
            @chartSVG.call(@zooomBehavior.transform, d3.zoomIdentity.scale(lastK))
          else
            @ensureNumeric()
        )

      @yAxisUpperExtremeValueText = text

  drawYAxisLowerExtremeValue: ->

      textContainer = @chartSVG.append('g')
        .attr('class', 'axes-extreme-value tick')

      @yAxisLowerExtremeValueContainer = textContainer

      conWidth = 30
      conHeight = 14
      offsetRight = 9
      offsetTop = 2
      underlineStroke = 2
      lineWidth = 15

      rect = textContainer.append('rect')
        .attr('fill', '#fff')
        .attr('width', conWidth)
        .attr('height', conHeight)
        .attr('y', @height + @config.margin.top - (conHeight / 2) + offsetTop)
        .attr('x', @config.margin.left - (conWidth + offsetRight))

      line = textContainer.append('line')
        .attr('opacity', 0)
        .attr('stroke', '#000')
        .attr('stroke-width', underlineStroke)
        .attr('x1', @config.margin.left - (conWidth + offsetRight))
        .attr('y1', @height + @config.margin.top + (conHeight / 2) - (underlineStroke / 2))
        .attr('x2', @config.margin.left - (conWidth + offsetRight) + conWidth)
        .attr('y2', @height + @config.margin.top + (conHeight / 2) - (underlineStroke / 2))

      text = textContainer.append('text')
        .attr('fill', '#000')
        .attr('x', @config.margin.left - (offsetRight + conWidth))
        .attr('y', @height + @config.margin.top - underlineStroke * 2)
        .attr('dy', '0.71em')
        .attr('font-size', '10px')
        .text(@getMaxY())

      text.attr('x', @config.margin.left - (offsetRight + text.node().getBBox().width))

      inputContainer = textContainer.append('foreignObject')
        .attr('width', conWidth)
        .attr('height', conHeight - offsetTop)
        .attr('y', @height + @config.margin.top - (conHeight / 2))
        .attr('x', @config.margin.left - (conWidth + offsetRight))

      form = inputContainer.append('xhtml:form')

      input = form.append('xhtml:input').attr('type', 'text')
        .style('display', 'block')
        .style('opacity', 0)
        .style('width', conWidth + 'px')
        .style('height', conHeight + 'px')
        .style('padding', '0px')
        .style('margin', '0px')
        .style('margin-top', '-1px')
        .style('text-align', 'center')
        .style('font-size', '10px')
        .attr('type', 'text')
        .on('mousemove', =>

          input.node().value = Math.round(@getDrawLineYScale().invert(@height) * 10) / 10

          textWidth = text.node().getBBox().width
          line.attr('x1', @config.margin.left - (textWidth + offsetRight))
            .attr('y1', @height + @config.margin.top + (conHeight / 2) - (underlineStroke / 2))
            .attr('x2', @config.margin.left - (textWidth + offsetRight) + textWidth)
            .attr('y2', @height + @config.margin.top + (conHeight / 2) - (underlineStroke / 2))
            .attr('opacity', 1)

          inputContainerOffset = 5
          inputWidth = 40

          inputContainer
            .attr('width', inputWidth + inputContainerOffset)
            .attr('x', @config.margin.left - (inputWidth + offsetRight) - (inputContainerOffset / 2))
          input.style('width', (inputWidth + inputContainerOffset) + 'px')

          rect
            .attr('width', inputWidth)
            .attr('x', @config.margin.left - (inputWidth + offsetRight))
        )
        .on('mouseout', ->
          line.attr('opacity', 0)
        )
        .on('click', =>
          val = Math.round(@yScale.invert(@height) * 10) / 10
          input.style('opacity', 1)
          input.node().value = val
        )
        .on('focusout', ->
          input.style('opacity', 0)
        )
        .on('keydown', =>
          if d3.event.keyCode is 13
            # enter
            d3.event.preventDefault()
            extent = @getMaxY()
            y = @yScale
            lastYScale = @lastYScale || y
            minY = input.node().value * 1
            maxY = lastYScale.invert(0)
            if (minY >= maxY)
              return false

            max = @getMaxY()
            min = @getMinY()
            diff = max - min
            allowance = diff * (if @config.axes.y.scale is 'log' then 0.2 else 0.05)
            min = if @config.axes.y.scale is 'log' then 5 else min - allowance

            if (minY < min)
              minY = min

            k = @height / (y(minY) - y(maxY))
            lastK = @getTransform().k
            @editingYAxis = true
            @chartSVG.call(@zooomBehavior.transform, d3.zoomIdentity.scale(k).translate(0, -y(maxY)))
            @editingYAxis = false
            @chartSVG.call(@zooomBehavior.transform, d3.zoomIdentity.scale(lastK))
          else
            @ensureNumeric()
        )

      @yAxisLowerExtremeValueText = text
      @yAxisLowerExtremeValueText = text

    updateXAxisExtremeValues: ->
      xScale = @getDrawLineXScale()
      yScale = @getDrawLineYScale()
      minWidth = 10
      if @xAxisLeftExtremeValueText
        text = @xAxisLeftExtremeValueText
        minX = Math.round(xScale.invert(0) * 10) / 10
        if @config.axes.x.tickFormat
          minX = @config.axes.x.tickFormat(minX)
        text.text(minX)
        textWidth = text.node().getBBox().width
        text.attr('x', @config.margin.left - (textWidth / 2))
      if @xAxisLeftExtremeValueTextUnderline
        lineWidth = textWidth
        lineWidth = if lineWidth > minWidth then lineWidth else minWidth
        @xAxisLeftExtremeValueTextUnderline
          .attr('x1', @config.margin.left - (lineWidth / 2))
          .attr('x2', @config.margin.left - (lineWidth / 2) + lineWidth)
      if @xAxisRightExtremeValueText
        maxX = Math.round(xScale.invert(@width) * 10) / 10
        if @config.axes.x.tickFormat
          maxX = @config.axes.x.tickFormat(maxX)
        @xAxisRightExtremeValueText.text(maxX)
        textWidth = @xAxisRightExtremeValueText.node().getBBox().width
        @xAxisRightExtremeValueText.attr('x', @width + @config.margin.left - (textWidth / 2))
      if @xAxisRightExtremeValueTextUnderline
        lineWidth = textWidth
        lineWidth = if lineWidth > minWidth then lineWidth else minWidth
        @xAxisRightExtremeValueTextUnderline
          .attr('x1', @width + @config.margin.left - (lineWidth / 2))
          .attr('x2', @width + @config.margin.left - (lineWidth / 2) + lineWidth)
      offsetRight = 9
      if @yAxisUpperExtremeValueText
        text = @yAxisUpperExtremeValueText
        maxY = Math.round(yScale.invert(0) * 10) / 10
        if @config.axes.y.tickFormat
          maxY = @config.axes.y.tickFormat(maxY)
        text.text(maxY)
        textWidth = text.node().getBBox().width
        text.attr('x', @config.margin.left - (offsetRight + text.node().getBBox().width))
      if @yAxisLowerExtremeValueText
        text = @yAxisLowerExtremeValueText
        minY = Math.round(yScale.invert(@height) * 10) / 10
        if @config.axes.y.tickFormat
          minY = @config.axes.y.tickFormat(minY)
        text.text(minY)
        textWidth = text.node().getBBox().width
        text.attr('x', @config.margin.left - (offsetRight + text.node().getBBox().width))

  initChart: ->
    d3.select(@elem).selectAll("*").remove()

    @width = @elem.parentElement.offsetWidth - @config.margin.left - @config.margin.right
    @height = @elem.parentElement.offsetHeight - @config.margin.top - @config.margin.bottom

    @zooomBehavior = d3.zoom()
      .on 'start', => @isZooming = true
      .on 'end', => @isZooming = false
      .on 'zoom', => @zoomed.call(@)

    @chartSVG = d3.select(@elem).append("svg")
        .attr("width", @width + @config.margin.left + @config.margin.right)
        .attr("height", @height + @config.margin.top + @config.margin.bottom)
        .call(@zooomBehavior)

    svg = @chartSVG.append("g")
        .attr("transform", "translate(" + @config.margin.left + "," + @config.margin.top + ")")
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
    @drawLines(@config.series)
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
        .on('mouseout', => @hideMouseIndicators())
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

  mouseMoveCb: ->
      @setHoveredLine()
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
    lineIndex
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
          if (@lines[@prevClosestLineIndex] isnt @activePath) and (@lines[@prevClosestLineIndex] isnt @hoveredLine) and !@hovering
            @lines[@prevClosestLineIndex].attr('stroke-width', @NORMAL_PATH_STROKE_WIDTH)
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
    console.log('getScaleExtent', @getScaleExtent())
    console.log('getMinX', @getMinX())
    console.log('k', k)
    @chartSVG.call(@zooomBehavior.scaleTo, k)

  updateSeries: (series) ->
    @config.series = series
    @updateXAxisExtremeValues()

  updateData: (data) ->
    @data = data
    @updateZoomScaleExtent()

  updateConfig: (config) ->
    @config = config
    @updateXAxisExtremeValues()

  updateInterpolation: (i) ->
    @config.axes.y.scale = i

  empty: -> d3.select(@elem).selectAll('*').remove()

  resize: (@elem, @data, @config) -> @initChart()


window.ChaiBioCharts = window.ChaiBioCharts || {}
window.ChaiBioCharts.BaseChart = BaseChart