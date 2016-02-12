App.service 'MeltCurveService', [
  'AmplificationChartHelper'
  (AmplificationChartHelper) ->
    self = @


    self.chartConfig = ->
      series = []
      for i in [0..15] by 1
        series.push
          axis: 'y'
          key: 'derivative'
          dataset: "well_#{i}"
          color: AmplificationChartHelper.COLORS[i]
          type: 'line'
          id: "well_#{i}"

      axes:
        x:
          min: 1
          key: 'temperature'
          ticks: 8
          ticksFormatter: (x) ->
            parseInt(x).toFixed(2)
        y:
          ticks: 10
          # ticksFormatter: (y) ->
          #   "#{$filter('round')(y/1000, 1)}k"
      margin:
        left: 70
        right: 70

      series: series
      # lineMode: 'basis'
      # thickness: '2px'
      # tension: 0.7
      # tooltipHook: -> false
      # drawLegend: false
      # drawDots: false
      # hideOverflow: false
    # end chartConfig

    self.XTicks = (min, max) ->
      ticks = []
      for i in [min..max] by 1
        ticks.push i
      return ticks
    # end ticks

    self.parseData = (data) ->
      datasets = {}

      for well, i in data by 1
        datasets["well_#{i}"] = []

        for temp, ii in data[i].temperature by 1
          datasets["well_#{i}"].push
            temperature: temp
            derivative: data[i].derivative[ii]

      return datasets
    # end parseData


    self.getTempRange = (data) ->
      temps = []
      for d in data[0].temperature by 1
        temps.push d

      min_temp = Math.min.apply(Math, temps)
      max_temp = Math.max.apply(Math, temps)

      return {min: min_temp, max: max_temp}
    # end getTempRange

    return self

]