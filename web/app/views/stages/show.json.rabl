object @stage
attribute :id, :stage_type, :name, :num_cycles

node(:errors, :unless => lambda { |obj| obj.errors.empty? }) do |o|
	o.errors
end
