Step.seed do |s|
  s.id = 8
  s.name = "Denature"
  s.temperature = 95
  s.hold_time = 30
  s.order_number = 0
  s.stage_id = 3
  s.collect_data = false
end

ramp = Ramp.seed do |r|
  r.next_step_id = 9
  r.rate = 3.0
end

Step.seed do |s|
  s.id = 9
  s.name = "Anneal"
  s.temperature = 60
  s.hold_time = 60
  s.order_number = 1
  s.stage_id = 3
  s.collect_data = false
  s.ramp = ramp.first
end

ramp = Ramp.seed do |r|
  r.next_step_id = 10
  r.rate = 3.0
end

Step.seed do |s|
  s.id = 10
  s.name = "Prepare melt"
  s.temperature = 72
  s.hold_time = 1
  s.order_number = 0
  s.stage_id = 4
  s.collect_data = false
  s.ramp = ramp.first
end

ramp = Ramp.seed do |r|
  r.next_step_id = 11
  r.collect_data = true
  r.rate = 0.1
end

Step.seed do |s|
  s.id = 11
  s.name = "Melt"
  s.temperature = 85
  s.hold_time = 1
  s.order_number = 1
  s.stage_id = 4
  s.collect_data = false
  s.ramp = ramp.first
end

Stage.seed do |s|
  s.id = 3
  s.num_cycles = 1
  s.protocol_id = 3
  s.order_number = 0
  s.stage_type = Stage::TYPE_HOLD
end

Stage.seed do |s|
  s.id = 4
  s.num_cycles = 1
  s.protocol_id = 3
  s.order_number = 1
  s.stage_type = Stage::TYPE_MELTCURVE
end

protocol = Protocol.seed do |s|
  s.id = 3
  s.lid_temperature = 110
  s.experiment_definition_id = 3
end

ExperimentDefinition.seed do |s|
  s.id = 3
  s.name = "HRM Calibration"
  s.guid = "hrm_calibration"
  s.experiment_type = ExperimentDefinition::TYPE_CALIBRATION
  s.protocol = protocol.first
end