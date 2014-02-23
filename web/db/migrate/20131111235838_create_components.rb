class CreateComponents < ActiveRecord::Migration
  def change
    create_table :protocols do |t|
      t.integer :lid_temperature
      t.integer :experiment_id
      t.timestamps
    end
    
    create_table :stages do |t|
      t.string  :name
      t.integer :numcycles, :null=>false
      t.integer :order_number, :default=>0, :null=>false
      t.integer :protocol_id
      t.integer :stage_type, :null=>false
      t.timestamps
    end
    
    create_table :steps do |t|
      t.string  :name
      t.integer :temperature
      t.integer :hold_time
      t.integer :order_number, :default=>0, :null=>false
      t.integer :stage_id, :null=>false
      t.timestamps
    end
    
    create_table :ramps do |t|
      t.integer :rate
      t.boolean :max, :default=>true
      t.integer :step_id
    end
    
  end
end
