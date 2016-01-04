object false

child(@amplification_data_group, :root=>:fluorescence_data, :object_root=>false) do
	attributes :step_id, :ramp_id
	
    child(:data, :root=>:data, :object_root=>false) do 
        attributes :fluorescence_value, :well_num, :cycle_num
    end
end








