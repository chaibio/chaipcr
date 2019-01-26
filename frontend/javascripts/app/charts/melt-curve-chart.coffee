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

window.ChaiBioCharts = window.ChaiBioCharts || {}
window.ChaiBioCharts.MeltCurveChart = MeltCurveChart
