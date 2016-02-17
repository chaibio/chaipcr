class AddChannelToAmplificationData < ActiveRecord::Migration
  def change
    add_column :amplification_data, :channel, :integer, :null=>false, :default=>1, :limit=>1
    add_column :amplification_curves, :channel, :integer, :null=>false, :default=>1, :limit=>1
  
    remove_index :amplification_curves, name: "index_amplification_curves_by_exp_chan_stage_well"
    remove_index :amplification_data, name: "index_amplification_data_by_exp_chan_stage_cycle_well"
    
    add_index "amplification_data", ["experiment_id", "stage_id", "cycle_num", "well_num", "channel"], name: "index_amplification_data_by_exp_chan_stage_cycle_well_channel", unique: true, using: :btree
    add_index "amplification_curves", ["experiment_id", "stage_id", "well_num", "channel"], name: "index_amplification_curves_by_exp_chan_stage_well_channel", unique: true
    
    AmplificationCurve.delete_all
    AmplificationDatum.delete_all
  
  end
end
