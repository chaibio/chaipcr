class AddCacheToFluorescenceData < ActiveRecord::Migration
  def change
    create_table :amplification_data do |t|
      t.integer :experiment_id
      t.integer :stage_id
      t.integer :well_num, :comment => "0-15"
      t.integer :cycle_num, :comment => "0-15"
      t.integer :background_subtracted_value
      t.integer :baseline_subtracted_value
    end
    
    add_index "amplification_data", ["experiment_id", "stage_id", "cycle_num", "well_num"], name: "index_amplification_data_by_exp_chan_stage_cycle_well", unique: true, using: :btree
  
    create_table :amplification_curves do |t|
      t.integer :experiment_id
      t.integer :stage_id
      t.integer :well_num
      t.decimal :ct, :precision => 5, :scale => 2
    end
    
    add_index "amplification_curves", ["experiment_id", "stage_id", "well_num"], name: "index_amplification_curves_by_exp_chan_stage_well", unique: true
  end
end
