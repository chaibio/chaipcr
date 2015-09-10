ExperimentDefinition.seed do |s|
  s.id = 1
  s.name = "calibration"
  s.guid = "optical_cal"
  s.experiment_type = ExperimentDefinition::TYPE_CALIBRATION
end

Protocol.seed do |s|
  s.id = 1
  s.lid_temperature = 110
  s.experiment_definition_id = 1
end

Stage.seed do |s|
  s.id = 1
  s.num_cycles = 1
  s.protocol_id = 1
  s.stage_type = Stage::TYPE_HOLD
end

Step.seed do |s|
  s.id = 1
  s.name = "Warm Up"
  s.temperature = 65
  s.hold_time = 60
  s.order_number = 0
  s.stage_id = 1
  s.collect_data = false
end

Step.seed do |s|
  s.id = 2
  s.name = "Water"
  s.temperature = 65
  s.hold_time = 20
  s.order_number = 1
  s.stage_id = 1
  s.collect_data = true
end

Step.seed do |s|
  s.id = 3
  s.name = "Swap"
  s.temperature = 65
  s.hold_time = 1
  s.order_number = 2
  s.stage_id = 1
  s.collect_data = false
  s.pause = true
end

Step.seed do |s|
  s.id = 4
  s.name = "Signal"
  s.temperature = 65
  s.hold_time = 20
  s.order_number = 3
  s.stage_id = 1
  s.collect_data = true
end

#Default Experiment
Experiment.seed do |s|
  s.id = 1
  s.experiment_definition_id = 1
  s.calibration_id = 1
end

waterstep_defaults = { step_id: 2, fluorescence_value: 1, cycle_num: 1, experiment_id: 1 }

FluorescenceDatum.seed(:experiment_id,:step_id,:well_num,
  waterstep_defaults.merge(well_num: 0),
  waterstep_defaults.merge(well_num: 1),
  waterstep_defaults.merge(well_num: 2),
  waterstep_defaults.merge(well_num: 3),
  waterstep_defaults.merge(well_num: 4),
  waterstep_defaults.merge(well_num: 5),
  waterstep_defaults.merge(well_num: 6),
  waterstep_defaults.merge(well_num: 7),
  waterstep_defaults.merge(well_num: 8),
  waterstep_defaults.merge(well_num: 9),
  waterstep_defaults.merge(well_num: 10),
  waterstep_defaults.merge(well_num: 11),
  waterstep_defaults.merge(well_num: 12),
  waterstep_defaults.merge(well_num: 13),
  waterstep_defaults.merge(well_num: 14),
  waterstep_defaults.merge(well_num: 15)
)

signalstep_defaults = { step_id: 4, fluorescence_value: 100, cycle_num: 1, experiment_id: 1 }

FluorescenceDatum.seed(:experiment_id,:step_id,:well_num,
  signalstep_defaults.merge(well_num: 0),
  signalstep_defaults.merge(well_num: 1),
  signalstep_defaults.merge(well_num: 2),
  signalstep_defaults.merge(well_num: 3),
  signalstep_defaults.merge(well_num: 4),
  signalstep_defaults.merge(well_num: 5),
  signalstep_defaults.merge(well_num: 6),
  signalstep_defaults.merge(well_num: 7),
  signalstep_defaults.merge(well_num: 8),
  signalstep_defaults.merge(well_num: 9),
  signalstep_defaults.merge(well_num: 10),
  signalstep_defaults.merge(well_num: 11),
  signalstep_defaults.merge(well_num: 12),
  signalstep_defaults.merge(well_num: 13),
  signalstep_defaults.merge(well_num: 14),
  signalstep_defaults.merge(well_num: 15)
)
