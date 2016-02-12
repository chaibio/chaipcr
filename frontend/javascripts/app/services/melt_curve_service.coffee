App.service 'MeltCurveService', [

  ->
    self = @

    # self.getTempRange = (exp) ->
    #   stages = exp.protocol.stages
    #   melt_curve_stage = _.find stages, (d) ->
    #     d.stage.stage_type is 'meltcurve' and d.stage.name is 'Melt Curve Stage'

    #   temps = []
    #   for d in melt_curve_stage.stage.steps by 1
    #     temps.push parseFloat(d.step.temperature)

    #   console.log temps

    #   min_temp = Math.min.apply(Math, temps)
    #   max_temp = Math.max.apply(Math, temps)

    #   return {min: min_temp, max: max_temp}
    # end getTempRange

    self.getTempRange = (data) ->
      temps = []
      for d in data[0].temperature by 1
        temps.push d

      min_temp = Math.min.apply(Math, temps)
      max_temp = Math.max.apply(Math, temps)

      return {min: min_temp, max: max_temp}
    # end getTempRange


    self.chartConfig = ->
      series = []
      for i in [0..15] by 1
        series.push
          y: "well_#{i}"

      axes:
        x:
          min: 1
          key: 'temperature'
          ticks: 8
          ticksFormatter: (x) ->
            parseInt(x)
        y:
          min: 0
          ticks: 10
          # ticksFormatter: (y) ->
          #   "#{$filter('round')(y/1000, 1)}k"
      margin:
        left: 70
      series: series
      lineMode: 'basis'
      thickness: '2px'
      tension: 0.7
      tooltip:
        mode: 'none'
      # tooltip:
      #   mode: 'scrubber'
      #   formatter: (x, y, series) ->
      #     "cycle: #{x} | calibration: #{$filter('round')(y/1000, 1)}k"
      drawLegend: false
      drawDots: false
      hideOverflow: false

    self.parseData = (data) ->
      derivative_arr = []
      temp_length = data[0].temperature.length

      for temp_i in [0...temp_length] by 1
        item = {temperature: 0}
        for well_i in [0..15] by 1
          item["well_#{well_i}"] = data[well_i].derivative[temp_i]
          item.temperature += data[well_i].temperature[temp_i]

        item.temperature = item.temperature/16
        derivative_arr.push item

      return derivative_arr


    return self

]