class CreateMeltCurveDataTable < ActiveRecord::Migration
  def change
    create_table :melt_curve_data do |t|
      t.integer :stage_id, :null => false
      t.integer :well_num, :null => false, :comment => "0-15"
      t.decimal :temperature, :precision => 5, :scale => 2, :comment => "degrees C"
      t.integer :fluorescence_value
    end
    
    add_index :melt_curve_data, [:stage_id, :well_num, :temperature]
  end
end
