object false

node :partial do
  (@partial)? true : false
end

child(@melt_curve_data_group, :root=>"ramps", :object_root=>false) do
	attributes :ramp_id
	child(:melt_curve_data, :root=>"melt_curve_data", :object_root=>false) do |t|
 		attributes :channel,:well_num, :temperature, :fluorescence_data, :normalized_data, :derivative_data, :tm, :area
	end
end
