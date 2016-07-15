class TemperatureDecimal < ActiveRecord::Migration
  def change
    change_column :experiments, :cached_temperature, :decimal, :precision => 7, :scale => 4
    change_column :melt_curve_data, :temperature, :decimal, :precision => 7, :scale => 4
  end
end
