ExperimentDefinition.seed(:guid) do |s|
  s.name = "Dual Channel Optical Calibration"
  s.guid = "dual_channel_optical_cal"
  s.experiment_type = ExperimentDefinition::TYPE_CALIBRATION
  s.protocol_params ={lid_temperature:10, stages:[
   {stage:{stage_type:"holding",steps:[
     {step:{name:"Warm Up",temperature:65,hold_time:120,collect_data:false}},
     {step:{name:"Swap",temperature:65,hold_time:1,pause:true}},
     {step:{name:"Water",temperature:65,hold_time:20,collect_data:true}},
     {step:{name:"Swap",temperature:65,hold_time:1,pause:true}},
     {step:{name:"FAM",temperature:65,hold_time:20,collect_data:true}},
     {step:{name:"Swap",temperature:65,hold_time:1,pause:true}},
     {step:{name:"HEX",temperature:65,hold_time:20,collect_data:true}}
   ]}}]}
end