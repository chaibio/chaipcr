class AmplificationChart extends window.ChaiBioCharts.BaseChart

  DEFAULT_MIN_Y: 0
  DEFAULT_MAX_Y: 10000
  DEFAULT_MIN_X: 1
  DEFAULT_MAX_X: 40

  formatPower: (d) ->
    superscript = "⁰¹²³⁴⁵⁶⁷⁸⁹"
    (d + "").split("").map((c) -> superscript[c]).join("")

  yAxisTickFormat: (y) ->
    if @config.axes.y.scale is 'log'
      '10' + @formatPower(Math.round(Math.log(y) / Math.LN10))
    else
      super

window.ChaiBioCharts = window.ChaiBioCharts || {}
window.ChaiBioCharts.AmplificationChart = AmplificationChart