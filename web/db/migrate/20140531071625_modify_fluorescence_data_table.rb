class ModifyFluorescenceDataTable < ActiveRecord::Migration
  def change
    add_column :fluorescence_data, :cycle_num, :integer
  end
end
