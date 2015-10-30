object false

node(:total_cycles) {(@first_stage_collect_data)? @first_stage_collect_data.num_cycles : 0}

node :ct do
  @ct
end

child(@fluorescence_data => :fluorescence_data) do
	attributes :baseline_subtracted_value, :background_subtracted_value, :well_num, :cycle_num
end







