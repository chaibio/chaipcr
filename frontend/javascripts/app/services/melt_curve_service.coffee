###
Chai PCR - Software platform for Open qPCR and Chai's Real-Time PCR instruments.
For more information visit http://www.chaibio.com

Copyright 2016 Chai Biotechnologies Inc. <info@chaibio.com>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
###
App.service 'MeltCurveService', [
  'AmplificationChartHelper'
  'Webworker'
  (AmplificationChartHelper, Webworker) ->
    self = @

    @COLORS = [
        '#04A0D9'
        '#1578BE'
        '#2455A8'
        '#3D3191'
        '#75278E'
        '#B01D8B'
        '#FA1485'
        '#FF0050'
        '#EA244E'
        '#FA3C00'
        '#F0662D'
        '#F6B014'
        '#FCDF2B'
        '#B7D436'
        '#68BD43'
        '#14A451'
      ]

    @SAMPLE_TARGET_COLORS = [
        '#04A0D9'
        '#2455A8'
        '#75278E'
        '#FA1485'
        '#EA244E'
        '#F0662D'
        '#FCDF2B'
        '#68BD43'
        '#1578BE'
        '#3D3191'
        '#B01D8B'
        '#FF0050'
        '#FA3C00'
        '#F6B014'
        '#B7D436'
        '#14A451'
      ]

    self.defaultData = (is_dual_channel) ->
      datasets = {}

      if is_dual_channel
        for ch in [1..2] by 1
          for i in [0..15] by 1
            datasets["well_#{i}_#{ch}"] = []
      else
        for i in [0..15] by 1
          datasets["well_#{i}_1"] = []

      return datasets

    @blankWellData = (is_dual_channel, well_targets) ->
      well_targets = angular.copy well_targets
      well_data = []
      for i in [0.. 15] by 1
        item = {}
        item['well_num'] = i+1
        item['tm'] = []
        item['channel'] = 1
        item['active'] = false

        if is_dual_channel
          item['target_name'] = well_targets[2*i].name if well_targets[2*i]
          item['target_id'] = well_targets[2*i].id if well_targets[2*i]
          item['color'] = well_targets[2*i].color if well_targets[2*i]
          item['well_type'] = well_targets[2*i].well_type if well_targets[2*i]
        else
          item['target_name'] = well_targets[i].name if well_targets[i]
          item['target_id'] = well_targets[i].id if well_targets[i]
          item['color'] = well_targets[i].color if well_targets[i]
          item['well_type'] = well_targets[i].well_type if well_targets[i]

        well_data.push item

        if is_dual_channel
          dual_item = angular.copy item
          dual_item['target_name'] = well_targets[2*i+1].name if well_targets[2*i+1]
          dual_item['target_id'] = well_targets[2*i+1].id if well_targets[2*i+1]
          dual_item['color'] = well_targets[2*i+1].color if well_targets[2*i+1]
          dual_item['well_type'] = well_targets[2*i+1].well_type if well_targets[2*i+1]
          dual_item['channel'] = 2
          well_data.push dual_item

      return well_data

    @normalizeSummaryData = (summary_data, target_data, well_targets) ->
      summary_data = angular.copy summary_data
      target_data = angular.copy target_data
      well_targets = angular.copy well_targets

      well_data = []

      for i in [0.. summary_data.length - 1] by 1
        item = summary_data[i]
        target = _.filter well_targets, (target) ->
          target and target.id is item.target_id and target.well_num is item.well_num

        if target.length
          item['target_name'] = target[0].name if target[0]
          item['channel'] = target[0].channel if target[0]
          item['color'] = target[0].color if target[0]
          item['well_type'] = target[0].well_type if target[0]
        else
          target = _.filter target_data, (target) ->
            target.target_id is item.target_id
          item['target_name'] = target[0].target_name if target[0]
          item['channel'] = target[0].channel if target[0]
          item['color'] = @SAMPLE_TARGET_COLORS[target[0].channel - 1] if target[0]
          item['well_type'] = ''

        item['active'] = false        

        well_data.push item

      return well_data    

    @normalizeChartData = (chart_data, target_data, well_targets) ->
      chart_data = angular.copy chart_data
      target_data = angular.copy target_data
      well_targets = angular.copy well_targets

      for i in [0.. chart_data.length - 1] by 1
        item = chart_data[i]
        target = _.filter well_targets, (target) ->
          target && target.id is item.target_id

        if target.length
          chart_data[i]['channel'] = target[0].channel if target[0]
        else
          target = _.filter target_data, (target) ->
            target.target_id is item.target_id
          chart_data[i]['channel'] = if target[0]['target_name'] == 'Ch 1' then 1 else 2

      return chart_data    

    @normalizeWellTargetData = (well_data, is_dual_channel) ->
      well_data = angular.copy well_data
      channel_count = if is_dual_channel then 2 else 1
      targets = []
      for i in [0.. 16 * channel_count - 1] by 1
        targets[i] = 
          id: null
          name: null
          channel: null
          color: null

      for i in [0.. well_data.length - 1] by 1
        targets[(well_data[i].well_num - 1) * channel_count + well_data[i].channel - 1] = 
          id: well_data[i].target_id
          name: well_data[i].target_name
          channel: well_data[i].channel
          color: well_data[i].color        

      return targets

    self.chartConfig = ->
      series = []
      # for i in [0..1] by 1
      for i in [0..15] by 1
        series.push
          dataset: "well_#{i}"
          color: AmplificationChartHelper.COLORS[i]

      series: series
      axes:
        x:
          key: 'temperature'
          label: 'Temperature (°C)'
          ticks: 8
          tickFormat: (x) ->
            x = x || 0
            x = Math.round(x * 10) / 10
            return x
        y:
          scale: 'linear'
          unit: 'k'
          ticks: 10
          tickFormat: (y) -># Math.round( y * 10 ) / 10
            Math.round(( y / 1000) * 10) / 10
      
      box:
        label:
          x: 'Temp'
          y: 'RFU'

    # end chartConfig

    self.parseData = (data, is_dual_channel, cb) ->

      parseData = (data, is_dual_channel) ->
        datasets = {}

        if is_dual_channel
          for ch in [1..2] by 1
            for i in [0..15] by 1
              datasets["well_#{i}_#{ch}"] = []
        else
          for i in [0..15] by 1
            datasets["well_#{i}_1"] = []

        for well, i in data by 1
          datasets["well_#{data[i].well_num - 1}_#{data[i].channel}"] = []

          for temp, ii in data[i].temperature by 1

            total_temp = 0
            for t in [0...data.length] by 1
              total_temp += if data[t] then data[t].temperature[ii] else 0

            datasets["well_#{data[i].well_num - 1}_#{data[i].channel}"].push
              temperature: Math.round((total_temp / data.length) * 100) / 100
              derivative: Math.round(data[i].derivative_data[ii] * 100) / 100
              normalized: Math.round(data[i].normalized_data[ii] * 100) / 100

        complete(datasets)

      return Webworker.create(parseData, async:true).run(data, is_dual_channel)
    # end parseData

    self.optimizeForEachResolution = (mc_data, resolutions) ->
      data = []
      for res in resolutions by 1
        data.push(self.optimizeForResolution(angular.copy(mc_data), res))

      return data

    self.optimizeForResolution = (mc_data, resolution) ->
      return if !mc_data
      calibration_dp = 200
      chunkSize = Math.round( resolution / calibration_dp )
      chunkSize = if chunkSize > 0 then chunkSize else 1
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

    self.averagedTm = (tms) ->
      return null if !tms
      return null if !tms[0]
      return tms[0]

    self.getYExtrems = (data, chart_type) ->
      data_length = data['well_0'].length
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
