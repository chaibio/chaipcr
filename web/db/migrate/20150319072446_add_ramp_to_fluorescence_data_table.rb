class AddRampToFluorescenceDataTable < ActiveRecord::Migration
  def change
    add_column :fluorescence_data, :ramp_id, :integer
    add_index :fluorescence_data, [:experiment_id, :ramp_id, :cycle_num, :well_num], :unique => true, :name => "index_fluorescence_data_by_exp_ramp_cycle_well"
  end
end
