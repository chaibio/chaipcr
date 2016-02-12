App.service 'MeltCurveService', [
  'AmplificationChartHelper'
  (AmplificationChartHelper) ->
    self = @


    self.chartConfig = (type) ->
      series = []
      for i in [0..15] by 1
        series.push
          axis: 'y'
          key: type
          dataset: "well_#{i}"
          color: AmplificationChartHelper.COLORS[i]
          type: 'line'
          id: "well_#{i}"
          label: "well-#{i+1}"

      axes:
        x:
          min: 1
          key: 'temperature'
          ticks: 8
          tickFormat: (x) ->
            return "#{x}°C"
        y:
          ticks: 10
          # ticksFormat: (y) ->
          #   "#{$filter('round')(y/1000, 1)}k"
      margin:
        left: 70
        right: 0

      series: series
      tooltipHook: (items) ->
        rows = []
        for item in items by 1
          rows.push
            label: item.series.label
            value: "#{item.row.y1}"
            id: item.series.id
            color: item.series.color

        abscissas: "#{item.row.x.toFixed(2)} °C"
        rows: rows
    # end chartConfig

    self.XTicks = (min, max) ->
      ticks = []
      calib = 10
      diff = max - min
      if diff <= calib
        for i in [min..max] by 1
          ticks.push i
        return ticks
      else
        return calib
    # end ticks

    self.parseData = (data) ->
      datasets = {}

      for well, i in data by 1
        datasets["well_#{i}"] = []

        for temp, ii in data[i].temperature by 1
          datasets["well_#{i}"].push
            temperature: temp
            derivative: data[i].derivative[ii]
            normalized: data[i].fluorescence_data[ii]

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