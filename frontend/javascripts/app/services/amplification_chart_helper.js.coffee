window.ChaiBioTech.ngApp.service 'AmplificationChartHelper', [
  'SecondsDisplay'
  '$filter'
  (SecondsDisplay, $filter) ->

    @chartConfig = ->
      axes:
        x:
          min: 0
          key: 'cycle_num'
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
      series: [
      ]
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


    @neutralizeData = (fluorescence_data) ->
      neutralized_baseline_data = [@paddData()]
      neutralized_background_data = [@paddData()]

      # get max cycle
      max_cycle = 0
      for datum in fluorescence_data by 1
        max_cycle = if datum.cycle_num > max_cycle then datum.cycle_num else max_cycle

      for i in [1..max_cycle] by 1
        data_by_cycle = _.select fluorescence_data, (datum) ->
          datum.cycle_num is i

        baseline_data = cycle_num: i
        background_data = cycle_num: i
        for datum in data_by_cycle by 1
          baseline_data["well_#{datum.well_num}"] = datum['baseline_subtracted_value']
          background_data["well_#{datum.well_num}"] = datum['background_subtracted_value']

        neutralized_baseline_data.push baseline_data
        neutralized_background_data.push background_data

      baseline: neutralized_baseline_data
      background: neutralized_background_data



    @paddData = ->
      paddData = cycle_num: 0
      for i in [0..15] by 1
        paddData["well_#{i}"] = 0

      paddData

    @getMaxExperimentCycle = (exp) ->
      stages = exp.protocol.stages || []
      cycles = []

      for stage in stages by 1
        cycles.push stage.stage.num_cycles

      Math.max.apply Math, cycles

    @getMaxCalibration = (fluorescence_data, is_baseline) ->
      calibs = _.map fluorescence_data, (datum) ->
        datum['baseline_subtracted_value']

      max_baseline = Math.max.apply Math, calibs
      calibs = _.map fluorescence_data, (datum) ->
        datum['background_subtracted_value']

      max_background = Math.max.apply Math, calibs

      return if max_baseline > max_background then max_baseline else max_background

    @Xticks = (max)->
      num_ticks = 10
      ticks = []
      if max < num_ticks
        for i in [0..max] by 1
          ticks.push i
      else
        chunkSize = Math.floor(max/num_ticks)
        for i in [0..max] by chunkSize
          ticks.push i
        ticks.push max if max % num_ticks isnt 0

      ticks

    @COLORS = [
        '#04A0D9'
        '#1578BE'
        '#2455A8'
        '#3B2F90'
        '#73258C'
        '#B01C8B'
        '#FA1284'
        '#FF004E'
        '#EA244E'
        '#FA3C00'
        '#EF632A'
        '#F5AF13'
        '#FBDE26'
        '#B6D333'
        '#67BC42'
        '#13A350'
      ]


    return
]