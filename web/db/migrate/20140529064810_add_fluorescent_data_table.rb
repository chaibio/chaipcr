class AddFluorescentDataTable < ActiveRecord::Migration
  def change
    create_table :fluorescent_data do |t|
      t.integer :step_id
      t.integer :fluorescent_value
      t.integer :well_num, :comment => "0-15"
    end
  end
end
