object @well

node(:errors, :unless => lambda { |obj| obj.errors.empty? }) do |o|
	o.errors.as_json
end