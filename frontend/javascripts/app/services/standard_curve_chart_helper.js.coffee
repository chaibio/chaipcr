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
window.ChaiBioTech.ngApp.service 'StandardCurveChartHelper', [
  'SecondsDisplay'
  '$filter'
  'Experiment'
  (SecondsDisplay, $filter, Experiment) ->

    @chartConfig = ->
      axes:
        x:
          key: 'cycle_num'
          ticks: 8
          label: 'Log (Quantity)'
          min: 0
          max: 1
        y:
          min: 0
          max: 1
          unit: 'k'
          label: 'Cq'
          ticks: 10
          scale: 'linear'
          tickFormat: (y) ->
            # if y >= 1000 then Math.round(( y / 1000) * 10) / 10 else Math.round(y * 10) / 10
            Math.round(( y / 1000) * 10) / 10

      box:
        label:
          x: 'Cycle'
          y: 'RFU'

      series: []
      line_series: []

    # end chartConfig

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

    @neutralizeData = (amplification_data, targets, is_dual_channel=false) ->
      amplification_data = angular.copy amplification_data
      targets = angular.copy targets

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
          target = _.filter targets, (target) ->
            target && target.id is datum[0]          
          target.length && target[0].channel is channel_i

        for cycle_i in [1..max_cycle] by 1          
          data_by_cycle = _.filter channel_data, (datum) ->
            datum[2] is cycle_i
          data_by_cycle = _.sortBy data_by_cycle, (d) ->
            d[1]
          channel_datasets[dataset_name].push data_by_cycle

        console.log('channel_datasets[dataset_name]')
        # console.log(channel_datasets[dataset_name])
        
        channel_datasets[dataset_name] = _.map channel_datasets[dataset_name], (datum) ->
          if datum[0]
            pt = cycle_num: datum[0][2]
            for y_item, i in datum by 1
              pt["well_#{i}_background"] = y_item[3]
              pt["well_#{i}_baseline"] =  y_item[4]
              pt["well_#{i}_background_log"] = if y_item[3] > 0 then y_item[3] else 10
              pt["well_#{i}_baseline_log"] =  if y_item[4] > 0 then y_item[4] else 10

              pt["well_#{i}_dr1_pred"] = y_item[5]
              pt["well_#{i}_dr2_pred"] = y_item[6]
            return pt
          else
            {}

      return channel_datasets


    @neutralizeChartData = (summary_data, target_data, targets, is_dual_channel=false) ->
      summary_data = angular.copy summary_data
      targets = angular.copy targets
      target_data = angular.copy target_data
      channels_count = if is_dual_channel then 2 else 1

      datasets = {}

      if is_dual_channel
        for ch in [1..2] by 1
          for i in [0..15] by 1
            datasets["well_#{i}_#{ch}"] = []
      else
        for i in [0..15] by 1
          datasets["well_#{i}_1"] = []

      for i in [1.. summary_data.length - 1] by 1
        target = _.filter targets, (target) ->
          target && target.id is summary_data[i][0]        
        channel = if target.length then target[0].channel else 1
        if summary_data[i][4] and summary_data[i][5]
          datasets["well_#{summary_data[i][1] - 1}_#{channel}"] = []
          datasets["well_#{summary_data[i][1] - 1}_#{channel}"].push
            cq: summary_data[i][3]
            log_quantity: Math.log10(summary_data[i][4] * Math.pow(10, summary_data[i][5]))

      return datasets

    @neutralizeLineData = (target_data) ->
      target_data = angular.copy target_data

      datasets = 
        target_line: []

      for i in [1.. target_data.length - 1] by 1
        if target_data[i][2]
          datasets["target_line"].push
            efficiency: target_data[i][2].efficiency
            offset: target_data[i][2].offset
            r2: target_data[i][2].r2
            slope: target_data[i][2].slope
            id: target_data[i][0]

      return datasets

    @normalizeWellTargetData = (well_data, init_targets) ->
      well_data = angular.copy well_data
      targets = angular.copy init_targets

      for i in [0.. targets.length - 1] by 1
        targets[i] = 
          id: null
          name: null
          channel: null
          color: null
          well_type: null

      for i in [0.. well_data.length - 1] by 1
        targets[(well_data[i].well_num - 1) * 2 + well_data[i].channel - 1] = 
          id: well_data[i].target_id
          name: well_data[i].target_name
          channel: well_data[i].channel
          color: well_data[i].color
          well_type: well_data[i].well_type
      return targets

    @normalizeSummaryData = (summary_data, target_data, well_targets) ->
      summary_data = angular.copy summary_data
      target_data = angular.copy target_data
      well_targets = angular.copy well_targets

      well_data = []

      for i in [1.. summary_data.length - 1] by 1
        item = {}
        for item_name in [0..summary_data[0].length - 1] by 1
          item[summary_data[0][item_name]] = summary_data[i][item_name]

        target = _.filter well_targets, (target) ->
          target && target.id is item.target_id

        if target.length
          item['target_name'] = target[0].name if target[0]
          item['channel'] = target[0].channel if target[0]
          item['color'] = target[0].color if target[0]
          item['well_type'] = target[0].well_type if target[0]
        else
          target = _.filter target_data, (target) ->
            target[0] is item.target_id
          item['target_name'] = target[0][1] if target[0]
          item['channel'] = if item['target_name'] == 'Ch 1' then 1 else 2
          item['color'] = if item['target_name'] == 'Ch 1' then @SAMPLE_TARGET_COLORS[0] else @SAMPLE_TARGET_COLORS[1]
          item['well_type'] = ''

        item['active'] = false

        item['mean_quantity'] = item['mean_quantity_m'] * Math.pow(10, item['mean_quantity_b'])
        item['quantity'] = item['quantity_m'] * Math.pow(10, item['quantity_b'])

        well_data.push item

      well_data = _.orderBy(well_data,['well_num', 'channel'],['asc', 'asc']);      

      return well_data

    @blankWellData = (is_dual_channel, well_targets) ->
      well_targets = angular.copy well_targets
      well_data = []
      for i in [0.. 15] by 1
        item = {}
        item['well_num'] = i+1
        item['replic_group'] = null
        item['quantity_m'] = null
        item['quantity_b'] = null
        item['quantity'] = 0
        item['mean_quantity_m'] = null
        item['mean_quantity_b'] = null
        item['mean_quantity'] = 0
        item['mean_cq'] = null
        item['cq'] = null
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

    @blankWellTargetData = (well_data) ->
      well_data = angular.copy well_data
      targets = []

      for i in [0.. well_data.length - 1] by 1
        targets.push 
          id: well_data[i].target_id
          name: well_data[i].target_name
          channel: well_data[i].channel
          color: well_data[i].color
          well_type: well_data[i].well_type

      return targets

    @paddData = (cycle_num = 1) ->
      paddData = cycle_num: cycle_num
      for i in [0..15] by 1
        paddData["well_#{i}_baseline"] = 0
        paddData["well_#{i}_background"] = 0
        paddData["well_#{i}_background_log"] = 0
        paddData["well_#{i}_baseline_log"] = 0

      channel_1: [paddData]
      channel_2: [paddData]

    @getMaxExperimentCycle = Experiment.getMaxExperimentCycle

    return
]
