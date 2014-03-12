object @ramp
attribute :id, :rate
node(:max) {|obj| obj.max?}
node(:errors, :unless => lambda { |obj| obj.errors.empty? }) do |o|
	o.errors
end
