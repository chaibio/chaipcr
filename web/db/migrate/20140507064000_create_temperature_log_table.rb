class CreateTemperatureLogTable < ActiveRecord::Migration
  def change
    create_table :temperature_logs, id: false do |t|
      t.integer :experiment_id
      t.integer :elapsed_time, :comment => "in milliseconds"
      t.decimal :lid_temp, :precision => 5, :scale => 2, :comment => "degrees C"
      t.decimal :heat_block_zone_1_temp, :precision => 5, :scale => 2, :comment => "degrees C"
      t.decimal :heat_block_zone_2_temp, :precision => 5, :scale => 2, :comment => "degrees C"
    end
    
    add_index :temperature_logs, [:experiment_id, :elapsed_time], :unique=>true
  end
end
