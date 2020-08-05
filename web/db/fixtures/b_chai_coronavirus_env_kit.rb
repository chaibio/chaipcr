experiment_definition = ExperimentDefinition.seed(:guid) do |s|
  s.guid = "chai_coronavirus_env_kit"
  s.experiment_type = ExperimentDefinition::TYPE_TESTKIT
  s.protocol_params = {
    lid_temperature:110,
    stages: [
      {
        stage: {
          stage_type:"holding", steps: [
            { step: { name:"UNG Digestion",temperature:25,hold_time:300 } },
            { step: { name:"Reverse Transcription",temperature:62,hold_time:300 } },
            { step: { name:"Initial Denaturing",temperature:95,hold_time:30 } }
          ]
        }
      },
      {
        stage: {
          stage_type:"cycling",
          num_cycles: 40,
          steps: [
            { step: { name:"Denature", temperature:95, hold_time:10 } },
            { step: { name:"Anneal", temperature:62, hold_time:40, collect_data:true } }
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
