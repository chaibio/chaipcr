object @experiment
attribute :id, :name, :notes, :targets_well_layout_id, :time_valid, :started_at, :completed_at, :completion_status, :completion_message, :created_at
 
node :standard_experiment_id do |experiment|
 WellLayout.experiment_id_for_well_layout_id(experiment.targets_well_layout_id)
end

node :type do |experiment|
 experiment.experiment_definition.experiment_type
end

node(:errors, :unless => lambda { |obj| obj.errors.empty? }) do |o|
  o.errors.as_json
end