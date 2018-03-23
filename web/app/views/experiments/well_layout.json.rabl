collection @well_layout, :object_root => false
attributes :samples
child :targets, :object_root => false, :if => lambda { |targets| !targets.blank? } do
	attribute :id, :name, :channel, :imported, :well_num, :well_type, :concentration
end





