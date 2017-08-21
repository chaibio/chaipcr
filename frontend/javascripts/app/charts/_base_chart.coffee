class BaseChart

  constructor: (@elem, @data, @config) ->

  formatPower: (d) ->
    superscript = "⁰¹²³⁴⁵⁶⁷⁸⁹"
    (d + "").split("").map((c) -> superscript[c]).join("")

  bisectX: (line_config) ->
    return d3.bisector((d) ->
      return d[line_config.x]
    ).left


window.ChaiBioCharts = window.ChaiBioCharts || {}
window.ChaiBioCharts.BaseChart = BaseChart