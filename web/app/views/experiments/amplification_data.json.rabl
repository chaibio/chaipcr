object false

node(:total_cycles) {(@first_stage_collect_data)? @first_stage_collect_data.num_cycles : 0}

node :ct do
  @ct
end

child(@amplification_data, :root=>:fluorescence_data, :object_root=>false) do
	attributes :baseline_subtracted_value, :background_subtracted_value, :well_num, :cycle_num
end








