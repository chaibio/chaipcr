class RenameFluorescenceDatumIndex < ActiveRecord::Migration
  def change
    rename_index :fluorescence_debug_data, "index_fluorescence_data_by_exp_chan_ramp_cycle_well", "index_fluorescence_debug_data_by_exp_chan_ramp_cycle_well"
    rename_index :fluorescence_debug_data, "index_fluorescence_data_by_exp_chan_step_cycle_well", "index_fluorescence_debug_data_by_exp_chan_step_cycle_well"
  end
end
