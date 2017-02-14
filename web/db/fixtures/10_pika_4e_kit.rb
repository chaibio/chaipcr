experiment_definition = ExperimentDefinition.seed(:guid) do |s|
  s.name = "Pika 4e Test Kit"
  s.guid = "pika_4e_kit"
  s.experiment_type = ExperimentDefinition::TYPE_TESTKIT
  s.protocol_params = {
    lid_temperature:110,
    stages: [
      {
        stage: {
          stage_type:"holding", steps: [
            { step: { name:"Initial Denaturing",temperature:95,hold_time:120 } }
          ]
        }
      },
      {
        stage: {
          stage_type:"cycling", steps: [
            { step: { name:"Denaturing", temperature:95, hold_time:15 } },
            { step: { name:"Annealing", temperature:60, hold_time:60, collect_data:true } }
          ]
        }
      }
    ]
  }
end

# set the protocol lid temperature to 110
protocol = Protocol.seed(:experiment_definition_id) do |s|
  s.lid_temperature = 110
  s.experiment_definition_id = experiment_definition[0].id
end
