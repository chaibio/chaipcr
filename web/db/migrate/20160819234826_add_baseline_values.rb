class AddBaselineValues < ActiveRecord::Migration
  def change
    add_column :fluorescence_data, :baseline_value, :integer
  end
end