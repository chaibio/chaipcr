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

  setYInputCaret: (input, val) ->
    @setCaretPosition(input, val.toString().replace(@config.axes.y.unit, '').length)

  onAxisInput: (loc, input, val) ->
    val = val * 1000
    if (loc is 'y:max' or loc is 'y:min')
      # pos = input.selectionStart + 1
      input.value = @yAxisTickFormat(val)
      # @setYInputCaret(input, pos)

  onEnterAxisInput: (loc, input, val) ->
    console.log arguments

window.ChaiBioCharts = window.ChaiBioCharts || {}
window.ChaiBioCharts.AmplificationChart = AmplificationChart