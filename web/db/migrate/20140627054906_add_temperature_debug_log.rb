class AddTemperatureDebugLog < ActiveRecord::Migration
  def change
    create_table :temperature_debug_logs, id: false do |t|
      t.integer :experiment_id
      t.integer :elapsed_time, :comment => "in milliseconds"
      t.decimal :lid_drive, :precision => 6, :scale => 1
      t.decimal :heat_block_zone_1_drive, :precision => 6, :scale => 1
      t.decimal :heat_block_zone_2_drive, :precision => 6, :scale => 1
    end
    
    add_index :temperature_debug_logs, [:experiment_id, :elapsed_time], :unique => true
  end
end
