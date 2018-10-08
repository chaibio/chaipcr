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
window.ChaiBioTech.ngApp.service 'AmplificationChartHelper', [
  'SecondsDisplay'
  '$filter'
  'Experiment'
  (SecondsDisplay, $filter, Experiment) ->

    @chartConfig = ->
      axes:
        x:
          min: 1
          key: 'cycle_num'
          ticks: 8
          label: 'Cycle Number'
        y:
          unit: 'k'
          label: 'Relative Fluorescence Units'
          ticks: 10
          tickFormat: (y) ->
            # if y >= 1000 then Math.round(( y / 1000) * 10) / 10 else Math.round(y * 10) / 10
            Math.round(( y / 1000) * 10) / 10

      box:
        label:
          x: 'Cycle'
          y: 'RFU'

      series: []

    # end chartConfig

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

    @neutralizeData = (amplification_data, is_dual_channel=false) ->
      amplification_data = angular.copy amplification_data
      channel_datasets = {}
      channels_count = if is_dual_channel then 2 else 1

      # get max cycle
      max_cycle = 0
      for datum in amplification_data by 1
        max_cycle = if datum[2] > max_cycle then datum[2] else max_cycle

      for channel_i in [1..channels_count] by 1
        dataset_name = "channel_#{channel_i}"
        channel_datasets[dataset_name] = []
        channel_data = _.filter amplification_data, (datum) ->
          datum[0] is channel_i
        for cycle_i in [1..max_cycle] by 1
          
          data_by_cycle = _.filter channel_data, (datum) ->
            datum[2] is cycle_i
          data_by_cycle = _.sortBy data_by_cycle, (d) ->
            d[1]
          channel_datasets[dataset_name].push data_by_cycle

        console.log('channel_datasets[dataset_name]')
        console.log(channel_datasets[dataset_name])
        
        channel_datasets[dataset_name] = _.map channel_datasets[dataset_name], (datum) ->
      
          pt = cycle_num: datum[0][2]
          for y_item, i in datum by 1
            pt["well_#{i}_background"] = y_item[3]
            pt["well_#{i}_baseline"] =  y_item[4]
            pt["well_#{i}_background_log"] = if y_item[3] > 0 then y_item[3] else 10
            pt["well_#{i}_baseline_log"] =  if y_item[4] > 0 then y_item[4] else 10

            pt["well_#{i}_dr1_pred"] =  y_item[5]
            pt["well_#{i}_dr2_pred"] =  y_item[6]
          return pt

      return channel_datasets

    @paddData = (cycle_num = 1) ->
      paddData = cycle_num: cycle_num
      for i in [0..15] by 1
        paddData["well_#{i}_baseline"] = 0
        paddData["well_#{i}_background"] = 0
        paddData["well_#{i}_background_log"] = 0
        paddData["well_#{i}_baseline_log"] = 0
        paddData["well_#{i}_dr1_pred"] = 0
        paddData["well_#{i}_dr2_pred"] = 0
  
      channel_1: [paddData]
      channel_2: [paddData]

    @getMaxExperimentCycle = Experiment.getMaxExperimentCycle

    return
]
