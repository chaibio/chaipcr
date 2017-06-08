class AddMeltCurveDebugData < ActiveRecord::Migration
  def change
    add_column :melt_curve_data, :optical_values, :string
  end
end
