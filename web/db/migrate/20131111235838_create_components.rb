class CreateComponents < ActiveRecord::Migration
  def change
    create_table :protocols do |t|
      t.decimal :lid_temperature, :precision => 4, :scale => 1, :comment => "degrees C"
      t.integer :experiment_id
      t.timestamps
    end
    
    create_table :stages do |t|
      t.string  :name
      t.integer :num_cycles, :default=>1, :null=>false
      t.integer :order_number, :default=>0, :null=>false
      t.integer :protocol_id
      t.string :stage_type, :null=>false, :comment => "holding, cycling, or meltcurve"
      t.timestamps
    end
    
    create_table :steps do |t|
      t.string  :name
      t.decimal :temperature, :null=>false, :precision => 4, :scale => 1, :comment => "degrees C"
      t.integer :hold_time, :null=>false, :comment => 'in seconds, 0 means infinite'
      t.integer :order_number, :default=>0, :null=>false, :comment => "the order of the step in the cycle, starting with 0, and continguous"
      t.integer :stage_id, :null=>false
      t.timestamps
    end
    
    create_table :ramps do |t|
      t.decimal :rate, :null=>false, :precision => 11, :scale => 8, :comment => 'degrees C/s, set to 100 for max'
      t.integer :step_id
    end
    
  end
end
