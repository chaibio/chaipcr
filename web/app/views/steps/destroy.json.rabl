object @step

node(:errors, :unless => lambda { |obj| obj.errors.empty? }) do |o|
	o.errors
end

node(:destroyed_stage_id, :unless => lambda { |obj| obj.destroyed_stage_id.nil? }) { |o| o.destroyed_stage_id }
