app = window.ChaiBioTech.ngApp

app.service 'ChoosenChartService', [

  ->
    callback = null
    @setCallback = (cb) ->
      callback = cb

    @chooseChart = (chart) ->
      callback(chart) if !!callback

    return

]