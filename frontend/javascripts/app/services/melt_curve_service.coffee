App.service 'MeltCurveService', [
  'AmplificationChartHelper'
  'Webworker'
  (AmplificationChartHelper, Webworker) ->
    self = @

    self.defaultData = ->
      datasets = {}
      for i in [0..15] by 1
        datasets["well_#{i}"] = []
      return datasets

    self.chartConfig = (type) ->
      series = []
      # for i in [0..1] by 1
      for i in [0..15] by 1
        series.push
          axis: 'y'
          key: type
          dataset: "well_#{i}"
          color: AmplificationChartHelper.COLORS[i]
          type: 'line'
          id: "well_#{i}"
          label: "well_#{i+1}: "
          interpolation: {mode: 'cardinal', tension: 0.7}

      axes:
        x:
          key: 'temperature'
          ticks: 8
          tickFormat: (x) ->
            return "#{x}°C"
        y:
          ticks: 10
      margin:
        left: 70
        right: 0

      grid:
        x: false
        y: false

      series: series

      tooltipHook: (items) ->
        rows = []
        for item in items by 1
          rows.push
            label: item.series.label
            value: "#{item.row.y1.toFixed(2)}"
            id: item.series.id
            color: item.series.color

        abscissas: "#{item.row.x.toFixed(2)} °C"
        rows: rows
    # end chartConfig

    self.parseData = (data, cb) ->

      parseData = (data) ->
        datasets = {}

        for well, i in data by 1
          datasets["well_#{i}"] = []

          for temp, ii in data[i].temperature by 1

            total_temp = 0
            for t in [0..15] by 1
              total_temp += data[t].temperature[ii]

            datasets["well_#{i}"].push
              temperature: total_temp/16
              derivative: data[i].derivative[ii]
              normalized: data[i].fluorescence_data[ii]

        complete(datasets)

      return Webworker.create(parseData, async:true).run(data)
    # end parseData

    self.optimizeForEachResolution = (mc_data, resolutions) ->
      console.log mc_data
      console.log resolutions
      data = []
      for res in resolutions by 1
        data.push(self.optimizeForResolution(angular.copy(mc_data), res))

      return data

    self.optimizeForResolution = (mc_data, resolution) ->
      return if !mc_data
      console.log resolution

      calibration_dp = 200
      chunkSize = Math.round( resolution / calibration_dp )
      chunkSize = if chunkSize > 0 then chunkSize else 1
      console.log "chunkSize: #{chunkSize}"
      new_data = {}

      for well_i in [0..15] by 1
        new_data["well_#{well_i}"] = []
        well_data = mc_data["well_#{well_i}"]
        chunked = _.chunk well_data, chunkSize

        new_data["well_#{well_i}"] = _.map chunked, (chunk) ->
          averaged_data = []
          total_temperature = 0
          total_derivative = 0
          total_normalized = 0

          for c in chunk by 1
            total_temperature += c.temperature
            total_derivative += c.derivative
            total_normalized += c.normalized

          return {
            temperature: total_temperature/chunk.length
            derivative: total_derivative/chunk.length
            normalized: total_normalized/chunk.length
          }

        new_data["well_#{well_i}"].unshift well_data[0]
        new_data["well_#{well_i}"].push well_data[well_data.length-1]

      return new_data

    self.moveData = (data, data_length, resolution, scrollbar) ->
      scrollbar = scrollbar || 0
      scrollbar = if scrollbar < 0 then 0 else scrollbar
      scrollbar = if scrollbar > 1 then 1 else scrollbar
      mc_data = angular.copy(data)
      new_data = {}
      data_span = Math.round((resolution/data_length) * mc_data['well_0'].length)
      start = (mc_data['well_0'].length - data_span) * scrollbar
      end = start + data_span
      start = Math.floor(start)
      end = Math.ceil(end)
      for i in [0..15] by 1
        new_data["well_#{i}"] = mc_data["well_#{i}"].slice(start, end)

      return new_data

    self.getYExtrems = (data, chart_type) ->
      console.log "chart_type: #{chart_type}"
      data_length = data['well_0'].length
      console.log "data_length: #{data_length}"
      min = 0
      max = 0

      for i in [0...data_length] by 1
        for ii in [0..15] by 1
          val = data["well_#{ii}"][i][chart_type]
          min = if val < min then val else min
          max = if val > max then val else max

      return {
        min: min
        max: max
      }

    return self

]