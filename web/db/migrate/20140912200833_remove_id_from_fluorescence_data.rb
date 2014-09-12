class RemoveIdFromFluorescenceData < ActiveRecord::Migration
  def change
    remove_column :fluorescence_data, :id
    add_column :fluorescence_data, :experiment_id, :integer
    add_index :fluorescence_data, [:experiment_id, :step_id, :cycle_num, :well_num], :unique => true, :name => "index_fluorescence_data_by_exp_step_cycle_well"
  end
end
