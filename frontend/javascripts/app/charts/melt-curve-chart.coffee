class MeltCurveChart extends window.ChaiBioCharts.AmplificationChart

  getScaleExtent: ->
    return @getMaxX()

window.ChaiBioCharts = window.ChaiBioCharts || {}
window.ChaiBioCharts.MeltCurveChart = MeltCurveChart