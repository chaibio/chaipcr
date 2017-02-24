Step.seed(:stage_id, :order_number) do |s|
  s.id = 12
  s.name = "LED off"
  s.temperature = 20
  s.hold_time = 5
  s.order_number = 0
  s.stage_id = 5
  s.collect_data = true
  s.excitation_intensity = 0
end

Step.seed(:stage_id, :order_number) do |s|
  s.id = 13
  s.name = "LED on"
  s.temperature = 20
  s.hold_time = 5
  s.order_number = 1
  s.stage_id = 5
  s.collect_data = true
end

Stage.seed(:protocol_id, :order_number) do |s|
  s.id = 5
  s.num_cycles = 1
  s.protocol_id = 4
  s.order_number = 1
  s.stage_type = Stage::TYPE_HOLD
end

protocol = Protocol.seed(:experiment_definition_id) do |s|
  s.id = 4
  s.lid_temperature = 10
  s.experiment_definition_id = 4
end

ExperimentDefinition.seed(:id) do |s|
  s.id = 4
  s.guid = "optical_test_single_channel"
  s.experiment_type = ExperimentDefinition::TYPE_DIAGNOSTIC
  s.protocol = protocol.first
end