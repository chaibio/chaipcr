object @step
attribute :id, :name, :temperature, :hold_time, :pause, :collect_data, :delta_temperature, :delta_duration_s, :order_number

node(:errors, :unless => lambda { |obj| obj.errors.empty? }) do |o|
	o.errors.as_json
end
