experiment_definition = ExperimentDefinition.seed(:guid) do |s|
  s.name = "Dual Channel Optical Calibration"
  s.guid = "dual_channel_optical_cal_v2"
  s.experiment_type = ExperimentDefinition::TYPE_CALIBRATION
  s.protocol_params ={lid_temperature:110, stages:[
   {stage:{stage_type:"holding",steps:[
     {step:{name:"Warm Up 75",temperature:75,hold_time:300}},
     {step:{name:"Warm Water",temperature:60,hold_time:90}},
     {step:{name:"Water",temperature:60,hold_time:20,collect_data:true}},
     {step:{name:"Swap",temperature:60,hold_time:1,pause:true}},
     {step:{name:"Warm FAM",temperature:60,hold_time:90}},
     {step:{name:"FAM",temperature:60,hold_time:20,collect_data:true}},
     {step:{name:"Swap",temperature:60,hold_time:1,pause:true}},
     {step:{name:"Warm HEX",temperature:60,hold_time:90}},
     {step:{name:"HEX",temperature:60,hold_time:20,collect_data:true}}
   ]}}]}
end

# set the protocol lid temperature to 110
protocol = Protocol.seed(:experiment_definition_id) do |s|
  s.lid_temperature = 110
  s.experiment_definition_id = experiment_definition[0].id
end
