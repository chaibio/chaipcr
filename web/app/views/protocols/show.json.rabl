object @protocol
attribute :id, :lid_temperature, :estimate_duration

node(:errors, :unless => lambda { |obj| obj.errors.empty? }) do |o|
	o.errors.as_json
end