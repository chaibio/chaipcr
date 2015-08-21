class UniqueIndex < ActiveRecord::Migration
  def change
    change_column_default(:stages, :num_cycles, nil)
    add_index :stages, [:protocol_id, :order_number], :unique=>true
    add_index :steps, [:stage_id, :order_number], :unique=>true
    add_index :ramps, :next_step_id, :unique=>true
  end
end
