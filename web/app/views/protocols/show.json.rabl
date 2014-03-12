object @protocol
attribute :id, :lid_temperature

node(:errors, :unless => lambda { |obj| obj.errors.empty? }) do |o|
	o.errors
end