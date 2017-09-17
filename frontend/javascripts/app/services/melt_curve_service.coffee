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

    self.defaultData = ->
      datasets = {}
      for i in [0..15] by 1
        datasets["well_#{i}"] = []
      return datasets

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
          unit: ' °C'
          key: 'temperature'
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
              temperature: Math.round((total_temp / 16) * 100) / 100
              derivative: Math.round(data[i].derivative_data[ii] * 100) / 100
              normalized: Math.round(data[i].normalized_data[ii] * 100) / 100

        complete(datasets)

      return Webworker.create(parseData, async:true).run(data)
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
