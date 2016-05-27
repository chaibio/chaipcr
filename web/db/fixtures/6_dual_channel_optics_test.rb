ExperimentDefinition.seed(:name) do |s|
  s.name = "Dual Channel Optical Test"
  s.guid = "optical_test_dual_channel"
  s.experiment_type = ExperimentDefinition::TYPE_DIAGNOSTIC
  s.protocol_params ={lid_temperature:10, stages:[
   {stage:{stage_type:"holding",steps:[
     {step:{name:"Baseline",temperature:20,hold_time:5,collect_data:true,excitation_intensity:0}},
     {step:{name:"Water",temperature:20,hold_time:5,collect_data:true}},
     {step:{name:"Swap",temperature:20,hold_time:1,pause:true}},
     {step:{name:"FAM",temperature:20,hold_time:5,collect_data:true}},
     {step:{name:"Swap",temperature:20,hold_time:1,pause:true}},
     {step:{name:"HEX",temperature:20,hold_time:5,collect_data:true}}
   ]}}]}
end