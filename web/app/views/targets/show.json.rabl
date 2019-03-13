object @target
attribute :id, :name, :channel, :imported

child :targets_wells, :object_root => false do |target_well|
	attribute :well_num, :well_type, :omit
	node(:quantity, :unless => lambda { |target_well| target_well.quantity_m.nil? }) do |o|
	  { :m => o.quantity_m.to_f, :b => o.quantity_b }
	end
end

node(:errors, :unless => lambda { |obj| obj.errors.empty? }) do |o|
  o.errors.as_json
end