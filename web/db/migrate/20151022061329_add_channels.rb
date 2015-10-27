class AddChannels < ActiveRecord::Migration
  def change
    remove_index :fluorescence_data, :name => "index_fluorescence_data_by_exp_step_cycle_well"
    remove_index :fluorescence_data, :name => "index_fluorescence_data_by_exp_ramp_cycle_well"
    
    add_column :fluorescence_data, :channel, :integer, :null=>false, :default=>1, :limit=>1
    add_column :melt_curve_data, :channel, :integer, :null=>false, :default=>1, :limit=>1
    
    add_index :fluorescence_data, [:experiment_id, :channel, :step_id, :cycle_num, :well_num], :unique => true, :name => "index_fluorescence_data_by_exp_chan_step_cycle_well"
    add_index :fluorescence_data, [:experiment_id, :channel, :ramp_id, :cycle_num, :well_num], :unique => true, :name => "index_fluorescence_data_by_exp_chan_ramp_cycle_well"
  end
end
