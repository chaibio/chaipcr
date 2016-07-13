class AddMeltCurveCaching < ActiveRecord::Migration
  def change
    create_table :cached_melt_curve_data do |t|
      t.integer :experiment_id
      t.integer :stage_id
      t.integer :channel
      t.integer :well_num, :comment => "1-16"
      t.text :temperature_text, :limit => 16777215
      t.text :fluorescence_data_text, :limit => 16777215
      t.text :derivative_text, :limit => 16777215
      t.text :tm_text
      t.text :area_text
    end
    
    add_index "cached_melt_curve_data", ["experiment_id", "stage_id", "channel", "well_num"], name: "index_meltcurvedata_by_exp_stage_chan_well", unique: true, using: :btree
    
    add_column :experiments, :cached_temperature, :decimal, :precision => 5, :scale => 2
  end
end
