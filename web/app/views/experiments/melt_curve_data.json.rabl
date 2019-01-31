object false

node :partial do
  (@partial)? true : false
end

child(@melt_curve_data_group, :root=>"ramps", :object_root=>false) do
	attributes :ramp_id
	child(:melt_curve_data, :root=>"melt_curve_data", :object_root=>false) do |t|
 		attributes :well_num, :target_id, :temperature, :fluorescence_data
		attributes :normalized_data if params[:normalized] == true
		attributes :derivative_data if params[:derivative] == true
		attributes :tm, :area if params[:tm] == true
	end
end

child(@targets, :root=>"targets", :object_root=>false) do
	attributes :target_id, :target_name
end