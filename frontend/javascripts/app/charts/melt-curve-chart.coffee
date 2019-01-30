class MeltCurveChart extends window.ChaiBioCharts.AmplificationChart

  DEFAULT_MAX_Y: 10
  DEFAULT_MAX_X: 1
  DEFAULT_MIN_Y: 0
  DEFAULT_MIN_X: 0
  # MARGIN:
  #   left: 75
  #   right: 20
  #   top: 10
  #   bottom: 20

  getScaleExtent: ->
    return @getMaxX()

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
        @onUpdateProperties(d.temperature, d.normalized, d.derivative)

window.ChaiBioCharts = window.ChaiBioCharts || {}
window.ChaiBioCharts.MeltCurveChart = MeltCurveChart
