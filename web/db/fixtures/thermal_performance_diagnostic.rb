ExperimentDefinition.seed do |s|
  s.id = 2
  s.name = "Thermal Performance Diagnostic"
  s.guid = "thermal_performance_diagnostic"
  s.experiment_type = ExperimentDefinition::TYPE_DIAGNOSTIC
end

Protocol.seed do |s|
  s.id = 2
  s.lid_temperature = 110
  s.experiment_definition_id = 2
end

Stage.seed do |s|
  s.id = 1
  s.num_cycles = 1
  s.protocol_id = 1
  s.stage_type = Stage::TYPE_HOLD
end

Step.seed do |s|
  s.id = 1
  s.name = "Preheat"
  s.temperature = 50
  s.hold_time = 10
  s.order_number = 0
  s.stage_id = 1
  s.collect_data = false
end

Step.seed do |s|
  s.id = 2
  s.name = "Heat"
  s.temperature = 95
  s.hold_time = 10
  s.order_number = 1
  s.stage_id = 1
  s.collect_data = true
end

Step.seed do |s|
  s.id = 3
  s.name = "Cool"
  s.temperature = 50
  s.hold_time = 10
  s.order_number = 2
  s.stage_id = 1
  s.collect_data = false
  s.pause = true
end
