class AddRampIdToMeltCurve < ActiveRecord::Migration
  def change
    add_column :melt_curve_data, :ramp_id, :integer
    add_column :cached_melt_curve_data, :ramp_id, :integer
    
    add_column :temperature_logs, :stage_id, :integer
    add_column :temperature_logs, :cycle_num, :integer
    add_column :temperature_logs, :step_id, :integer
    add_column :temperature_logs, :ramp_id, :integer

    #??? update ramp_id
  end
end
