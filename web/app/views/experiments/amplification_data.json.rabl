object false

node :partial do
  (@partial)? true : false
end

node(:total_cycles) {(@first_stage_collect_data)? @first_stage_collect_data.num_cycles : 0}

child(@amplification_data_group, :root=>"steps", :object_root=>false) do
	attributes :step_id, :ramp_id, :amplification_data, :summary_data, :targets
end






