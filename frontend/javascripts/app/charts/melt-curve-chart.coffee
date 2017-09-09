class MeltCurveChart extends window.ChaiBioCharts.BaseChart

  DEFAULT_MAX_Y: 10
  DEFAULT_MAX_X: 1
  DEFAULT_MIN_Y: 0
  DEFAULT_MIN_X: 0

  getScaleExtent: ->
    return @getMaxX()

window.ChaiBioCharts = window.ChaiBioCharts || {}
window.ChaiBioCharts.MeltCurveChart = MeltCurveChart
