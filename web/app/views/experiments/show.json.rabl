object @experiment
attribute :id, :name, :time_valid, :started_at, :completed_at, :completion_status, :completion_message, :created_at

node :name do |experiment|
 experiment.experiment_definition.name
end
 
node :type do |experiment|
 experiment.experiment_definition.experiment_type
end

node(:errors, :unless => lambda { |obj| obj.errors.empty? }) do |o|
  o.errors
end