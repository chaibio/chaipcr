Step.seed(:stage_id, :order_number) do |s|
  s.id = 1
  s.name = "Warm Up"
  s.temperature = 65
  s.hold_time = 60
  s.order_number = 0
  s.stage_id = 1
  s.collect_data = false
end

Step.seed(:stage_id, :order_number) do |s|
  s.id = 2
  s.name = "Water"
  s.temperature = 65
  s.hold_time = 20
  s.order_number = 1
  s.stage_id = 1
  s.collect_data = true
end

Step.seed(:stage_id, :order_number) do |s|
  s.id = 3
  s.name = "Swap"
  s.temperature = 65
  s.hold_time = 1
  s.order_number = 2
  s.stage_id = 1
  s.collect_data = false
  s.pause = true
end

Step.seed(:stage_id, :order_number) do |s|
  s.id = 4
  s.name = "Signal"
  s.temperature = 65
  s.hold_time = 20
  s.order_number = 3
  s.stage_id = 1
  s.collect_data = true
end

Stage.seed(:protocol_id, :order_number) do |s|
  s.id = 1
  s.num_cycles = 1
  s.protocol_id = 1
  s.stage_type = Stage::TYPE_HOLD
  s.order_number = 0
end

protocol = Protocol.seed(:experiment_definition_id) do |s|
  s.id = 1
  s.lid_temperature = 110
  s.experiment_definition_id = 1
end

ExperimentDefinition.seed(:guid) do |s|
  s.id = 1
  s.guid = "optical_cal"
  s.experiment_type = ExperimentDefinition::TYPE_CALIBRATION
  s.protocol = protocol.first
end

#Default Experiment
Experiment.seed do |s|
  s.id = 1
  s.name = "calibration"
  s.experiment_definition_id = 1
  s.calibration_id = 1
end

waterstep_defaults = { step_id: 2, fluorescence_value: 1, cycle_num: 1, experiment_id: 1 }

FluorescenceDatum.seed(:experiment_id,:step_id,:well_num,:channel,
*(0...16).map {|num| waterstep_defaults.merge(channel: 1, well_num: num)}
)
FluorescenceDatum.seed(:experiment_id,:step_id,:well_num,:channel,
*(0...16).map {|num| waterstep_defaults.merge(channel: 2, well_num: num)}
)

signalstep_defaults = { step_id: 4, fluorescence_value: 100, cycle_num: 1, experiment_id: 1 }

FluorescenceDatum.seed(:experiment_id,:step_id,:well_num,:channel,
*(0...16).map {|num| signalstep_defaults.merge(channel: 1, well_num: num)}
)
FluorescenceDatum.seed(:experiment_id,:step_id,:well_num,:channel,
*(0...16).map {|num| signalstep_defaults.merge(channel: 2, well_num: num)}
)