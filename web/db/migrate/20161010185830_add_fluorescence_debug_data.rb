class AddFluorescenceDebugData < ActiveRecord::Migration
  def change
    create_table "fluorescence_debug_data", id: false, force: true do |t|
      t.integer "step_id"
      t.integer "well_num",                                              comment: "0-15"
      t.integer "cycle_num"
      t.integer "experiment_id"
      t.integer "ramp_id"
      t.integer "channel",            limit: 1, default: 1, null: false
      t.string "adc_values"
    end
    
    add_index "fluorescence_debug_data", ["experiment_id", "channel", "ramp_id", "cycle_num", "well_num"], name: "index_fluorescence_data_by_exp_chan_ramp_cycle_well", unique: true, using: :btree
    add_index "fluorescence_debug_data", ["experiment_id", "channel", "step_id", "cycle_num", "well_num"], name: "index_fluorescence_data_by_exp_chan_step_cycle_well", unique: true, using: :btree
  end
end
