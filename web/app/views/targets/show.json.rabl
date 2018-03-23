object @target
attribute :id, :name, :channel, :imported

child :targets_wells, :object_root => false do
	attribute :well_num, :well_type, :concentration
end

node(:errors, :unless => lambda { |obj| obj.errors.empty? }) do |o|
  o.errors.as_json
end