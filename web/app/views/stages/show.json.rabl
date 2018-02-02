object @stage
attribute :id, :stage_type, :name, :num_cycles, :auto_delta, :auto_delta_start_cycle, :order_number

node(:errors, :unless => lambda { |obj| obj.errors.empty? }) do |o|
	o.errors.as_json
end
