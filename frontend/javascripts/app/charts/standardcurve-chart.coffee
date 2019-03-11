class StandardCurveChart extends window.ChaiBioCharts.BaseChart

  DEFAULT_MIN_Y: 0
  DEFAULT_MAX_Y: 20
  DEFAULT_MIN_X: 0
  DEFAULT_MAX_X: 1

  DEFAULT_PT_SMALL_SIZE: 3
  DEFAULT_PT_SMALL_HOVER_SIZE: 3.5
  DEFAULT_PT_SMALL_ACTIVE_SIZE: 4

  DEFAULT_PT_SIZE: 10
  DEFAULT_PT_HOVER_SIZE: 15
  DEFAULT_PT_ACTIVE_SIZE: 16

  NORMAL_LINE_STROKE_WIDTH: 1
  HOVERED_LINE_STROKE_WIDTH: 1.5
  THICK_LINE_STROKE_WIDTH: 0.8

  NORMAL_PLOT_STROKE_WIDTH: 0.7
  HOVERED_PLOT_STROKE_WIDTH: 1
  ACTIVED_PLOT_STROKE_WIDTH: 2

  DEFAULT_SCALE_EXTENT: 5
  INACTIVE_OPACITY: 0.4

  MARGIN:
    top: 20
    left: 60
    right: 20
    bottom: 60

  constructor: (@elem, @data, @config, @line_data) ->
    # console.log('@data')
    # console.log(@data)
    # setTimeout(@initChart, 100)
    @initChart()

  inK: ->
    @getMaxY() - @getMinY() > 20000

  getYUnit: -> if @inK() then 'k' else ''

  formatPower: (d) ->
    superscript = "⁰¹²³⁴⁵⁶⁷⁸⁹"
    (d + "").split("").map((c) -> superscript[c]).join("")

  getLineCurve: ->
    if @config.axes.y.scale is 'log' then d3.curveMonotoneX else d3.curveBasis

  getYExtremeValuesAllowance: ->
    max = @getMaxY()
    min = @getMinY()
    diff = max - min
    diff * 0.05

  hasData: ->
    return false if !@data
    if @data and @config
      if @config.series?.length > 0
        if (@data[@config.series[0].dataset]?.length)
          true
        else
          false
      else
        false
    else
      false

  computedMaxY: ->
    max = if angular.isNumber(@config.axes.y.max) and @hasData() then @config.axes.y.max else if @hasData() then @getMaxY() else @DEFAULT_MAX_Y
    if @config.axes.y.scale is 'linear'
      m = @roundUpExtremeValue( max + @getYExtremeValuesAllowance())
      return if @hasData() then m else max
    else
      ticks = @getYLogTicks(@getMinY(), @getMaxY())
      return ticks[ticks.length - 1]

  computedMinY: ->
    min = if angular.isNumber(@config.axes.y.min) and @hasData() then @config.axes.y.min else if @hasData() then @getMinY() else @DEFAULT_MIN_Y    
    if @config.axes.y.scale is 'linear'
      return if @hasData() then @roundDownExtremeValue(min - @getYExtremeValuesAllowance()) else min
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

  setYAxis: (showLabel = true) ->
    @chartSVG.selectAll('g.axis.y-axis').remove()
    @chartSVG.selectAll('.g-y-axis-text').remove()
    svg = @chartSVG.select('.chart-g')

    min = @computedMinY()
    max = @computedMaxY()

    @gapY = max - min

    @yScale = if @config.axes.y.scale is 'log' then d3.scaleLog() else d3.scaleLinear()

    if @config.axes.y.scale is 'log'
      ticks = @getYLogTicks(@getMinY(), @getMaxY())
      @yScale.range([@height, 0]).domain([ticks[0], ticks[ticks.length - 1]])
      @yAxis = d3.axisLeft(@yScale)
      @yAxis.tickValues(ticks)
    else
      if @hasData()
        @yScale.range([@height, 0]).domain([min - @gapY * 0.05, max + @gapY * 0.05])
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
    if showLabel
      @setYAxisLabel()
    @lastYScale = @yScale

  setXAxis: (showLabel = true)->
    @chartSVG.selectAll('g.axis.x-axis').remove()
    @chartSVG.selectAll('.g-x-axis-text').remove()
    svg = @chartSVG.select('.chart-g')
    @xScale = d3.scaleLinear().range([0, @width])

    min = if angular.isNumber(@config.axes.x.min) and @hasData() then @config.axes.x.min else if @hasData() then @getMinX() else @DEFAULT_MIN_X
    max = if angular.isNumber(@config.axes.x.max) and @hasData() then @config.axes.x.max else if @hasData() then @getMaxX() else @DEFAULT_MAX_X
    
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

  activePlotRow: (well_data) ->
    path = null
    plot_config = null
    for p, i in @plots by 1
      if p.well == well_data.well - 1 and p.channel == well_data.channel
        path = p.plot
        plot_config = p.config
        break

    @setActivePlot(path, plot_config)

  getTargetLineConfig: (path) ->
    activeLineConfig = null
    activeLineIndex = null

    for line, i in @target_lines by 1
      if line is path
        activeLineConfig = @line_data['target_line'][i]
        activeLineIndex = i
        break
    return {
      config: activeLineConfig,
      index: activeLineIndex,
    }

  setActiveTargetLine: (path, mouse) ->
    @activeTargetLine = path
    @activeTargetLine.attr('stroke-width', @NORMAL_LINE_STROKE_WIDTH)
    @activeTargetLineConfig = @getTargetLineConfig(path)

    if typeof @onUpdateProperties is 'function'
      @onUpdateProperties(@activeTargetLineConfig.config)

    @prevMousePosition = mouse
    @deprioritItem()
    @unselectPlot()

  unselectTargetLine: () ->
    if typeof @onUnselectLine is 'function'
      @onUnselectLine()
    @prioritItem()
    @unselectPlot()

  setActivePlot: (path, plot_config) ->
    line_index = -1
    activePlotIndex = -1
    for l, i in @line_data['target_line'] by 1
      if l.id is plot_config.target_id
        line_index = i
        break    

    @setActiveTargetLine(@target_lines[line_index], null)

    for plot, plot_index in @plots by 1
      if plot.well == plot_config.well and plot.channel == plot_config.channel
        _path = plot.plot
        _unknown_path = plot.unknown

        new_plot_path = @makeWhitePlot(plot.config)
        @activeWhitePlot = new_plot_path[0]
        @activeWhiteUnknownPlot = new_plot_path[1]

        new_plot_path = @makeColoredPlot(plot.config, 'active')
        @plots[plot_index].plot = new_plot_path[0]
        @plots[plot_index].unknown = new_plot_path[1]
        @activePlot = new_plot_path[0]
        @activeUnknownPlot = new_plot_path[1]

        _unknown_path.remove() if _unknown_path          
        _path.remove()
        
        activePlotIndex = plot_index
        break

    @activePlotConfig = {
      config: plot_config,
      plot_index: activePlotIndex
    }

    if typeof @onSelectPlot is 'function'
      @onSelectPlot(@activePlotConfig.config)

  prioritItem: () ->
    for l in @target_lines by 1
      l.attr('stroke-width', @NORMAL_LINE_STROKE_WIDTH)
      l.attr('opacity', 1)
    @activeTargetLine = null

    for p in @plots by 1
      p.plot.attr('opacity', 1)
      p.unknown.attr('opacity', 1) if p.unknown

  deprioritItem: () ->
    for l in @target_lines by 1
      if l isnt @activeTargetLine
        l.attr('stroke-width', @THICK_LINE_STROKE_WIDTH)
        l.attr('opacity', 0.5)

    for p in @plots by 1
      if p.target_id isnt @activeTargetLineConfig.config.id
        p.plot.attr('opacity', @INACTIVE_OPACITY)
        p.unknown.attr('opacity', @INACTIVE_OPACITY) if p.unknown

  unselectPlot: ->
    if @activePlotConfig
      _path = @plots[@activePlotConfig.plot_index].plot
      _unknown_path = @plots[@activePlotConfig.plot_index].unknown

      new_plot_path = @makeColoredPlot(@activePlotConfig.config)
      @plots[@activePlotConfig.plot_index].plot = new_plot_path[0]
      @plots[@activePlotConfig.plot_index].unknown = new_plot_path[1]
      @activePlot = null
      @activeUnknownPlot = null
      @activePlotConfig = null

      @activeWhiteUnknownPlot.remove() if @activeWhiteUnknownPlot
      @activeWhiteUnknownPlot = null
      @activeWhitePlot.remove() if @activeWhitePlot
      @activeWhitePlot = null

      _unknown_path.remove() if _unknown_path          
      _path.remove()
    
    if typeof @onUnSelectPlot is 'function'
      @onUnSelectPlot()

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

    @plotCross = 
      draw: (context, size) =>
        r = Math.sqrt(size / 20)
        context.moveTo(-20 * r, -r)
        context.lineTo(-r, -r)
        context.lineTo(-r, -20 * r)
        context.lineTo(r, -20 * r)
        context.lineTo(r, -r)
        context.lineTo(20 * r, -r)
        context.lineTo(20 * r, r)
        context.lineTo(r, r)
        context.lineTo(r, 20 * r)
        context.lineTo(-r, 20 * r)
        context.lineTo(-r, r)
        context.lineTo(-20 * r, r)
        context.closePath()

    @plotPoint = 
      draw: (context, size) =>
        r = size / 2
        context.moveTo(r, 0)
        context.arc(0, 0, r, 0, Math.PI * 2)

    @setMouseOverlay()
    @setYAxis()
    @setXAxis()
    @drawTargetLines()
    @drawPlots()
    @updateZoomScaleExtent()
    @drawAxesExtremeValues()

  drawTargetLines: ->

    xScale = @getXScale()
    yScale = @getYScale()

    @target_lines = @target_lines || []
    for l in @target_lines by 1
      l.remove()
    @target_lines = []

    if @hasData()
      x1 = @config.axes.x.min
      x2 = @config.axes.x.max
      for s in @line_data['target_line'] by 1
        y1 = s.slope * x1 + s.offset
        y2 = s.slope * x2 + s.offset
        if s.color != 'transparent'
          _line = @viewSVG.append("line")
              .attr("x1", xScale(x1))
              .attr("y1", yScale(y1))
              .attr("x2", xScale(x2))
              .attr("y2", yScale(y2))
              .attr("stroke-width", @NORMAL_LINE_STROKE_WIDTH)
              .attr('stroke', s.color)
              .style("fill", s.color)
              .on('click', (e, a, path) =>
                el = _line.node()                
                @setActiveTargetLine(_line, @getMousePosition(el))
                @onUnselectPlot()
              )
              .on('mousemove', (e, a, path) =>
                if (_line isnt @activeTargetLine)
                  _line.attr('stroke-width', @HOVERED_LINE_STROKE_WIDTH)
                  @hoveredLine = _line
                  @hovering = true
              )
              .on('mouseout', (e, a, path) =>
                if (_line isnt @activeTargetLine)
                  _line.attr('stroke-width', @NORMAL_LINE_STROKE_WIDTH)
                  @hovering = false
              )

          @target_lines.push(_line)

  drawPlots: ->
    series = @config.series
    return if not series

    @plots = @plots || []
    for l in @plots by 1
      l.plot.remove()
      l.unknown.remove() if l.unknown
    @plots = []

    for s in series by 1
      plot_path = @makeColoredPlot(s)
      @plots.push
        well: s.well
        channel: s.channel
        target_id: s.target_id
        config: s
        plot: plot_path[0]
        unknown: plot_path[1]

    if @activePlotConfig
      _path = @plots[@activePlotConfig.plot_index].plot
      _unknown_path = @plots[@activePlotConfig.plot_index].unknown

      new_plot_path = @makeWhitePlot(@activePlotConfig.config)
      @activeWhitePlot = new_plot_path[0]
      @activeWhiteUnknownPlot = new_plot_path[1]

      new_plot_path = @makeColoredPlot(@activePlotConfig.config, 'active')
      @plots[@activePlotConfig.plot_index].plot = new_plot_path[0]
      @plots[@activePlotConfig.plot_index].unknown = new_plot_path[1]
      @activePlot = new_plot_path[0]
      @activeUnknownPlot = new_plot_path[1]

      _unknown_path.remove() if _unknown_path          
      _path.remove()

      if typeof @onSelectPlot is 'function'
        @onSelectPlot(@activePlotConfig.config)

    return

  unsetHoverPlot: () ->
    for plot, plot_index in @plots by 1
      if plot.config.dataset isnt @activePlotConfig?.config.dataset
        _path = plot.plot
        _unknown_path = plot.unknown

        new_plot_path = @makeColoredPlot(plot.config)
        @plots[plot_index].plot = new_plot_path[0]
        @plots[plot_index].unknown = new_plot_path[1]
        
        _path.remove()
        _unknown_path.remove() if _unknown_path

    if @activePlotConfig
      _path = @plots[@activePlotConfig.plot_index].plot
      _unknown_path = @plots[@activePlotConfig.plot_index].unknown

      @activeWhiteUnknownPlot.remove() if @activeWhiteUnknownPlot
      @activeWhitePlot.remove() if @activeWhitePlot
      new_plot_path = @makeWhitePlot(@activePlotConfig.config)
      @activeWhitePlot = new_plot_path[0]
      @activeWhiteUnknownPlot = new_plot_path[1]

      new_plot_path = @makeColoredPlot(@activePlotConfig.config, 'active')
      @plots[@activePlotConfig.plot_index].plot = new_plot_path[0]
      @plots[@activePlotConfig.plot_index].unknown = new_plot_path[1]     

      @activePlot = new_plot_path[0]
      @activeUnknownPlot = new_plot_path[1]

      _path.remove()
      _unknown_path.remove() if _unknown_path


  setHoverPlot: (plot_config, isHover = true)->
    for plot, plot_index in @plots by 1
      if plot.well == plot_config.well and plot.channel == plot_config.channel
        _path = plot.plot
        _unknown_path = plot.unknown

        if isHover
          if plot.config.dataset isnt @activePlotConfig?.config.dataset
            new_plot_path = @makeColoredPlot(plot_config, 'hover')
            @plots[plot_index].plot = new_plot_path[0]
            @plots[plot_index].unknown = new_plot_path[1]            
            _path.remove()
            _unknown_path.remove() if _unknown_path          

            if @activePlotConfig
              new_plot_path = @makeColoredPlot(@activePlotConfig.config)
              @plots[@activePlotConfig.plot_index].plot = new_plot_path[0]
              @plots[@activePlotConfig.plot_index].unknown = new_plot_path[1]
              
              @activePlot.remove() if @activePlot
              @activeUnknownPlot.remove() if @activeUnknownPlot
              @activePlot = null
              @activeUnknownPlot = null
              @activePlotConfig = null

              @activeWhiteUnknownPlot.remove() if @activeWhiteUnknownPlot
              @activeWhiteUnknownPlot = null
              @activeWhitePlot.remove() if @activeWhitePlot
              @activeWhitePlot = null

            if typeof @onHoverPlot is 'function'
              @onHoverPlot(plot_config)

            @isSetHovered = true
        else
          if plot.config.dataset isnt @activePlotConfig?.config.dataset
            new_plot_path = @makeColoredPlot(plot_config)
            @plots[plot_index].plot = new_plot_path[0]
            @plots[plot_index].unknown = new_plot_path[1]

            if typeof @onHoverPlot is 'function'
              @onHoverPlot(null)

            _path.remove()
            _unknown_path.remove() if _unknown_path
          @isSetHovered = false

        break

  makeWhitePlot: (plot_config) ->
    xScale = @getXScale()
    yScale = @getYScale()
    if plot_config.well_type isnt 'standard'
      plot = d3.symbol().type(@plotPoint).size(@DEFAULT_PT_SMALL_ACTIVE_SIZE)
      stroke_width = @ACTIVED_PLOT_STROKE_WIDTH
    else
      plot = d3.symbol().type(@plotCross).size(@DEFAULT_PT_ACTIVE_SIZE / 5 + 1)
      stroke_width = @ACTIVED_PLOT_STROKE_WIDTH

    _path = @viewSVG.append("path")
        .data(@data[plot_config.dataset])
        .attr("class", "point")
        .attr("d", plot)
        .attr("fill", '#fff')
        .attr('stroke', '#fff')
        .attr('stroke-location', 'outside')        
        .attr('stroke-width', stroke_width)
        .attr("transform", (d) => 
          "translate(" + xScale(d[plot_config.x]) + "," + yScale(d[plot_config.y]) + ")rotate(45)"
        )
        .on('click', (e, a, path) =>
          @setActivePlot(_path, plot_config)
        )
        .on('mousemove', (e, a, path) =>
          if _path isnt @activePlot and !@hovering
            @hovering = true
            @setHoverPlot(plot_config, true)
        )
        .on('mouseout', (e, a, path) =>
          if (_path isnt @activePlot)
            @hovering = false
            @setHoverPlot(plot_config, false)
        )

    _unknown_path = null

    if plot_config.well_type isnt 'standard'
      plot_size = @DEFAULT_PT_ACTIVE_SIZE
      plot = d3.symbol().type(@plotPoint).size(plot_size)
      _unknown_path = @viewSVG.append("path")
          .data(@data[plot_config.dataset])
          .attr("class", "point")
          .attr("d", plot)
          .attr("fill", 'transparent')
          .attr('stroke', '#fff')
          .attr('stroke-width', @ACTIVED_PLOT_STROKE_WIDTH + 1)
          .attr("transform", (d) => 
            "translate(" + xScale(d[plot_config.x]) + "," + yScale(d[plot_config.y]) + ")"
          )
          .on('click', (e, a, path) =>
            @setActivePlot(_path, plot_config)
          )
          .on('mousemove', (e, a, path) =>
            if _path isnt @activeUnknownPlot and !@hovering
              @hovering = true
              @setHoverPlot(plot_config, true)
          )
          .on('mouseout', (e, a, path) =>
            if (_path isnt @activeUnknownPlot)
              @hovering = false
              @setHoverPlot(plot_config, false)
          )

    [_path, _unknown_path]


  makeColoredPlot: (plot_config, type='normal')->
    xScale = @getXScale()
    yScale = @getYScale()

    if plot_config.well_type isnt 'standard'
      plot_size = if type is 'normal' then @DEFAULT_PT_SMALL_SIZE else if type is 'hover' then @DEFAULT_PT_SMALL_HOVER_SIZE else @DEFAULT_PT_SMALL_ACTIVE_SIZE
      plot = d3.symbol().type(@plotPoint).size(plot_size)
      stroke_width = @NORMAL_PLOT_STROKE_WIDTH
    else
      plot_size = if type is 'normal' then @DEFAULT_PT_SIZE else if type is 'hover' then @DEFAULT_PT_HOVER_SIZE else @DEFAULT_PT_ACTIVE_SIZE
      plot = d3.symbol().type(@plotCross).size(plot_size / 5)
      stroke_width = if type is 'active' then @ACTIVED_PLOT_STROKE_WIDTH - 1 else @NORMAL_PLOT_STROKE_WIDTH

    if @activeTargetLineConfig and plot_config.target_id isnt @activeTargetLineConfig.config.id
      plot_opacity = @INACTIVE_OPACITY
    else
      plot_opacity = 1

    _path = @viewSVG.append("path")
        .data(@data[plot_config.dataset])
        .attr("class", "point")
        .attr("d", plot)
        .attr("opacity", plot_opacity)
        .attr("fill", plot_config.color)
        .attr('stroke', plot_config.color)
        .attr('stroke-location', 'outside')        
        .attr('stroke-width', stroke_width)
        .attr("transform", (d) => 
          "translate(" + xScale(d[plot_config.x]) + "," + yScale(d[plot_config.y]) + ")rotate(45)"
        )
        .on('click', (e, a, path) =>
          @setActivePlot(_path, plot_config)
        )
        .on('mousemove', (e, a, path) =>
          if _path isnt @activePlot and !@hovering
            @hovering = true
            @setHoverPlot(plot_config, true)
        )
        .on('mouseout', (e, a, path) =>
          if (_path isnt @activePlot)
            @hovering = false
            @setHoverPlot(plot_config, false)
        )

    _unknown_path = null

    if plot_config.well_type isnt 'standard'
      plot_size = if type is 'normal' then @DEFAULT_PT_SIZE + 1 else if type is 'hover' then @DEFAULT_PT_HOVER_SIZE - 2 else @DEFAULT_PT_ACTIVE_SIZE - 1
      plot = d3.symbol().type(@plotPoint).size(plot_size)
      _unknown_path = @viewSVG.append("path")
          .data(@data[plot_config.dataset])
          .attr("class", "point")
          .attr("d", plot)
          .attr("opacity", plot_opacity)
          .attr("fill", 'transparent')
          .attr('stroke', plot_config.color)
          .attr('stroke-width', @NORMAL_PLOT_STROKE_WIDTH + 1)
          .attr("transform", (d) => 
            "translate(" + xScale(d[plot_config.x]) + "," + yScale(d[plot_config.y]) + ")"
          )
          .on('click', (e, a, path) =>
            @setActivePlot(_path, plot_config)
          )
          .on('mousemove', (e, a, path) =>
            if _path isnt @activeUnknownPlot and !@hovering
              @hovering = true
              @setHoverPlot(plot_config, true)
          )
          .on('mouseout', (e, a, path) =>
            if (_path isnt @activeUnknownPlot)
              @hovering = false
              @setHoverPlot(plot_config, false)
          )

    [_path, _unknown_path]

  updateData: (data, line_data) ->
    @data = data
    @line_data = line_data
    @updateZoomScaleExtent()
    setTimeout =>
      @updateAxesExtremeValues()
    , 500

  onSelectPlot: (fn) ->
    @onSelectPlot = fn

  onUnselectPlot: (fn) ->
    @onUnselectPlot = fn    

  onHoverPlot: (fn) ->
    @onHoverPlot = fn

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

    @drawTargetLines()
    @drawPlots()

  setMouseOverlay: ->
    @mouseOverlay = @viewSVG.append('rect')
        .attr('width', @width)
        .attr('height', @height)
        .attr('fill', 'transparent')
        .on('mousemove', (e, a, path) =>
          if @isSetHovered
            @isSetHovered = false
            @unsetHoverPlot()
        )
        .on 'click', =>
          @unselectTargetLine()
          @unselectPlot()
          @onUnselectPlot()

  updateZoomScaleExtent: ->
    return if !@zooomBehavior
    extent = if @getScaleExtent() - @getMinX() < @DEFAULT_SCALE_EXTENT then @DEFAULT_SCALE_EXTENT else @getScaleExtent() - @getMinX()
    @zooomBehavior.scaleExtent([1, extent])

window.ChaiBioCharts = window.ChaiBioCharts || {}
window.ChaiBioCharts.StandardCurveChart = StandardCurveChart
