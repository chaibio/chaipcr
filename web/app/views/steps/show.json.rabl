object @step
attribute :id, :name, :temperature, :hold_time

node :errors do |o|
	o.errors
end

child :ramp do
	extends "ramps/show"
end