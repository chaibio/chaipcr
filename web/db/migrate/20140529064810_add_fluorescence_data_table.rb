class AddFluorescenceDataTable < ActiveRecord::Migration
  def change
    create_table :fluorescence_data do |t|
      t.integer :step_id
      t.integer :fluorescence_value
      t.integer :well_num, :comment => "0-15"
    end
  end
end
