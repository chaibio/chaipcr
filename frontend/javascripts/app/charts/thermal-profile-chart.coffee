class ThermalProfileChart extends window.ChaiBioCharts.BaseChart


  AXIS_LABEL_FONT_SIZE: 17
  DASHED_LINE_STROKE_WIDTH: 2

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
    xScale = @getDrawLineXScale()
    yScale = @getDrawLineYScale()
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
    @circles = @circles || [];
    @circles.forEach (circle) ->
      circle.remove()
    @circles = []
    for config in @config.series by 1
      @circles.push(@makeCircleForLine(config))

  makeCircleForLine: (line_config) ->
    console.log line_config
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
        @toggleCirclesVisibility(true)
      )
      .on('mouseout', =>
        @toggleCirclesVisibility(false)
      )
      .on('mousemove', => 
        @followTheMouse()
      )

  toggleCirclesVisibility: (show) ->
    opacity = if show then 1 else 0
    @dashedLine.attr('opacity', opacity) if @dashedLine
    @circles.forEach (circle) ->
      circle.attr('opacity', opacity)
    @xAxisCircle.attr('opacity', opacity) if @xAxisCircle


  followTheMouse: ->
    return if @isZooming or !@hasData()
    @toggleCirclesVisibility(true)
    x = d3.mouse(@mouseOverlay.node())[0]

    console.log @lines

    @lines.forEach (path, i) =>
      pathEl = path.node();
      pathLength = pathEl.getTotalLength();
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

    if @dashedLine
      @dashedLine
        .attr("opacity", 1)
        .attr('x1', x)
        .attr('x2', x)

    if @xAxisCircle
      x = d3.mouse(@chartSVG.node())[0];
      @xAxisCircle
        .attr("cx", x)
        .attr("cy", @height + @config.margin.top)

    if (typeof @onMouseMove is 'function')
      # get data point at point x
      x = @getMousePosition(@mouseOverlay.node())[0]

      line_config = @config.series[0]
      x0 = if @zoomTransform.k > 1 then @zoomTransform.rescaleX(@xScale).invert(x) else @xScale.invert(x)
      i = @bisectX(line_config)(@data[line_config.dataset], x0, 1)
      d0 = @data[line_config.dataset][i - 1]

      return if not d0

      d1 = @data[line_config.dataset][i]
      d = if x0 - d0[line_config.x] > d1[line_config.x] - x0 then d1 else d0

      @onMouseMove(d)

window.ChaiBioCharts = window.ChaiBioCharts || {}
window.ChaiBioCharts.ThermalProfileChart = ThermalProfileChart