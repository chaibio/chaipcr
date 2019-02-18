class ThermalProfileChart extends window.ChaiBioCharts.BaseChart


  AXIS_LABEL_FONT_SIZE: 17
  DASHED_LINE_STROKE_WIDTH: 2

  DEFAULT_MAX_Y: 120
  DEFAULT_MIN_Y: 0
  DEFAULT_MAX_X: 60
  DEFAULT_MIN_X: 0
  MARGIN:
    top: 20
    left: 80
    right: 30
    bottom: 50


  getMinY: -> @DEFAULT_MIN_Y

  roundDownExtremeValue: (v) -> v

  roundUpExtremeValue: (v) -> v

  setXAxis: ->
    super
    @setXAxisCircle()

  setXAxisCircle: ->
    @xAxisCircle.remove() if @xAxisCircle
    @xAxisCircle = @chartSVG.append('circle')
      .attr('opacity', 0)
      .attr('r', @CIRCLE_RADIUS)
      .attr('fill', "#333")
      .attr('stroke', '#fff')
      .attr('stroke-width', @CIRCLE_STROKE_WIDTH)
      .attr('class', 'mouse-indicator-circle')

  setMouseMoveListener: (fn) ->
    @onMouseMove = fn

  drawLines: ->
    series = @config.series
    return if not series
    @lines = @lines || []
    @lines.forEach (line) ->
      line.remove()
    @lines = []

    series.forEach (line_config) =>
      @lines.push(@makeLine(line_config))

    @dashedLine = @makeDashedLine()
    @drawCircleTooltips()
    @setMouseOverlay()

  makeDashedLine: ->
    @dashedLine.remove() if @dashedLine
    @viewSVG
      .append("line")
      .attr("opacity", 0)
      .attr("y1", 0)
      .attr("y2", @height)
      .attr("stroke-dasharray", @DASHED_LINE_STROKE_WIDTH + ',' + @DASHED_LINE_STROKE_WIDTH)
      .attr("stroke-width", @DASHED_LINE_STROKE_WIDTH)
      .attr("stroke", "#333")
      .attr("fill", "none")

  makeLine: (line_config) ->
    xScale = @getXScale()
    yScale = @getYScale()
    line = d3.line()
      .curve(d3.curveCardinal)
      .x((d) ->
        return xScale(d[line_config.x])
      )
      .y((d) ->
        return yScale(d[line_config.y])
      )

    @viewSVG.append("path")
      .datum(@data[line_config.dataset])
      .attr("class", "line")
      .attr("stroke", line_config.color)
      .attr('fill', 'none')
      .attr('stroke-width', @NORMAL_PATH_STROKE_WIDTH)
      .attr("d", line)

  drawCircleTooltips: ->
    return if not @config.series
    @circles = @circles || []
    @circles.forEach (circle) ->
      circle.remove()
    @circles = []
    for config in @config.series by 1
      @circles.push(@makeCircleForLine(config))
    return

  makeCircleForLine: (line_config) ->
    @viewSVG.append('circle')
      .attr('opacity', 0)
      .attr('r', @CIRCLE_RADIUS)
      .attr('fill', line_config.color)
      .attr('stroke', '#fff')
      .attr('stroke-width', @CIRCLE_STROKE_WIDTH)
      .attr('class', 'mouse-indicator-circle')

  setMouseOverlay: ->
    @mouseOverlay.remove() if @mouseOverlay

    @mouseOverlay = @viewSVG.append('rect')
      .attr('width', @width)
      .attr('height', @height)
      .attr('fill', 'transparent')
      .on('mouseenter', =>
        if @hasData() and !@isZooming
          @toggleMouseIndicatorsVisibility(true)
      )
      .on('mouseout', =>
        @toggleMouseIndicatorsVisibility(false)
      )
      .on('mousemove', =>
        @followTheMouse()
      )

  toggleMouseIndicatorsVisibility: (show) ->
    opacity = if show then 1 else 0
    @dashedLine.attr('opacity', opacity) if @dashedLine
    @xAxisCircle.attr('opacity', opacity) if @xAxisCircle
    @circles.forEach (circle) ->
      circle.attr('opacity', opacity)


  followTheMouse: ->
    return if @isZooming or !@hasData()
    @toggleMouseIndicatorsVisibility(!@isZooming)
    x = d3.mouse(@mouseOverlay.node())[0]

    @lines.forEach (path, i) =>
      pathEl = path.node()
      pathLength = pathEl.getTotalLength()
      beginning = x
      end = pathLength
      target = null
      pos = null

      while true
        target = Math.floor(((beginning + end) / 2) * 100) / 100
        pos = pathEl.getPointAtLength(target)
        if ((target is end || target is beginning) && pos.x != x)
          break
        
        if pos.x > x
          end = target
        else if pos.x < x
          beginning = target
        else
          break # position found

      if @circles
        @circles[i]
          .attr("cx", x)
          .attr("cy", pos.y)

    opacity = if (@isZooming or !@hasData()) then 0 else 1

    if @dashedLine
      @dashedLine
        .attr("opacity", opacity)
        .attr('x1', x)
        .attr('x2', x)

    if @xAxisCircle
      xx = d3.mouse(@chartSVG.node())[0]
      @xAxisCircle
        .attr("opacity", opacity)
        .attr("cx", xx)
        .attr("cy", @height + @MARGIN.top)

    if (typeof @onMouseMove is 'function')
      line_config = @config.series[0]
      x0 = @getXScale().invert(x)
      i = @bisectX(line_config)(@data[line_config.dataset], x0, 1)
      d0 = @data[line_config.dataset][i - 1]

      return if not d0

      d1 = @data[line_config.dataset][i]
      d = if x0 - d0[line_config.x] > d1[line_config.x] - x0 then d1 else d0

      @onMouseMove(d)


  onEnterAxisInput: (loc, input, val) ->
    axis = if loc is 'x:min' or loc is 'x:max' then 'x' else 'y'
    if axis is 'y'
      super
    else
      val = @parseXAxisInput(val).toString()
      super

  onAxisInput: (loc, input, val) ->
    axis = if loc is 'x:min' or loc is 'x:max' then 'x' else 'y'
    if axis isnt 'x'
      super
  
  parseXAxisInput: (val) ->
    valArr = val.split(':')

    if valArr.length is 0
     if loc is 'x:min'
       return @getMinX()
     else
       return @getMaxX()

    valArr = valArr.reverse()

    if val.length is 2 and valArr.length is 1
      secs = 0
      mins = valArr[0] * 1
    else
      secs = valArr[0] * 1
      mins = valArr[1] * 1

    hours = if valArr[2] then valArr[2] * 1 else 0
    days = if valArr[3] then valArr[3] * 1 else 0

    total = secs + mins * 60 + hours * 60 * 60
    return total
    
  drawAxesExtremeValues: ->
    @chartSVG.selectAll('.axes-extreme-value').remove()

  updateAxesExtremeValues: ->
    xScale = @getXScale()
    yScale = @getYScale()
    minWidth = 10

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
    @updateAxesExtremeValues()

    if (@onZoomAndPan and !@editingYAxis)
      @onZoomAndPan(@zoomTransform, @width, @height, @getScaleExtent() - @getMinX() )

    @drawLines()

  setXAxisLabel: ->
    return if not (@config.axes.x.label)
    svg = @chartSVG.select('.chart-g')
    @xAxisLabel = svg.append("text")
      .attr('class', 'XH3M')
      .attr("transform",
        "translate(" + (@width / 2) + " ," +
        (@height + @MARGIN.top + @MARGIN.bottom - 30) + ")")
      .style("text-anchor", "middle")
      .attr("fill", "#333")
      .text(@config.axes.x.label)

  setYAxisLabel: ->
    return if not @config.axes.y.label
    svg = @chartSVG.select('.chart-g')
    @yAxisLabel = svg.append("text")
      .attr("class", "XH3M")
      .attr("transform", "rotate(-90)")
      .attr("y", 0 - @MARGIN.left + 10)
      .attr("x", 0 - (@height / 2))
      .attr("dy", "1em")
      .attr("fill", "#333")
      .style("text-anchor", "middle")
      .text(@config.axes.y.label)

window.ChaiBioCharts = window.ChaiBioCharts || {}
window.ChaiBioCharts.ThermalProfileChart = ThermalProfileChart
