class MoveNameToExperiment < ActiveRecord::Migration
  def change
    add_column :experiments, :name, :string
    ExperimentDefinition.where("name is not NULL").each do |definition|
      Experiment.where("experiment_definition_id=?", definition.id).update_all(name: definition.name)
    end
    remove_column :experiment_definitions, :name
  end
end
