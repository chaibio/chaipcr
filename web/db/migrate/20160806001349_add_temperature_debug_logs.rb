class AddTemperatureDebugLogs < ActiveRecord::Migration
  def change
    add_column :temperature_debug_logs, :heat_sink_temp, :decimal, :precision => 5, :scale => 2, :comment => "degrees C"
    add_column :temperature_debug_logs, :heat_sink_drive, :decimal, :precision => 5, :scale => 4
    change_column :temperature_debug_logs, :lid_drive, :decimal, :precision => 5, :scale => 4
    change_column :temperature_debug_logs, :heat_block_zone_1_drive, :decimal, :precision => 5, :scale => 4
    change_column :temperature_debug_logs, :heat_block_zone_2_drive, :decimal, :precision => 5, :scale => 4
  end
end
