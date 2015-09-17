object false
node(:total_cycles) {(@first_stage_collect_data)? @first_stage_collect_data.num_cycles : 0}

child(@fluorescence_data => :fluorescence_data) do
	attributes :calibrated_value, :well_num, :cycle_num
end





