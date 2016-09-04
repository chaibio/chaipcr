class AddRampIdToMeltCurve < ActiveRecord::Migration
  def change
    add_column :melt_curve_data, :ramp_id, :integer
    add_column :cached_melt_curve_data, :ramp_id, :integer

    #??? update ramp_id
  end
end
