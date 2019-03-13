object @sample
attribute :id, :name, :notes

child :samples_wells, :object_root => false do
	attribute :well_num
end

node(:errors, :unless => lambda { |obj| obj.errors.empty? }) do |o|
  o.errors.as_json
end