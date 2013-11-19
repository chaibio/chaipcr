class CreateComponents < ActiveRecord::Migration
  def change
    create_table :components do |t|
      t.string :name
      t.integer :order_number, :default=>0, :null=>false
      t.integer :repeat
      t.integer :temperature
      t.integer :hold_time
      t.integer :parent_id
      t.integer :protocol_id, :null=>false
      t.string :type, :null=>false

      t.timestamps
    end
  end
end
