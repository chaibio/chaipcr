collection @well_layout, :object_root => false
attributes :samples
child :targets, :object_root => false, :if => lambda { |targets| !targets.blank? } do |target|
	attribute :id, :name, :channel, :imported, :well_num, :well_type
	node(:quantity, :unless => lambda { |target| target.quantity_m.nil? }) do |o|
	  { :m => o.quantity_m.to_f, :b => o.quantity_b }
	end
end





