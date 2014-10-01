object @step
attribute :id, :name, :temperature, :hold_time, :collect_data

node(:errors, :unless => lambda { |obj| obj.errors.empty? }) do |o|
	o.errors
end
